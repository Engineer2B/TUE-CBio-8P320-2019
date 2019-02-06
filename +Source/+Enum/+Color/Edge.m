classdef Edge
	enumeration
		flat
		interp
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
		ERROR_CODE_PREFIX = 'Source:Enum:Color:Edge:'
		CLASS_NAME = 'Source.Enum.Color.Edge'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.Color.Edge.flat
					str = 'flat';
				case Source.Enum.Color.Edge.interp
					str = 'interp';
				case Source.Enum.Color.Edge.none
					str = 'none';
				case Source.Enum.Color.Edge.yellow
					str = 'yellow';
				case Source.Enum.Color.Edge.magenta
					str = 'magenta';
				case Source.Enum.Color.Edge.cyan
					str = 'cyan';
				case Source.Enum.Color.Edge.red
					str = 'red';
				case Source.Enum.Color.Edge.green
					str = 'green';
				case Source.Enum.Color.Edge.blue
					str = 'blue';
				case Source.Enum.Color.Edge.white
					str = 'white';
				case Source.Enum.Color.Edge.black
					str = 'black';
				case Source.Enum.Color.Edge.y
					str = 'y';
				case Source.Enum.Color.Edge.m
					str = 'm';
				case Source.Enum.Color.Edge.c
					str = 'c';
				case Source.Enum.Color.Edge.r
					str = 'r';
				case Source.Enum.Color.Edge.g
					str = 'g';
				case Source.Enum.Color.Edge.b
					str = 'b';
				case Source.Enum.Color.Edge.w
					str = 'w';
				case Source.Enum.Color.Edge.k
					str = 'k';
				otherwise
					error([Source.Enum.Color.Edge.ERROR_CODE_PREFIX 'Unknown'],...
						'Unknown EdgeColor!');
			end
		end
	end
end
