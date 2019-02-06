classdef TriangleSurfaceMesh_U < matlab.unittest.TestCase 
	%TriangleSurfaceMesh_U
	properties
		SurfaceMeshes
		Nx1StructMesh
		ElementNr
		ErrorMeshes
		SurfaceMeshesGMSH
		Media
	end
	methods(TestMethodSetup)
		function LoadConfiguration(this)
			load(Test.Settings.MESH_FILE,...
				'arrayNx1StructMesh');
			this.Nx1StructMesh = arrayNx1StructMesh;
			this.SurfaceMeshes = Source.Helper.Collection.New(...
				Shim.Geometry.TriangleSurfaceMesh_S.S_CLASS_NAME);
			this.Media =	Test.Settings.MAIN_TEST_MEDIA;
			for inStructMesh = 1:length(arrayNx1StructMesh)
				this.SurfaceMeshes.Add(Shim.Geometry.TriangleSurfaceMesh_S...
					.FromOldStruct(arrayNx1StructMesh(inStructMesh),inStructMesh,...
					this.Media));
			end
			reader = Source.Geometry.gmsh.GMSHReader.New(...
				Test.Settings.GMSH_FILE, Source.Logging.Logger.Default(),...
				Source.Geometry.gmsh.GMSHReaderOptions.New(...
				Source.Physics.OutsideBoundaries...
				.MARKOIL_HAS_NO_OUTSIDE_BOUNDARIES_FN));
			[this.SurfaceMeshesGMSH, ~] = reader.ExportMeshes(this.Media);
		end
	end
	methods(Test)
		function NonEmpty_Nx1StructMesh(this)
			for indexMesh = this.SurfaceMeshes.Count
				mesh = this.SurfaceMeshes(indexMesh);
				this.verifyNotEmpty(mesh.Nodes);
				this.verifyNotEmpty(mesh.TriangleElements);
				this.verifyNotEmpty(mesh.ElementIndices);
				this.verifyNotEmpty(mesh.OutwardNormalVectors);
				this.verifyTrue(isa(mesh.Medium,...
					Source.Physics.Medium.Base.BASE_CLASS_NAME));
				this.verifyNotEmpty(mesh.Color);
				this.verifyTrue(strcmp(mesh.Id, 'NaN') == 0);
			end
		end
		function NonEmpty_GMSH(this)
			for indexMesh = length(this.SurfaceMeshesGMSH)
				mesh = this.SurfaceMeshesGMSH(indexMesh);
				this.verifyNotEmpty(mesh.Nodes);
				this.verifyNotEmpty(mesh.TriangleElements);
				this.verifyNotEmpty(mesh.ElementIndices);
				this.verifyNotEmpty(mesh.OutwardNormalVectors);
				this.verifyTrue(isa(mesh.Medium,...
					Source.Physics.Medium.Base.BASE_CLASS_NAME));
				this.verifyNotEmpty(mesh.Color);
				this.verifyTrue(strcmp(mesh.Id, 'NaN') == 0);
			end
		end
		function EqualToArrayNx1Mesh(this)
			for indexMesh = this.SurfaceMeshes.Count
				mesh = this.SurfaceMeshes(indexMesh);
				structMesh = this.Nx1StructMesh(indexMesh);
				structInfo = structMesh.structInfo;
				structData = structMesh.structData;
				usedPoints = cellfun(@(item) ~isempty(item),...
					structData.cellKx1ElementsOfPoint);
				structData.cellKx1ElementsOfPoint =...
					structData.cellKx1ElementsOfPoint(usedPoints);
				structData.arrayKx3DoublePoints =...
					structData.arrayKx3DoublePoints(usedPoints);
				mediumEnum = Source.Enum.MediumName(structInfo.integerMedium);		
				this.verifyEqual(mediumEnum.ToDisplayString(), mesh.Medium.Name);
				this.verifyEqual(size(mesh.Nodes, 1),length(...
					structData.arrayKx3DoublePoints));
				this.verifyEqual(length(mesh.TriangleElements),...
					size(structData.arrayLx3IntegerElements, 1));
			end
		end
		function InwardNormalVectorsArePerpendicularToEdges(this)
			mesh = this.SurfaceMeshes(1);
			for index = 1:length(mesh.OutwardNormalVectors)
				outwardNormalVector = mesh.OutwardNormalVectors(index,:);
				triangleElement = mesh.TriangleElements(index);
				this.verifyLessThan(abs(outwardNormalVector*...
					triangleElement.Edge1'), Test.Settings.Tolerance,...
					Test.Geometry.TriangleSurfaceMesh_U...
					.edgeNormalNotPerpendicularMessage(1, index));
				this.verifyLessThan(abs(outwardNormalVector*...
					triangleElement.Edge2'), Test.Settings.Tolerance,...
						Test.Geometry.TriangleSurfaceMesh_U...
						.edgeNormalNotPerpendicularMessage(2, index));
				this.verifyEqual(norm(outwardNormalVector), 1,...
					'abstol', Test.Settings.Tolerance);
			end
		end
		function InwardNormalVectorsArePerpendicularToEdges_GMSH(this)
			mesh = this.SurfaceMeshesGMSH(1);
			for index = 1:length(mesh.OutwardNormalVectors)
				outwardNormalVector = mesh.OutwardNormalVectors(index,:);
				triangleElement = mesh.TriangleElements(index);
				this.verifyLessThan(abs(outwardNormalVector*...
					triangleElement.Edge1'), Test.Settings.Tolerance,...
					Test.Geometry.TriangleSurfaceMesh_U...
					.edgeNormalNotPerpendicularMessage(1, index));
				this.verifyLessThan(abs(outwardNormalVector*...
					triangleElement.Edge2'), Test.Settings.Tolerance,...
						Test.Geometry.TriangleSurfaceMesh_U...
						.edgeNormalNotPerpendicularMessage(2, index));
				this.verifyEqual(norm(outwardNormalVector), 1,...
					'abstol', Test.Settings.Tolerance);
			end
		end
		function FindRayIntersection(this)
			mesh = this.SurfaceMeshes(1);
			someRay = Source.Physics.GRay.Initial([-14 0 0],[1 0 0], 0, 1);
			numberOfIntersections = mesh.FindNumberOfIntersections(...
				someRay.Origin, someRay.Direction);
			this.verifyGreaterThan(numberOfIntersections, 0);
		end
		function FindRayIntersection_GMSH(this)
			mesh = this.SurfaceMeshesGMSH(1);
			someRay = Source.Physics.GRay.Initial([-14 0 0],[1 0 0], 0, 1);
			numberOfIntersections = mesh.FindNumberOfIntersections(...
				someRay.Origin, someRay.Direction);
			this.verifyGreaterThan(numberOfIntersections, 0);
		end
		function Copy_ShouldReturnEqualObject(this)
			mesh = this.SurfaceMeshesGMSH(1);
			copyMesh = mesh.Copy(this.Media);
			this.verifyTrue(mesh.EqualTo(copyMesh));
		end
	end
	methods(Access = private, Static)
		function msg = edgeNormalNotPerpendicularMessage(...
				indexEdge, indexTriangleElement)
			msg = ['mesh.OutwardNormalVectors(' num2str(indexTriangleElement)...
				') ~ perpendicular mesh.TriangleElements('...
				num2str(indexTriangleElement) ').Edge' num2str(indexEdge)];
		end
	end
end


