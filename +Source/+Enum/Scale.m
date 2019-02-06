classdef Scale
	enumeration
		linear
		log
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:Scale:'
		CLASS_NAME = 'Source.Enum.Scale'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.Scale.linear
					str = 'linear';
				case Source.Enum.Scale.log
					str = 'log';
				otherwise
					error([ Source.Enum.Scale.ERROR_CODE_PREFIX 'Unknown'],...
						'Unknown Scale!');
			end
		end
	end
end
