classdef Font
	properties
		% Character slant, specified as one of these values:
		% 'normal' - No character slant
		% 'italic' - Slanted characters
		% Not all fonts have both font styles.
		% Therefore, the italic font might look the same as the normal font.
		Angle = Source.Enum.Font.Angle.Normal
		% Font name, specified a supported font name or 'FixedWidth'.
		% To display and print properly, you must choose a font that your
		% system supports. The default font depends on the specific operating
		% system and locale.
		% To use a fixed-width font that looks good in any locale,
		% use 'FixedWidth'. The 'FixedWidth' value relies on the root
		% FixedWidthFontName property.
		% Setting the root FixedWidthFontName property causes an immediate
		% update of the display to use the new font.
		Name = 'FixedWidth'
		Size = 14
		% Character thickness, specified as one of these values:
		% 'normal' - Default weight as defined by the particular font
		% 'bold' - Thicker character outlines than normal
		% MATLAB- uses the FontWeight property to select a font from those
		% available on your system. Not all fonts have a bold font weight.
		% Therefore, specifying a bold font weight still can result in the
		% normal font weight.
		Weight = Source.Enum.Font.Weight.Normal
	end
	methods(Access = public, Static)
		function obj = New()
			obj = Source.Display.Options.Font();
		end
	end
	methods(Access = public)
		function cellObject = ToCell(this)
			cellObject = {'FontAngle', char(this.Angle),...
				'FontName', this.Name,...
				'FontSize', this.Size,...
				'FontWeight', char(this.Weight)};
		end
	end
	methods(Access = protected)
		function this = Font()
		end
	end
end

