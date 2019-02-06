classdef Horizontal
	enumeration
		Left
		Center
		Right
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:Alignment:Horizontal:'
		CLASS_NAME = 'Source.Enum.Alignment.Horizontal'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.Alignment.Horizontal.Left
					str = 'left';
				case Source.Enum.Alignment.Horizontal.Center
					str = 'center';
				case Source.Enum.Alignment.Horizontal.Right
					str = 'right';
				otherwise
					error([Source.Enum.Alignment.Horizontal.ERROR_CODE_PREFIX...
						'Unknown'],'Unknown horizontal alignment!');
			end
		end
	end
end
