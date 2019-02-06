classdef StyleSettings
	properties
		Axes
		LabelText
		LegendOptions
		ColorbarOptions
		LineOptions
		PatchOptions
		Title
		ForegroundColor
		BackgroundColor
		Type
		Interpreter = Source.Enum.Interpreter.Latex
		TitleFont
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Display:StyleSettings'
		CLASS_NAME = 'Source.Display.StyleSettings'
		PRESENTATION_FOREGROUNDCOLOR = 'w'
		PRESENTATION_BACKGROUNDCOLOR = 'k'
		DEFAULT_LABEL_FONT_SIZE = 14;
		PRESENTATION_LABEL_FONT_SIZE = 24;
	end
	methods(Access = public, Static)
		function obj = Default()
			titleStyle = {'FontSize'; 16; 'Interpreter'; 'latex'};
			interpreter = Source.Enum.Interpreter.Latex;
			lblFontSize = Source.Display.StyleSettings...
				.DEFAULT_LABEL_FONT_SIZE;
			obj = Source.Display.StyleSettings();
			% In general
			obj.ForegroundColor = obj.PRESENTATION_BACKGROUNDCOLOR;
			obj.BackgroundColor = obj.PRESENTATION_FOREGROUNDCOLOR;
			obj.Type = Source.Enum.StyleSettings.Default;
			% Axes
			obj.Axes = Source.Display.Options.Axes.New();
			obj.Axes.Font.Size = lblFontSize;
			obj.Axes.Color = Source.Display.StyleSettings...
				.PRESENTATION_FOREGROUNDCOLOR;
			% Labels
			obj.LabelText = Source.Display.Options.Text.New();
			obj.LabelText.HorizontalAlignment =...
				Source.Enum.Alignment.Horizontal.Center;
			obj.LabelText.VerticalAlignment =...
				Source.Enum.Alignment.Vertical.Top;
			obj.LabelText.Interpreter = interpreter;
			obj.LabelText.ExtendedFont.Size = Source.Display.StyleSettings...
				.DEFAULT_LABEL_FONT_SIZE;
			% Legends
			obj.LegendOptions = Source.Display.Options.Legend.FromStyle(obj);
			obj.LegendOptions.Font.Size = 14;
			obj.LegendOptions.Interpreter = interpreter;
			% Colorbars
			obj.ColorbarOptions = Source.Display.Options.ColorBar.FromStyle(obj);
			obj.ColorbarOptions.Font.Size = 14;
			obj.ColorbarOptions.TickLabelInterpreter = interpreter;
			% Lines
			obj.LineOptions = Source.Display.Options.Line.FromStyle(obj);
			% Patches
			obj.PatchOptions = Source.Display.Options.Patch.FromStyle(obj);
			% Title
			obj.Title = titleStyle;
			obj.TitleFont = Source.Display.Options.ExtendedFont.New();
			obj.TitleFont.Size = 16;
		end
		function obj = Presentation()
			obj = Source.Display.StyleSettings.Default();
			backColor = Source.Display.StyleSettings...
				.PRESENTATION_BACKGROUNDCOLOR;
			foreColor = Source.Display.StyleSettings...
				.PRESENTATION_FOREGROUNDCOLOR;
			lblFontSize = Source.Display.StyleSettings...
				.PRESENTATION_LABEL_FONT_SIZE;
			obj.Axes.Font.Size = lblFontSize;
			obj.Axes.XColor = foreColor;
			obj.Axes.YColor = foreColor;
			obj.Axes.ZColor = foreColor;
			obj.Axes.Color = backColor;
			obj.LabelText.Color = foreColor;
			obj.LabelText.ExtendedFont.Size = lblFontSize;
			obj.ForegroundColor = obj.PRESENTATION_FOREGROUNDCOLOR;
			obj.BackgroundColor = obj.PRESENTATION_BACKGROUNDCOLOR;
			obj.Title = {'FontSize'; 24; 'Interpreter'; 'latex';...
				'Color'; 'w'};
			obj.Type = Source.Enum.StyleSettings.Presentation;
			obj.LegendOptions = Source.Display.Options.Legend.FromStyle(obj);
			obj.LegendOptions.Font.Size = 24;
			obj.LegendOptions.Interpreter = Source.Enum.Interpreter.Latex;
			obj.ColorbarOptions = Source.Display.Options.ColorBar.FromStyle(obj);
			obj.ColorbarOptions.Font.Size = 24;
			obj.ColorbarOptions.TickLabelInterpreter =...
				Source.Enum.Interpreter.Latex;
			obj.LineOptions = Source.Display.Options.Line.FromStyle(obj);
			obj.PatchOptions = Source.Display.Options.Patch.FromStyle(obj);
			obj.TitleFont.Size = 24;
		end
	end
	methods(Access = protected)
		function this = StyleSettings()
		end
	end
end
