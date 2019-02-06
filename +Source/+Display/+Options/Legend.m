classdef Legend < Source.Display.MultiColorObject &...
		matlab.mixin.Copyable & Source.Display.Exportable
	% LEGENDOPTIONS define options for a legend.
	% See also https://nl.mathworks.com/help/matlab/ref/matlab.graphics.illustration.legend-properties.html
	properties
		Override = Source.Enum.Toggle.Off
		% Appearance
		TextColor = char(Source.Enum.Color.Default.black)
		% Box options
		Box = Source.Enum.Toggle.Off
		BackgroundColor = char(Source.Enum.Color.Default.white)
		EdgeColor = char(Source.Enum.Color.Default.white)
		LineWidth = 0.5
		% Location and size
		Location = Source.Enum.Location.Best
		Orientation = Source.Enum.Orientation.Vertical
		Position
		Units = Source.Enum.Units.Normalized
		% Text
		AutoUpdate = Source.Enum.Toggle.On
		String
		Interpreter = Source.Enum.Interpreter.Latex
		Title
		% Line options
		LinesOptions
		% Font style
		Font = Source.Display.Options.Font.New()
		% Visibility
		Visible = Source.Enum.Toggle.On
		% Identifiers
		Tag = 'legend'
		UserData
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Display:Options:Legend:'
		CLASS_NAME = 'Source.Display.Options.Legend'
	end
	methods(Access = public, Static)
		function obj = New()
			obj = Source.Display.Options.Legend();
		end
		function obj = FromStyle(styleSettings)
			obj = Source.Display.Options.Legend();
			obj.TextColor = styleSettings.ForegroundColor;
			obj.EdgeColor = styleSettings.ForegroundColor;
			obj.BackgroundColor = styleSettings.BackgroundColor;
		end
		function obj = Presentation()
			obj = Source.Display.Options.Legend();
			obj.TextColor = Source.Display.StyleSettings...
				.PRESENTATION_FOREGROUNDCOLOR;
			obj.BackgroundColor = Source.Display.StyleSettings...
				.PRESENTATION_BACKGROUNDCOLOR;
		end
		function obj = WithLineOptions(linesOptions)
			obj = Source.Display.Options.Legend.Presentation();
			obj.LinesOptions = linesOptions;
			obj.Override = Source.Enum.Toggle.On;
		end
	end
	methods
		function set.TextColor(this, colorIn)
			this.TextColor = this.convertColor(colorIn, 'TextColor');
		end
		function set.EdgeColor(this, colorIn)
			this.EdgeColor = this.convertColor(colorIn, 'EdgeColor');
		end
		function set.BackgroundColor(this, colorIn)
			this.BackgroundColor = this.convertColor(colorIn, 'BackgroundColor');
		end
	end
	methods(Access = public)
		function cellObject = ToCell(this)
			this.OutputCell = {...
				'TextColor', this.TextColor,...
				'Color', this.BackgroundColor,...
				'Box', char(this.Box),...
				'EdgeColor', this.EdgeColor,...
				'Location', char(this.Location),...
				'LineWidth', this.LineWidth,...
				'Orientation', char(this.Orientation),...
				'Units', char(this.Units),...
				'AutoUpdate', char(this.AutoUpdate),...
				'Interpreter', char(this.Interpreter),...
				'Visible', char(this.Visible)};
			if(~isempty(this.Font))
				this.OutputCell = [this.OutputCell, this.Font.ToCell()];
			end
			this.AddIfNonEmpty('Title', this.Title);
			this.AddIfNonEmpty('Tag', this.Tag);
			this.AddIfNonEmpty('UserData', this.UserData);
			% When the location is set to none, it must be specified via the
			% position.
			if(this.Location == Source.Enum.Location.None)
				this.OutputCell = [this.OutputCell, {'Position', this.Position}];
			end
			% Has to come first.
			if(~isempty(this.String))
				this.OutputCell = [{'String', this.String}, this.OutputCell];
			end
			cellObject = this.OutputCell;
		end
	end
	methods(Access = protected)
		function this = Legend()
		end
	end
end
