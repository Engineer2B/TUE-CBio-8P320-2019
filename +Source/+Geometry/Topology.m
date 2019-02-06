classdef Topology
	%TOPOLOGY A collection of objects that together make up the topology with
	%which the rays interact.
	properties
		Cylinders
		Planes
		Meshes
		SourceFileName
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Geometry:Topology:'
		CLASS_NAME = 'Source.Geometry.Topology'
	end
	methods(Static)
		function obj = New()
			obj = Source.Geometry.Topology();
		end
		function obj = FromDTO(dto, sourceFileName, media,...
				hasOutsideBoundariesFn)
			Source.Helper.Assert.IsOfType(media,...
				Source.Physics.Media.CLASS_NAME, 'media');
			obj = Source.Geometry.Topology();
			obj.SourceFileName = sourceFileName;
			if(isfield(dto, 'Meshes'))
				obj.Meshes = arrayfun(@(meshDTO) Source.Geometry...
					.TriangleSurfaceMesh.FromDTO(meshDTO, media,...
					hasOutsideBoundariesFn), dto.Meshes);
			end
			if(isfield(dto, 'Cylinders'))
				obj.Cylinders = arrayfun(@(cylDTO) Source.Geometry.Cylinder...
				.FromDTO(cylDTO, media, hasOutsideBoundariesFn), dto.Cylinders);
			end
			if(isfield(dto, 'Planes'))
				obj.Planes = arrayfun(@(plaDTO) Source.Geometry.Plane...
				.FromDTO(plaDTO, media, hasOutsideBoundariesFn), dto.Planes);
			end
		end
		function obj = FromFile(filePath, media, hasOutsideBoundariesFn)
			obj = Source.Geometry.Topology.FromDTO(...
				Source.IO.JSON.Read(filePath), filePath, media,...
				hasOutsideBoundariesFn);
		end
	end
	methods(Static, Access = protected)
		function closestResult = getClosestIntersectionResult(result1, result2)
			if(result1.MinLambda <= result2.MinLambda)
				closestResult = result1;
			else
				closestResult = result2;
			end
		end
		function cylinderStruct = convertCylinder(cylinder)
			cylinderData = Source.Initialization.CylinderData.FromCylinder(...
				cylinder);
			cylinderStruct = cylinderData.ToStruct();
			cylinderStruct.HasOutsideBoundariesFn =...
				cylinder.HasOutsideBoundariesFn;
		end
		function meshStruct = convertMesh(mesh)
			meshData = Source.Geometry.TriangleSurfaceMeshData.FromMesh(mesh);
			meshStruct = meshData.ToStruct();
			meshStruct.HasOutsideBoundariesFn = mesh.HasOutsideBoundariesFn;
		end
		function planeStruct = convertPlane(plane)
			planeData = Source.Initialization.PlaneData.FromPlane(plane);
			planeStruct = planeData.ToStruct();
			planeStruct.HasOutsideBoundariesFn = plane.HasOutsideBoundariesFn;
		end
		function handles = showTopologyAndGenerateName(uniquenessFn,...
				plotFn, elements, patchOptions)
			unEls = Source.Helper.List.Unique(elements,...
				@(el1, el2) uniquenessFn(el1, el2));
			nOfUnEls = length(unEls);
			handles = gobjects(nOfUnEls, 0);
			for inUnEl = 1:nOfUnEls
				el1 = unEls(inUnEl);
				if(~isempty(findprop(el1, 'Color')))
					patchOptions.FaceColor = el1.Color;
					if(el1.IsShown == false)
						continue;
					end
				end
				patchOptions = patchOptions.copy();
				patchOptions.DisplayName = ['surface of ' el1.Medium.Name];
				handles(inUnEl) = plotFn(el1, patchOptions);
			end
		end
	end
	methods(Access = public)
		function this = Topology()
		end
		function dto = ToDTO(this)
			dto.Cylinders =	arrayfun(@(cyl) cyl.ToDTO(), this.Cylinders);
			dto.Planes = arrayfun(@(pla) pla.ToDTO(), this.Planes);
			dto.Meshes = arrayfun(@(mes) mes.ToDTO(), this.Meshes);
		end
		function ApplyTransformation(this, transformation)
			if(transformation == Source.Geometry.Transformation.None)
				return;
			end
			Source.Helper.List.ForEach(@(cyl) transformation...
				.ApplyToHandleObj(cyl), this.Cylinders);
			Source.Helper.List.ForEach(@(plane) transformation...
				.ApplyToHandleObj(plane), this.Planes);
			Source.Helper.List.ForEach(@(mesh) transformation...
				.ApplyToHandleObj(mesh), this.Meshes);
		end
		function ChangeInclination(this, angle)
			Source.Helper.List.ForEach(@(cyl) cyl.ChangeInclination(angle),...
				this.Cylinders);
			Source.Helper.List.ForEach(@(pla) pla.ChangeInclination(angle),...
				this.Planes);
			Source.Helper.List.ForEach(@(mesh) mesh.ChangeInclination(angle),...
				this.Meshes);
		end
		function ChangeAzimuth(this, angle)
			Source.Helper.List.ForEach(@(cyl) cyl.ChangeAzimuth(angle),...
				this.Cylinders);
			Source.Helper.List.ForEach(@(pla) pla.ChangeAzimuth(angle),...
				this.Planes);
			Source.Helper.List.ForEach(@(mesh) mesh.ChangeAzimuth(angle),...
				this.Meshes);
		end
		function Translate(this, translation)
			Source.Helper.List.ForEach(@(cyl) cyl.Translate(translation),...
				this.Cylinders);
			Source.Helper.List.ForEach(@(pla) pla.Translate(translation),...
				this.Planes);
			Source.Helper.List.ForEach(@(mesh) mesh.Translate(translation),...
				this.Meshes);
		end
		function Rescale(this, scaleFactor)
			Source.Helper.List.ForEach(@(cyl) cyl.Rescale(scaleFactor),...
				this.Cylinders);
			Source.Helper.List.ForEach(@(pla) pla.Rescale(scaleFactor),...
				this.Planes);
			Source.Helper.List.ForEach(@(mesh) mesh.Rescale(scaleFactor),...
				this.Meshes);
		end
		function plotHandlesMap = ShowDebug(this, planeWidth, planeHeight,...
				patchOptions)
			plotHandlesMap = containers.Map('KeyType','char',...
				'ValueType','any');
			if(isempty(patchOptions.DisplayName))
				if(~isempty(this.Meshes))
					plotHandlesMap('meshes') = this.showTopologyAndGenerateName(...
					@(mesh1, mesh2) mesh1 == mesh2,...
					@(mesh, opts) mesh.ShowDebug(opts),...
					this.Meshes, patchOptions);
				end
				if(~isempty(this.Cylinders))
					plotHandlesMap('cylinders') = this.showTopologyAndGenerateName(...
					@(cyl1, cyl2) all(cyl1.Center == cyl2.Center),...
					@(cyl1, opts) cyl1.ShowDebug(planeHeight, opts),...
					this.Cylinders, patchOptions);
				end
				if(~isempty(this.Planes))
					plotHandlesMap('planes') = this.showTopologyAndGenerateName(...
						@(pl1, pl2) all(pl1.Center == pl2.Center),...
						@(pl1, opts) pl1.ShowDebug(planeWidth, planeHeight, opts),...
						this.Planes, patchOptions);
				end
			else
				plotHandlesMap('meshes') = arrayfun(@(mesh) mesh...
					.ShowDebug(patchOptions), this.Meshes);
				plotHandlesMap('cylinders') = arrayfun(@(cylinder) cylinder...
					.ShowDebug(planeHeight, patchOptions), this.Cylinders);
				plotHandlesMap('planes') = arrayfun(@(plane) plane...
					.ShowDebug(planeWidth, planeHeight, patchOptions), this.Planes);
			end
		end
		function intersectionResult = FindIntersection(this, ray)
			% Filter cylinders that have the same medium.
			filteredCylinders = Source.Geometry.Cylinder.empty(...
				length(this.Cylinders),0);
			filteredCylinderCounter = 1;
			for inCyl = 1:length(this.Cylinders)
				if(strcmp(this.Cylinders(inCyl).Medium.Name,ray.Medium.Name)~=1)
					filteredCylinders(filteredCylinderCounter) =...
						this.Cylinders(inCyl);
					filteredCylinderCounter = filteredCylinderCounter + 1;
				end
			end
			% Filter meshes that have the same medium.
			filteredMeshes = Source.Geometry.TriangleSurfaceMesh.empty(...
				length(this.Meshes),0);
			filteredMeshCounter = 1;
			for inMesh = 1:length(this.Meshes)
				if(strcmp(this.Meshes(inMesh).Medium.Name,ray.Medium.Name)~=1)
					filteredMeshes(filteredMeshCounter) =...
						this.Meshes(inMesh);
					filteredMeshCounter = filteredMeshCounter + 1;
				end
			end
			% Filter planes that have the same medium.
			filteredPlanes = Source.Geometry.Plane.empty(...
				length(this.Planes),0);
			filteredPlaneCounter = 1;
			for inPlane = 1:length(this.Planes)
				if(strcmp(this.Planes(inPlane).Medium.Name,ray.Medium.Name)~=1)
					filteredPlanes(filteredPlaneCounter) =...
						this.Planes(inPlane);
					filteredPlaneCounter = filteredPlaneCounter + 1;
				end
			end
			intersectionResults = [...
				arrayfun(@(cyl) cyl.FindIntersection(ray), filteredCylinders),...
				arrayfun(@(plane) plane.FindIntersection(ray), filteredPlanes),...
				arrayfun(@(mesh) mesh.FindIntersection(ray), filteredMeshes)];
			
			intersectionResult = Source.Helper.List.Reduce(@(maxVal,...
				nextIntersectionResult) Source.Geometry.Topology...
				.getClosestIntersectionResult(maxVal, nextIntersectionResult),...
				intersectionResults,...
				Source.Geometry.IntersectionResult.Default('EmptySpace', '0'));
		end
	end
	properties(Access = protected, Constant)
		outwardNormalVector = [0 0 0];
	end
end
