classdef AxisLocation
	enumeration
		Out
		In
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:AxisLocation:'
		CLASS_NAME = 'Source.Enum.AxisLocation'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.AxisLocation.Out
					str = 'out';
				case Source.Enum.AxisLocation.In
					str = 'in';
				otherwise
					error([Source.Enum.AxisLocation.ERROR_CODE_PREFIX...
						'Unknown'], 'Unknown AxisLocation!')
			end
		end
	end
end

