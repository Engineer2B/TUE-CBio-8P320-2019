classdef Weight
	enumeration
		% Default weight as defined by the particular font.
		Normal
		% Thicker character outlines than normal.
		Bold
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:Font:Weight:'
		CLASS_NAME = 'Source.Enum.Font.Weight'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.Font.Weight.Normal
					str = 'normal';
				case Source.Enum.Font.Weight.Bold
					str = 'bold';
				otherwise
					error([Source.Enum.Font.Angle.ERROR_CODE_PREFIX 'Unknown'],...
						'Unknown font weight!');
			end
		end
	end
end
