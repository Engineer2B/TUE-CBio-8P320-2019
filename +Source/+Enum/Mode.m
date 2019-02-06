classdef Mode
	enumeration
		auto
		manual
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Display:Options:Mode:'
		CLASS_NAME = 'Source.Display.Options.Mode'
	end
	methods
		function str = char(obj)
			switch(obj)
					case Source.Enum.Mode.auto
						str = 'auto';
					case Source.Enum.Mode.manual
						str = 'manual';
				otherwise
					error([Source.Enum.Mode.ERROR_CODE_PREFIX 'UnknownValue'],...
					'Unknown mode value!');
			end
		end
	end
end
