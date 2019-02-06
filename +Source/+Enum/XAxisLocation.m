classdef XAxisLocation
	enumeration
		bottom
		top
		origin
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:XAxisLocation:'
		CLASS_NAME = 'Source.Enum.XAxisLocation'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.XAxisLocation.bottom
					str = 'bottom';
				case Source.Enum.XAxisLocation.top
					str = 'top';
				case Source.Enum.XAxisLocation.origin
					str = 'origin';
				otherwise
					error([Source.Enum.XAxisLocation.ERROR_CODE_PREFIX...
						'Unknown'], 'Unknown x-axis location!')
			end
		end
	end
end

