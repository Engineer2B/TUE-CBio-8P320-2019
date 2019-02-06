classdef Base_S < Source.Physics.Medium.Base
	methods(Access = public, Static)
		function obj = Empty()
			obj = Shim.Physics.Medium.Base_S();
		end
	end
	methods(Access = public)
		function this = Base_S()
			this = this@Source.Physics.Medium.Base();
		end
		function dto = ToBaseDTO(this, varargin)
			dto = this.toBaseDTO(varargin{:});
		end
	end
end
