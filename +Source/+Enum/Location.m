classdef Location
	enumeration
		North
		South
		East
		West
		NorthEast
		NorthWest
		SouthEast
		SouthWest
		NorthOutside
		SouthOutside
		EastOutside
		WestOutside
		NorthEastOutside
		NorthWestOutside
		SouthEastOutside
		SouthWestOutside
		Best
		BestOutside
		None
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:Location:'
		CLASS_NAME = 'Source.Enum.Location'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.Location.North
					str = 'north';
				case Source.Enum.Location.South
					str = 'south';
				case Source.Enum.Location.East
					str = 'east';
				case Source.Enum.Location.West
					str = 'west';
				case Source.Enum.Location.NorthEast
					str = 'northeast';
				case Source.Enum.Location.NorthWest
					str = 'northwest';
				case Source.Enum.Location.SouthEast
					str = 'southeast';
				case Source.Enum.Location.SouthWest
					str = 'southwest';
				case Source.Enum.Location.NorthOutside
					str = 'northoutside';
				case Source.Enum.Location.SouthOutside
					str = 'southoutside';
				case Source.Enum.Location.EastOutside
					str = 'eastoutside';
				case Source.Enum.Location.WestOutside
					str = 'westoutside';
				case Source.Enum.Location.NorthEastOutside
					str = 'northeastoutside';
				case Source.Enum.Location.NorthWestOutside
					str = 'northwestoutside';
				case Source.Enum.Location.SouthEastOutside
					str = 'southeastoutside';
				case Source.Enum.Location.SouthWestOutside
					str = 'southwestoutside';
				case Source.Enum.Location.Best
					str = 'best';
				case Source.Enum.Location.BestOutside
					str = 'bestoutside';
				case Source.Enum.Location.None
					str = 'none';
				otherwise
					error([Source.Enum.Location.ERROR_CODE_PREFIX 'Unknown'],...
						'Unknown Location!')
			end
		end
	end
end

