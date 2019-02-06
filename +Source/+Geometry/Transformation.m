classdef Transformation < handle
	properties
		% Inclination in [deg].
		Inclination
		% Azimuth in [deg].
		Azimuth
		% Scale factor in [-].
		ScaleFactor
		% Translation in [m, m, m].
		Translation
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Geometry:Transformation:'
		CLASS_NAME = 'Source.Geometry.Transformation'
		None = Source.Geometry.Transformation.New(0, 0, 1,...
				[0 0 0]);
	end
	methods(Access = public, Static)
		function obj = New(inclination, azimuth, scaleFactor,	translation)
			obj = Source.Geometry.Transformation();
			obj.Inclination = inclination;
			obj.Azimuth = azimuth;
			obj.ScaleFactor = scaleFactor;
			obj.Translation = translation;
		end
		function obj = FromDTO(dto)
			obj = Source.Geometry.Transformation.New(...
				dto.Inclination,...
				dto.Azimuth, dto.ScaleFactor,...
				Source.Geometry.Vec3.FromDTO(dto.Translation));
		end
	end
	methods(Access = public)
		function ApplyToHandleObj(this, object)
			if(this.ScaleFactor ~= 1)
				object.Rescale(this.ScaleFactor);
			end
			if(this.Inclination ~= 0)
				object.ChangeInclination(this.Inclination);
			end
			if(this.Azimuth ~= 0)
				object.ChangeAzimuth(this.Azimuth);
			end
			if(~all(this.Translation == [0 0 0]))
				object.Translate(this.Translation);
			end
		end
		function transformedVec3 = ApplyToVec3(this, vec3)
			transformedVec3 = vec3*...
				(Source.Geometry.Transform.GetRotationMatrix('z',...
			this.Azimuth)*Source.Geometry.Transform.GetRotationMatrix('y',...
			this.Inclination));
			transformedVec3 = transformedVec3*this.ScaleFactor;
			transformedVec3 = transformedVec3 + this.Translation;
		end
		function dto = ToDTO(this)
			dto.Inclination = this.Inclination;
			dto.Azimuth = this.Azimuth;
			dto.ScaleFactor = this.ScaleFactor;
			dto.Translation = Source.Geometry.Vec3.ToDTO(this.Translation);
		end
		function str = ToDisplayString(this, name, distanceUnit, digRound)
			thetaPhiScaleString = [' $\theta$: %.2g $\left[rad\right]$ '...
				'$\phi$: %.2g $\left[rad\right]$ '...
				'scale: %.2g $\left[-\right]$'];
			if(exist('digRound', 'var'))
				str =	[Source.Geometry.Vec3.ToDisplayString(this.Translation,...
					'r', name, distanceUnit, digRound), thetaPhiScaleString];
				str = sprintf(Source.Display.MathString.Escape(str),...
				round(this.Azimuth, digRound), round(this.Inclination, digRound),...
				round(this.ScaleFactor, digRound));
			else
				str =	[Source.Geometry.Vec3.ToDisplayString(this.Translation,...
					'r', name, distanceUnit, 3), thetaPhiScaleString];
				str = sprintf(Source.Display.MathString.Escape(str),...
				this.Azimuth, this.Inclination, this.ScaleFactor);
			end
		end
		function AddInclination(this, inclinationAngle)
			this.Inclination = mod(this.Inclination + inclinationAngle, 2*pi);
		end
		function AddAzimuth(this, azimuthAngle)
			this.Azimuth = mod(this.Azimuth + azimuthAngle, 2*pi);
		end
		function AddRescaling(this, scaleFactor)
			this.ScaleFactor = this.ScaleFactor * scaleFactor;
		end
		function AddTranslation(this, translation)
			this.Translation = this.Translation + translation;
		end
		function isEqual = eq(this, other)
			isEqual = this.Inclination == other.Inclination &&...
			this.Azimuth == other.Azimuth &&...
			this.ScaleFactor == other.ScaleFactor &&...
			all(this.Translation == other.Translation);
		end
		function isEqual = ApproxEqualTo(this, other, tolerance)
			isEqual = Source.Geometry.Transform.AnglesApproximatelyEqual(...
				this.Inclination, other.Inclination, tolerance) &&...
			Source.Geometry.Transform.AnglesApproximatelyEqual(...
				this.Azimuth, other.Azimuth, tolerance) &&...
			abs(this.ScaleFactor/other.ScaleFactor-1) < tolerance &&...
			Source.Geometry.Vec3.ApproxEq(this.Translation, other.Translation,...
			tolerance);
		end
	end
	methods(Access = protected)
		function this = Transformation()
		end
	end
end

