classdef AxesLabel
	properties
		X
		Y
		Z
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Display:AxesLabel'
		CLASS_NAME = 'Source.Display.AxesLabel'
	end
	methods(Access = public, Static)
		function obj = New(styleSettings, xLabel, yLabel, zLabel)
			obj = Source.Display.AxesLabel();
			xText = styleSettings.LabelText.copy();
			xText.String = xLabel;
			yText = xText.copy();
			yText.String = yLabel;
			zText = xText.copy();
			if(~exist('zLabel','var'))
				zText.Visible = Source.Enum.Toggle.Off;
			else
				zText.String = zLabel;
			end
			obj.X = xText;
			obj.Y = yText;
			obj.Z = zText;
		end
		function obj = Geometry2D(unit, styleSettings)
			obj = Source.Display.AxesLabel.New(styleSettings,...
				sprintf('$x\\left[%s\\right]$', unit),...
				sprintf('$y\\left[%s\\right]$', unit));
		end
		function obj = Geometry(unit, styleSettings)
			obj = Source.Display.AxesLabel.New(styleSettings,...
				sprintf('$x\\left[%s\\right]$', unit),...
				sprintf('$y\\left[%s\\right]$', unit),...
				sprintf('$z\\left[%s\\right]$', unit));
		end
		function obj = Default()
			styleSettings = Source.Display.StyleSettings.Presentation();
			obj = Source.Display.AxesLabel.Geometry('m', styleSettings);
		end
	end
	methods(Access = protected)
		function obj = AxesLabel()
		end
	end
end
