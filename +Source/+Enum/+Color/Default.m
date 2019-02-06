classdef Default
	enumeration
		yellow
		magenta
		cyan
		red
		green
		blue
		white
		black
		y
		m
		c
		r
		g
		b
		w
		k
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:Color:Default:'
		CLASS_NAME = 'Source.Enum.Color.Default'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.Color.Default.yellow
					str = 'yellow';
				case Source.Enum.Color.Default.magenta
					str = 'magenta';
				case Source.Enum.Color.Default.cyan
					str = 'cyan';
				case Source.Enum.Color.Default.red
					str = 'red';
				case Source.Enum.Color.Default.green
					str = 'green';
				case Source.Enum.Color.Default.blue
					str = 'blue';
				case Source.Enum.Color.Default.white
					str = 'white';
				case Source.Enum.Color.Default.black
					str = 'black';
				case Source.Enum.Color.Default.y
					str = 'y';
				case Source.Enum.Color.Default.m
					str = 'm';
				case Source.Enum.Color.Default.c
					str = 'c';
				case Source.Enum.Color.Default.r
					str = 'r';
				case Source.Enum.Color.Default.g
					str = 'g';
				case Source.Enum.Color.Default.b
					str = 'b';
				case Source.Enum.Color.Default.w
					str = 'w';
				case Source.Enum.Color.Default.k
					str = 'k';
				otherwise
					error([Source.Enum.Color.Default.ERROR_CODE_PREFIX 'Unknown'],...
						'Unknown color!');
			end
		end
	end
end

