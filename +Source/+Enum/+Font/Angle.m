classdef Angle
	enumeration
		% No character slant.
		Normal
		% Slanted characters.
		Italic
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:Font:Angle:'
		CLASS_NAME = 'Source.Enum.Font.Angle'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.Font.Angle.Normal
					str = 'normal';
				case Source.Enum.Font.Angle.Italic
					str = 'italic';
				otherwise
					error([Source.Enum.Font.Angle.ERROR_CODE_PREFIX...
						'Unknown'],'Unknown font angle!');
			end
		end
	end
end
