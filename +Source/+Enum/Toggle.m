classdef Toggle
	enumeration
		On
		Off
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:Toggle:'
		CLASS_NAME = 'Source.Enum.Toggle'
	end
	methods
		function str = char(obj)
			switch(obj)
					case Source.Enum.Toggle.On
						str = 'on';
					case Source.Enum.Toggle.Off
						str = 'off';
				otherwise
					error([ Source.Enum.Toggle.ERROR_CODE_PREFIX 'UnknownValue'],...
					'Unknown toggle value!');
			end
		end
	end
end
