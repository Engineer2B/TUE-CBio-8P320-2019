classdef Units
	enumeration
		% Points.
		% One point equals 1/72 inch.
		Points
		% Inches
		Inches
		% Centimeters
		Centimeters
		% Interpret font size as a fraction of the axes plot box height.
		% If you resize the axes, the font size modifies accordingly.
		% For example, if the FontSize is 0.1 in normalized units,
		% then the text is 1/10 of the plot box height.
		Normalized
		% Starting in R2015b, distances in pixels are independent of your
		% system resolution on Windows® and Macintosh systems:
		% On Windows systems, a pixel is 1/96th of an inch.
		% On Macintosh systems, a pixel is 1/72nd of an inch.
		% On Linux® systems, the size of a pixel is determined by your
		% system resolution.
		Pixels
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:Font:Units:'
		CLASS_NAME = 'Source.Enum.Font.Units'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.Font.Units.Points
					str = 'points';
				case Source.Enum.Font.Units.Inches
					str = 'inches';
				case Source.Enum.Font.Units.Centimeters
					str = 'centimeters';
				case Source.Enum.Font.Units.Normalized
					str = 'normalized';
				case Source.Enum.Font.Units.Pixels
					str = 'pixels';
				otherwise
					error([Source.Enum.Font.Units.CLASS_NAME ':Unknown'],...
						'Unknown font units!');
			end
		end
	end
end

