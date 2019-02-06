classdef Extremum < handle
	properties
		Min
		Max
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Geometry:Extremum:'
		CLASS_NAME = 'Source.Geometry.Extremum'
	end
	methods(Access = public, Static)
		function obj = New(min, max)
			obj = Source.Geometry.Extremum(min, max);
		end
		function obj = Inf()
			obj = Source.Geometry.Extremum(-Inf, Inf);
		end
		function obj = Zero()
			obj = Source.Geometry.Extremum(0, 0);
		end
		function obj = FromColorLimits(colorLimits)
			obj = Source.Geometry.Extremum(colorLimits(1), colorLimits(2));
		end
		function obj = FromDTO(dto)
			obj = Source.Geometry.Extremum(dto.Min, dto.Max);
		end
	end
	methods(Access = public)
		function distance = Distance(this)
			distance = this.Max - this.Min;
		end
		function UpdateByExtremum(this, extremum)
			if(extremum.Min < this.Min)
				this.Min = extremum.Min;
			end
			if(extremum.Max > this.Max)
				this.Max = extremum.Max;
			end
		end
		function UpdateByValue(this, value)
			if(value < this.Min)
				this.Min = value;
			end
			if(value > this.Max)
				this.Max = value;
			end
		end
		function StretchToDistance(this, distance)
			if(distance <= 0)
				return;
			end
			beginDistance = this.Distance();
			additionalLength = (distance - beginDistance)/2;
			this.Min = this.Min - additionalLength;
			this.Max = this.Max + additionalLength;
		end
		function Widen(this, addedDistance)
			distance = this.Distance();
			if(distance < -addedDistance)
				return;
			end
			this.StretchToDistance(distance + addedDistance);
		end
		function copy = Copy(this)
			copy = Source.Geometry.Extremum(this.Min, this.Max);
		end
		function limits = ToArray(this)
			limits = [this.Min, this.Max];
		end
		function dto = ToDTO(this)
			dto.Min = this.Min;
			dto.Max = this.Max;
		end
		function extremumValue = GetByBoole(this, booleanValue)
			if(booleanValue)
				extremumValue = this.Max;
			else
				extremumValue = this.Min;
			end
		end
		function isEqual = ApproxEqualTo(this, that, tolerance)
			isEqual = (abs(this.Min-that.Min) < tolerance &&...
				abs(this.Max-that.Max) < tolerance);
		end
		function isEqual = eq(this, that)
			isEqual = this.Min == that.Min &&...
				this.Max == that.Max;
		end
		function notEqual = ne(this, that)
			notEqual = this.Min ~= that.Min ||...
				this.Max ~= that.Max;
		end
	end
	methods(Access = protected)
		function this = Extremum(min, max)
			this.Min = min;
			this.Max = max;
		end
	end
end

