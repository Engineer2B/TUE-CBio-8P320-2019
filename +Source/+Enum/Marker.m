classdef Marker < double
	enumeration
		Circle(1)
		PlusSign(2)
		Asterisk(3)
		Point(4)
		Cross(5)
		Square(6)
		Diamond(7)
		UpwardPointingTriangle(8)
		DownwardPointingTriangle(9)
		RightPointingTriangle(10)
		LeftPointingTriangle(11)
		Pentagram(12)
		Hexagram(13)
		None(0)
	end
	methods
		function str = char(obj)
			switch(obj)
					case Source.Enum.Marker.Circle
						str = 'o';
					case Source.Enum.Marker.PlusSign
						str = '+';
					case Source.Enum.Marker.Asterisk
						str = '*';
					case Source.Enum.Marker.Point
						str = '.';
					case Source.Enum.Marker.Cross
						str = 'x';
					case Source.Enum.Marker.Square
						str = 's';
					case Source.Enum.Marker.Diamond
						str = 'd';
					case Source.Enum.Marker.UpwardPointingTriangle
						str = '^';
					case Source.Enum.Marker.DownwardPointingTriangle
						str = 'v';
					case Source.Enum.Marker.RightPointingTriangle
						str = '>';
					case Source.Enum.Marker.LeftPointingTriangle
						str = '<';
					case Source.Enum.Marker.Pentagram
						str = 'p';
					case Source.Enum.Marker.Hexagram
						str = 'h';
					case Source.Enum.Marker.None
						str = 'none';
				otherwise
					error('Source:Enum:Marker:Unknown','Unknown marker!');
			end
		end
	end
end
