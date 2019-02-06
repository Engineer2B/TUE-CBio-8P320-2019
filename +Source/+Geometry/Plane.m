classdef Plane < handle & Source.Geometry.Boundary
	%PLANE Describes an infinitely wide plane.
	properties
		Normal
		Center
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Geometry:Plane:'
		CLASS_NAME = 'Source.Geometry.Plane'
	end
	methods(Static)
		function obj = New(direction, center, medium, id, color,...
				hasOutsideBoundariesFn)
			obj = Source.Geometry.Plane();
			obj.setProperties(direction, center, medium, id, color,...
				hasOutsideBoundariesFn);
		end
		function obj = FromDTO(dto, media, hasOutsideBoundariesFn)
			if(~isfield(dto, 'Color'))
				dto.Color = Source.Helper.Random.Color;
			end
			medium = media.NameToMediumMap(dto.MediumName);
			obj = Source.Geometry.Plane.New(...
				Source.Geometry.Vec3.FromDTO(dto.Normal),...
				Source.Geometry.Vec3.FromDTO(dto.Center),...
				medium, dto.Id, dto.Color, hasOutsideBoundariesFn);
		end
		function planes = FromDTOs(dtos, media, hasOutsideBoundariesFn)
			nOfPlanes = length(dtos);
			planes = Source.Geometry.Plane.empty(nOfPlanes, 0);
			for inPlane = 1:nOfPlanes
				planes(inPlane) = Source.Geometry.Plane.FromDTO(...
					dtos(inPlane), media, hasOutsideBoundariesFn);
			end
		end
		function handle = Show(center, normal, w, h, patchOptions)
			a = Source.Geometry.Vec3.Normalize(...
				Source.Geometry.Vec3.PerpendicularDirection(normal));
			b = Source.Geometry.Vec3.Normalize(...
				Source.Geometry.Vec3.CrossProduct(normal, a));
			
			p1 = center - .5*w*a - .5*h*b;
			p2 = center + .5*w*a - .5*h*b;
			p3 = center + .5*w*a + .5*h*b;
			p4 = center - .5*w*a + .5*h*b;

			patchOptions.Vertices = [p1; p2; p3; p4];
			patchOptions.Faces = [1 2 3 4 1];
			patchOptionsCell = patchOptions.ToCell();
			handle = patch(patchOptionsCell{:});
		end
		function handle = ShowCircle(direction, translation, x, y, radius,...
				lineOptions)
			% (x, y) are the coordinates of the circle relative to the plane.
			% direction is the direction of the plane.
			t = linspace(0, 2*pi);
			X = radius*cos(t) + x;
			Y = radius*sin(t) + y;
			mPoints = [X;Y;zeros(1,length(Y))];
			normVec = [0 0 1];
			rotAx = Source.Geometry.Vec3.Normalize(...
				Source.Geometry.Vec3.CrossProduct(direction, normVec));
			dDotIn = direction * normVec';
			if(abs(dDotIn) >= .5)
				rotAngle = acos(direction * normVec');
			else
				rotAngle = -acos(direction * normVec');
			end			
			rotMat = Source.Geometry.Transform...
				.GetArbitraryAngleRotationMatrix(rotAx, rotAngle);
			mPoints = bsxfun(@(A,b) A+b,rotMat*mPoints, translation');
			lineOptionsCell = lineOptions.ToCell();
			handle = plot3(mPoints(1,:), mPoints(2,:), mPoints(3,:),...
				lineOptionsCell{:});
		end
		function handle = ShowEllipse(normal, translation, x1, y1, x2, y2,...
				ecc, scaling, lineOptions)
			% (x1,y1) and (x2,y2) are the coordinates of the two vertices of
			% the ellipse's major axis, and ecc is its eccentricity.
			% normal is the normal direction of the plane.
			a = 1/2*sqrt((x2-x1)^2+(y2-y1)^2);
			b = a*sqrt(1-ecc^2);
			t = linspace(0, 2*pi);
			X = a*cos(t);
			Y = b*sin(t);
			w = atan2(y2-y1,x2-x1);
			x = (x1+x2)/2 + scaling*(X*cos(w) - Y*sin(w));
			y = (y1+y2)/2 + scaling*(X*sin(w) + Y*cos(w));
			mPoints = [x;y;zeros(1,length(y))];
			normVec = [0 0 1];
			rotAx = Source.Geometry.Vec3.CrossProduct(normal, normVec);
			rotAngle = acos(normal * normVec');
			rotMat = Source.Geometry.Transform...
				.GetArbitraryAngleRotationMatrix(rotAx, rotAngle);
			mPoints = bsxfun(@(A,b) A+b,rotMat*mPoints, translation');
			lineOptionsCell = lineOptions.ToCell();
			handle = plot3(mPoints(1,:), mPoints(2,:), mPoints(3,:),...
				lineOptionsCell{:});
		end
	end
	methods
		function copyObj = Copy(this, media)
			copyObj = this.FromDTO(this.ToDTO(), media,...
				this.HasOutsideBoundariesFn);
		end
		function dto = ToDTO(this)
			dto = this.toDTO();
			dto.Normal =  Source.Geometry.Vec3.ToDTO(this.Normal);
			dto.Center = Source.Geometry.Vec3.ToDTO(this.Center);
		end
		function isCircular = Is5LineIntersectionACircle(this, l1, l2, l3,...
				l4, l5, tolerance)
			syms a b c;
			[vec1, vec2] = this.GetBasisVectors();
			x1 = vec1*l1';
			x2 = vec1*l2';
			x3 = vec1*l3';
			x4 = vec1*l4';
			x5 = vec1*l5';

			y1 = vec2*l1';
			y2 = vec2*l2';
			y3 = vec2*l3';
			y4 = vec2*l4';
			y5 = vec2*l5';
			eq1 = (x1-a)^2 + (y1-b)^2==c^2;
			eq2 = (x2-a)^2 + (y2-b)^2==c^2;
			eq3 = (x3-a)^2 + (y3-b)^2==c^2;
			w = solve([eq1 eq2 eq3], [a b c]);
			solI = vpa(w.c) > 0;
			wFields = fieldnames(w);
			for inWField = 1:length(wFields)
				val = w.(wFields{inWField});
				w.(wFields{inWField}) = vpa(val(solI));
			end
			isCircular = false;
			wcSq = vpa(w.c)^2;
			if((x4-vpa(w.a))^2+(y4-vpa(w.b))^2 - wcSq < tolerance)
				if((x5-vpa(w.a))^2+(y5-vpa(w.b))^2 - wcSq < tolerance)
					isCircular = true;
				end
			end
% 			(x1-w.a(solI))^2+(y1-w.b(solI))^2
% 			M = [x^2 x*y y^2 x y 1
% 				x1^2 x1*y1 y1^2 x1 y1 1
% 				x2^2 x2*y2 y2^2 x2 y2 1
% 				x3^2 x3*y3 y3^2 x3 y3 1
% 				x4^2 x4*y4 y4^2 x4 y4 1
% 				x5^2 x5*y5 y5^2 x5 y5 1];
% 			w = solve(det(M), [x y]);
		end
		function [vec1, vec2] = GetBasisVectors(this)
			vec1 = Source.Geometry.Vec3.PerpendicularDirection(this.Normal);
			vec2 = cross(vec1, this.Normal);
		end
		function handle = ShowDebug(this, w, h, patchOptions)
			% Since the plane is infinite and MATLAB cannot show infinite planes
			% we have to define a width and height.
			if(isempty(patchOptions.DisplayName))
				patchOptions = patchOptions.copy();
				patchOptions.DisplayName = char(Source.Enum.MediumName(...
					this.MediumName));
			end
			handle = Source.Geometry.Plane.Show(this.Center, this.Normal,...
				w, h, patchOptions);
		end
		function ShowIntersection(this, ray, res)
			mp = Source.Display.MeshProjector.Default();
			mp.ShowLine(ray.Origin, ray.Origin+res.MinLambda*ray.Direction);
			mp.ShowPlane(this, 30, 30);
		end
		function intersectionResult = FindIntersection(this, ray)
			intersectionResult = Source.Geometry.IntersectionResult.Default(...
				this.Medium.Name, this.Id);
			d = ((this.Center - ray.Origin)*this.Normal')/(ray.Direction*...
				this.Normal');
			if(d<=Test.Settings.Tolerance)
				return;
			end
			if(~this.HasOutsideBoundariesFn(this))
				intersectionResult.OutwardNormalVector = -this.Normal;
			else
				intersectionResult.OutwardNormalVector = this.Normal;
			end
			intersectionResult.MinLambda = d;
		end
		function this = ChangeInclination(this, inclinationAngle)
			this.Normal = Source.Geometry.Transform.GetRotationMatrix(...
			'y', inclinationAngle) * this.Normal;
		end
		function this = ChangeAzimuth(this, azimuthAngle)
			this.Normal = Source.Geometry.Transform...
			.GetRotationMatrix('z', azimuthAngle) * this.Normal;
		end
		function this = Translate(this, translation)
			this.Center = this.Center + translation;
		end
		function this = Rescale(this, scaleFactor)
			this.Center = this.Center * scaleFactor;
		end
	end
	methods(Access = protected)
		function this = Plane()
		end
		function setProperties(this, direction, center, medium, id,...
				color, hasOutsideBoundariesFn)
			this.setBaseProperties(medium, id, color, hasOutsideBoundariesFn);
			this.Center = center;
			this.Normal = Source.Geometry.Vec3.Normalize(direction);
		end
	end
end