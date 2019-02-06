classdef DisplayFacility < handle
	properties
		AxisLabels
		Logger
		StyleSettings
		AxesShown
		FigureHandle
		FrameHandle
		AxesHandle
		FigureTag
		AxisLimits
		ColorLimits1
		ColorLimits2
		Azimuth
		Elevation
		HiddenLegendPlotHandles
		NoShow = false
		LineOptions
		PatchOptions
		LegendOptions
		ColorbarOptions1
		ColorbarOptions2
		LegendHandle
		ColorbarHandle1
		ColorbarHandle2
		HiddenAxesHandle
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Display:DisplayFacility:'
		CLASS_NAME = 'Source.Display.DisplayFacility'
		MAIN_AXES_TAG = 'main'
		HIDDEN_AXES_TAG = 'hidden'
	end
	properties(Access = protected)
		p_AxisLimitLabels
		p_AxisLabels
	end
	methods
		function set.LegendOptions(this, legendOptionsIn)
			Source.Helper.Assert.IsOfType(legendOptionsIn,...
				Source.Display.Options.Legend.CLASS_NAME, 'legendOptionsIn');
			this.LegendOptions = legendOptionsIn;
		end
		function set.ColorbarOptions1(this, colorbarOptions1In)
			Source.Helper.Assert.IsOfType(colorbarOptions1In,...
				Source.Display.Options.ColorBar.CLASS_NAME, 'colorbarOptions1In');
			this.ColorbarOptions1 = colorbarOptions1In;
		end
		function set.ColorbarOptions2(this, colorbarOptions2In)
			Source.Helper.Assert.IsOfType(colorbarOptions2In,...
				Source.Display.Options.ColorBar.CLASS_NAME, 'colorbarOptions2In');
			this.ColorbarOptions2 = colorbarOptions2In;
		end
		function set.AxesShown(this, value)
			Source.Helper.Assert.IsOfType(value, 'logical', 'AxesShown');
			if(~isempty(this.AxesHandle) && ~value)
				this.AxesHandle.XAxis.Visible = false;
				this.AxesHandle.YAxis.Visible = false;
				this.AxesHandle.ZAxis.Visible = false;
			end
			this.AxesShown = value;
		end
	end
	methods(Access = public, Static)
		function obj = New(logger, styleSettings, figureTag, axesLabel)
			obj = Source.Display.DisplayFacility(logger, styleSettings,...
				figureTag, axesLabel);
			obj.LineOptions = styleSettings.LineOptions;
			obj.PatchOptions = styleSettings.PatchOptions;
			obj.LegendOptions = styleSettings.LegendOptions;
			obj.ColorbarOptions1 = styleSettings.ColorbarOptions.copy();
			obj.ColorbarOptions2 = styleSettings.ColorbarOptions.copy();
		end
		function obj = Default(figureTag)
			logger = Source.Logging.Logger.Default();
			styleSettings = Source.Display.StyleSettings.Presentation();
			obj = Source.Display.DisplayFacility.New(...
				logger, styleSettings, figureTag,...
				Source.Display.AxesLabel.Default());
		end
		function obj = WithAxesLabel(figureTag, axesLabel)
			logger = Source.Logging.Logger.Default();
			styleSettings = Source.Display.StyleSettings.Presentation();
			obj = Source.Display.DisplayFacility.New(...
				logger, styleSettings, figureTag, axesLabel);
		end
	end
	methods(Access = protected, Static)
		function reopenFigure(figureTag, backgroundColor)
			theFigure = findobj('Tag', figureTag);
			if(~isempty(theFigure))
				close(theFigure);
			end
			figure('Name', figureTag, 'Tag', figureTag,...
				'Color', char(backgroundColor), 'NumberTitle', 'off');
		end
	end
	methods(Access = public)
		function this = PrepareFigure(this)
			if(isempty(this.FigureHandle) || ~isvalid(this.FigureHandle))
				Source.Display.DisplayFacility.reopenFigure(...
					this.FigureTag, this.StyleSettings.BackgroundColor);
				this.FigureHandle = findobj('Tag', this.FigureTag);
				this.FrameHandle = get(handle(this.FigureHandle), 'JavaFrame');
				this.AxesHandle = this.FigureHandle.CurrentAxes;
				this.setAxes();
			end
			if(gcf ~= this.FigureHandle)
				figure(this.FigureHandle);
			end
			this.FigureHandle.InvertHardcopy = 'off';
			this.HideFigure();
		end
		function ShowFigure(this)
			if(this.NoShow)
				return;
			end
			set(this.FigureHandle, 'Visible','on');
			this.MaximizeWindow();
		end
		function ShowGrid(this, extrema, stepSize)
			grid(this.AxesHandle, 'on');
			xticks(this.AxesHandle, extrema.X.Min:stepSize.X:extrema.X.Max);
			yticks(this.AxesHandle, extrema.Y.Min:stepSize.Y:extrema.Y.Max);
			zticks(this.AxesHandle, extrema.Z.Min:stepSize.Z:extrema.Z.Max);
		end
		function ShowLegend(this, legendOptions)
			this.PrepareFigure();
			if(~exist('legendOptions', 'var'))
				legendOptions = this.LegendOptions;
			else
				this.LegendOptions = legendOptions;
			end
			if(this.LegendOptions.Override == Source.Enum.Toggle.On)
				this.makeHiddenPlotForLegends();
			else
				legendOptionsCell = legendOptions.ToCell();
				if(isempty(legendOptions.String))
					this.LegendHandle = legend(this.AxesHandle, {},...
						legendOptionsCell{:});
				else
					this.LegendHandle = legend(this.AxesHandle,...
						legendOptionsCell{:});
				end
			end
			this.ShowFigure();
		end
		function axesHandle = ShowColorbar(this, colorbarOptions)
			if(~isempty(this.ColorbarHandle1) && isvalid(this.ColorbarHandle1))
				% The handle already exits.
				if(exist('colorbarOptions', 'var'))
					if(strcmp(this.ColorbarHandle1.Tag, colorbarOptions.Tag) == 1)
						this.ColorbarOptions1 = colorbarOptions;
						colorbarOptionsCell = colorbarOptions.ToCell();
						this.ColorbarHandle1 = colorbar(this.AxesHandle,...
							colorbarOptionsCell{:});
						if(~isempty(this.ColorbarOptions1.Label))
							this.ColorbarOptions1.Label.ApplyPreserveAutoRotate(this.ColorbarHandle1.Label);
						end
						axesHandle = this.AxesHandle;
					else
						this.ColorbarOptions2 = colorbarOptions;
						colorbarOptionsCell = colorbarOptions.ToCell();
						this.ColorbarHandle2 = colorbar(this.HiddenAxesHandle,...
							colorbarOptionsCell{:});
						if(~isempty(this.ColorbarOptions2.Label))
							this.ColorbarOptions2.Label.ApplyPreserveAutoRotate(this.ColorbarHandle2.Label);
						end
						axesHandle = this.HiddenAxesHandle;
					end
				else
					this.ColorbarOptions1 = colorbarOptions;
					colorbarOptionsCell = colorbarOptions.ToCell();
					this.ColorbarHandle1 = colorbar(this.AxesHandle,...
							colorbarOptionsCell{:});
					if(~isempty(this.ColorbarOptions1.Label))
						this.ColorbarOptions1.Label.ApplyPreserveAutoRotate(this.ColorbarHandle1.Label);
					end
					axesHandle = this.AxesHandle;
				end
			else
				this.ColorbarOptions1 = colorbarOptions;
				colorbarOptionsCell = colorbarOptions.ToCell();
				this.ColorbarHandle1 = colorbar(this.AxesHandle,...
					colorbarOptionsCell{:});
				if(~isempty(this.ColorbarOptions1.Label))
					this.ColorbarOptions1.Label.ApplyPreserveAutoRotate(this.ColorbarHandle1.Label);
				end
				axesHandle = this.AxesHandle;
			end
			axesHandle.Tag = colorbarOptions.Tag;
			axes(this.AxesHandle);
		end
		function SetAxisLimits(this, limits)
			this.PrepareFigure();
			if(isa(limits, Source.Geometry.Extrema.CLASS_NAME))
				axis(this.AxesHandle, limits.ToAxisLimits());
				this.AxisLimits = limits;
			else
				axis(this.AxesHandle, limits);
				if(length(limits) == 4)
					limits = [limits 0 0];
				end
				this.AxisLimits = Source.Geometry.Extrema.FromAxisLimits(limits);
			end
			this.ShowFigure();
		end
		function SetAxisLimitLabels(this, limits)
			this.PrepareFigure();
			if(isa(limits, Source.Geometry.Extrema.CLASS_NAME))
				this.AxesHandle.XLim
				axis(this.AxesHandle, limits.ToAxisLimits());
				this.p_AxisLimitLabels = limits;
			else
				axis(this.AxesHandle, limits);
				if(length(limits) == 4)
					limits = [limits 0 0];
				end
				this.p_AxisLimitLabels =...
					Source.Geometry.Extrema.FromAxisLimits(limits);
			end
			this.ShowFigure();
		end
		function SetColorLimitsByAxes(this, axesHandle, limits)
			if(~(strcmp(axesHandle.Tag, this.AxesHandle.Tag) == 1) &&...
					~(strcmp(axesHandle.Tag, this.HiddenAxesHandle.Tag) == 1))
				this.Logger.Error(' Axes do not exist yet!',...
					[this.ERROR_CODE_PREFIX 'NonExistantAxes']);
			end
			if(isa(limits, Source.Geometry.Extremum.CLASS_NAME))
				limits = limits.ToArray();
				caxis(axesHandle, limits);
			else
				caxis(axesHandle, limits);
				limits = Source.Geometry.Extremum.FromColorLimits(...
					limits);
			end
			
			if(strcmp(axesHandle.Tag, this.AxesHandle) == 1)
				this.ColorLimits1 = limits;
			else
				this.ColorLimits2 = limits;
			end
		end
		function SetColorLimitsByOptions(this, options)
			if(strcmp(options.Tag, this.AxesHandle.Tag) == 1)
				axesHandle = this.AxesHandle;
			elseif(strcmp(options.Tag, this.HiddenAxesHandle.Tag) == 1)
				axesHandle = this.HiddenAxesHandle;
			else
				this.Logger.Error(' Axes do not exist yet!',...
					[ this.ERROR_CODE_PREFIX 'NonExistantAxes']);
			end
			if(isa(options.Limits, Source.Geometry.Extremum.CLASS_NAME))
				limits = options.Limits.ToArray();
				caxis(axesHandle, limits);
			else
				caxis(axesHandle, options.Limits);
				limits = Source.Geometry.Extremum.FromColorLimits(...
					options.Limits);
			end
			if(strcmp(axesHandle.Tag, this.AxesHandle) == 1)
				this.ColorLimits1 = limits;
			else
				this.ColorLimits2 = limits;
			end
		end
		function SetColorLimits1(this, limits)
			if(isa(limits, Source.Geometry.Extremum.CLASS_NAME))
				caxis(this.AxesHandle, limits.ToArray());
				this.ColorLimits1 = limits;
			else
				caxis(this.AxesHandle, limits);
				this.ColorLimits1 = Source.Geometry.Extremum.FromColorLimits(...
					limits);
			end
		end
		function SetColorLimits2(this, limits)
			if(isa(limits, Source.Geometry.Extremum.CLASS_NAME))
				caxis(this.HiddenAxesHandle, limits.ToArray());
				this.ColorLimits2 = limits;
			else
				caxis(this.AxesHandle, limits);
				this.ColorLimits2 = Source.Geometry.Extremum.FromColorLimits(...
					limits);
			end
		end
		function SetViewPoint(this, azimuth, elevation)
			% See also https://nl.mathworks.com/help/matlab/ref/view.html.
			view(this.AxesHandle, azimuth, elevation);
			this.Azimuth = azimuth;
			this.Elevation = elevation;
		end
		function textHandle = SetTitle(this, text)
			this.PrepareFigure();
			textHandle = title(this.AxesHandle, text,...
				this.StyleSettings.Title{:});
			this.ShowFigure();
		end
		function ToXYView(this)
			this.SetViewPoint(0, 90);
		end
		function ToYXView(this)
			this.SetViewPoint(-90, 90);
		end
		function ToYZXTowardsView(this)
			this.SetViewPoint(90, 0);
		end
		function ToYZXAwayView(this)
			this.SetViewPoint(-90, 0);
		end
		function ToXZView(this)
			this.SetViewPoint(0, 0);
		end
 		function FixateAspectRatio(this)
 			this.AxesHandle.DataAspectRatioMode = 'manual';
			this.AxesHandle.DataAspectRatio = [1 1 1];
 		end
		function HideFigure(this)
			set(this.FigureHandle, 'Visible','off');
		end
		function MaximizeWindow(this)
			pause(0.00001);
			try
				this.FrameHandle.setMaximized(true);
			catch
				oldUnits = get(this.FigureHandle, 'Units');
				set(this.FigureHandle, 'Units', 'norm', 'Pos', [0,0,1,1]);
				set(this.FigureHandle, 'Units', oldUnits);
			end
		end
		function SetWindowDimensions(this, dimensions)
			jClient = this.FrameHandle.fHG2Client;
			jWindow = jClient.getWindow;
			if isempty(jWindow)
				drawnow;
				pause(0.002);
				jWindow = jClient.getWindow;
			end
			jWindow.setSize(...
				java.awt.Dimension(dimensions.Width, dimensions.Height));
		end
		function ToClipboard(this, dimensions)
			if(~exist('dimensions', 'var'))
				dimensions.Width = 16*80;
				dimensions.Height = 9*80;
			end
			this.SetWindowDimensions(dimensions);
			print(this.FigureHandle, '-clipboard', '-dmeta');
		end
		function SaveFigure(this, fileName, dimensions)
			if(~exist('dimensions', 'var'))
				% Default 16:9 wide screen dimensions
				dimensions.Width = 16*80;
				dimensions.Height = 9*80;
			end
			this.SetWindowDimensions(dimensions);
			this.FigureHandle.PaperPositionMode = 'auto';
			print(this.FigureHandle, [fileName '.emf'], '-dmeta','-loose');
		end
		function Destroy(this)
			this.clearFigure(this.FigureTag);
		end
		function clearFigure(this, figureTag)
			oldFigure = findobj('Tag', figureTag);
			if(~isempty(oldFigure))
				clf(oldFigure);
				delete(oldFigure);
			end
			if(~isempty(this.FigureHandle))
				delete(this.FigureHandle);
			end
		end
	end
	methods(Access = protected)
		function this = DisplayFacility(logger, styleSettings, figureTag,...
				axesLabel)
			Source.Helper.Assert.IsOfType(logger,...
				Source.Logging.Logger.CLASS_NAME, 'logger');
			this.Logger = logger;
			Source.Helper.Assert.IsOfType(styleSettings,...
				Source.Display.StyleSettings.CLASS_NAME, 'styleSettings');
			this.StyleSettings = styleSettings;
			this.FigureTag = figureTag;
			this.LegendOptions = styleSettings.LegendOptions;
			this.clearFigure(figureTag);
			Source.Helper.Assert.IsOfType(axesLabel,...
				Source.Display.AxesLabel.CLASS_NAME, 'axesLabel');
			this.p_AxisLabels = axesLabel;
			% Disable maximization warning.
			warning('off', 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
		end
		function setAxes(this)
			mainAxes = this.StyleSettings.Axes.copy();
			mainAxes.Tag = this.MAIN_AXES_TAG;
			axesOptionsCell = mainAxes.ToCell();
			if(isempty(this.FigureHandle.CurrentAxes))
				this.AxesHandle = axes(this.FigureHandle, axesOptionsCell{:});
			else
				this.AxesHandle = this.FigureHandle.CurrentAxes;
				set(this.FigureHandle.CurrentAxes, axesOptionsCell{:});
			end
			hiddenAxes = this.StyleSettings.Axes.copy();
			hiddenAxes.Tag = this.HIDDEN_AXES_TAG;
			hiddenAxes.Visible = Source.Enum.Toggle.Off;
			hiddenAxesCell = hiddenAxes.ToCell();
			this.HiddenAxesHandle = axes(this.FigureHandle, hiddenAxesCell{:});
			% Set axes to main axes.
			axes(this.AxesHandle);
			this.FigureHandle.CurrentAxes = this.AxesHandle;
			% Override the labels.
			xH = xlabel(this.AxesHandle, this.p_AxisLabels.X.String);
			this.p_AxisLabels.X.ApplyPreserveAutoRotate(xH);
			yH = ylabel(this.AxesHandle,this.p_AxisLabels.Y.String);
			this.p_AxisLabels.Y.ApplyPreserveAutoRotate(yH);
			zH = zlabel(this.AxesHandle,this.p_AxisLabels.Z.String);
			this.p_AxisLabels.Z.ApplyPreserveAutoRotate(zH);
			% Set the aspect ratio.
			pbaspect([1 1 1]);
			if(~this.AxesShown)
				this.AxesHandle.XAxis.Visible = false;
				this.AxesHandle.YAxis.Visible = false;
				this.AxesHandle.ZAxis.Visible = false;
			end
		end
		function makeHiddenPlotForLegends(this)
			% from https://stackoverflow.com/a/33475174/1750173.
			this.tryRemoveHiddenPlotForLegends();
			linesOptions = this.LegendOptions.LinesOptions;
			this.HiddenLegendPlotHandles = zeros(length(linesOptions), 1);
			hold(this.AxesHandle, 'on');
			for indexLinesOptions = 1:length(linesOptions)
				lineOptions = linesOptions(indexLinesOptions).ToCell();
				this.HiddenLegendPlotHandles(indexLinesOptions) =...
					plot(NaN, NaN, lineOptions{:});
			end
			legendOptions = this.LegendOptions.ToCell();
			legend(this.HiddenLegendPlotHandles, {}, legendOptions{:});
		end
		function tryRemoveHiddenPlotForLegends(this)
			if(~isa(this.HiddenLegendPlotHandles, 'double'))
				for indexHiddenLegendPlotHandle =...
						1:length(this.HiddenLegendPlotHandles)
					hlph = this.HiddenLegendPlotHandles{indexHiddenLegendPlotHandle};
					delete(hlph);
				end
			end
		end
	end
end