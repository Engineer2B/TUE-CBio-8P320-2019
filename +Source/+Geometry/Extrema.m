classdef Extrema < handle
	properties(SetAccess = immutable)
		X
		Y
		Z
		Minimum
		Maximum
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Geometry:Extrema:'
		CLASS_NAME = 'Source.Geometry.Extrema'
	end
	methods(Access = public, Static)
		function obj = New(x, y, z)
			obj = Source.Geometry.Extrema(x, y, z);
		end
		function obj = Inf()
			infExtremum = Source.Geometry.Extremum.Inf();
			obj = Source.Geometry.Extrema(infExtremum, infExtremum,...
				infExtremum);
		end
		function obj = Zero()
			zeroExtremum = Source.Geometry.Extremum.Zero();
			obj = Source.Geometry.Extrema(zeroExtremum, zeroExtremum,...
				zeroExtremum);
		end
		function obj = FromAxisLimits(axisLimits)
			xLim = Source.Geometry.Extremum.New(axisLimits(1), axisLimits(2));
			yLim = Source.Geometry.Extremum.New(axisLimits(3), axisLimits(4));
			zLim = Source.Geometry.Extremum.New(axisLimits(5), axisLimits(6));
			obj = Source.Geometry.Extrema(xLim, yLim, zLim);
		end
		function obj = FromTwoPoints(point1, point2)
			xExtremum = Source.Geometry.Extremum.New(...
				min([point1(1) point2(1)]),...
				max([point1(1) point2(1)]));
			yExtremum = Source.Geometry.Extremum.New(...
				min([point1(2) point2(2)]),...
				max([point1(2) point2(2)]));
			zExtremum = Source.Geometry.Extremum.New(...
				min([point1(3) point2(3)]),...
				max([point1(3) point2(3)]));
			obj = Source.Geometry.Extrema.New(xExtremum,yExtremum,zExtremum);
		end
		function obj = FromMatrixLx3(matrix)
			xPoints = matrix(:,1);
			yPoints = matrix(:,2);
			zPoints = matrix(:,3);
			xExtremum = Source.Geometry.Extremum.New(...
				min(xPoints), max(xPoints));
			yExtremum = Source.Geometry.Extremum.New(...
				min(yPoints), max(yPoints));
			zExtremum = Source.Geometry.Extremum.New(...
				min(zPoints), max(zPoints));
			obj = Source.Geometry.Extrema(xExtremum, yExtremum, zExtremum);
		end
		function obj = FromMatrixLx2(matrix)
			xPoints = matrix(:,1);
			yPoints = matrix(:,2);
			xExtremum = Source.Geometry.Extremum.New(...
				min(xPoints), max(xPoints));
			yExtremum = Source.Geometry.Extremum.New(...
				min(yPoints), max(yPoints));
			zExtremum = Source.Geometry.Extremum.New(...
				min([xPoints; yPoints]), max([xPoints; yPoints]));
			obj = Source.Geometry.Extrema(xExtremum, yExtremum, zExtremum);
		end
		function obj = FromDTO(dto)
			xExtremum = Source.Geometry.Extremum.FromDTO(dto.X);
			yExtremum = Source.Geometry.Extremum.FromDTO(dto.Y);
			zExtremum = Source.Geometry.Extremum.FromDTO(dto.Z);
			obj = Source.Geometry.Extrema(xExtremum, yExtremum, zExtremum);
		end
		function obj = FromRays(rays, logger)
			obj = Source.Geometry.Extrema.Zero();
			for inRay = 1:length(rays)
				obj.UpdateByExtrema(rays(inRay).ToExtrema(logger));
			end
		end
	end
	methods(Access = public)
		function handle = ShowDebug(this, patchOptions)
			patchOptions.Vertices = [this.X.Min, this.Y.Min, this.Z.Min%1
				this.X.Min, this.Y.Min, this.Z.Max%2
				this.X.Min, this.Y.Max, this.Z.Min%3
				this.X.Min, this.Y.Max, this.Z.Max%4
				this.X.Max, this.Y.Min, this.Z.Min%5
				this.X.Max, this.Y.Min, this.Z.Max%6
				this.X.Max, this.Y.Max, this.Z.Min%7
				this.X.Max, this.Y.Max, this.Z.Max];%8
			patchOptions.Faces = [ 1 5 6 2; 7 8 4 3; 5 7 8 6; 1 3 4 2
				1 3 7 5;2 4 8 6];
			patchOptionsCell = patchOptions.ToCell();
			handle = patch(patchOptionsCell{:});
		end
		function ShowMarker(this, lineOptions)
			vertices = [this.X.Min, this.Y.Min, this.Z.Min%1
				this.X.Min, this.Y.Min, this.Z.Max%2
				this.X.Min, this.Y.Max, this.Z.Min%3
				this.X.Min, this.Y.Max, this.Z.Max%4
				this.X.Max, this.Y.Min, this.Z.Min%5
				this.X.Max, this.Y.Min, this.Z.Max%6
				this.X.Max, this.Y.Max, this.Z.Min%7
				this.X.Max, this.Y.Max, this.Z.Max];%8
			lineOptionsCell = lineOptions.ToCell();
			for indexVertex = 1:size(vertices,1)
				line([vertices(indexVertex,1) vertices(indexVertex,1)],...
					[vertices(indexVertex,2) vertices(indexVertex,2)],...
					[vertices(indexVertex,3) vertices(indexVertex,3)],...
					lineOptionsCell{:});
			end
		end
		function Show(this, lineOptions)
			lineOptionsCell = lineOptions.ToCell();
			% line 1
			line([this.X.Min this.X.Max],...
				[this.Y.Min this.Y.Min],...
				[this.Z.Min this.Z.Min],...
				lineOptionsCell{:});
			% line 2
			line([this.X.Min this.X.Max],...
				[this.Y.Min this.Y.Min],...
				[this.Z.Max this.Z.Max],...
				lineOptionsCell{:});
			% line 3
			line([this.X.Min this.X.Max],...
				[this.Y.Max this.Y.Max],...
				[this.Z.Min this.Z.Min],...
				lineOptionsCell{:});
			% line 4
			line([this.X.Min this.X.Max],...
				[this.Y.Max this.Y.Max],...
				[this.Z.Max this.Z.Max],...
				lineOptionsCell{:});
			% line 5
			line([this.X.Min this.X.Min],...
				[this.Y.Min this.Y.Min],...
				[this.Z.Min this.Z.Max],...
				lineOptionsCell{:});
			% line 6
			line([this.X.Max this.X.Max],...
				[this.Y.Min this.Y.Min],...
				[this.Z.Min this.Z.Max],...
				lineOptionsCell{:});
			% line 7
			line([this.X.Min this.X.Min],...
				[this.Y.Max this.Y.Max],...
				[this.Z.Min this.Z.Max],...
				lineOptionsCell{:});
			% line 8
			line([this.X.Max this.X.Max],...
				[this.Y.Max this.Y.Max],...
				[this.Z.Min this.Z.Max],...
				lineOptionsCell{:});
			% line 9
			line([this.X.Min this.X.Min],...
				[this.Y.Min this.Y.Max],...
				[this.Z.Min this.Z.Min],...
				lineOptionsCell{:});
			% line 10
			line([this.X.Max this.X.Max],...
				[this.Y.Min this.Y.Max],...
				[this.Z.Min this.Z.Min],...
				lineOptionsCell{:});
			% line 11
			line([this.X.Min this.X.Min],...
				[this.Y.Min this.Y.Max],...
				[this.Z.Max this.Z.Max],...
				lineOptionsCell{:});
			% line 12
			line([this.X.Max this.X.Max],...
				[this.Y.Min this.Y.Max],...
				[this.Z.Max this.Z.Max],...
				lineOptionsCell{:});
		end
		function UpdateByExtrema(this, otherExtrema)
			if(isa(otherExtrema, 'double'))
				return;
			end
			this.X.UpdateByExtremum(otherExtrema.X);
			this.Y.UpdateByExtremum(otherExtrema.Y);
			this.Z.UpdateByExtremum(otherExtrema.Z);
		end
		function UpdateByPoint(this, point)
			this.X.UpdateByValue(point.X);
			this.Y.UpdateByValue(point.Y);
			this.Z.UpdateByValue(point.Z);
		end
		function UpdateUniformlyByPoint(this, point)
			this.UpdateByValue(point.X);
			this.UpdateByValue(point.Y);
			this.UpdateByValue(point.Z);
		end
		function UpdateByValue(this, value)
			this.X.UpdateByValue(value);
			this.Y.UpdateByValue(value);
			this.Z.UpdateByValue(value);
		end
		function UpdateToCube(this)
			maxDistance = this.maxDistance();
			this.X.StretchToDistance(maxDistance);
			this.Y.StretchToDistance(maxDistance);
			this.Z.StretchToDistance(maxDistance);
		end
		function axisLimits = ToAxisLimits(this)
			axisLimits = [this.X.Min this.X.Max this.Y.Min this.Y.Max...
				this.Z.Min this.Z.Max];
		end
		function displayString = ToDisplayString(this, distanceUnit,...
				roundingDigits)
			displayString = [Source.Geometry.Vec3.ToDisplayString(...
				this.Minimum, 'r', 'min', distanceUnit, roundingDigits) ' '...
				Source.Geometry.Vec3.ToDisplayString(this.Maximum, 'r',...
				'max', distanceUnit, roundingDigits)];
		end
		function Widen(this, addedDistance)
			this.X.Widen(addedDistance(1));
			this.Y.Widen(addedDistance(2));
			this.Z.Widen(addedDistance(3));
		end
		function filtRays = FilterRays(this, rays)
			filtRays = Source.Helper.List.Filter(@(ray) Source.Geometry...
				.Intersection.Box.WithRayAndExtrema(ray, this)...
				.EntryDistance ~= Inf, rays);
		end
		function raySegments = GetRaySegments(this, rays, threshold)
			filtRays = this.FilterRays(rays);
			intersectionResults  = arrayfun(@(ray) Source.Geometry...
				.Intersection.Box.WithRayAndExtrema(ray, this), filtRays);
			raySegments = Shim.Physics.GRay_S.empty(length(...
				intersectionResults), 0);
			for inResult = 1:length(intersectionResults)
				intersectionResult = intersectionResults(inResult);
				ray = filtRays(inResult);
				if(intersectionResult.EntryDistance < 0)
					intersectionResult.EntryDistance = 0;
				end
				if(intersectionResult.ExitDistance > ray.TravelDistance)
					intersectionResult.ExitDistance = ray.TravelDistance;
				end
				origin = ray.Origin+(ray.Direction*intersectionResult...
						.EntryDistance);
				raySegments(inResult) = Shim.Physics.GRay_S.Test(origin,...
					ray.Direction);
				raySegments(inResult).InitialPower = ray.InitialPower;
				segmentDistance = intersectionResult.ExitDistance-...
					intersectionResult.EntryDistance;
				min2Attenuation = log(ray.EndPower/ray.InitialPower)/...
					ray.TravelDistance;
