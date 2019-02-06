classdef Marker
	enumeration
		auto
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
		ERROR_CODE_PREFIX = 'Source:Enum:Color:Marker:'
		CLASS_NAME = 'Source.Enum.Color.Marker'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.Color.Marker.auto
					str = 'auto';
				case Source.Enum.Color.Marker.flat
					str = 'flat';
				case Source.Enum.Color.Marker.none
					str = 'none';
				case Source.Enum.Color.Marker.yellow
					str = 'yellow';
				case Source.Enum.Color.Marker.magenta
					str = 'magenta';
				case Source.Enum.Color.Marker.cyan
					str = 'cyan';
				case Source.Enum.Color.Marker.red
					str = 'red';
				case Source.Enum.Color.Marker.green
					str = 'green';
				case Source.Enum.Color.Marker.blue
					str = 'blue';
				case Source.Enum.Color.Marker.white
					str = 'white';
				case Source.Enum.Color.Marker.black
					str = 'black';
				case Source.Enum.Color.Marker.y
					str = 'y';
				case Source.Enum.Color.Marker.m
					str = 'm';
				case Source.Enum.Color.Marker.c
					str = 'c';
				case Source.Enum.Color.Marker.r
					str = 'r';
				case Source.Enum.Color.Marker.g
					str = 'g';
				case Source.Enum.Color.Marker.b
					str = 'b';
				case Source.Enum.Color.Marker.w
					str = 'w';
				case Source.Enum.Color.Marker.k
					str = 'k';
				otherwise
					error([Source.Enum.Color.Marker.ERROR_CODE_PREFIX 'Unknown'],...
						'Unknown Marker!');
			end
		end
	end
end
