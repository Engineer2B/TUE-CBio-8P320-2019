classdef Direction
	enumeration
		%  Display the colormap and labels ascending from bottom to top for a vertical colorbar,
		% and ascending from left to right for a horizontal colorbar.
		Normal
		% Display the colormap and labels descending from bottom to top for a vertical colorbar,
		% and descending from left to right for a horizontal colorbar.
		Reverse
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:Direction:'
		CLASS_NAME = 'Source.Enum.Direction'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.Direction.Normal
					str = 'normal';
				case Source.Enum.Direction.Reverse
					str = 'reverse';
				otherwise
					error([Source.Enum.Direction.ERROR_CODE_PREFIX 'Unknown'],...
						'Unknown Direction!');
			end
		end
	end
end
