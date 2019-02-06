classdef Transform
	methods(Access = public, Static)
		function v = ReflectionToPlane(u, n)
			% Reflection of u on hyperplane n.
			%
			% u can be a matrix. u and v must have the same number of rows.
			v = u - 2 * n * (n'*u) / (n'*n);
		end
		function theta = GetTheta(point)
			% Calculate the angle between [1,0,0] and the x,y-component of a
			% point.
			theta = atan(point.Y/point.X);
		end
		function phi = GetPhi(point)
			% Calculate the angle between the projection of a point on the
			% x,y-plane and the point.
			phi = atan(point.Z/sqrt((point.X)^2+(point.Y^2)));
		end
		function rotationMatrix = GetRotationMatrixToOtherNormal(...
				normal1, normal2)
			v = cross(normal1, normal2);
			c = acos(normal1 * normal2');
			v_skew = [0		-v(3),   v(2)
				        v(3)	 0		-v(1)
				       -v(2)	 v(1)		0];
			rotationMatrix = eye(3) + v_skew + v_skew^2 * ((1-c)/s^2);
		end
		function rotationMatrix = GetRotationMatrix(rotationAxis, rotationAngle)
		%% Calculate the rotation matrix around an axis "x", "y" or "z".
			switch(rotationAxis)
				case('x')
					rotationMatrix =...
						[1	0						0
						 0	cos(rotationAngle)	-sin(rotationAngle)
						 0	sin(rotationAngle)	cos(rotationAngle)];
				case('y')
					rotationMatrix =...
						[cos(rotationAngle)  0	-sin(rotationAngle)
						 0           1	0
						 sin(rotationAngle) 0	cos(rotationAngle)];
				case('z')
					rotationMatrix =...
						[cos(rotationAngle) -sin(rotationAngle) 0
						 sin(rotationAngle) cos(rotationAngle)  0
						 0					0						1];
				otherwise
					rotationMatrix = zeros(3,3);
					External.cprintf.cprintf(...
						'Errors','Unsupported axis string "%s"!\n', rotationAxis);
			end
		end
		function rotMat = GetArbitraryAngleRotationMatrix(u, a)
			% Implementation of the Rodrigues' rotation formula.
			rotMat = [cos(a)+(u(1)^2)*(1-cos(a)) u(1)*u(2)*(1-cos(a))-u(3)*sin(a) u(1)*u(3)*(1-cos(a))+u(2)*sin(a)
			u(2)*u(1)*(1-cos(a))+u(3)*sin(a) cos(a)+(u(2)^2)*(1-cos(a)) u(2)*u(3)*(1-cos(a))-u(1)*sin(a)
			u(3)*u(1)*(1-cos(a))-u(2)*sin(a) u(3)*u(2)*(1-cos(a))+u(1)*sin(a) cos(a)+(u(3)^2)*(1-cos(a))];
		end
		function rotationMatrix = GetArbitraryRotationMatrix(...
				rotationPoint1, rotationPoint2, rotationAngle)
			x1 = rotationPoint1.X;
			y1 = rotationPoint1.Y;
			z1 = rotationPoint1.Z;
			if(~all(rotationPoint1 == [0 0 0]))
				% Translate space so that the rotation axis passes through the
				% origin.
				T = [1 0 0 -x1; 0 1 0 -y1; 0 0 1 -z1; 0 0 0 1];
				TInv = [1 0 0 x1; 0 1 0 y1; 0 0 1 z1; 0 0 0 1];
			else
				T = eye(4);
				TInv = T;
			end
			U = rotationPoint1 - rotationPoint2;
			U = U.Normalized();
			a = U.X;
			b = U.Y;
			c = U.Z;
			d = sqrt(U.Y^2+U.Z^2);
			if(d ~=0)
				% Rotate space about the x axis so that the rotation axis lies in
				% the xz plane.
				Rx = [1 0 0 0; 0 c/d -b/d 0; 0 b/d c/d 0; 0 0 0 1];
				RxInv = [1 0 0 0; 0 c/d b/d 0; 0 -b/d c/d 0; 0 0 0 1];
			else
				Rx = eye(4);
				RxInv = Rx;
			end
			Ry = [d 0 -a 0; 0 1 0 0; a 0 d 0; 0 0 0 1];
			RyInv = [d 0 a 0; 0 1 0 0; -a 0 d 0; 0 0 0 1];
			Rz = [cos(rotationAngle) -sin(rotationAngle) 0 0; sin(rotationAngle) cos(rotationAngle) 0 0
				0 0 1 0; 0 0 0 1];
			rotationMatrix = TInv*RxInv*RyInv*Rz*Ry*Rx*T;
		end
		function isEqual = AnglesApproximatelyEqual(angle1, angle2, tolerance)
			isEqual = acos((2-((sin(angle1)-sin(angle2))^2+...
				(cos(angle1)-cos(angle2))^2))/2) < tolerance;
		end
		function A = MapFrom00_10_01To(a, b, c, d)
			M = [a' b' c'];
			uwv = d'\M;
			A = bsxfun(@(val1, val2) val1*val2', M, uwv);
		end
	end
end