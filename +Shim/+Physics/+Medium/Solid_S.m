classdef Solid_S < Source.Physics.Medium.Solid &...
		Shim.Physics.Medium.Base_S
	methods(Access = public, Static)
		function obj = Empty()
			obj = Shim.Physics.Medium.Solid_S();
		end
		function obj = FromFile(fileName, frequency)
			obj = Shim.Physics.Medium.Solid_S.Empty();
			data = Source.IO.JSON.Read(fileName);
			obj.setProperties(data.Name,...
				data.SpeedOfSound.Longitudinal,...
				data.SpeedOfSound.Transversal,...
				data.Density,...
				data.AcousticAttenuation.Longitudinal,...
				data.AcousticAttenuation.Transversal,...
				data.HeatAbsorptionFraction,...
				frequency);
		end
	end
	methods(Access = public)
		function this = Solid_S()
			this = this@Source.Physics.Medium.Solid();
		end
		function SetProperties(this, varargin)
			this.setProperties(varargin{:});
		end
	end
end
