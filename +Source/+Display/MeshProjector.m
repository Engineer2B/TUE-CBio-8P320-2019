classdef MeshProjector < handle
	%MESHPROJECTOR A class for easy drawing of objects in 3D.
	properties
		DisplayFacility
		Logger
	end
	properties(Constant)
		NORM_LENGTH = 0.1;
		ERROR_CODE_PREFIX = 'Source:Display:MeshProjector:'
		CLASS_NAME = 'Source.Display.MeshProjector'
	end
	properties(Access = protected)
		Handle
		HandlesMap
	end
	methods(Access = public, Static)
		function obj = New(displayFacility)
			obj = Source.Display.MeshProjector();
			obj.DisplayFacility = displayFacility;
			obj.Logger = displayFacility.Logger;
			obj.DisplayFacility.PrepareFigure();
		end
		function obj = Default()
			obj = Source.Display.MeshProjector.New(...
				Source.Display.DisplayFacility.Default('Default'));
		end
		function obj = WithTag(tag)
			obj = Source.Display.MeshProjector.New(...
				Source.Display.DisplayFacility.Default(tag));
		end
	end
	methods(Access = public)
		function frames = Record(this, tVals, mpFn)
			nOfT = length(tVals);
			frames(nOfT) = struct('cdata', [], 'colormap',[]);
			for iT = 1:nOfT
				mpFn(tVals(iT));
				frames(iT) = getframe(this.DisplayFacility.FigureHandle);
			end
		end
		function ExportMovie(this, frames, fn, fps)
			v = VideoWriter([fn '.mp4'],'MPEG-4');
			v.FrameRate = fps;
			open(v);
			writeVideo(v,frames);
			close(v);
		end
		function ShowSystem(this, configuration, topology, transducer)
			configStrings = configuration.ToDisplayString('m','m', 12);
			this.DisplayFacility.SetTitle(...
					{configStrings.header, configStrings.object});			
			extremas = topology.Map('Source.Geometry.Extrema',...
				@(surfaceMesh) this.showMesh(surfaceMesh));
			
			extrema = this.ShowMarkers(transducer.ElementPositions);
			extrema.UpdateByExtrema(configuration.ToExtrema());
			extremas.ForEach(@(extremaValue)...
				extrema.UpdateByExtrema(extremaValue));
			extrema.UpdateToCube();
			this.DisplayFacility.SetAxisLimits(extrema);
		end
		function handlesMap = ShowTopology(this, varargin)
			fn = @() this.showTopology(varargin{:});
			this.withPreparation(fn);
			handlesMap = this.HandlesMap;
		end
		function handle = ShowTransducer(this, varargin)
			fn = @() this.showTransducer(varargin{:});
			this.withPreparation(fn);
			handle = this.Handle;
		end
		function ShowCylinder(this, varargin)
			fn = @() this.showCylinder(varargin{:});
			this.withPreparation(fn);
		end
		function handle = ShowArbitraryCylinder(this, varargin)
			fn = @() this.showArbitraryCylinder(varargin{:});
			this.withPreparation(fn);
			handle = this.Handle;
		end
		function handle = ShowPlane(this, varargin)
			fn = @() this.showPlane(varargin{:});
			this.withPreparation(fn);
			handle = this.Handle;
		end
		function handle = ShowArbitraryPlane(this, varargin)
			fn = @() this.showArbitraryPlane(varargin{:});
			this.withPreparation(fn);
			handle = this.Handle;
		end
		function handle = ShowEllipseOnPlane(this, varargin)
			fn = @() this.showEllipseOnPlane(varargin{:});
			this.withPreparation(fn);
			handle = this.Handle;
		end
		function handle = ShowCircleOnPlane(this, varargin)
			fn = @() this.showCircleOnPlane(varargin{:});
			this.withPreparation(fn);
			handle = this.Handle;
		end
		function handle = ShowMesh(this, varargin)
			fn = @() this.showMesh(varargin{:});
			this.withPreparation(fn);
			handle = this.Handle;
		end
		function handle = ShowArbitraryMesh(this, varargin)
			fn = @() this.showArbitraryMesh(varargin{:});
			this.withPreparation(fn);
			handle = this.Handle;
		end
		function ShowTriangleElement(this, varargin)
			fn = @() this.showTriangleElement(varargin{:});
			this.withPreparation(fn);
		end
		function ShowTriangleElementZoomed(this, varargin)
			fn = @() this.showTriangleElementZoomed(varargin{:});
			this.withPreparation(fn);
		end
		function ShowTriangleElementNorms(this, triangleElement)
			this.ShowLine(triangleElement.Incenter,...
			triangleElement.Incenter+triangleElement.NormalVector1,...
			struct('label',...
			Source.Display.MathString.Formula(...
			Source.Display.MathString.Vector('n','1'))));
			this.ShowLine(triangleElement.Incenter,...
			triangleElement.Incenter+triangleElement.NormalVector2,...
			struct('label',...
			Source.Display.MathString.Formula(...
			Source.Display.MathString.Vector('n','2'))));
			extrema = triangleElement.ToExtrema();
			extrema.UpdateToCube();
			this.DisplayFacility.SetAxisLimits(extrema);
			this.DisplayFacility.ShowFigure();
		end
		function ShowLine(this, varargin)
			fn = @() this.showLine(varargin{:});
			this.withPreparation(fn);
		end
		function ShowLineNew(this, startPoint, endPoint, lineOptions)
			this.DisplayFacility.PrepareFigure();
			this.DisplayFacility.ToXYView();
			hold on
			if(~exist('lineOptions','var'))
				line([startPoint(1) endPoint(1)], [startPoint(2) endPoint(2)],...
					[startPoint(3) endPoint(3)], 'Color',...
					this.DisplayFacility.StyleSettings.ForegroundColor);
			else
				Source.Helper.Assert.IsOfType(lineOptions,...
					'Source.Display.Options.Line', 'lineOptions');
				lineOptionsCell = lineOptions.ToCell();
				h = line([startPoint(1) endPoint(1)], [startPoint(2) endPoint(2)],...
					[startPoint(3) endPoint(3)], lineOptionsCell{:});
				h.Annotation.LegendInformation.IconDisplayStyle =...
					char(lineOptions.IncludeInLegend);
			end
			hold off
			this.DisplayFacility.ShowFigure();
		end
		function handle = ShowExtrema(this, extrema, varargin)
			fn = @() this.showExtrema(extrema, varargin{:});
			this.withPreparation(fn);
			handle = this.Handle;
		end
		function MarkExtrema(this, extrema, varargin)
			fn = @() this.markExtrema(extrema, varargin{:});
			this.withPreparation(fn);	
		end
		function ShowExtremaN(this, extrema, lineOptions)
			this.DisplayFacility.PrepareFigure();
			hold(this.DisplayFacility.AxesHandle, 'on');
			extrema.Show(lineOptions);
			hold(this.DisplayFacility.AxesHandle, 'off');
			this.DisplayFacility.ShowFigure();
		end
		function MarkExtremas(this, extremas, lineOptions)
			this.DisplayFacility.PrepareFigure();
			hold(this.DisplayFacility.AxesHandle, 'on');
			if(isa(lineOptions, Source.Helper.Collection.CLASS_NAME))
				extremas.ForEach(@(extrema, index)...
					extrema.ShowMarker(lineOptions(index)));
			else
				extremas.ForEach(@(extrema) extrema.ShowMarker(lineOptions));
			end
			hold(this.DisplayFacility.AxesHandle, 'off');
			this.DisplayFacility.ShowFigure();		
		end
		function ShowExtremas(this, extremas, patchOptions)
			this.DisplayFacility.PrepareFigure();
			hold(this.DisplayFacility.AxesHandle, 'on');
			if(isa(patchOptions, Source.Helper.Collection.CLASS_NAME))
				extremas.ForEach(@(extrema, index)...
					extrema.ShowDebug(patchOptions(index)));
			else
				extremas.ForEach(@(extrema) extrema.ShowDebug(patchOptions));
			end
			hold(this.DisplayFacility.AxesHandle, 'off');
			this.DisplayFacility.ShowFigure();
		end
		function ShowVectors(this, vectors, options)
			if(~exist('options', 'var') || ~isfield(options, 'color'))
				options.color = Source.Helper.Random.Color();
			end
			[xPoints, yPoints, zPoints] = vectors.ToArrays();
			this.DisplayFacility.PrepareFigure();
			hold(this.DisplayFacility.AxesHandle, 'on');
			for index = 1:length(xPoints)
				line([0, xPoints(index)], [0, yPoints(index)],...
					[0, zPoints(index)], 'LineWidth', 2, 'Color', options.color);
			end
			hold(this.DisplayFacility.AxesHandle, 'off');
			this.DisplayFacility.ShowFigure();
		end
		function ShowRay(this, ray, displayMode)
			if(~exist('displayMode', 'var'))
				displayMode = Source.Enum.RayDisplayMode.MediumNameAndWaveType;
			end
			this.DisplayFacility.PrepareFigure();
			hold(this.DisplayFacility.AxesHandle, 'on');
			switch(displayMode)
				case Source.Enum.RayDisplayMode.AbsolutePower
					colormap(cool(256));
					this.DisplayFacility.SetColorLimits([0,1]);
			end
			ray.Show(this.Logger, displayMode)
			extrema = Source.Geometry.Extrema.Zero();
			extrema.UpdateByExtrema(this.DisplayFacility.AxisLimits);
			extrema.UpdateByExtrema(ray.ToExtrema(this.Logger))
			extrema.UpdateToCube();
			this.DisplayFacility.SetAxisLimits(extrema);
			switch(displayMode)
				case Source.Enum.RayDisplayMode.AbsolutePower
					colorBar = colorbar('Ticks', linspace(0,1,11));
					colorBar.Color =...
						this.DisplayFacility.StyleSettings.ForegroundColor;
					colorBar.FontSize = this.DisplayFacility.StyleSettings...
					.LabelText.ExtendedFont.Size;
					colorBar.Label.String = 'relative power';
			end
			hold(this.DisplayFacility.AxesHandle, 'off');
			this.DisplayFacility.ShowFigure();
		end
		function plotHs = ShowRays(this, rays, unfinishedRayLength,...
				displayMode)
			if(~exist('unfinishedRayLength','var'))
				unfinishedRayLength = .5;
			end
			if(~exist('displayMode', 'var'))
				displayMode = Source.Enum.RayDisplayMode.MediumNameAndWaveType;
			end
			if(isempty(rays))
				return;
			end
			this.DisplayFacility.PrepareFigure();
			hold(this.DisplayFacility.AxesHandle, 'on');
			if(isa(rays, 'cell'))
				rays = Source.Helper.CellOfStructsWithRayStacks.ToArray(rays);
			end
			plotHs = arrayfun(@(ray) ray.Show(this.Logger,...
				displayMode, unfinishedRayLength), rays);
			extremas = arrayfun(@(ray) ray.ToExtrema(this.Logger,...
				unfinishedRayLength), rays);
			extrema = Source.Geometry.Extrema.Zero();
			extrema.UpdateByExtrema(this.DisplayFacility.AxisLimits);
			Source.Helper.List.ForEach(@(extremaValue)...
				extrema.UpdateByExtrema(extremaValue), extremas);
			extrema.UpdateToCube();
			this.DisplayFacility.SetAxisLimits(extrema);
			switch(displayMode)
				case Source.Enum.RayDisplayMode.AbsolutePower
					colorbarOpts = this.DisplayFacility.StyleSettings...
						.ColorbarOptions.copy();
					colorbarOpts.Ticks = linspace(0, 1, 11);
					labelTxt = Source.Display.Options.Text.FromStyle(...
					this.DisplayFacility.StyleSettings);
					labelTxt.String = 'relative power';
					labelTxt.Rotation = 270;
					labelTxt.HorizontalAlignment = Source.Enum.Alignment...
						.Horizontal.Center;
					labelTxt.VerticalAlignment = Source.Enum.Alignment...
						.Vertical.Bottom;
					colorbarOpts.Label = labelTxt;
					colorbarOpts.Tag = 'rays';
					axesHandle = this.DisplayFacility.ShowColorbar(colorbarOpts);
					colormap(axesHandle, cool(256));
					linesOptions = Source.Display.Options.Line.FromStyle(...
						this.DisplayFacility.StyleSettings);
					linesOptions(1).Color = Source.Enum.Color.Default.yellow;
					linesOptions(1).DisplayName = 'relative power';
					legendOptions = this.DisplayFacility.LegendOptions.copy();
					legendOptions.LinesOptions = linesOptions;
					legendOptions.Override = Source.Enum.Toggle.On;
					legendOptions.Location = Source.Enum.Location.North;
					this.DisplayFacility.LegendOptions = legendOptions;
				case Source.Enum.RayDisplayMode.MediumNameAndWaveType
					dispStr = @(mediumName, waveType) [' ' char(mediumName) ' - '...
						char(waveType)];
					legendOptions = this.DisplayFacility.LegendOptions.copy();
					linesOptions = Source.Helper.List.Unique(arrayfun(@(ray)...
						Source.Display.Options.Line.PresentationWithColorAndName(...
						ray.ToColorByMedium(), dispStr(ray.MediumName,...
						ray.WaveType)), rays));
					legendOptions.LinesOptions = linesOptions;
					legendOptions.Override = Source.Enum.Toggle.On;
					legendOptions.Location = Source.Enum.Location.North;
					this.DisplayFacility.LegendOptions = legendOptions;
			end
			hold(this.DisplayFacility.AxesHandle, 'off');
			switch(displayMode)
				case Source.Enum.RayDisplayMode.MediumNameAndWaveType
					this.DisplayFacility.ShowLegend();
				otherwise
					this.DisplayFacility.ShowFigure();
			end
		end
		function ShowMarker(this, positionPoint, lineOptions)
			if(~exist('lineOptions', 'var'))
				lineOptions = Source.Display.Options.Line.DefaultMarker();
			end
			lineOptionsCell = lineOptions.ToCell();
			this.DisplayFacility.PrepareFigure();
			hold(this.DisplayFacility.AxesHandle, 'on');
			line([positionPoint(1) positionPoint(1)],...
				[positionPoint(2) positionPoint(2)],...
				[positionPoint(3) positionPoint(3)], lineOptionsCell{:});
			hold(this.DisplayFacility.AxesHandle, 'off');
			this.DisplayFacility.ShowFigure();
		end
		function handle = ShowMarkers(this, varargin)
			fn = @() this.showMarkers(varargin{:});
			this.withPreparation(fn);
			handle = this.Handle;
		end
		function ShowTexts(this, positions, texts, options)
			fn = @() this.showTexts(positions, texts, options);
			this.withPreparation(fn);
		end
		function ShowTextMarkers(this, positions, markerText, options)
			fn = @() this.showTextMarkers(positions, markerText, options);
			this.withPreparation(fn);
		end
		function ShowTriangleSurfaceMeshData(this, triangleSurfaceMeshData)
			input.Nodes = triangleSurfaceMeshData.Nodes;
			input.ElementIndices = triangleSurfaceMeshData.ElementIndices;
			input.Color = triangleSurfaceMeshData.Color;
			this.ShowMesh(input);
		end
		function ShowTriangleSurfaceMeshNorms(this, triangleSurfaceMesh, func)
			incenters = triangleSurfaceMesh.GetIncenters();
			this.DisplayFacility.PrepareFigure();
			hold(this.DisplayFacility.AxesHandle, 'on');
			for indexElement = 1:length(triangleSurfaceMesh.TriangleElements)
				incenter = incenters(indexElement,:);
				outwardNormalVector = triangleSurfaceMesh...
					.OutwardNormalVectors(indexElement,:);
				endpoint = func(incenter,...
					Source.Display.MeshProjector.NORM_LENGTH*outwardNormalVector);
				line([incenter(1) endpoint(1)],[incenter(2) endpoint(2)],...
					[incenter(3) endpoint(3)], 'color', 'y');
				line([incenter(1) incenter(1)], [incenter(2) incenter(2)],...
					[incenter(3) incenter(3)], 'LineWidth', 2,...
					'MarkerSize', 2, 'Marker','V',...
					'Color','red');
			end
			hold(this.DisplayFacility.AxesHandle, 'off');
			this.DisplayFacility.ShowFigure();
		end
		function handle = Surface(this, x, y, z, surfaceOptions)
			Source.Helper.Assert.IsOfType(surfaceOptions,...
				Source.Display.Options.Surface.CLASS_NAME, 'surfaceOptions');
			fn = @() this.surface(x, y, z, surfaceOptions);
			this.withPreparation(fn);
			handle = this.Handle;
		end
		function handle = SurfC(this, x, y, z, options)
			fn = @() this.surfc(x, y, z, options);
			this.withPreparation(fn);
			handle = this.Handle;
		end
		function handle = Contour(this, x, y, z, contourOptions)
			Source.Helper.Assert.IsOfType(contourOptions,...
				Source.Display.Options.Contour.CLASS_NAME, 'contourOptions');
			fn = @() this.contour(x, y, z, contourOptions);
			this.withPreparation(fn);
			handle = this.Handle;
		end
		function handle = ContourF(this, x, y, z, contourOptions)
			Source.Helper.Assert.IsOfType(contourOptions,...
				Source.Display.Options.Contour.CLASS_NAME, 'contourOptions');
			fn = @() this.contourF(x, y, z, contourOptions);
			this.withPreparation(fn);
			handle = this.Handle;
		end
		function handle = Quiver3(this, x, y, z, u, v, w, quiverOptions)
			Source.Helper.Assert.IsOfType(quiverOptions,...
				Source.Display.Options.Quiver.CLASS_NAME, 'quiverOptions');
			fn = @() this.quiver3(x, y, z, u, v, w, quiverOptions);
			this.withPreparation(fn);
			handle = this.Handle;
		end
		function handle = ImageSc(this, varargin)
			fn = @() this.imagesc(varargin{:});
			this.withPreparation(fn);
			handle = this.Handle;
		end
		function handle = Text(this, varargin)
			textOptions = this.getTextOptions(varargin);
			Source.Helper.Assert.IsOfType(textOptions,...
				Source.Display.Options.Text.CLASS_NAME, 'textOptions');
			fn = @() this.text(textOptions);
			this.withPreparation(fn);
			handle = this.Handle;
		end
	end
	methods(Access = protected, Static)
		function plotLine(startPoint, endPoint, lineOptions, lineOptionsCell)
			%% TODO use patch everywhere.
			h = line([startPoint(1) endPoint(1)], [startPoint(2) endPoint(2)],...
					[startPoint(3) endPoint(3)], lineOptionsCell{:});
			h.Annotation.LegendInformation.IconDisplayStyle =...
					char(lineOptions.IncludeInLegend);
		end
		function showTexts(positions, texts, options)
			if(length(options)==size(positions,1))
				textOptions = arrayfun(@(option) option.ToCell(), options,...
					'UniformOutput', false);
			else
				textOptions = repmat(options.ToCell(), size(positions,1),1);
			end
			if(size(positions,2) == 3)
				for indexText = 1:length(texts)
					textOption = textOptions(indexText,:);
					for i = 1:3
						textOption{i} = positions(indexText, i);
					end
					text(textOption{1:3}, texts{indexText}, textOption{4:end});
				end
			else
				for indexText = 1:length(texts)
					textOption = textOptions(indexText,:);
					for i = 1:2
						textOption{i} = positions(indexText, i);
					end
					textOption(3) = [];
					text(textOption{1:2}, texts{indexText}, textOption{3:end});
				end
			end
		end
		function showTextMarkers(positions, markerText, options)
			nOfPositions = size(positions, 1);
			textOptions = options.ToCell();
			if(size(positions, 2) == 3)
				for iPosition = 1:nOfPositions
					text(positions(iPosition, 1), positions(iPosition, 2),...
						positions(iPosition, 3), markerText, textOptions{:});
				end
			else
				for iPosition = 1:nOfPositions
					text(positions(iPosition, 1), positions(iPosition, 2),...
						markerText, textOptions{:});
				end
			end
		end
	end
	methods(Access = protected)
		function this = MeshProjector()
		end
		function withPreparation(this, fn)
			this.DisplayFacility.PrepareFigure();
			hold(this.DisplayFacility.AxesHandle, 'on');
			fn();
			hold(this.DisplayFacility.AxesHandle, 'off');
			this.DisplayFacility.ShowFigure();
		end
		function showLine(this, startPoint, endPoint, varargin)
			lineOptions = this.getLineOptions(varargin);
			lineOptionsCell = lineOptions.ToCell();
			h = line([startPoint(1) endPoint(1)], [startPoint(2) endPoint(2)],...
					[startPoint(3) endPoint(3)], lineOptionsCell{:});
			h.Annotation.LegendInformation.IconDisplayStyle =...
					char(lineOptions.IncludeInLegend);
			if(length(varargin) >= 2)
				label = varargin{2};
				midPoint = (endPoint + startPoint)/2;
				lineDirection = endPoint - startPoint;
				mid2text = Source.Geometry.Vec3.PerpendicularDirection(...
					lineDirection);
				midTextDistance = Source.Geometry.Vec3.Distance(startPoint,...
					endPoint)/4;
				if(midTextDistance == 0)
					midTextDistance = 0.1;
				end
				if(length(varargin) == 3)
					midTextDistance = varargin{3};
				end
				textPoint = midPoint + midTextDistance*mid2text;
				labelText = this.DisplayFacility.StyleSettings.LabelText.copy();
				labelText.HorizontalAlignment =...
					Source.Enum.Alignment.Horizontal.Left;
				labelText.String = ['   ' char(label)];
				labelTextCell = labelText.ToCell();
				text(textPoint(1), textPoint(2), textPoint(3), labelTextCell{:});
			end
		end
		function showExtrema(this, extrema, varargin)
			patchOptions = this.getPatchOptions(varargin);
			this.Handle = extrema.ShowDebug(patchOptions);
		end
		function markExtrema(this, extrema, varargin)
			lineOptions = this.getLineOptions(varargin);
			extrema.ShowMarker(lineOptions);
		end
		function showCylinder(this, cylinder, height, varargin)
			patchOptions = this.getPatchOptions(varargin);
			cylinder.ShowDebug(height, patchOptions);
		end
		function showArbitraryCylinder(this, center, radius,...
				height, varargin)
			patchOptions = this.getPatchOptions(varargin);
			this.Handle = Source.Geometry.Cylinder.Show(center, radius,...
				height, patchOptions);
		end
		function showPlane(this, plane, w, h, varargin)
			patchOptions = this.getPatchOptions(varargin);
			this.Handle = plane.ShowDebug(w, h, patchOptions);
		end
		function showArbitraryPlane(this, center, direction, w, h, varargin)
			patchOptions = this.getPatchOptions(varargin);
			this.Handle = Source.Geometry.Plane.Show(center, direction, w, h,...
				patchOptions);
		end
		function showCircleOnPlane(this, direction, x, y, radius, varargin)
			lineOptions = this.getLineOptions(varargin);
			this.Handle = Source.Geometry.Plane.ShowCircle(direction,...
				x, y, radius, lineOptions);
		end
		function showEllipseOnPlane(this, normal, translation,...
			 x1, y1, x2, y2, ecc, scaling, varargin)
			lineOptions = this.getLineOptions(varargin);
			this.Handle = Source.Geometry.Plane.ShowEllipse(normal,...
				 translation, x1, y1, x2, y2, ecc, scaling, lineOptions);
		end
		function showMarkers(this, points, varargin)
			patchOptions = this.getPatchOptions(varargin);
			patchOptions.EdgeColor = Source.Enum.Color.Edge.none;
			patchOptions.XData = points(:,1);
			patchOptions.YData = points(:,2);
			patchOptions.ZData = points(:,3);
			this.patch(patchOptions);
		end
		function showMesh(this, mesh, varargin)
			patchOptions = this.getPatchOptions(varargin);
			this.Handle = mesh.ShowDebug(patchOptions);
		end
		function showArbitraryMesh(this, mesh, varargin)
			patchOptions = this.getPatchOptions(varargin);
			this.Handle = Source.Geometry.TriangleSurfaceMesh.Show(...
				mesh, patchOptions);
		end
		function showTopology(this, topology, planeWidth,...
				planeHeight, varargin)
			patchOptions = this.getPatchOptions(varargin);
			this.HandlesMap = topology.ShowDebug(planeWidth, planeHeight,...
				patchOptions);
		end
		function showTransducer(this, transducer, focusDiameter,...
				focusPosition, varargin)
			if(isempty(varargin))
				lineOptionsList = arrayfun(@() this.DisplayFacility.LineOptions...
					.copy(), 1:length(transducer.ElementPositions));
			else
				lineOptionsList = varargin{1};
			end
			if(isempty(varargin) || length(varargin) == 1)
				patchOptionsList = arrayfun(@(nu) this.DisplayFacility...
					.PatchOptions.copy(), 1:2);
			else
				patchOptionsList = varargin{2};
			end
			this.Handle = transducer.ShowDebug(focusDiameter,...
				focusPosition, lineOptionsList, patchOptionsList);
		end
		function showTriangleElement(this, triangleElement, varargin)
			patchOptions = this.getPatchOptions(varargin);
			patchOptions.Vertices = [triangleElement.PointA;...
				triangleElement.PointB;...
				triangleElement.PointC];
			patchOptions.Faces = [1 2 3];
			patchOptionsCell = patchOptions.ToCell();
			patch(patchOptionsCell{:});
		end
		function showTriangleElementZoomed(this, triangleElement, varargin)
			patchOptions = this.getPatchOptions(varargin);
			patchOptions.Vertices = [triangleElement.PointA;...
				triangleElement.PointB;...
				triangleElement.PointC];
			patchOptions.Faces = [1 2 3];
			patchOptionsCell = patchOptions.ToCell();
			patch(patchOptionsCell{:});
			extrema = triangleElement.ToExtrema();
			extrema.UpdateToCube();
			this.DisplayFacility.SetAxisLimits(extrema);
		end
		function textOptions = getTextOptions(this, argument)
			if(isempty(argument))
				textOptions = this.DisplayFacility.StyleSettings.LabelText;
			else
				textOptions = argument{1};
			end
		end
		function patchOptions = getPatchOptions(this, argument)
			if(isempty(argument))
				patchOptions = this.DisplayFacility.PatchOptions.copy();
			else
				patchOptions = argument{1};
			end
		end
		function lineOptions = getLineOptions(this, argument)
			if(isempty(argument))
				lineOptions = this.DisplayFacility.LineOptions.copy();
			else
				lineOptions = argument{1};
			end
		end
		function patch(this, patchOptions)
			patchOptionsCell = patchOptions.ToCell();
			this.Handle = patch(patchOptionsCell{:});
			this.Handle.Annotation.LegendInformation.IconDisplayStyle =...
					char(patchOptions.IncludeInLegend);
		end
		function surface(this, x, y, z, surfaceOptions)
			surfaceOptionsCell = surfaceOptions.ToCell();
			this.Handle = surface(x, y, z, surfaceOptionsCell{:});
		end
		function surfc(this, x, y, z, options)
			optionsCell = options.ToCell();
			this.Handle = surfc(x, y, z, optionsCell{:});
		end
		function contour(this, x, y, z, contourOptions)
			contourOptionsCell = contourOptions.ToCell();
			this.Handle = contour(x, y, z, contourOptionsCell{:});
		end
		function contourF(this, x, y, z, contourOptions)
			contourOptionsCell = contourOptions.ToCell();
			this.Handle = contourf(x, y, z, contourOptionsCell{:});
		end
		function quiver3(this, x, y, z, u, v, w, quiverOptions)
			quiverOptionsCell = quiverOptions.ToCell();
			this.Handle = quiver3(x, y, z, u, v, w, quiverOptionsCell{:});
		end
		function imagesc(this, imageOptions)
			imageOptionsCell = imageOptions.ToCell();
			this.Handle = imagesc(imageOptionsCell{:});
		end
		function text(this, textOptions)
			textOptionsCell = textOptions.ToCell();
			this.Handle = text(textOptionsCell{:});
		end
	end
end