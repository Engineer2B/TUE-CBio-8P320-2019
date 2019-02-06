classdef Solid < Source.Physics.Medium.Base
	%SOLID Summary of this class goes here
	%   Detailed explanation goes here
	properties(SetAccess = protected)
		LongitudinalSpeed

		% 2*pi*f/c_longitudinal
		LongitudinalK

		LongitudinalMin2Attenuation

		% c_longitudinal*rho [kg/(m^2*s)]
		LongitudinalSpeedDensity

		% f/c_longitudinal
		% TODO: find out where this can be used.
		FrequencyPerLongitudinalSpeed

		% sqrt(Const3)*Const4
		LongitudinalPowerConstant

		% Shear speed [m/s].
		ShearSpeed

		ShearModulus

		% 2*pi*f/c_shear
		ShearK

		ShearMin2Attenuation

		% f/c_shear
		FrequencyPerShearSpeed

		% c_shear*rho [kg/(m^2*s)]
		ShearSpeedDensity

		% aka sqrt(Const6)*Const7
		ShearPowerConstant

		% c_shear/c_longitudinal
		RatioSpeedShearLongitudinal

		% c_longitudinal/c_shear
		RatioSpeedLongitudinalShear

		Xi
		Eta
		XiPlus4EtaOver3
		XiMinus2EtaOver3
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Physics:Medium:Solid:'
		CLASS_NAME = 'Source.Physics.Medium.Solid'
		FILE_EXTENSION = '.solid'
	end
	methods(Access = public, Static)
		function obj = New(name, longitudinalSpeed, shearSpeed, density,...
				longitudinalAttenuation, shearAttenuation, absorption, frequency)
			obj = Source.Physics.Medium.Solid();
			obj.setProperties(name, longitudinalSpeed, shearSpeed, density,...
				longitudinalAttenuation, shearAttenuation, absorption, frequency);
		end
		function obj = FromDTO(dto)
			obj = Source.Physics.Medium.Solid.New(dto.Name,...
				dto.LongitudinalSpeed, dto.ShearSpeed, dto.Density,...
				dto.LongitudinalAttenuation, dto.ShearAttenuation,...
				dto.Absorption,	dto.Frequency);
		end
		function obj = FromFile(fileName, frequency)
			data = Source.IO.JSON.Read(fileName);
			obj = Source.Physics.Medium.Solid.New(data.Name,...
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
		function CollideWith(~, ray)
			ray.SolidMediumCollision();
		end
		function heat = GetHeat(this, hpRaytracer, nonZeroIndex)
			v = hpRaytracer.HTotalVelocities.A(:,nonZeroIndex);
			phiv1 = angle(v(1));
			phiv2 = angle(v(2));
			phiv3 = angle(v(3));
			heat = this.XiPlus4EtaOver3*...
				(abs(v(1))^2+abs(v(2))^2+abs(v(3))^2)/2+...
				this.Eta*(abs(v(4))^2 + abs(v(5))^2 +abs(v(6))^2)/2+...
				this.XiMinus2EtaOver3*...
				(abs(v(1))*abs(v(2))*cos(phiv1-phiv2)+...
				abs(v(1))*abs(v(3))*cos(phiv1-phiv3)+...
				abs(v(2))*abs(v(3))*cos(phiv2-phiv3));
		end
		function dto = ToDTO(this)
			dto = this.toBaseDTO();
			dto.LongitudinalAttenuation = -this.LongitudinalMin2Attenuation/2;
			dto.ShearAttenuation = -this.ShearMin2Attenuation/2;
			dto.LongitudinalSpeed = this.LongitudinalSpeed;
			dto.ShearSpeed = this.ShearSpeed;
		end
		function obj = Copy(this)
			obj = this.FromDTO(this.ToDTO());
		end
		function equal = EqualTo(this, that)
			equal = this.equalTo(that) &&...
				this.LongitudinalSpeed == that.LongitudinalSpeed &&...
				this.LongitudinalK == that.LongitudinalK &&...
				this.LongitudinalMin2Attenuation ==...
				that.LongitudinalMin2Attenuation &&...
				this.LongitudinalSpeedDensity ==...
				that.LongitudinalSpeedDensity &&...
				this.FrequencyPerLongitudinalSpeed ==...
				that.FrequencyPerLongitudinalSpeed &&...
				this.LongitudinalPowerConstant ==...
				that.LongitudinalPowerConstant &&...
				this.ShearSpeed == that.ShearSpeed &&...
				this.ShearModulus == that.ShearModulus &&...
				this.ShearK == that.ShearK &&...
				this.ShearMin2Attenuation == that.ShearMin2Attenuation &&...
				this.FrequencyPerShearSpeed == that.FrequencyPerShearSpeed &&...
				this.ShearSpeedDensity == that.ShearSpeedDensity &&...
				this.ShearPowerConstant == that.ShearPowerConstant &&...
				this.RatioSpeedShearLongitudinal ==...
				that.RatioSpeedShearLongitudinal &&...
				this.RatioSpeedLongitudinalShear ==...
				that.RatioSpeedLongitudinalShear &&...
				this.Xi == that.Xi &&...
				this.Eta == that.Eta;
		end
	end
	methods(Access = protected)
		function this = Solid()
			this@Source.Physics.Medium.Base();
		end
		function setProperties(this, name, longitudinalSpeed, shearSpeed,...
				density, longitudinalAttenuation, shearAttenuation, absorption,...
				frequency)
			this.Name = name;
			this.Density = density;
			this.Absorption = absorption;
			this.Frequency = frequency;
			this.LongitudinalSpeed = longitudinalSpeed;
			this.ShearSpeed = shearSpeed;

			% Set derived values.
			this.LongitudinalMin2Attenuation = -2.0 * longitudinalAttenuation;
			this.ShearMin2Attenuation = -2.0 * shearAttenuation;
			angularFrequency = 2 * pi * frequency;
			this.LongitudinalK = angularFrequency / this.LongitudinalSpeed;
			this.ShearK = angularFrequency / this.ShearSpeed;
			this.FrequencyPerLongitudinalSpeed = this.Frequency /...
				this.LongitudinalSpeed;
			this.FrequencyPerShearSpeed = this.Frequency / this.ShearSpeed;
			this.LongitudinalSpeedDensity = this.LongitudinalSpeed *...
				this.Density;
			this.ShearSpeedDensity = this.ShearSpeed * this.Density;
			this.ShearModulus = this.Density * (this.ShearSpeed^2);
			this.Lambda = this.Density * (this.LongitudinalSpeed^2) - 2 *...
				this.ShearModulus;
			this.RatioSpeedLongitudinalShear = this.LongitudinalSpeed /...
				this.ShearSpeed;
			this.RatioSpeedShearLongitudinal = this.ShearSpeed /...
				this.LongitudinalSpeed;

			w = 2.0 * pi * frequency;
			[mu, this.Eta] = this.getWaveCoefficients(this.ShearSpeed,...
				shearAttenuation, w);
			[p1, p2] = this.getWaveCoefficients(this.LongitudinalSpeed,...
				longitudinalAttenuation, w);
			lam = p1 - 2.0 * mu;
			this.Xi = p2 - 4.0 * this.Eta / 3.0;
			kL = this.LongitudinalK;
			aL = longitudinalAttenuation;
			this.XiPlus4EtaOver3 = this.Xi + 4*this.Eta/3;
			this.XiMinus2EtaOver3 = this.Xi - 2*this.Eta/3;
			this.LongitudinalPowerConstant = sqrt(2.0 / (w * ((lam + 2.0 * mu)...
				* kL + (this.Xi + 4.0 * this.Eta / 3.0) * w * aL))) * (-1i * w) *...
				(1i * kL - aL);
			kS = this.ShearK;
			aS = shearAttenuation;
			this.ShearPowerConstant = sqrt(2.0 / (mu * w * kS + this.Eta *...
				(w^2.0) * aS)) * (-1i * w) * (1i * kS - aS);
		end
		function [p1, p2] = getWaveCoefficients(this, speed, alpha,...
				angularFrequency)
			k = angularFrequency / speed;
			C = this.Density * (angularFrequency^2)/((alpha^2) + (k^2));
			D = sqrt(2.0) * C / (speed * sqrt(this.Density));
			p1 = (D^2.0) - C;
			p2 = sqrt((C^2.0) - (p1^2.0)) / angularFrequency;
		end
	end
end

