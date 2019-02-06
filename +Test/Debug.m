classdef Debug
	methods(Static)
		function LatticeIntersection(latticeOptions, ray, distances,...
				entryDistance, exitDistance)
			latticeOptions_S = Shim.Geometry.LatticeOptions_S...
				.FromLatticeOptions(latticeOptions);
			logger = Source.Logging.Logger.Default();
			styleSettings = Source.Display.StyleSettings.Presentation();
			axesLabel = Source.Display.AxesLabel.Geometry('m');
			displayFacility = Source.Display.DisplayFacility.New(logger,...
				styleSettings, 'cube example', axesLabel);
			displayFacility.NoShow = true;
			cubeProjector = Source.Display.MeshProjector.New(displayFacility,...
				logger);
			% Plot the grid.
			latticeOptions_S.ShowExtremas(cubeProjector);
			outerPatchOptions = Source.Display.Options.Patch.New();
			cubeProjector.ShowExtrema(latticeOptions.Extrema, outerPatchOptions);
			% Plot the grid entry points
			entry = ray.Origin + entryDistance * ray.Direction;
			exit = ray.Origin + exitDistance * ray.Direction;
			entryMarkerO = Source.Display.Options.Line.DefaultMarker();
			entryMarkerO.Color = Source.Enum.Color.Default.green;
			entryMarkerO.Marker = Source.Enum.Marker.LeftPointingTriangle;
			entryMarkerO.MarkerSize = 20;
			exitMarkerO = Source.Display.Options.Line.DefaultMarker();
			exitMarkerO.Color = Source.Enum.Color.Default.blue;
			exitMarkerO.Marker = Source.Enum.Marker.LeftPointingTriangle;
			exitMarkerO.MarkerSize = 20;
			cubeProjector.ShowMarker(entry, entryMarkerO);
			cubeProjector.ShowMarker(exit, exitMarkerO);
			% Plot the ray.
			cubeProjector.ShowLine(ray.Origin, ray.EndPoint);
			originMarkerO = Source.Display.Options.Line.DefaultMarker();
			originMarkerO.Color = Source.Enum.Color.Default.green;
			originMarkerO.Marker = Source.Enum.Marker.Square;
			originMarkerO.MarkerSize = 20;
			originMarkerE = Source.Display.Options.Line.DefaultMarker();
			originMarkerE.Color = Source.Enum.Color.Default.blue;
			originMarkerE.Marker = Source.Enum.Marker.Square;
			originMarkerE.MarkerSize = 20;
			cubeProjector.ShowMarker(ray.Origin, originMarkerO);
			cubeProjector.ShowMarker(ray.EndPoint, originMarkerE);
			if exist('distances', 'var')
				% Plot markers of expected intersections.
				markerOptions = Source.Display.Options.Line.DefaultMarker();
				markerOptions.Marker = Source.Enum.Marker.Cross;
				markerOptions.Color = Source.Enum.Color.Default.r;
				markerOptions.MarkerSize = 10;
				for indexIntersection = 1:length(distances)
					cubeProjector.ShowMarker(ray.Origin+distances(...
						indexIntersection)*ray.Direction, markerOptions);
				end
				positions = zeros(length(distances)-1,3);
				for indexDistance = 1:length(distances)-1
					distance1 = distances(indexDistance);
					distance2 = distances(indexDistance+1);
					distance12 = distance1 + (distance2-distance1)/2;
					position = ray.Origin + distance12*ray.Direction;
					positions(indexDistance,:) = position;
				end
				latticeOptions_S.ShowCubeAtPositions(cubeProjector, positions);
				markerOptions.Marker = Source.Enum.Marker.Circle;
				markerOptions.Color = Source.Enum.Color.Default.white;
				cubeProjector.ShowMarkers(positions, markerOptions);
			end
			displayFacility.NoShow = false;
			limits = latticeOptions.Extrema.Copy();
			limits.Widen([0.2 0.2 0.2]);
			displayFacility.SetAxisLimits(limits);
		end
	end
end

