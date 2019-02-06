classdef GMSHReaderOptions
	properties
		HasOutsideBoundariesFn
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Geometry:gmsh:GMSHReaderOptions:'
		CLASS_NAME = 'Source.Geometry.gmsh.GMSHReaderOptions'
	end
	methods(Access = public, Static)
		function obj = New(hasOutsideBoundariesFn)
			obj = Source.Geometry.gmsh.GMSHReaderOptions(hasOutsideBoundariesFn);
		end
		function obj = Default()
			hasOutsideBoundariesFn = Source.Physics.OutsideBoundaries...
				.DEFAULT_HAS_OUTSIDE_BOUNDARIES_FN;
			obj = Source.Geometry.gmsh.GMSHReaderOptions(hasOutsideBoundariesFn);
		end
	end
	methods(Access = protected)
		function this = GMSHReaderOptions(hasOutsideBoundariesFn)
			this.HasOutsideBoundariesFn = hasOutsideBoundariesFn;
		end
	end
end

