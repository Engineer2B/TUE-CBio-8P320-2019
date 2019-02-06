classdef ColorBar < matlab.mixin.Copyable & Source.Display.MultiColorObject
	properties
		% Tick mark locations
		% vector of monotonically increasing numeric values
		%  The values do not need to be equally spaced.
		% If you do not want tick marks displayed, then set the property to 
		% the empty vector, [].
		Ticks
		% Selection mode for Ticks
		TicksMode = Source.Enum.Mode.auto
		% Tick mark labels
		TickLabels
		% Selection mode for TickLabels
		TickLabelsMode = Source.Enum.Mode.auto
		% Interpretation of characters in tick labels
		TickLabelInterpreter = Source.Enum.Interpreter.Latex
		% Minimum and maximum tick mark values
		Limits
		% Selection mode for limits
		LimitsMode = Source.Enum.Mode.auto
		% Label that displays along the colorbar, returned as a text object.
		Label
		% Direction of color scale
		Direction = Source.Enum.Direction.Normal
		% Tick mark length
		TickLength = 0.01
		% Tick mark direction
		TickDirection = Source.Enum.TickDirection.In
		% Font
		Font = Source.Display.Options.Font.New()
		% Position
		Location = Source.Enum.ColorbarLocation.EastOutside
		% Custom location and size, specified as a four-element vector of the 
		% form [left, bottom, width, height].
		% The left and bottom elements specify the distance from the lower-left
		%corner of the figure or to the lower-left corner of the colorbar.
		% The width and height elements specify the dimensions of the colorbar.
		% The Units property determines the position units.
		% If you specify the Position property, then MATLAB changes the
		% Location property to 'manual'.
		% The associated axes does not resize to accommodate the colorbar when
		% the Location property is 'manual'.
		% Example: [0.1 0.1 0.3 0.7]
		Position
		% All units are measured from the lower-left corner of the container
		% window.
		% This property affects the Position property.
		% If you change the units, then it is good practice to return it to
		% its default value after completing your computation to prevent
		% affecting other functions that assume Units is the default value.
		% If you specify the Position and Units properties as Name, Value pairs
		% when creating the object, then the order of specification matters.
		% If you want to define the position with particular units, then you
		% must set the Units property before the Position property.
		Units = Source.Enum.Units.Normalized
		% Use this property to specify the location of the tick marks,
		% tick labels, and colorbar label.
		AxisLocation = Source.Enum.AxisLocation.Out
		% Selection mode for AxisLocation
		AxisLocationMode = Source.Enum.Mode.auto
		% Color and Styling
		% Color of the tick marks, text, and box outline.
		Color = [0 0 0]
		% Box outline.
		Box = Source.Enum.Toggle.On
		% Width of box outline, specified as a positive value in point units.
		% One point equals 1/72 inch.
		LineWidth = 0.5
		% State of visibility
		Visible = Source.Enum.Toggle.On
		Tag = ''
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Display:Options:ColorBar:'
		CLASS_NAME = 'Source.Display.Options.ColorBar'
	end
	methods
		function set.Color(this, colorIn)
			this.Color = this.convertColorbarColor(colorIn, 'Color');
		end
	end
	methods(Access = public, Static)
		function obj = New()
			obj = Source.Display.Options.ColorBar();
		end
		function obj = FromStyle(styleSettings)
			obj = Source.Display.Options.ColorBar();
			obj.Color = styleSettings.ForegroundColor;
		end
	end
	methods(Access = public)
		function cellObject = ToCell(this)
			cellObject = {'Ticks', this.Ticks,...
				'TicksMode', char(this.TicksMode),...
				'TickLabels', this.TickLabels,...
				'TickLabelsMode', char(this.TickLabelsMode),...
				'TickLabelInterpreter', char(this.TickLabelInterpreter),...
				'LimitsMode', char(this.LimitsMode),...
				'Direction', char(this.Direction),...
				'TickLength', this.TickLength,...
				'TickDirection', char(this.TickDirection),...
				'Location', char(this.Location),...
				'Units', char(this.Units),...
				'AxisLocation', char(this.AxisLocation),...
				'AxisLocationMode', char(this.AxisLocationMode),...
				'Color', this.Color,...
				'Box', char(this.Box),...
				'LineWidth', this.LineWidth,...
				'Visible', char(this.Visible),...
				'Tag', this.Tag};
			if(~isempty(this.Limits))
				cellObject = [cellObject, {'Limits', this.Limits}];
			end
			if(~isempty(this.Position))
				cellObject = [cellObject, {'Position', this.Position}];
			end
			cellObject = [cellObject, this.Font.ToCell()];
		end
	end
	methods(Access = protected)
		function this = ColorBar()
		end
	end
end

