classdef Vec3
	methods(Static)
		function arr = Normalize(vec)
			arr = vec/sqrt(vec(1)*vec(1)+vec(2)*vec(2)+vec(3)*vec(3));
		end
		function arr = FromDTO(dto)
			arr = [dto.X dto.Y dto.Z];
		end
		function dto = ToDTO(vec)
			dto.X = vec(1);
			dto.Y = vec(2);
			dto.Z = vec(3);
		end
		function gmshString = ToGMSHString(vec, nodeNr)
			gmshString = sprintf('%i %.16g %.16g %.16g',...
				nodeNr, vec(1), vec(2), vec(3));
		end
		function randVec = Random()
			randVec = random('unif', 0, 1, 1, 3);
		end
		function equal = ApproxEq(vec1, vec2, tolerance)
			equal = all(abs(vec1 - vec2) <= tolerance);
		end
		function distance = Distance(vec1, vec2)
			distance = sqrt((vec1(1)-vec2(1))^2+...
				(vec1(2)-vec2(2))^2+...
				(vec1(3)-vec2(3))^2);
		end
		function crossProduct = CrossProduct(vec1, vec2)
				crossProduct = [(vec1(2)*vec2(3)-vec2(2)*vec1(3)),...
				-(vec1(1)*vec2(3)-vec2(1)*vec1(3)),...
				(vec1(1)*vec2(2)-vec2(1)*vec1(2))];
		end
		function rotVec = Rotate(vec, axis, angle)
			rotationMatrix = Source.Geometry.Transform.GetRotationMatrix(axis,...
				angle);
			rotVec = vec*rotationMatrix;
		end
		function vRot = RodriguesRotate(v, k, a)
			% Implements Rodrigues' rotation formula for rotation of a vector
			% v around an arbitrary axis direction k with an arbitrary angle a.
			vRot = v * cos(a) + Source.Geometry.Vec3.CrossProduct(k, v) *...
				sin(a) + k * (k * v') * (1-cos(a));
		end
		function perpDir = PerpendicularDirection(vec)
			if(all(vec == [0 0 0]))
				perpDir = [0 0 0];
				return;
			end
			if(vec(1) == 0)
				if(vec(2) == 0)
					perpDir = [0, 1, 0];
				elseif(vec(3) == 0)
					perpDir = [1, 0, 0];
				else
					perpDir = [0, 1,  -vec(2)/vec(3)];
				end
			elseif(vec(2) == 0)
				if(vec(3) == 0)
					perpDir = [0, 1, 0];
				else
					perpDir = [1, 0, -vec(1)/vec(3)];
				end
			elseif(vec(3) == 0)
				perpDir = [-vec(2)/vec(1), 1, 0];
			else
				perpDir = [1, 1, -(vec(1)+vec(2))/vec(3)];
			end
		end
		function str = ToString(vec)
			str = sprintf('(% +.4g % +.4g % +.4g)', vec(1), vec(2), vec(3));
		end
		function displayString = ToDisplayString(vec, vectorName, subText,...
				distanceUnit, roundingDigits)
			% roundingDigits The amount of digits to use in rounding.
			% A positive amount rounds behind the decimal separator, a negative
			% amount rounds in front of the decimal separator.
			% e.g. round(30.23, 1) = 30.2, round(31.23,-1) = 30.
			if(strcmp(subText, '') == 1)
				vectorSubText = '';
			else
				vectorSubText = ['\textrm{' subText '}'];
			end
			str = '$\left[%s,%s,%s\right]$';
			str = sprintf(Source.Display.MathString.Escape(str),...
				distanceUnit, distanceUnit, distanceUnit);
			str = ['$' Source.Display.MathString.Vector(vectorName,...
				vectorSubText) '$: '...
				'$\left(%.16g, %.16g, %.16g\right)^\top$ ' str];
			if(exist('roundingDigits', 'var'))
				displayString = sprintf(Source.Display.MathString.Escape(str),...
				round(vec(1), roundingDigits),...
				round(vec(2), roundingDigits), round(vec(3), roundingDigits));
			else
				displayString = sprintf(Source.Display.MathString.Escape(str),...
				vec(1), vec(2), vec(3));
			end
		end
	end
end
