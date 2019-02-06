classdef BoxStyle
	enumeration
		back
		full
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:BoxStyle:'
		CLASS_NAME = 'Source.Enum.BoxStyle'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.BoxStyle.back
					str = 'back';
				case Source.Enum.BoxStyle.full
					str = 'full';
				otherwise
					error([Source.Enum.BoxStyle 'UnknownValue'],...
					'Unknown box style!');
			end
		end
	end
end

