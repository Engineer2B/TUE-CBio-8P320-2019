classdef GRay < handle
	%RAY Describes a generic ray traveling in a medium.
	properties
		% The name of the medium that the ray is travelling in.
		%  See also Source.Enum.MediumName.
		MediumName
		% The type of wave, longitudinal or shear.
		% See also Source.Enum.WaveType.
		WaveType
		% The position of the origin of the ray.
		Origin
		% The direction of the ray.
		Direction
		InitialPhase
		Polarisation
		InitialPower
		% The position of the end point of the ray.
		EndPoint
		% Phases are in radians.
		EndPhase
		EndPower
		TravelDistance
	end
	properties(Constant, Access = protected)
		p_MediumToColor
	end
  properties(Dependent)
		 Medium
   end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Physics:GRay:'
		CLASS_NAME = 'Source.Physics.GRay'
		MSG_NOENDPOINT = 'Ray doesn''t have an endpoint yet.'
	end
	methods
		function medium = get.Medium(this)
			medium.Name = Source.Enum.MediumName(this.MediumName);
		end
	end
	methods(Access = public, Static)
		function obj = New(origin, direction, medium, waveType,...
				initialPhase, initialPower, polarisation)
			obj = Source.Physics.GRay();
			obj.Origin = origin;
			obj.Direction = Source.Geometry.Vec3.Normalize(direction);
			obj.MediumName = medium.Name;
			obj.WaveType = Source.Enum.WaveType(waveType);
			obj.InitialPhase = initialPhase;
			obj.InitialPower = initialPower;
			if(waveType == Source.Enum.WaveType.Shear)
				obj.Polarisation = Source.Geometry.Vec3.Normalize(polarisation);
			end
		end
		function obj = Initial(origin, direction, initialPhase,...
				initialPower)
			medium.Name = 'Markoil';
			obj = Source.Physics.GRay.New(origin,...
				Source.Geometry.Vec3.Normalize(direction),...
				medium,...
				Source.Enum.WaveType.Longitudinal,...
				initialPhase, initialPower, [0 0 0]);
		end
		function obj = FromDTO(dto)
			obj = Source.Physics.GRay();
			obj.Origin = dto.Origin;
			obj.Direction = Source.Geometry.Vec3.Normalize(dto.Direction);
			obj.MediumName = dto.MediumName;
			obj.WaveType = Source.Enum.WaveType(dto.WaveType);
			obj.InitialPhase = dto.InitialPhase;
			obj.InitialPower = dto.InitialPower;
			if(dto.WaveType == Source.Enum.WaveType.Shear)
				obj.Polarisation = Source.Geometry.Vec3.Normalize(...
					dto.Polarisation);
			end
			obj.EndPoint = dto.EndPoint;
			obj.EndPhase = dto.EndPhase;
			obj.EndPower = dto.EndPower;
			obj.TravelDistance = dto.TravelDistance;
		end
		function power = GetPowerByDistance(beginPower, min2Attenuation,...
				distance)
			power = beginPower*exp(min2Attenuation * distance);
		end
	end
	methods(Access = public)
		function copyRay = Copy(this)
			copyRay = Source.Physics.GRay.FromDTO(this.ToDTO());
		end
		function dto = ToDTO(this)
			dto.Direction = this.Direction;
			dto.MediumName = this.MediumName;
			dto.WaveType = double(this.WaveType);
			dto.Origin = this.Origin;
			dto.InitialPhase = this.InitialPhase;
			dto.InitialPower = this.InitialPower;
			dto.EndPoint = this.EndPoint;
			dto.EndPhase = this.EndPhase;
			dto.EndPower = this.EndPower;
			dto.Polarisation = this.Polarisation;
			dto.TravelDistance = this.TravelDistance;
		end
		function location = GetLocation(this, distance)
			location = this.Origin + distance * this.Direction;
		end
		function SetEndPointAndEndPower(this, distance, min2Attenuation,...
				powerThreshold)
			if(distance == Inf)
				[distance, min2Attenuation] = this.getDistanceByPower(...
					min2Attenuation, powerThreshold);
				this.setEndPower(min2Attenuation, distance);
			else
				this.setEndPower(min2Attenuation, distance);
				if(this.EndPower < powerThreshold)
					[distance, min2Attenuation] =...
						this.getDistanceByPower(min2Attenuation, powerThreshold);
					this.setEndPower(min2Attenuation, distance);
				end
			end
			this.setEndPoint(distance);
			this.TravelDistance = distance;
		end
		function SetEndPhase(this, frequencyPerSpeed)
			this.EndPhase = this.getPhase(this.TravelDistance, frequencyPerSpeed);
		end
		function meshProjector = ShowDebug(this, meshProjector,...
				unfinishedRayLength)
			if(~exist('meshProjector','var'))
				meshProjector = Source.Display.MeshProjector.Default();
			end
			if(isempty(this.EndPoint))
				if(~exist('unfinishedRayLength','var'))
					unfinishedRayLength = .5;
				end
				endPoint = this.Origin + this.Direction*unfinishedRayLength;
				meshProjector.DisplayFacility.Logger.Log(...
					"Ray doesn't have an endpoint yet", '');
			else
				endPoint = this.EndPoint;
			end
			lineOptions = meshProjector.DisplayFacility.LineOptions;
			lineOptions.Color = this.ToColorByMedium();
			meshProjector.ShowLine(this.Origin, endPoint, lineOptions,...
				this.MediumName);
			lineOptions.Marker = Source.Enum.Marker.Circle;
			meshProjector.ShowLine(this.Origin, this.Origin, lineOptions);
			lineOptions.Marker = Source.Enum.Marker.Cross;
			meshProjector.ShowLine(endPoint, endPoint, lineOptions);
		end
		function plotH = Show(this, logger, displayMode, unfinishedRayLength)
			if(isempty(this.EndPoint))
				if(~exist('unfinishedRayLength','var'))
					unfinishedRayLength = .5;
				end
				endPoint = this.Origin + this.Direction*unfinishedRayLength;
				logger.Log(this.MSG_NOENDPOINT, this.MSG_NOENDPOINT);
				endPower = 0;
			else
				endPoint = this.EndPoint;
				endPower = this.EndPower;
			end
			switch(displayMode)
				case Source.Enum.RayDisplayMode.AbsolutePower
					n = 256;
					if(this.InitialPower == endPower)
						cVals = linspace(this.InitialPower,...
							this.InitialPower, n);
					else
						cVals = linspace(this.InitialPower, endPower, n);
					end
					% From https://nl.mathworks.com/matlabcentral/answers/
					%254696-how-to-assign-gradual-color-to-a-3d-line-based-
					%on-values-of-another-vector
					X = linspace(this.Origin(1), endPoint(1), n);
					Y = linspace(this.Origin(2), endPoint(2), n);
					Z = linspace(this.Origin(3), endPoint(3), n);
					plotH = patch([X NaN], [Y NaN], [Z NaN], [cVals NaN],...
						'FaceColor','none',...
						'EdgeColor','interp',...
						'LineWidth', 1);
				case Source.Enum.RayDisplayMode.MediumNameAndWaveType
					plotH = line([this.Origin(1) endPoint(1)],...
						[this.Origin(2) endPoint(2)],...
						[this.Origin(3) endPoint(3)],...
						'LineWidth', 1, 'Color', this.ToColorByMedium());
				case Source.Enum.RayDisplayMode.WaveType
					plotH = line([this.Origin(1) endPoint(1)],...
						[this.Origin(2) endPoint(2)],...
						[this.Origin(3) endPoint(3)],...
						'LineWidth', 1, 'Color', char(this.WaveType.ToColor()));
				otherwise
					logger.LogNotImplementedForEnumValue(displayMode);
			end
		end
		function extrema = ToExtrema(this, logger, unfinishedRayLength)
			if(isempty(this.EndPoint))
				if(~exist('unfinishedRayLength','var'))
					unfinishedRayLength = .5;
				end
				endPoint = this.Origin + this.Direction*unfinishedRayLength;
				logger.Log(this.MSG_NOENDPOINT, this.MSG_NOENDPOINT);
			else
				endPoint = this.EndPoint;
			end
			extrema = Source.Geometry.Extrema.FromTwoPoints(...
				this.Origin, endPoint);
		end
		function color = ToColorByMedium(this)
			if(this.WaveType == Source.Enum.WaveType.Shear)
				lightness = 30;
			else
				lightness = 100;
			end
			% A-Z: 65 - 90
			% a-z: 97 - 122
			rgbVals = zeros(1, min(2, length(this.MediumName)));
			for inCh = 1:length(rgbVals)
				valC = double(this.MediumName(inCh));
				if(valC < 65 || (valC > 90 && valC < 97) || valC > 122)
					rgbVals(inCh) = 127;
					continue;
				end
				if(valC <= 90)
					rgbVals(inCh) = 127*(valC - 64)/53;
				end
				if(valC >= 97)
					rgbVals(inCh) = 127*(valC - 96)/53;
				end
			end
			color = double(lab2rgb([lightness rgbVals],...
				'OutputType','uint16'))/2^16;
		end
		function ScalePower(this, scaling)
			this.InitialPower = this.InitialPower * scaling;
		end
	end
	methods(Access = protected)
		function this = GRay()
		end
		function [distance, min2Attenuation] = getDistanceByPower(this,...
				min2Attenuation, powerThreshold)
			if(this.InitialPower < powerThreshold)
					distance = 0;
			else
				distance = log(powerThreshold/this.InitialPower)/min2Attenuation;
			end
		end
		function setEndPoint(this, distance)
			this.EndPoint = this.GetLocation(distance);
		end
		function setEndPower(this, min2Attenuation, distance)
			this.EndPower = this.GetPowerByDistance(this.InitialPower,...
			min2Attenuation, distance);
		end
		function phase = getPhase(this, distance, frequencyPerSpeed)
			phase = this.InitialPhase + frequencyPerSpeed*distance;
		end
	end
end