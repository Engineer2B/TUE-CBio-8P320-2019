classdef TriangleSurfaceMesh < handle & Source.Geometry.Boundary
	%TRIANGLESURFACEMESH Class representing a triangle surface mesh.
	properties (SetAccess = protected)
		% A Nx3 array that together form the N nodes of the mesh.
		Nodes
		% An array of TriangleElement objects that together form the mesh.
		% See also Source.Geometry.TriangleElement.
		TriangleElements
		% An Nx3 array with for each row the 3 triangle element indices that
		% together form a triangle.
		ElementIndices
		% A 1x3 array representing the norm of every element.
		% See also TriangleElement.
		OutwardNormalVectors
	end
	properties(Access = protected)
		p_Lambdas
	end
	properties(Constant)
		% Value below which to points are considered equal.
		EPSILON = 1e-7
		CLASS_NAME = 'Source.Geometry.TriangleSurfaceMesh'
		ERROR_CODE_PREFIX = 'Source:Geometry:TriangleSurfaceMesh:'
	end
	methods (Access = public, Static)
		function obj = New(points, elementIndices, medium,...
				id, color, hasOutsideBoundariesFn)
			obj = Source.Geometry.TriangleSurfaceMesh();
			obj.setProperties(points, elementIndices, medium, id, color,...
				hasOutsideBoundariesFn)
		end
		function obj = FromDTO(dto, media, hasOutsideBoundariesFn)
			if(~isfield(dto, 'Color'))
				dto.Color = Source.Helper.Random.Color;
			end
			medium = media.NameToMediumMap(dto.MediumName);
			obj = Source.Geometry.TriangleSurfaceMesh.New(dto.Nodes,...
				dto.ElementIndices, medium, dto.Id, dto.Color,...
				hasOutsideBoundariesFn);
		end
		function handle = Show(mesh, patchOptions)
			patchOptions.Vertices = mesh.Nodes;
			patchOptions.Faces = mesh.ElementIndices;
			patchOptionsCell = patchOptions.ToCell();
			handle = patch(patchOptionsCell{:});
		end
	end
	methods (Access = public)
		function this = TriangleSurfaceMesh()
		end
		function copy = Copy(this, media)
			copy = this.FromDTO(this.ToDTO(), media,...
				this.HasOutsideBoundariesFn);
		end
		function dto = ToDTO(this)
			dto = this.toDTO();
			dto.Nodes = this.Nodes;
			dto.ElementIndices = this.ElementIndices;
		end
		function numberOfIntersections = FindNumberOfIntersections(this,...
					origin, direction)
			for elementIndex = 1:length(this.TriangleElements)
				this.p_Lambdas(elementIndex) =...
				this.TriangleElements(elementIndex)...
					.FindIntersectionMTA(origin, direction);
			end
			numberOfIntersections = sum((this.p_Lambdas < Inf) &...
				(this.p_Lambdas > Source.Geometry.TriangleSurfaceMesh.EPSILON));
		end
		function intersectionResult = FindIntersection(this, ray)
			intersectionResult = Source.Geometry.IntersectionResult...
					.Default(this.Medium, this.Id);
			intersectionResult.MinLambda = Inf;
			minElementIndex = -1;
			for triangleElementIndex = 1:length(this.TriangleElements)
				triangleElement = this.TriangleElements(triangleElementIndex);
				lambda = triangleElement.FindIntersectionMTA(...
					ray.Origin, ray.Direction);
				if(lambda < intersectionResult.MinLambda && lambda >...
						Source.Geometry.TriangleSurfaceMesh.EPSILON)
					intersectionResult.MinLambda = lambda;
					minElementIndex = triangleElementIndex;
				end
			end
			if(minElementIndex~=-1)
				intersectionResult.OutwardNormalVector =...
					this.OutwardNormalVectors(minElementIndex, :);
			end
		end
		function incenters = GetIncenters(this)
			incenters = zeros(length(this.TriangleElements), 3);
			for elementIndex = 1:length(this.TriangleElements)
				incenters(elementIndex, :) =...
					this.TriangleElements(elementIndex).Incenter;
			end
		end
		function meshProjector = ShowInNorms(this, meshProjector)
			if(~exist('meshProjector','var'))
				meshProjector = Source.Display.MeshProjector.Default();
			end
			meshProjector.ShowTriangleSurfaceMeshNorms(this,...
				@(val1, val2) val1 - val2);
		end
		function meshProjector = ShowOutNorms(this, meshProjector)
			if(~exist('meshProjector','var'))
				meshProjector = Source.Display.MeshProjector.Default();
			end
			meshProjector.ShowTriangleSurfaceMeshNorms(this,...
				@(val1, val2) val1 + val2);
		end
		function handle = ShowDebug(this, patchOptions)
			if(isempty(patchOptions.DisplayName))
				patchOptions = patchOptions.copy();
				patchOptions.DisplayName = this.MediumChar;
			end
			handle = Source.Geometry.TriangleSurfaceMesh.Show(...
				this, patchOptions);
		end
		function meshProjector = ShowFast(this, meshProjector)
			if(~exist('meshProjector','var'))
				meshProjector = Source.Display.MeshProjector.Default();
			end
			meshProjector.ShowMesh(this);
		end
		function this = ChangeInclination(this, inclinationAngle)
			rotationMatrix = Source.Geometry.Transform.GetRotationMatrix(...
			'y', inclinationAngle);
			this.Nodes = this.Nodes * rotationMatrix;
			this.OutwardNormalVectors = this.OutwardNormalVectors *...
				rotationMatrix;
			Source.Helper.List.ForEach(@(triangleElement)...
				triangleElement.ApplyMatrix(rotationMatrix),...
				this.TriangleElements);
		end
		function this = ChangeAzimuth(this, azimuthAngle)
			rotationMatrix = Source.Geometry.Transform.GetRotationMatrix(...
			'z', azimuthAngle);
			this.Nodes = this.Nodes * rotationMatrix;
			this.OutwardNormalVectors = this.OutwardNormalVectors *...
				rotationMatrix;
			Source.Helper.List.ForEach(@(triangleElement)...
				triangleElement.ApplyMatrix(rotationMatrix),...
				this.TriangleElements);
		end
		function this = Translate(this, translation)
			this.Nodes = this.Nodes + translation;
			Source.Helper.List.ForEach(@(triangleElement)...
				triangleElement.Translate(translation), this.TriangleElements);
        end
        function this = Rotate(this, rotationMatrix)
            this.Nodes = this.Nodes*rotationMatrix;
            Source.Helper.List.ForEach(@(triangleElement)...
				triangleElement.Rotate(rotationMatrix), this.TriangleElements);
        end
		function this = Rescale(this, scaleFactor)
			this.Nodes = this.Nodes * scaleFactor;
			Source.Helper.List.ForEach(@(triangleElement)...
				triangleElement.Rescale(scaleFactor), this.TriangleElements);
		end
		function isEqual = eq(this, that)
			isEqual = strcmp(this.Id, that.Id) == 1;
		end
		function isEqual = EqualTo(this, that)
			for inEle = 1:length(this.TriangleElements)
				if(this.TriangleElements(inEle) ~= that.TriangleElements(inEle))
					isEqual = false;
					return;
				end
			end
			isEqual = strcmp(this.Id, that.Id) == 1 &&...
				all(all(this.Nodes == that.Nodes)) &&...
				all(all(this.ElementIndices == that.ElementIndices)) &&...
				all(all(this.OutwardNormalVectors == that.OutwardNormalVectors)) &&...
				this.Medium.EqualTo(that.Medium);
		end
		function notEqual = neq(this, that)
			notEqual = ~(this == that);
		end
	end
	methods (Access = protected, Static)
		function outwardNormalVector = getOutwardNormalVector(...
				nOfIntersections, element, getOutwardNormalVectorEvenFn,...
				getOutwardNormalVectorUnevenFn)
			if(mod(nOfIntersections, 2) == 1)
				outwardNormalVector = getOutwardNormalVectorUnevenFn(element);
			else
				outwardNormalVector = getOutwardNormalVectorEvenFn(element);
			end
		end
	end
	methods (Access = protected)
		function setProperties(this, points, elementIndices, medium, id,...
				color, hasOutsideBoundariesFn)
			this.setBaseProperties(medium, id, color, hasOutsideBoundariesFn);
			this.Nodes = points;
			this.ElementIndices = elementIndices;
			this.setElements();
			this.filterUsedPoints();
			this.calculateAndSetOutwardNormalVectors();
		end
		function setElements(this)
			nOfElements = size(this.ElementIndices,1);
			this.TriangleElements = Source.Geometry.TriangleElement.empty(...
				nOfElements,0);
			for elementIndexIndex = 1:nOfElements
				elementIndices =...
					this.ElementIndices(elementIndexIndex,:);
				pointA = this.Nodes(elementIndices(1),:);
				pointB = this.Nodes(elementIndices(2),:);
				pointC = this.Nodes(elementIndices(3),:);
				this.TriangleElements(elementIndexIndex) =...
					Source.Geometry.TriangleElement.New(pointA, pointB, pointC);
			end
		end
		function filterUsedPoints(this)
			% Remove unused points from the surface mesh when the input was a
			% composition of multiple meshes.
			usedIndices = unique(this.ElementIndices);
			nOfUsedIndices = length(usedIndices);
			newPoints = zeros(nOfUsedIndices, 3);
			for inUsedIndices = 1:nOfUsedIndices
				usedIndex = usedIndices(inUsedIndices);
				newPoints(inUsedIndices, :) = this.Nodes(...
					usedIndices(inUsedIndices), :);
				this.ElementIndices(...
					this.ElementIndices == usedIndex) = inUsedIndices;
			end
			this.Nodes = newPoints;
		end
		function calculateAndSetOutwardNormalVectors(this)
			nOfElements = length(this.TriangleElements);
			this.OutwardNormalVectors = zeros(nOfElements, 3);
			if(this.HasOutsideBoundariesFn(this))
				getOutwardNormalVectorEvenFn = @(element) element.NormalVector1;
				getOutwardNormalVectorUnevenFn = @(element) element.NormalVector2;
			else
				% Flip normal vectors if the mesh has no outside boundaries.
				getOutwardNormalVectorEvenFn = @(element) element.NormalVector2;
				getOutwardNormalVectorUnevenFn = @(element) element.NormalVector1;
			end
			this.p_Lambdas(nOfElements) = 0;
			for elementIndex = 1:nOfElements
				element = this.TriangleElements(elementIndex);
				nOfIntersections = this.FindNumberOfIntersections(...
					element.Incenter, element.NormalVector1);
				this.OutwardNormalVectors(elementIndex,:) =...
					Source.Geometry.TriangleSurfaceMesh.getOutwardNormalVector(...
					nOfIntersections, element, getOutwardNormalVectorEvenFn,...
				getOutwardNormalVectorUnevenFn);
			end
			% Finished using lambdas
			this.p_Lambdas = [];
		end
	end
end