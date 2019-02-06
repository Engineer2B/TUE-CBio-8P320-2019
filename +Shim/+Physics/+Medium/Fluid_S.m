classdef Fluid_S < Source.Physics.Medium.Fluid & Shim.Physics.Medium.Base_S
	methods(Access = public, Static)
		function obj = Empty()
			obj = Shim.Physics.Medium.Fluid_S();
		end
		function obj = FromFile(fileName, frequency)
			obj = Shim.Physics.Medium.Fluid_S.Empty();
			data = Source.IO.JSON.Read(fileName);
			obj.setProperties(data.Name, data.SpeedOfSound, data.Density,...
				data.AcousticAttenuation, data.HeatAbsorptionFraction, frequency);
		end
	end
	methods(Access = public)
		function this = Fluid_S()
			this = this@Source.Physics.Medium.Fluid();
		end
		function SetProperties(this, varargin)
			this.setProperties(varargin{:});
		end
	end
end
