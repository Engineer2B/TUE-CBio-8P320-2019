classdef Base < handle
	properties(SetAccess = protected)
		% The name/alias of the medium.
		Name

		% Density [kg/m^3].
		Density

		% Absorption coefficient [-].
		Absorption

		% Frequency [1/s]
		Frequency

		% Lame (pronounced la-may) coefficient
		Lambda
	end
	properties(Constant)
		BASE_ERROR_CODE_PREFIX = 'Source:Physics:Medium:Base:'
		BASE_CLASS_NAME = 'Source.Physics.Medium.Base'
	end
	methods(Access = protected)
		function this = Base()
		end
		function dto = toBaseDTO(this)
			dto.Name = this.Name;
			dto.Density = this.Density;
			dto.Absorption = this.Absorption;
			dto.Frequency = this.Frequency;
			dto.Lambda = this.Lambda;
		end
		function equal = equalTo(this, that)
			equal = strcmp(this.Name, that.Name) &&...
				this.Density == that.Density &&...
				this.Absorption == that.Absorption &&...
				this.Frequency == that.Frequency &&...
				this.Lambda == that.Lambda;
		end
	end
end
