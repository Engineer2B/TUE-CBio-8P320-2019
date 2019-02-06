classdef Vertical
	enumeration
		BaseLine
		Bottom
		Middle
		Top
		Cap
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:Alignment:Vertical:'
		CLASS_NAME = 'Source.Enum.Alignment.Vertical'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.Alignment.Vertical.BaseLine
					str = 'baseline';
				case Source.Enum.Alignment.Vertical.Bottom
					str = 'bottom';
				case Source.Enum.Alignment.Vertical.Middle
					str = 'middle';
				case Source.Enum.Alignment.Vertical.Top
					str = 'top';
				case Source.Enum.Alignment.Vertical.Cap
					str = 'cap';
				otherwise
					error([Source.Enum.Alignment.Vertical.ERROR_CODE_PREFIX...
						'Unknown'],'Unknown vertical alignment!');
			end
		end
	end
end
