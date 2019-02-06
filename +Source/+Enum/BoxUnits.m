classdef BoxUnits
	enumeration
		% Data coordinates.
		Data
		% Normalized with respect to the axes. The lower left corner of
		% the axes maps to (0,0) and the upper right corner maps to (1,1).
		Normalized
		% Inches.
		Inches
		%	Centimeters.
		Centimeters
		% Based on the default system font character size.
		% Character width = width of letter x.
		% Character height = distance between the baselines of two lines of
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
		ERROR_CODE_PREFIX = 'Source:Enum:BoxUnits:'
		CLASS_NAME = 'Source.Enum.BoxUnits'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.BoxUnits.Data
					str = 'data';
				case Source.Enum.BoxUnits.Normalized
					str = 'normalized';
				case Source.Enum.BoxUnits.Inches
					str = 'inches';
				case Source.Enum.BoxUnits.Centimeters
					str = 'centimeters';
				case Source.Enum.BoxUnits.Characters
					str = 'characters';
				case Source.Enum.BoxUnits.Points
					str = 'points';
				case Source.Enum.BoxUnits.Pixels
					str = 'pixels';
				otherwise
					error([Source.Enum.BoxUnits 'UnknownValue'],...
					'Unknown box units!');
			end
		end
	end
end

