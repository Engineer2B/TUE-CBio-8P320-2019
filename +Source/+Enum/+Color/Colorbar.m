classdef Colorbar
	enumeration
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
		ERROR_CODE_PREFIX = 'Source:Enum:Color:Colorbar:'
		CLASS_NAME = 'Source.Enum.Color.Colorbar'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.Color.Colorbar.none
					str = 'none';
				case Source.Enum.Color.Colorbar.yellow
					str = 'yellow';
				case Source.Enum.Color.Colorbar.magenta
					str = 'magenta';
				case Source.Enum.Color.Colorbar.cyan
					str = 'cyan';
				case Source.Enum.Color.Colorbar.red
					str = 'red';
				case Source.Enum.Color.Colorbar.green
					str = 'green';
				case Source.Enum.Color.Colorbar.blue
					str = 'blue';
				case Source.Enum.Color.Colorbar.white
					str = 'white';
				case Source.Enum.Color.Colorbar.black
					str = 'black';
				case Source.Enum.Color.Colorbar.y
					str = 'y';
				case Source.Enum.Color.Colorbar.m
					str = 'm';
				case Source.Enum.Color.Colorbar.c
					str = 'c';
				case Source.Enum.Color.Colorbar.r
					str = 'r';
				case Source.Enum.Color.Colorbar.g
					str = 'g';
				case Source.Enum.Color.Colorbar.b
					str = 'b';
				case Source.Enum.Color.Colorbar.w
					str = 'w';
				case Source.Enum.Color.Colorbar.k
					str = 'k';
				otherwise
					error([Source.Enum.Color.Colorbar.ERROR_CODE_PREFIX 'Unknown'],...
						'Unknown Colorbar color!');
			end
		end
	end
end
