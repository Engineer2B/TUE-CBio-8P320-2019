classdef Layer
	enumeration
		bottom
		top
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:Layer:'
		CLASS_NAME = 'Source.Enum.Layer'
	end
	methods
		function str = char(obj)
			switch(obj)
					case Source.Enum.Layer.bottom
						str = 'bottom';
					case Source.Enum.Layer.top
						str = 'top';
				otherwise
					error([ Source.Enum.Layer.ERROR_CODE_PREFIX 'UnknownValue'],...
					'Unknown layer value!');
			end
		end
	end
end
