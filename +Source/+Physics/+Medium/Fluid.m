classdef Fluid < Source.Physics.Medium.Base
	properties(SetAccess = protected)
		% Speed [m/s].
		Speed

		% 2*pi*f/c
		K

		% f/c
		FrequencyPerSpeed

		% -2*attenuation
		Min2Attenuation

		% c*rho [kg/(m^2*s)]
		SpeedDensity

		% sqrt(2*c*rho), used only in fluid heat calculations.
		SqTwoTimesSpeedDensity

		% aka Const1
		FluidHeatProductionConstant
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Physics:Medium:Fluid:'
		CLASS_NAME = 'Source.Physics.Medium.Fluid'
		FILE_EXTENSION = '.fluid'
	end
	methods(Access = public, Static)
		function obj = New(name, speed, density, attenuation, absorption,...
				frequency)
			obj = Source.Physics.Medium.Fluid();
			obj.setProperties(name, speed, density, attenuation, absorption,...
				frequency);
		end
		function obj = FromFile(fileName, frequency)
			data = Source.IO.JSON.Read(fileName);
			obj = Source.Physics.Medium.Fluid.New(data.Name,...
				data.SpeedOfSound, data.Density, data.AcousticAttenuation,...
				data.HeatAbsorptionFraction, frequency);
		end
		function obj = FromDTO(dto)
			obj = Source.Physics.Medium.Fluid.New(dto.Name, dto.Speed,...
				dto.Density, dto.Attenuation, dto.Absorption,	dto.Frequency);
		end
	end
	methods(Access = public)
		function CollideWith(~, ray)
			ray.FluidMediumCollision();
		end
		function heat = GetHeat(this, hpRaytracer, nonZeroIndex)
			heat = this.FluidHeatProductionConstant*abs(...
				hpRaytracer.FluidContribution.HPressures.A(nonZeroIndex))^2;
		end
		function dto = ToDTO(this)
			dto = this.toBaseDTO();
			dto.Attenuation = -this.Min2Attenuation/2;
			dto.Speed = this.Speed;
		end
		function obj = Copy(this)
			obj = this.FromDTO(this.ToDTO());
		end
		function equal = EqualTo(this, that)
			equal = this.equalTo(that) && this.Speed == that.Speed &&...
				this.K == that.K &&...
				this.FrequencyPerSpeed == that.FrequencyPerSpeed &&...
				this.Min2Attenuation == that.Min2Attenuation &&...
				this.SpeedDensity == that.SpeedDensity &&...
				this.SqTwoTimesSpeedDensity == that.SqTwoTimesSpeedDensity &&...
				this.FluidHeatProductionConstant ==...
				that.FluidHeatProductionConstant;
		end
	end
	methods(Access = protected)
		function this = Fluid()
			this@Source.Physics.Medium.Base();
		end
		function setProperties(this, name, speed, density, attenuation,...
				absorption, frequency)
			this.Absorption = absorption;
			this.Name = name;
			this.Speed = speed;
			this.Density = density;
			this.Frequency = frequency;
			this.SpeedDensity = speed * density;
			this.Min2Attenuation = -2.0 * attenuation;
			this.SqTwoTimesSpeedDensity = sqrt(2.0 * this.SpeedDensity);
			this.Lambda = density * (speed ^ 2.0);
			this.FrequencyPerSpeed = frequency / speed;
			this.K = 2.0 * pi * this.FrequencyPerSpeed;
			% TODO: Check if attenuation_shear / density * speed_shear 
			% == shear heat production constant.
			this.FluidHeatProductionConstant = attenuation / this.SpeedDensity;
		end
	end
end

