classdef Units
	enumeration
		% 	Normalized with respect to the container, which is usually the
		% figure. The lower left corner of the figure maps to (0,0) and the
		% upper right corner maps to (1,1).
		Normalized
		% Inches.
		Inches
		% Centimeters.
		Centimeters
		% Based on the default system font character size.
		% * Character width = width of letter x.
		% * Character height = distance between the baselines of two lines of
		% text.
		Characters
		% Points. One point equals 1/72 inch.
		Points
		% Pixels.
		% Starting in R2015b, distances in pixels are independent of your
		% system resolution on Windows and Macintosh systems:
		% On Windows systems, a pixel is 1/96th of an inch.
		% On Macintosh systems, a pixel is 1/72nd of an inch.
		% On Linux systems, the size of a pixel is determined
		% by your system resolution.
		Pixels
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:Units:'
		CLASS_NAME = 'Source.Enum.Units'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.Units.Normalized
					str = 'normalized';
				case Source.Enum.Units.Inches
					str = 'inches';
				case Source.Enum.Units.Centimeters
					str = 'centimeters';
				case Source.Enum.Units.Characters
					str = 'characters';
				case Source.Enum.Units.Points
					str = 'points';
				case Source.Enum.Units.Pixels
					str = 'pixels';
				otherwise
					error([Source:Enum:Units 'UnknownValue'],...
					'Unknown units!');
			end
		end
	end
end

