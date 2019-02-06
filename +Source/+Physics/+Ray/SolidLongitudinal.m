classdef SolidLongitudinal < Source.Physics.Ray.Base
	%SOLIDLONGITUDINAL Summary of this class goes here
	%   Detailed explanation goes here
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Physics:Ray:SolidLongitudinal:'
		CLASS_NAME = 'Source.Physics.Ray.SolidLongitudinal'
	end
	methods(Access = public, Static)
		function obj = New(origin, direction, initialPhase, initialPower,...
				medium)
			obj = Source.Physics.Ray.SolidLongitudinal();
			obj.Origin = origin;
			obj.Direction = Source.Geometry.Vec3.Normalize(direction);
			obj.InitialPhase = initialPhase;
			obj.InitialPower = initialPower;
			obj.Medium = medium;
			obj.frequencyPerSpeed = medium.FrequencyPerLongitudinalSpeed;
		end
	end
	methods(Access = public)
		function CollideWith(this, newMedium, distance, outNorm, powerLimit,...
			batch, newId)
			this.collisionMedium = newMedium;
			this.frequencyPerSpeed = this.Medium.FrequencyPerLongitudinalSpeed;
			this.min2Attenuation = this.Medium.LongitudinalMin2Attenuation;
			this.powerLimit = powerLimit;
			this.TravelDistance = distance;
			this.SetEndPointAndEndPower();
			this.SetEndPhase();
			if(this.finalRay)
				return;
			end
			this.outNorm = outNorm;
			this.directionDotInNormal = this.Direction * -outNorm';
			this.Batch = batch;
			this.newId = newId;
			this.newMedium.CollideWith(this);
		end
		function FluidMediumCollision(this)
			c2c1L = this.collisionMedium.Speed / this.Medium.LongitudinalSpeed;
			sinAnII = sqrt(1.0 - (this.directionDotInNormal^2.0));
			sinAnOO = sinAnII * c2c1L;
			cosAnOO = sqrt(1.0 - (sinAnOO^2.0));
			sinAnOrIS = sinAnII * this.Medium.RatioSpeedShearLongitudinal;
			% Not complex, since c_S/c_L < 1
			cosAnOrIS = sqrt(1.0 - (sinAnOrIS^2.0));
		
			kL = this.Medium.LongitudinalK;
			kS = this.Medium.ShearK;
			l1 = this.Medium.Lambda;
			l2 = this.collisionMedium.Lambda;
			shM = this.Medium.ShearModulus;
			k2 = this.collisionMedium.K;

			matrixM = [this.directionDotInNormal, sinAnOrIS, cosAnOO;...
			kL * (l1 + 2 * shM * (this.directionDotInNormal^2.0)), 2 * shM *...
			kS * cosAnOrIS * sinAnOrIS, -l2 * k2;...
			2 * shM * kL * this.directionDotInNormal * sinAnII, shM * kS *...
			((sinAnOrIS^2.0) - (cosAnOrIS^2.0)), 0];

			arrayA = [this.directionDotInNormal;...
				-kL * (l1 + 2.0 * shM * (this.directionDotInNormal^2.0));...
				2.0 * shM * kL * this.directionDotInNormal * sinAnII];

			raySpeeds =	Source.Physics.PowerCalculator...
			.calculateRaySpeeds(matrixM, arrayA);
		
			pFrRL = abs(raySpeeds(1)) ^ 2.0;
			pFrRS = (abs(raySpeeds(2)) ^ 2.0) * this.Medium...
				.RatioSpeedShearLongitudinal * cosAnOrIS /...
				this.directionDotInNormal;
			pFrTL = 1 - (pFrRL + pFrRS);
			% reflectedLongitudinalSpeed = raySpeeds[1];
			% reflectedShearSpeed = raySpeeds[2];
			% transmittedLongitudinalSpeed = raySpeeds[3];

			% Longitudinal reflection
			pRL = pFrRL * this.EndPower;
			if(pRL > this.powerLimit)
				direction = this.Direction + 2*this.directionDotInNormal *...
				this.outNorm;
				this.Batch.ReflectedLongitudinal = [...
				this.Batch.ReflectedLongitudinal,...
				Source.Physics.Ray.SolidLongitudinal.New(...
				this.EndPoint, direction, this.EndPhase + angle(raySpeeds(1)),...
				pRL, this.Medium)];
			end
		
			% Shear reflection
			pRS = pFrRS * this.EndPower;
			if(pRS > this.powerLimit)
				horizontalComponent = -this.Direction + this.outNorm *...
					this.directionDotInNormal;
				horizontalNorm = horizontalComponent / Source.Geometry...
				.Vec3.Normalize(horizontalComponent);
				direction = horizontalComponent * this.Medium...
					.RatioSpeedShearLongitudinal + this.outNorm * cosAnOrIS;
				polarisation = horizontalNorm * cosAnOrIS - this.outNorm *...
					sinAnOrIS;
				this.Batch.ReflectedShear = [this.Batch.ReflectedShear,...
				Source.Physics.Ray.SolidShear.New(this.EndPoint, direction,...
				this.EndPhase + angle(raySpeeds(2)), pRS, this.Medium,...
				polarisation)];
			end
		
			% Longitudinal transmission
			pTL = pFrTL * this.EndPower;
			if(pTL > this.powerLimit)
				horizontalComponent = this.Direction + this.outNorm *...
					this.directionDotInNormal;
				horizontalNorm = horizontalComponent / Source.Geometry...
				.Vec3.Normalize(horizontalComponent);
				direction = horizontalNorm * sinAnOO -...
					outNorm * sqrt(1.0 - (sinAnOO ^ 2.0));
				fieldName = ['L' this.newId];
				if(~isfield(this.Batch.TransmittedFluid, fieldName))
					this.Batch.TransmittedFluid = struct(fieldName,...
						Source.Physics.Ray.Fluid.New(this.EndPoint,...
						direction, this.EndPhase + angle(raySpeeds(3)), pTL,...
						this.Medium));
				else
					this.Batch.TransmittedFluid.(fieldName) = [...
						this.Batch.TransmittedFluid.(fieldName),...
						Source.Physics.Ray.Fluid.New(this.EndPoint,...
						direction, this.EndPhase + angle(raySpeeds(3)), pTL,...
						this.Medium)];
				end

			end
		end
		function SolidMediumCollision(this)
			% TODO: implement.
		end
	end
	methods(Access = protected)
		function this = SolidLongitudinal()
		end
	end
end

