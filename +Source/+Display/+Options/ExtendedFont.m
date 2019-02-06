classdef ExtendedFont < Source.Display.Options.Font
	properties
		% Font size units
		% points (default) | inches | centimeters | normalized | pixels
		Units = Source.Enum.Font.Units.Points
		% Smooth font character appearance
		Smoothing = Source.Enum.Toggle.On
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Display:Options:ExtendedFont:'
		CLASS_NAME = 'Source.Display.Options.ExtendedFont'
	end
	methods(Access = public, Static)
		function obj = New()
			obj = Source.Display.Options.ExtendedFont();
		end
	end
	methods(Access = public)
		function cellObject = ToCell(this)
			cellObject = ToCell@Source.Display.Options.Font(this);
			cellObject = [cellObject, {'FontUnits', char(this.Units),...
				'FontSmoothing', char(this.Smoothing)}];
		end
	end
	methods(Access = protected)
		function this = ExtendedFont()
			this = this@Source.Display.Options.Font();
		end
	end
end

