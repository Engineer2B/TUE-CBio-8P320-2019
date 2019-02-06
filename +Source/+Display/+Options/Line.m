classdef Line < matlab.mixin.Copyable & Source.Display.MultiColorObject
	% See also https://nl.mathworks.com/help/matlab/ref/matlab.graphics.primitive.line-properties.html
	properties
		% Line
		Color = [0 0 0]
		LineStyle = Source.Enum.LineStyle.Solid
		LineWidth = 0.5
		LineJoin = Source.Enum.LineJoinType.Round
		AlignVertexCenters = Source.Enum.Toggle.Off
		% Marker
		Marker = Source.Enum.Marker.None
		MarkerIndices
		MarkerSize = 6
		MarkerEdgeColor = 'auto'
		MarkerFaceColor = 'none'
		% Legend
		IncludeInLegend = Source.Enum.Toggle.On
		Visible = Source.Enum.Toggle.On
		Opacity = 1
		DisplayName
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Display:Options:Line:'
		CLASS_NAME = 'Source.Display.Options.Line'
	end
	methods(Access = public, Static)
		function obj = New()
			obj = Source.Display.Options.Line();
		end
		function obj = FromStyle(styleSettings)
			obj = Source.Display.Options.Line();
			obj.Color = styleSettings.ForegroundColor;
		end
		function obj = DefaultMarker()
			obj = Source.Display.Options.Line();
			obj.Marker = Source.Enum.Marker.Circle;
			obj.Color = [51,255,255]/255;
			obj.LineWidth = 2;
		end
		function obj = Presentation()
			obj = Source.Display.Options.Line();
			obj.LineWidth = 2.5;
			obj.MarkerSize = 15;
			obj.Color = Source.Enum.Color.Default.w;
		end
		function obj = PresentationWithColorAndName(color, displayName)
			obj = Source.Display.Options.Line.Presentation();
			obj.Color = color;
			obj.DisplayName = displayName;
		end
	end
	methods
		function set.Visible(this, visibleIn)
			if(isa(visibleIn, Source.Enum.Toggle.CLASS_NAME))
				this.Visible = visibleIn;
			elseif(islogical(visibleIn))
				if(visibleIn)
					this.Visible = Source.Enum.Toggle.On;
				else
					this.Visible = Source.Enum.Toggle.Off;
				end
			else
				error([this.ERROR_CODE_PREFIX 'SetVisibility:Invalid'],...
					'Invalid visibility value!');
			end
		end
		function set.MarkerEdgeColor(this, colorIn)
			this.MarkerEdgeColor = this.convertMarkerColor(colorIn,...
				'MarkerEdgeColor');
		end
		function set.MarkerFaceColor(this, colorIn)
			this.MarkerFaceColor = this.convertMarkerColor(colorIn,...
				'MarkerFaceColor');
		end
		function set.Color(this, colorIn)
			this.Color = this.convertColor(colorIn, 'Color');
		end
	end
	methods(Access = public)
		function AddRandomMarkers(this, inputLength)
			this.Marker = Source.Enum.Marker(1+floor(rand*13));
			this.MarkerIndices = 1:ceil(inputLength/...
				((1+rand)*log10(inputLength))):inputLength;
		end
		function cellObject = ToCell(this)
			cellObject = {...
				'LineStyle', char(this.LineStyle),...
				'LineWidth', this.LineWidth,...
				'Color', this.Color,...
				'LineJoin', char(this.LineJoin),...
				'AlignVertexCenters', char(this.AlignVertexCenters),...
				'Marker', char(this.Marker),...
				'MarkerSize', this.MarkerSize,...
				'MarkerEdgeColor', this.MarkerEdgeColor,...
				'MarkerFaceColor', this.MarkerFaceColor,...
				'Visible', char(this.Visible)};
			if(~isempty(this.MarkerIndices))
				cellObject = [cellObject, {'MarkerIndices', this.MarkerIndices}];
			end
			if(~isa(this.DisplayName, 'double'))
				cellObject = [cellObject, {'DisplayName', this.DisplayName}];
			end
		end
		function SetVisibility(this, visibility)
			this.Visible = visibility;
		end
		function isEqual = eq(this, that)
			isEqual = strcmp(this.DisplayName, that.DisplayName);
		end
	end
	methods(Access = protected)
		function obj = Line()
		end
	end
end

