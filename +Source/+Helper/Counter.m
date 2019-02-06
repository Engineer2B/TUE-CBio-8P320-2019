classdef Counter < handle
	properties(SetAccess = protected)
		Value
	end
	
	methods(Static)
		function obj = Init(value)
			obj = Source.Helper.Counter();
			obj.Value = value;
		end
	end
	methods
		function Increment(this, value)
			this.Value = this.Value + value;
		end
		function Decrement(this, value)
			this.Value = this.Value - value;
		end
	end
	methods(Access = protected)
		function this = Counter()
		end
	end
end
