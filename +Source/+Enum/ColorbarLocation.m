classdef ColorbarLocation
	enumeration
		North
		South
		East
		West
		NorthOutside
		SouthOutside
		EastOutside
		WestOutside
		Manual
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:ColorbarLocation:'
		CLASS_NAME = 'Source.Enum.ColorbarLocation'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.ColorbarLocation.North
					str = 'north';
				case Source.Enum.ColorbarLocation.South
					str = 'south';
				case Source.Enum.ColorbarLocation.East
					str = 'east';
				case Source.Enum.ColorbarLocation.West
					str = 'west';
				case Source.Enum.ColorbarLocation.NorthOutside
					str = 'northoutside';
				case Source.Enum.ColorbarLocation.SouthOutside
					str = 'southoutside';
				case Source.Enum.ColorbarLocation.EastOutside
					str = 'eastoutside';
				case Source.Enum.ColorbarLocation.WestOutside
					str = 'westoutside';
				case Source.Enum.ColorbarLocation.Manual
					str = 'manual';
				otherwise
					error([Source.Enum.ColorbarLocation.ERROR_CODE_PREFIX...
						'Unknown'], 'Unknown ColorbarLocation!')
			end
		end
	end
end

