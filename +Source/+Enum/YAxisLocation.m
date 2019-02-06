classdef YAxisLocation
	enumeration
		left
		right
		origin
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:YAxisLocation:'
		CLASS_NAME = 'Source.Enum.YAxisLocation'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.YAxisLocation.left
					str = 'left';
				case Source.Enum.YAxisLocation.right
					str = 'right';
				case Source.Enum.YAxisLocation.origin
					str = 'origin';
				otherwise
					error([Source.Enum.YAxisLocation.ERROR_CODE_PREFIX...
						'Unknown'], 'Unknown y-axis location!')
			end
		end
	end
end

