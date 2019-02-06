classdef Text < matlab.mixin.Copyable & Source.Display.MultiColorObject &...
		Source.Display.Exportable
	properties
		% Text to display
		String
		% Text
		% Text color
		Color = [0 0 0]
		% Interpreter
		Interpreter = Source.Enum.Interpreter.Latex
		% Font
		ExtendedFont = Source.Display.Options.ExtendedFont.New()
		% Text box
		% Scalar value in degrees
		Rotation = 0
		% Color of box outline.
		EdgeColor = 'none'
		% Color of text box background.
		BackgroundColor = 'none'
		% Line style of box outline.
		LineStyle = Source.Enum.LineStyle.Solid
		% Width of box outline, specified as a scalar numeric value
		% in point units. One point equals 1/72 inch.
		LineWidth = 0.5
		% Scalar numeric value.
		Margin = 3
		% Clipping of the text to the axes plot box,
		% which is the box defined by the axis limits
		Clipping = Source.Enum.Toggle.Off
		% Position
		% Position units
		Units = Source.Enum.BoxUnits.Data
		% Horizontal alignment of the text with respect to the x value
		% in the Position property
		HorizontalAlignment = Source.Enum.Alignment.Horizontal.Left
		% Vertical alignment of the text with respect to the y value
		% in the Position property.
		VerticalAlignment = Source.Enum.Alignment.Vertical.Middle
		% Interactivity
		% Interactive edit mode.
		Editing = Source.Enum.Toggle.Off
		% State of visibility.
		Visible = Source.Enum.Toggle.On
		% Callbacks
		% Callback Execution Control
		% Parent/Child
		% Identifiers
		% Tag to associate with the text object.
		Tag = ''
		% Position
		% Location of the text, specified as a two-element vector of the form
		% [x y] or a three-element vector of the form [x y z]. If you omit the
		% third element, z, then MATLAB sets it to 0. Specify the position
		% using numeric values. To convert datetime or duration values to the
		% appropriate numeric values for a particular coordinate direction, see
		% ruler2num. By default, the position value is defined in data units.
		% To change the units, use the Units property. 
		Position = [0 0 0]
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Display:Options:Text:'
		CLASS_NAME = 'Source.Display.Options.Text'
	end
	methods(Access = public, Static)
		function obj = New()
			obj = Source.Display.Options.Text();
		end
		function obj = FromStyle(styleSettings)
			obj = Source.Display.Options.Text();
			obj.Color = styleSettings.ForegroundColor;
			obj.ExtendedFont = styleSettings.TitleFont;
		end
	end
	methods
		function set.Color(this, colorIn)
			this.Color = this.convertColor(colorIn, 'Color');
		end
		function set.EdgeColor(this, colorIn)
			this.EdgeColor = this.convertMarkerColor(colorIn, 'EdgeColor');
		end
		function set.BackgroundColor(this, colorIn)
			this.BackgroundColor = this.convertMarkerColor(colorIn,...
				'BackgroundColor');
		end
	end
	methods(Access = public)
		function cellObject = ToCell(this)
			this.OutputCell = {...
					'Color', this.Color,...
					'Interpreter', char(this.Interpreter),...
					'Rotation', this.Rotation,...
					'EdgeColor', this.EdgeColor,...
					'BackgroundColor', this.BackgroundColor,...
					'LineStyle', char(this.LineStyle),...
					'LineWidth', this.LineWidth,...
					'Margin', this.Margin,...
					'Clipping', char(this.Clipping),...
					'Units', char(this.Units),...
					'HorizontalAlignment', char(this.HorizontalAlignment),...
					'VerticalAlignment', char(this.VerticalAlignment),...
					'Editing', char(this.Editing),...
					'Visible', char(this.Visible),...
					'Tag', this.Tag};
				this.OutputCell = [this.OutputCell, this.ExtendedFont.ToCell()];
				this.AddFirstIfNoneEmpty(this.String);
				this.AddFirstAsCellIfNoneEmpty(this.Position);
				cellObject = this.OutputCell;
		end
		function Apply(this, handle)
			handle.Interpreter = char(this.Interpreter);
			handle.String = this.String;
			handle.FontAngle = char(this.ExtendedFont.Angle);
			handle.FontName = this.ExtendedFont.Name;
			handle.FontWeight = char(this.ExtendedFont.Weight);
			handle.FontSize = this.ExtendedFont.Size;
			handle.FontUnits = char(this.ExtendedFont.Units);
			handle.FontSmoothing = char(this.ExtendedFont.Smoothing);
			handle.Color = this.Color;
			handle.Rotation = this.Rotation;
			handle.EdgeColor = this.EdgeColor;
			handle.BackgroundColor = this.BackgroundColor;
			handle.LineStyle = char(this.LineStyle);
			handle.LineWidth = this.LineWidth;
			handle.Margin = this.Margin;
			handle.Clipping = char(this.Clipping);
			handle.Units = char(this.Units);
			handle.HorizontalAlignment = char(this.HorizontalAlignment);
			handle.VerticalAlignment = char(this.VerticalAlignment);
			handle.Editing = char(this.Editing);
			handle.Visible = char(this.Visible);
			handle.Tag = this.Tag;
			handle.Position = this.Position;
		end
		function ApplyPreserveAutoRotate(this, handle)
			% Don't set some properties that disable auto-rotate feature of axes objects.
			cellValues = this.toCellOmittingPropertiesThatBreakAutoRotate();
			set(handle, cellValues{:});
		end
	end
	methods(Access = protected)
		function this = Text()
		end
		function cellObject = toCellOmittingPropertiesThatBreakAutoRotate(this)
			this.OutputCell = {...
					'Color', this.Color,...
					'Interpreter', char(this.Interpreter),...
					'EdgeColor', this.EdgeColor,...
					'BackgroundColor', this.BackgroundColor,...
					'LineStyle', char(this.LineStyle),...
					'LineWidth', this.LineWidth,...
					'Margin', this.Margin,...
					'Clipping', char(this.Clipping),...
					'Units', char(this.Units),...
					'String', this.String,...
					'Tag', this.Tag};
				this.OutputCell = [this.OutputCell, this.ExtendedFont.ToCell()];
				cellObject = this.OutputCell;
		end
	end
end

