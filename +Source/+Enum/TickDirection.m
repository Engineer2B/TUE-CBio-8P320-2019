classdef TickDirection
	enumeration
		% Display the tick marks inside colorbar box.
		In
		% Display the tick marks outside the colorbar box.
		Out
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:TickDirection:'
		CLASS_NAME = 'Source.Enum.TickDirection'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.TickDirection.In
					str = 'in';
				case Source.Enum.TickDirection.Out
					str = 'out';
				otherwise
					error([Source.Enum.TickDirection.ERROR_CODE_PREFIX 'Unknown'],...
						'Unknown TickDirection!');
			end
		end
	end
end
