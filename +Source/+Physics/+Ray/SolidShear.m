classdef SolidShear < Source.Physics.Ray.Base
	%SOLIDSHEAR Summary of this class goes here
	%   Detailed explanation goes here
	properties
		Polarisation
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Physics:Ray:SolidShear:'
		CLASS_NAME = 'Source.Physics.Ray.SolidShear'
	end
	methods(Access = public, Static)
		function obj = New(origin, direction, initialPhase, initialPower,...
				medium, polarisation)
			obj = Source.Physics.Ray.SolidShear();
			obj.Origin = origin;
			obj.Direction = Source.Geometry.Vec3.Normalize(direction);
			obj.InitialPhase = initialPhase;
			obj.InitialPower = initialPower;
			obj.Medium = medium;
			obj.frequencyPerSpeed = medium.FrequencyPerShearSpeed;
			obj.Polarisation = Source.Geometry.Vec3.Normalize(polarisation);
		end
	end
	methods(Access = public)
		function CollideWith(this, newMedium, distance, outNorm, powerLimit,...
			 batch, newId)
		 this.hCollisionMedium = newMedium;	
		 this.frequencyPerSpeed = this.Medium.FrequencyPerShearSpeed;
		 this.min2Attenuation = this.Medium.ShearMin2Attenuation;
		 this.powerLimit = powerLimit;
		 this.TravelDistance = distance;
		 this.SetEndPointAndEndPower();
		 this.SetEndPhase();
		 this.outNorm = outNorm;
		 this.directionDotInNormal = this.Direction * -outNorm';
		 this.Batch = batch;
		 this.newId = newId;
		 newMedium.CollideWith(this);
		end
		function FluidMediumCollision(this)
			% Vertical refers to the same plane as the plane in which the
			% normal vector lays, horizontal is then the plane perpendicular
			% to this plane. Forces in the horizontal direction are not 
			% aimed at the new medium and get completely reflected.
			sinAnII = sqrt(1 - (this.directionDotInNormal^2));
			horizontalComponent = this.Direction + this.outNorm *...
				this.directionDotInNormal;
			horizontalNorm = horizontalComponent /...
				Source.Geometry.Vec3.Normalize(horizontalComponent);
			direction = this.Direction + 2*this.directionDotInNormal *...
				this.outNorm;
			verticalPolarisationIn = this.outNorm * sinAnII + horizontalNorm *...
				this.directionDotInNormal;
			verticalPolarisationOut = this.outNorm * -sinAnII +...
				horizontalNorm * this.directionDotInNormal;
			horizontalPolarisation = Source.Geometry.Vec3.CrossProduct(...
				horizontalNorm, this.outNorm);
			% Reflection of horizontal component.
			pRH = this.EndPower * (this.Polarisation * horizontalPolarisation')^2;
			pRV = this.EndPower * (this.Polarisation * verticalPolarisationIn')^2;
			if(pRH > this.powerLimit)
				this.Batch.ReflectedShear = [this.Batch...
					.ReflectedShear, Source.Physics.Ray.SolidShear.New(...
					this.EndPoint, direction, this.EndPhase, pRH,...
					 this.Medium, horizontalPolarisation)];
			end

			% c_L/c_S > 1.
			sinAnOrIL = sinAnII * this.Medium.RatioSpeedLongitudinalShear;
			cosAnOrIL = sqrt(1.0 - (sinAnOrIL^ 2.0));

			c2c1S = this.CollisionMedium.Speed / this.Medium.ShearSpeed;
			sinAnOO = sinAnII * c2c1S;
			cosAnOO = sqrt(1 - (sinAnOO ^ 2.0));

			kL = this.Medium.LongitudinalK;
			kS = this.Medium.ShearK;
			l1 = this.Medium.Lambda;
			l2 = this.CollisionMedium.Lambda;
			shM = this.Medium.ShearModulus;
			k2 = this.CollisionMedium.K;

			matrixM = [sinAnII, cosAnOrIL, cosAnOO
			2.0 * shM * kS * sinAnII * this.DirectionDotInNormal,...
			2.0 * shM * kL * (cosAnOrIL^2.0) + l1 * kL, -l2 * k2
			kS * ((sinAnII^2.0) - (this.DirectionDotInNormal^2.0)),...
			2.0 * kL * sinAnOrIL * cosAnOrIL, 0.0];

			arrayA = [-sinAnII;...
			2.0 * shM * kS * sinAnII * this.DirectionDotInNormal;...
			-kS * ((sinAnII^2.0) - (this.DirectionDotInNormal^2.0))];

			raySpeeds =	Source.Physics.PowerCalculator...
			.calculateRaySpeeds(matrixM, arrayA);

			pFrRS = (abs(raySpeeds(1))^ 2.0);
			pFrRL = real((abs(raySpeeds(2))^2.0) * this.Medium...
			.RatioSpeedLongitudinalShear * cosAnOrIL / this.DirectionDotInNormal);

			pFrT = 1.0 - (pFrRS + pFrRL);
			vRS = raySpeeds(1);
			vRL = raySpeeds(2);
			vTL = raySpeeds(3);

			% Shear reflection of vertical component.
			pRVS = pFrRS * pRV;
			if(pRVS > this.powerLimit)
				this.Batch.ReflectedShear = [...
					this.Batch.ReflectedShear,...
					Source.Physics.Ray.SolidShear.New(...
					this.EndPoint, direction,...
					this.EndPhase+angle(vRS),...
					pRVS, this.Medium, verticalPolarisationOut)];
			end

			% Longitudinal reflection of vertical component.
			pRVL = pFrRL * pRV;
			if(pRVL > this.powerLimit)
				direction = horizontalComponent * this.Medium...
				.RatioSpeedLongitudinalShear + this.OutwardNormalVector *...
				cosAnOO;
				this.Batch.ReflectedLongitudinal = [...
					this.Batch.ReflectedLongitudinal,...
					Source.Physics.Ray.SolidLongitudinal.New(...
					this.EndPoint, direction, this.EndPhase+angle(vRL),...
					pRVL, this.Medium)];
			end

			% Longitudinal transmission of vertical component.
			pTV = pFrT * pRV;
			if(pTV > this.powerLimit)
				direction = horizontalNorm * sinAnOO -...
				 this.OutwardNormalVector * cosAnOO;
				fieldName = ['L' this.newId];
				if(~isfield(this.Batch.TransmittedFluid, fieldName))
					this.Batch.TransmittedFluid = struct(fieldName,...
						Source.Physics.Ray.Fluid.New(this.EndPoint, direction,...
						this.EndPhase+angle(vTL), pTV, this.hCollisionMedium));
				else
					this.Batch.TransmittedFluid.(fieldName) = [...
						this.Batch.TransmittedFluid.(fieldName),...
						Source.Physics.Ray.Fluid.New(this.EndPoint, direction,...
						this.EndPhase+angle(vTL), pTV, this.hCollisionMedium)];
				end
			end
		end
		function SolidMediumCollision(this)
			% TODO: implement.
		end
	end
	methods(Access = protected)
		function this = SolidShear()
		end
	end
end

