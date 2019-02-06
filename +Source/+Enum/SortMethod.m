classdef SortMethod
	enumeration
		depth
		childorder
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:SortMethod:'
		CLASS_NAME = 'Source.Enum.SortMethod'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.SortMethod.depth
					str = 'depth';
				case Source.Enum.SortMethod.childorder
					str = 'childorder';
				otherwise
					error([ Source.Enum.SortMethod.ERROR_CODE_PREFIX 'Unknown'],...
						'Unknown SortMethod!');
			end
		end
	end
end
