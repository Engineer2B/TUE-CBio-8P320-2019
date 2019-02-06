classdef TriangleSurfaceMesh_S < Source.Geometry.TriangleSurfaceMesh
	properties(Constant)
		% Value below which to points are considered equal.
		S_CLASS_NAME = 'Shim.Geometry.TriangleSurfaceMesh_S'
		S_ERROR_CODE_PREFIX = 'Shim:Geometry:TriangleSurfaceMesh_S:'
	end
	methods(Static, Access = public)
		function obj = FromOldStruct(oldStructMesh, id, media,...
				hasOutsideBoundariesFn)
			if(~exist('hasOutsideBoundariesFn', 'var'))
				hasOutsideBoundariesFn = Source.Physics.OutsideBoundaries...
					.DEFAULT_HAS_OUTSIDE_BOUNDARIES_FN;
			end
			data = oldStructMesh.structData;
			info = oldStructMesh.structInfo;
			color = info.stringColor;
			elements = data.arrayLx3IntegerElements;
			nodes = data.arrayKx3DoublePoints;
			mediumId = Source.Enum.MediumName(info.integerMedium);
			medium = media.NameToMediumMap(mediumId.ToDisplayString());
			obj = Shim.Geometry.TriangleSurfaceMesh_S();
			obj.setProperties(nodes, elements, medium, id, color,...
				hasOutsideBoundariesFn);
		end
	end
	methods(Access = public)
		function obj = TriangleSurfaceMesh_S(varargin)
			obj = obj@Source.Geometry.TriangleSurfaceMesh(varargin{:});
		end
		function SetElements(this)
			this.setElements();
		end
		function this = SetNodes(this, nodes)
			this.Nodes = nodes;
		end
		function this = SetTriangleElementIndices(this, elementIndices)
			this.ElementIndices = elementIndices;
		end
		function this = SetHasOutsideBoundariesFn(this, hasOutsideBoundariesFn)
			this.HasOutsideBoundariesFn = hasOutsideBoundariesFn;
		end
		function SetProperties(this, varargin)
			this.setProperties(varargin{:});
		end
	end
end