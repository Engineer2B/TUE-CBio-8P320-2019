classdef OpenMesh < Source.Geometry.TriangleSurfaceMesh
	properties
		BoundaryMedia
		FileName
	end
	methods(Static, Access = public)
		function obj = Unfilled(fileName, boundaryMedia, color,...
				hasOutsideBoundariesFn)
			obj = Source.Geometry.gmsh.OpenMesh();
			obj.FileName = fileName;
			obj.BoundaryMedia = boundaryMedia;
			obj.Color = color;
			obj.HasOutsideBoundariesFn = hasOutsideBoundariesFn;
		end
	end
	methods
		function this = OpenMesh()
		end
		function SetMediumName(this, value)
			this.Medium.Name = value;
		end
		function SetNodes(this, value)
			this.Nodes = value;
		end
		function SetElementIndices(this, value)
			this.ElementIndices = value;
		end
		function SetId(this, value)
			Source.Helper.Assert.IsOfType(value, 'double', 'value');
			this.Id = num2str(value);
		end
	end
	methods(Access = protected)
	end
end

