classdef Math
	methods(Static)
		function clippedValue = Clip(input, minValue, maxValue)
			clippedValue = max(min(input, maxValue), minValue);
		end
	end
end

