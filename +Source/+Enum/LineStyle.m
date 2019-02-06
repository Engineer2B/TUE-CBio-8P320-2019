classdef LineStyle
	enumeration
		Solid
		Dashed
		Dotted
		DashDot
		None
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:LineStyle:'
		CLASS_NAME = 'Source.Enum.LineStyle'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.LineStyle.Solid
					str = '-';
				case Source.Enum.LineStyle.Dashed
					str = '--';
				case Source.Enum.LineStyle.Dotted
					str = ':';
				case Source.Enum.LineStyle.DashDot
					str = '-.';
				case Source.Enum.LineStyle.None
					str = 'none';
				otherwise
					error([ Source.Enum.LineStyle.ERROR_CODE_PREFIX 'Unknown'],...
						'Unknown LineStyle!');
			end
		end
	end
end
