classdef Slice
	properties(SetAccess = protected)
		Plane
		Offset
		Value
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Geometry:Slice:'
		CLASS_NAME = 'Source.Geometry.Slice'
	end
	methods(Static)
		function obj = New(plane, value)
			obj = Source.Geometry.Slice();
			Source.Helper.Assert.IsOfType(plane,...
				'Source.Enum.Plane', 'plane');
			obj.Plane = plane;
			obj.Value = value;
			obj.Offset = value-1;
		end
	end
	methods
		function values = TakeFrom(this, values, latticeOptions)
			values = latticeOptions.GetPlanarSliceValues(...
				values, this.Plane, this.Offset);
		end
	end
	methods(Access = protected)
		function this = Slice()
		end
	end
end

