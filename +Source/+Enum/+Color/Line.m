classdef Line
	enumeration
		flat
		none
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
		ERROR_CODE_PREFIX = 'Source:Enum:Color:Line:'
		CLASS_NAME = 'Source.Enum.Color.Line'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.Color.Line.flat
					str = 'flat';
				case Source.Enum.Color.Line.none
					str = 'none';
				case Source.Enum.Color.Line.yellow
					str = 'yellow';
				case Source.Enum.Color.Line.magenta
					str = 'magenta';
				case Source.Enum.Color.Line.cyan
					str = 'cyan';
				case Source.Enum.Color.Line.red
					str = 'red';
				case Source.Enum.Color.Line.green
					str = 'green';
				case Source.Enum.Color.Line.blue
					str = 'blue';
				case Source.Enum.Color.Line.white
					str = 'white';
				case Source.Enum.Color.Line.black
					str = 'black';
				case Source.Enum.Color.Line.y
					str = 'y';
				case Source.Enum.Color.Line.m
					str = 'm';
				case Source.Enum.Color.Line.c
					str = 'c';
				case Source.Enum.Color.Line.r
					str = 'r';
				case Source.Enum.Color.Line.g
					str = 'g';
				case Source.Enum.Color.Line.b
					str = 'b';
				case Source.Enum.Color.Line.w
					str = 'w';
				case Source.Enum.Color.Line.k
					str = 'k';
				otherwise
					error([Source.Enum.Color.Line.ERROR_CODE_PREFIX 'Unknown'],...
						'Unknown line color!');
			end
		end
	end
end