% 				fprintf('medium: %s min2attenuation: %f\n', ray.MediumName,...
% 					min2Attenuation);
				raySegments(inResult).SetEndPointAndEndPower(segmentDistance,...
					min2Attenuation, threshold);
				raySegments(inResult).MediumName = ray.MediumName;
				raySegments(inResult).WaveType = ray.WaveType;
				k = (ray.EndPhase-ray.InitialPhase)/ray.TravelDistance;
				raySegments(inResult).InitialPhase = ray.InitialPhase +...
					intersectionResult.EntryDistance*k;
				raySegments(inResult).EndPhase = raySegments(inResult)...
					.InitialPhase + raySegments(inResult).TravelDistance*k;
			end
		end
		function extremaCopy = Copy(this)
			extremaCopy = Source.Geometry.Extrema(this.X, this.Y, this.Z);
		end
		function isEqual = ApproxEqualTo(this, that, tolerance)
			isEqual = this.X.ApproxEqualTo(that.X, tolerance) &&...
				this.Y.ApproxEqualTo(that.Y, tolerance) &&...
				this.Z.ApproxEqualTo(that.Z, tolerance);
		end
		function isEqual = eq(this, that)
			isEqual = this.X == that.X &&...
				this.Y == that.Y &&...
				this.Z == that.Z;
		end
		function notEqual = ne(this, that)
			notEqual = this.X ~= that.X ||...
				this.Y ~= that.Y || this.Z ~= that.Z;
		end
		function dto = ToDTO(this)
			dto.X = this.X.ToDTO();
			dto.Y = this.Y.ToDTO();
			dto.Z = this.Z.ToDTO();
		end
	end
	methods(Access = protected)
		function this = Extrema(x, y, z)
			Source.Helper.Assert.IsOfType(x, 'Source.Geometry.Extremum', 'x');
			Source.Helper.Assert.IsOfType(y, 'Source.Geometry.Extremum', 'y');
			Source.Helper.Assert.IsOfType(z, 'Source.Geometry.Extremum', 'z');
			this.X = x.Copy();
			this.Y = y.Copy();
			this.Z = z.Copy();
			this.Minimum = this.toMinimum();
			this.Maximum = this.toMaximum();
		end
		function maxDistance = maxDistance(this)
			maxDistance = max([this.X.Distance(), this.Y.Distance(),...
				this.Z.Distance()]);
		end
		function minimalPoint = toMinimum(this)
			minimalPoint = [this.X.Min, this.Y.Min, this.Z.Min];
		end
		function maximalPoint = toMaximum(this)
			maximalPoint = [this.X.Max, this.Y.Max, this.Z.Max];
		end
	end
end

