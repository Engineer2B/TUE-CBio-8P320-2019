classdef DateTime
	%DATETIME Provides time information.
	methods(Access = public, Static)
		function value = Now()
			value = sprintf("%i-%02i-%02i %02i:%02i.%02.0f", clock);
		end
	end
end

