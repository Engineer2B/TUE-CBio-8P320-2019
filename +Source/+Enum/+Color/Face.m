classdef Face
	enumeration
		flat
		interp
		none
		texturemap
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
		ERROR_CODE_PREFIX = 'Source:Enum:Color:Face:'
		CLASS_NAME = 'Source.Enum.Color.Face'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.Color.Face.flat
					str = 'flat';
				case Source.Enum.Color.Face.interp
					str = 'interp';
				case Source.Enum.Color.Face.none
					str = 'none';
				case Source.Enum.Color.Face.texturemap
					str = 'texturemap';
				case Source.Enum.Color.Face.yellow
					str = 'yellow';
				case Source.Enum.Color.Face.magenta
					str = 'magenta';
				case Source.Enum.Color.Face.cyan
					str = 'cyan';
				case Source.Enum.Color.Face.red
					str = 'red';
				case Source.Enum.Color.Face.green
					str = 'green';
				case Source.Enum.Color.Face.blue
					str = 'blue';
				case Source.Enum.Color.Face.white
					str = 'white';
				case Source.Enum.Color.Face.black
					str = 'black';
				case Source.Enum.Color.Face.y
					str = 'y';
				case Source.Enum.Color.Face.m
					str = 'm';
				case Source.Enum.Color.Face.c
					str = 'c';
				case Source.Enum.Color.Face.r
					str = 'r';
				case Source.Enum.Color.Face.g
					str = 'g';
				case Source.Enum.Color.Face.b
					str = 'b';
				case Source.Enum.Color.Face.w
					str = 'w';
				case Source.Enum.Color.Face.k
					str = 'k';
				otherwise
					error([Source.Enum.Color.Face.ERROR_CODE_PREFIX 'Unknown'],...
						'Unknown Face!');
			end
		end
	end
end
