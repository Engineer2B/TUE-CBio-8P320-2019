classdef Fluid < Source.Physics.Ray.Base
	%FLUID Summary of this class goes here
	%   Detailed explanation goes here
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Physics:Ray:Fluid:'
		CLASS_NAME = 'Source.Physics.Ray.Fluid'
	end
	methods(Access = public, Static)
		function obj = New(origin, direction, initialPhase, initialPower,...
				medium)
			obj = Source.Physics.Ray.Fluid();
			obj.Origin = origin;
			obj.Direction = Source.Geometry.Vec3.Normalize(direction);
			obj.InitialPhase = initialPhase;
			obj.InitialPower = initialPower;
			obj.Medium = medium;
		end
	end
	methods(Access = public)
		function CollideWith(this, newMedium, distance, outNorm, powerLimit,...
			batch, newId)
			this.collisionMedium = newMedium;
			this.frequencyPerSpeed = this.Medium.FrequencyPerSpeed;
			this.min2Attenuation = this.Medium.Min2Attenuation;
			this.powerLimit = powerLimit;
			this.TravelDistance = distance;
			this.SetEndPointAndEndPower();
			this.SetEndPhase();
			if(this.finalRay)
				return;
			end
			this.outNorm = outNorm;
			this.directionDotInNormal = this.Direction *-outNorm';
			this.Batch = batch;
			this.newId = newId;
			newMedium.CollideWith(this);
		end
		function FluidMediumCollision(this)
			dIn = this.directionDotInNormal;
			c1 = this.Medium.Speed;
			crho1 = this.collisionMedium.SpeedDensity;
			c2 = this.collisionMedium.Speed;
			sinAnOO = sqrt(1.0 - (this.directionDotInNormal ^ 2.0)) * c2/c1;
			cosAnOO = sqrt(1.0 - (sinAnOO ^ 2));
			a = crho1 * dIn;
			b = this.Medium.SpeedDensity * cosAnOO;
		
			pFrRefl = (abs((a - b) / (a + b)) ^ 2);
			pFrTra = 1 - pFrRefl;
		
			pRefl = pFrRefl * this.EndPower;
			if(pRefl > this.powerLimit)
				phaseChange = 0;
				if(this.Medium.SpeedDensity > crho1)
					% Add a phase of pi.
					% http://hyperphysics.phy-astr.gsu.edu/hbase/Sound/reflec.html
					phaseChange = pi;
				end
				direction = this.Direction + 2*this.directionDotInNormal *...
					this.outNorm;
					this.Batch.ReflectedFluid = [...
					this.Batch.ReflectedFluid,...
					Source.Physics.Ray.Fluid.New(this.EndPoint, direction,...
					this.EndPhase + phaseChange, pRefl, this.Medium)];
			end
			pTra = pFrTra * this.EndPower;
			if(pTra > this.powerLimit)
				horComp = this.Direction+...
				this.directionDotInNormal*this.outNorm;
				if(all(horComp == [0 0 0]))
					horNorm = [0 0 0];
				else
					horNorm = horComp/...
						sqrt(horComp(1)*horComp(1)+...
						horComp(2)*horComp(2)+...
						horComp(3)*horComp(3));
				end
				direction = sinAnOO*horNorm-sqrt(1-sinAnOO^2)*this.outNorm;
				fieldName = ['L' this.newId];
				if(~isfield(this.Batch.TransmittedFluid, fieldName))
					this.Batch.TransmittedFluid = struct(fieldName,...
						Source.Physics.Ray.Fluid.New(this.EndPoint, direction,...
						this.EndPhase, pTra, this.collisionMedium));
				else
					this.Batch.TransmittedFluid.(fieldName) = [...
						this.Batch.TransmittedFluid.(fieldName),...
						Source.Physics.Ray.Fluid.New(this.EndPoint, direction,...
						this.EndPhase, pTra, this.collisionMedium)];
				end
			end
		end
		function SolidMediumCollision(this)
