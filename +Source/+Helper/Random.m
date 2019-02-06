classdef Random
	methods(Access = public, Static)
		function array3x1RandomColor = Color()
			array3x1RandomColor =...
				[random('unif', 0,1), random('unif', 0,1), random('unif', 0,1)];
		end
	end
end

