classdef Cylinder < handle & Source.Geometry.Boundary
	%CYLINDER Describes an infinitely tall cylinder.
	properties(SetAccess = protected)
		ShaftDirection
		Radius
		Center
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Geometry:Cylinder:'
		CLASS_NAME = 'Source.Geometry.Cylinder'
	end
	methods(Static)
		function obj = New(direction, radius, center, medium, id, color,...
				hasOutsideBoundariesFn)
			obj = Source.Geometry.Cylinder();
			obj.setProperties(direction, radius, center, medium, id, color,...
				hasOutsideBoundariesFn);
		end
		function obj = FromDTO(dto, media, hasOutsideBoundariesFn)
			if(~isfield(dto, 'Color'))
				dto.Color = Source.Helper.Random.Color;
			end
			medium = media.NameToMediumMap(dto.MediumName);
			direction = Source.Geometry.Vec3.FromDTO(dto.ShaftDirection);
			center = Source.Geometry.Vec3.FromDTO(dto.Center);
			obj = Source.Geometry.Cylinder.New(direction, dto.Radius, center,...
				medium, dto.Id, dto.Color, hasOutsideBoundariesFn);
		end
		function cylinders = FromDTOs(dtos, hasOutsideBoundariesFn)
			nOfCylinders = length(dtos);
			cylinders = Source.Geometry.Cylinder.empty(nOfCylinders, 0);
			for inCyl = 1:nOfCylinders
				cylinders(inCyl) = Source.Geometry.Cylinder.FromDTO(...
					dtos(inCyl), hasOutsideBoundariesFn);
			end
		end
		function handle = Show(center, radius, height, patchOptions)
			% Create a unit cylinder
			[x, y, z] = cylinder(1,36);
			
			x = x*radius;
			y = y*radius;
			% Translate center of cylinder down to origin and change cylinder
			% height from 1 to set value.
			z = (z-0.5)*height;

			% Translate cylinder acording to given center point
			x = x + center(1);
			y = y + center(2);
			z = z + center(3);

			% Actual drawing
			[f, v, ~] = surf2patch(x, y, z);
			patchOptions.Vertices = v;
			patchOptions.Faces = f;
			patchOptionsCell = patchOptions.ToCell();
			handle = patch(patchOptionsCell{:});
		end
		function handle = ShowOutline(direction, center, radius, patchOptions)
			% (x, y) are the coordinates of the circle relative to the plane.
			t = linspace(0, 2*pi);
			X = radius*cos(t) + center(1);
			Y = radius*sin(t) + center(2);
			mPoints = [X;Y;zeros(1,length(Y))];
			normVec = [0 0 1];
			rotAx = Source.Geometry.Vec3.CrossProduct(direction, normVec);
			rotAngle = acos(direction * normVec');
			rotMat = Source.Geometry.Transform...
				.GetArbitraryAngleRotationMatrix(rotAx, rotAngle);
			mPoints = rotMat*mPoints;
			patchOptions.XData = mPoints(1,:);
			patchOptions.YData = mPoints(2,:);
			patchOptions.ZData = mPoints(3,:);
			patchOptionsCell = patchOptions.ToCell();
			handle = patch(patchOptionsCell{:});
		end
	end
	methods
		function copyObj = Copy(this, media)
			copyObj = this.FromDTO(this.ToDTO(), media,...
				this.HasOutsideBoundariesFn);
		end
		function dto = ToDTO(this)
			dto = this.toDTO();
			dto.Radius = this.Radius;
			dto.Center = Source.Geometry.Vec3.ToDTO(this.Center);
			dto.ShaftDirection = Source.Geometry.Vec3.ToDTO(...
				this.ShaftDirection);
		end
		function handle = ShowDebug(this, h, patchOptions)
			if(isempty(patchOptions.DisplayName))
				patchOptions = patchOptions.copy();
				patchOptions.DisplayName = char(Source.Enum.MediumName(...
					this.MediumName));
			end
			handle = Source.Geometry.Cylinder.Show(this.Center, this.Radius,...
				h, patchOptions);
		end
		function handle = ShowDebugOutline(this, patchOptions)
			if(isempty(patchOptions.DisplayName))
				patchOptions = patchOptions.copy();
				patchOptions.DisplayName = char(Source.Enum.MediumName(...
					this.MediumName));
			end
			handle = Source.Geometry.Cylinder.ShowOutline(this.ShaftDirection,...
				this.Center, this.Radius, patchOptions);
		end
		function intersectionResult = FindIntersection(this, ray)
			intersectionResult = Source.Geometry.IntersectionResult.Default(...
				this.Medium, this.Id);
			rayDdotCylD = ray.Direction * this.ShaftDirection';
			a = 1-rayDdotCylD^2;
			if(a== 0)
				return;
			end
			rayOminCylC = ray.Origin - this.Center;
			rayDminRayDdotCylDtimesCylD =...
				ray.Direction - rayDdotCylD * this.ShaftDirection;
			b = 2*rayOminCylC*rayDminRayDdotCylDtimesCylD';
			c = rayOminCylC*rayOminCylC' -...
				(rayOminCylC*this.ShaftDirection')^2-this.Radius^2;
			% Nu de echte kwadratische vergelijking.
			determ = b^2-4*a*c;
			if(determ<0)
				% Alleen complexe oplossingen.
				return;
			else
					lam1 = (-b+sqrt(determ))/(2*a);
					lam2 = (-b-sqrt(determ))/(2*a);
					% Omdat a>0 altijd lam1 >= lam2
					if(lam2 > 1e-10)
							% lam2 is de kleinste positive oplossing.
							intersectionResult.MinLambda = lam2;
					elseif(lam1>1e-10)
							% lam2 <= 0 en lam1>0, dus lam1 is de
							% kleinste positive oplossing.
							intersectionResult.MinLambda = lam1;
					else
						return;
					end
			end
			% Snijpunt lijn met cilinder.
			intersection = ray.Origin+intersectionResult.MinLambda*...
				ray.Direction;
			% Bijbehorend punt op hartlijn van cilinder.
			centerLinePoint  = this.Center +...
					((intersection(1)-this.Center(1))*this.ShaftDirection(1)+...
					 (intersection(2)-this.Center(2))*this.ShaftDirection(2)+...
					 (intersection(3)-this.Center(3))*this.ShaftDirection(3))*...
					 this.ShaftDirection;
			% Normaal op cilinder in snijpunt, gericht naar buiten.
			outwardNormalVector = (intersection-centerLinePoint);
			if(~this.HasOutsideBoundariesFn(this))
				outwardNormalVector = -outwardNormalVector;
			end
			intersectionResult.OutwardNormalVector =...
				Source.Geometry.Vec3.Normalize(outwardNormalVector);
			% Het snijpunt is nu in ray.Origin+minLambda*ray.Direction,
			% ook als ray.Origin niet genormaliseerd was.
		end
		function this = ChangeInclination(this, inclinationAngle)
			this.ShaftDirection = Source.Geometry.Transform.GetRotationMatrix(...
			'y', inclinationAngle) * this.ShaftDirection;
		end
		function this = ChangeAzimuth(this, azimuthAngle)
			this.ShaftDirection = Source.Geometry.Transform...
			.GetRotationMatrix('z', azimuthAngle) * this.ShaftDirection;
		end
		function this = Translate(this, translation)
			this.Center = this.Center + translation;
		end
		function this = Rescale(this, scaleFactor)
			this.Center = this.Center * scaleFactor;
			this.Radius = this.Radius * scaleFactor;
		end
	end
	methods(Access = protected)
		function this = Cylinder()
		end
		function setProperties(this, direction, radius, center, medium, id,...
				color, hasOutsideBoundariesFn)
			this.setBaseProperties(medium, id, color, hasOutsideBoundariesFn);
			this.Center = center;
			this.Radius = radius;
			this.ShaftDirection = direction;
		end
	end
end