% 			pCalc = Source.Physics.PowerCalculator.New(this, this.Medium,...
% 				this.collisionMedium, this.outNorm, this.directionDotInNormal);
			
			cL2 = this.collisionMedium.LongitudinalSpeed;
			cS2 = this.collisionMedium.ShearSpeed;
			% TODO: investigate precomputing these values in MediumCollection.
			cL2c1 = cL2 / this.Medium.Speed;
		
			cS2c1 = cS2 / this.Medium.Speed;
		
			rho1rho2 = this.Medium.Density / this.collisionMedium.Density;
		
			sinAnII = sqrt(1 - (this.directionDotInNormal ^ 2.0));
		
			sinAnOOSh = sinAnII * cS2c1;
			% Purely imaginary if doubleAngleDNormalIn > alpha_shear_crit
			cosAnOOSh = sqrt(1 - (sinAnOOSh ^ 2.0));
			
			sinAnOOLo = sinAnII * cL2c1;
		% Purely imaginary if doubleAngleDNormalIn > alpha_long_crit
			cosAnOOLo = sqrt(1 - (sinAnOOLo ^ 2.0));

			Z1 = this.Medium.SpeedDensity / this.directionDotInNormal;
		
			ZLo = this.collisionMedium.LongitudinalSpeedDensity / cosAnOOLo;
		
			ZSh = this.collisionMedium.ShearSpeedDensity / cosAnOOSh;
		
			Zeff = ZLo * (((cosAnOOSh ^ 2.0) - (sinAnOOSh ^  2.0))^ 2.0) +...
				ZSh * ((2.0 * sinAnOOSh * cosAnOOSh) ^ 2.0);
			InvZeffPZl = 1.0 / (Zeff + Z1);
		
			cR = (Zeff - Z1) * InvZeffPZl;
			pFrRefl = abs(cR)^ 2.0;

			cTLo = InvZeffPZl * rho1rho2 * 2.0 * ZLo *...
				((cosAnOOSh ^ 2.0) - (sinAnOOSh ^ 2.0)) / cL2c1;
		
			pFrTraLong = real((abs(cTLo) ^ 2.0) * cL2c1 / rho1rho2 *...
				cosAnOOLo / this.directionDotInNormal);

			cTSh = -rho1rho2 * 4.0 * ZSh * sinAnOOSh * cosAnOOSh *...
				InvZeffPZl / cS2c1;
			pFrTraShear = 1.0 - (pFrRefl + pFrTraLong);
			% Longitudinal reflection
			pRefl = pFrRefl * this.EndPower;
			if(pRefl > this.powerLimit)
				direction = this.Direction + this.outNorm * 2.0 *...
					this.directionDotInNormal;
				this.Batch.ReflectedFluid = [...
				this.Batch.ReflectedFluid,...
				Source.Physics.Ray.Fluid.New(this.EndPoint,...
				direction, this.EndPhase + angle(cR),...
				pRefl, this.Medium)];
			end
			% Longitudinal transmission
			pTraLong = pFrTraLong * this.EndPower;
			if(pTraLong > this.powerLimit)
				horComp = this.Direction+this.directionDotInNormal*this.outNorm;
				if(all(horComp == [0 0 0]))
					horNorm = [0 0 0];
				else
					horNorm = horComp/...
						sqrt(horComp(1)*horComp(1)+...
						horComp(2)*horComp(2)+...
						horComp(3)*horComp(3));
				end
				direction = sinAnOOLo*horNorm-sqrt(1-sinAnOOLo^2)*this.outNorm;
				fieldName = ['L' this.newId];
				if(~isfield(this.Batch.TransmittedLongitudinal, fieldName))
					this.Batch.TransmittedLongitudinal = struct(fieldName,...
						Source.Physics.Ray.Fluid.New(this.EndPoint, direction,...
						this.EndPhase + angle(cTLo), pTraLong, this.collisionMedium));
				else
					this.Batch.TransmittedLongitudinal.(fieldName) = [...
						this.Batch.TransmittedLongitudinal.(fieldName),...
						Source.Physics.Ray.Fluid.New(this.EndPoint, direction,...
						this.EndPhase + angle(cTLo), pTraLong, this.collisionMedium)];
				end
			end
			% Shear transmission
			pTraShear = pFrTraShear * this.EndPower;
			if(pTraShear > this.powerLimit)
				horComp = this.Direction+...
				this.directionDotInNormal*this.outNorm;
				if(all(horComp == [0 0 0]))
					horNorm = [0 0 0];
				else
					horNorm = horComp/...
						sqrt(horComp(1)*horComp(1)+...
						horComp(2)*horComp(2)+...
						horComp(3)*horComp(3));
				end
				direction = sinAnOOSh*horNorm-...
				cosAnOOSh*this.outNorm;
				polarisation = cosAnOOSh*horNorm+...
				sinAnOOSh*this.outNorm;
				fieldName = ['S' this.newId];
				if(~isfield(this.Batch.TransmittedShear, fieldName))
					this.Batch.TransmittedShear = struct(fieldName,...
						Source.Physics.Ray.SolidShear.New(this.EndPoint,...
						direction, this.EndPhase+angle(cTSh),...
						pTraShear, this.collisionMedium, polarisation));
				else
					this.Batch.TransmittedShear.(fieldName) = [...
						this.Batch.TransmittedShear.(fieldName),...
						Source.Physics.Ray.SolidShear.New(this.EndPoint,...
						direction, this.EndPhase+angle(cTSh),...
						pTraShear, this.collisionMedium, polarisation)];
				end
			end
		end
	end
	methods(Access = protected)
		function this = Fluid()
		end
	end
end

