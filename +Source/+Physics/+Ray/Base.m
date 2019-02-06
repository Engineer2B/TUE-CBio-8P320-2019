classdef Base < handle
	%BASE Summary of this class goes here
	%   Detailed explanation goes here
	properties
		% The position of the origin of the ray.
		Origin
		% The direction of the ray.
		Direction
		% The position of the end point of the ray.
		EndPoint
		% The initial phase of the ray.
		InitialPhase
		% The end phase of the ray.
		EndPhase
		InitialPower
		EndPower
		TravelDistance
		Medium
		Batch
	end
	properties(Access = protected)
		collisionMedium
		directionDotInNormal
		outNorm
		newId
		powerLimit
		min2Attenuation
		frequencyPerSpeed
		finalRay = false
	end
	properties(Constant)
		BASE_ERROR_CODE_PREFIX = 'Source:Physics:Ray:Base:'
		BASE_CLASS_NAME = 'Source.Physics.Ray.Base'
		MSG_NOENDPOINT = 'Ray doesn''t have an endpoint yet.'
	end
	methods(Access = public)
		function location = GetLocation(this, distance)
			location = this.Origin + distance * this.Direction;
		end
		function SetEndPointAndEndPower(this)
			if(this.TravelDistance == Inf)
				this.finalRay = true;
				this.setTravelDistanceByPower();
				this.setEndPower();
			else
				this.setEndPower();
				if(this.EndPower < this.powerLimit)
					this.finalRay = true;
					this.setTravelDistanceByPower();
					this.setEndPower();
				end
			end
			this.setEndPoint();
		end
		function SetEndPhase(this)
			this.EndPhase = this.InitialPhase + this.frequencyPerSpeed*...
				this.TravelDistance;
		end
		function power = GetPowerByDistance(this, beginPower, distance)
			power = beginPower*exp(this.min2Attenuation * distance);
		end
		function ScalePower(this, scaling)
			this.InitialPower = this.InitialPower * scaling;
		end
	end
	methods(Access = protected)
		function this = Base()
		end
		function setTravelDistanceByPower(this)
			if(this.InitialPower < this.powerLimit)
					this.TravelDistance = 0;
			else
				this.TravelDistance =...
					log(this.powerLimit/this.InitialPower)/this.min2Attenuation;
			end
		end
		function setEndPower(this)
			this.EndPower = this.GetPowerByDistance(this.InitialPower,...
				this.TravelDistance);
		end
		function setEndPoint(this)
			this.EndPoint = this.GetLocation(this.TravelDistance);
		end
	end
end
