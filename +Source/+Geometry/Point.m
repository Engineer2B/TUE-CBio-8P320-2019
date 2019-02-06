classdef Point
	%POINT A point consisting of coordinates in space.
	% synonymous to a vector.
	properties
		X % The X coordinate.
		Y % The Y coordinate.
		Z % The Z coordinate.
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Geometry:Point:'
		CLASS_NAME = 'Source.Geometry.Point'
	end
	methods (Access = public, Static)
		function obj = New(x, y, z)
			obj = Source.Geometry.Point(x, y, z);
		end
		function obj = Repeated(value)
			obj = Source.Geometry.Point(value, value, value);
		end
		function obj = Normal(x, y, z)
			obj = Source.Geometry.Point(x, y, z);
			obj = obj.Normalized();
		end
		function obj = Random(generator)
			if(~exist('generator', 'var'))
				generator = @() random('unif', 0, 1);
			end
			obj = Source.Geometry.Point(generator(), generator(), generator());
		end
		function obj = Origin()
			obj = Source.Geometry.Point(0, 0, 0);
		end
		function obj = FromArray(array3x1)
			obj = Source.Geometry.Point(array3x1(1),array3x1(2),array3x1(3));
		end
		function obj = FromStruct(xyzStruct)
			obj = Source.Geometry.Point(xyzStruct.X,xyzStruct.Y,xyzStruct.Z);
		end
		function isEqual = Compare(pointArray,arrayNx3)
			nOfPoints = length(pointArray);
			isEqual = true;
			if(length(pointArray) ~= length(arrayNx3))
				isEqual = false;
				return;
			end
			for pointIndex = 1:nOfPoints
				if(~pointArray(pointIndex).EqualTo(arrayNx3(pointIndex,:)))
					isEqual = false;
					return;
				end
			end
		end
		function pointlikeObj = Convert(pointlikeObj)
			if(~isa(pointlikeObj, 'Source.Geometry.Point'))
				if(isnumeric(pointlikeObj) && length(pointlikeObj) == 3)
					pointlikeObj = Source.Geometry.Point.FromArray(pointlikeObj);
				else
					error([Source.Geometry.Point.ERROR_CODE_PREFIX 'Convert'],...
						'Object must be convertable to a Source.Geometry.Point');
				end
			end
		end
	end
	methods (Access = public)
		function result = mpower(this, value)
			result = Source.Geometry.Point.New(...
				this.X^value,...
				this.Y^value,...
				this.Z^value);
		end
		function result = abs(this)
			result = Source.Geometry.Point.New(...
				abs(this.X),...
				abs(this.Y),...
				abs(this.Z));
		end
		function result = ceil(this)
			result = Source.Geometry.Point.New(...
				ceil(this.X),...
				ceil(this.Y),...
				ceil(this.Z));
		end
		function result = floor(this)
			result = Source.Geometry.Point.New(...
				floor(this.X),...
				floor(this.Y),...
				floor(this.Z));
		end
		function result = Summarize(this, func)
			result = func(this.X, this.Y, this.Z);
		end
		function result = Apply(this, func)
			result = Source.Geometry.Point.New(func(this.X), func(this.Y),...
				func(this.Z));
		end
		function result = Combine(this, other, func)
			result = Source.Geometry.Point.New(func(this.X,other.X),...
				func(this.Y, other.Y),...
				func(this.Z, other.Z));
		end
		function result = ConditionalApply(this, comparisonPoint,...
			comparisonFunction, funcTrue, funcFalse)
			if(comparisonFunction(this.X, comparisonPoint.X))
				x = funcTrue(this.X);
			else
				x = funcFalse(this.X);
			end
			if(comparisonFunction(this.Y, comparisonPoint.Y))
				y = funcTrue(this.Y);
			else
				y = funcFalse(this.Y);
			end
			if(comparisonFunction(this.Z, comparisonPoint.Z))
				z = funcTrue(this.Z);
			else
				z = funcFalse(this.Z);
			end
			result = Source.Geometry.Point.New(x, y, z);
		end
		function result = plus(obj1, obj2)
			if(isnumeric(obj1) && length(obj1) == 1)
				result = Source.Geometry.Point(obj1+obj2.X,obj1+obj2.Y,obj1+obj2.Z);
			elseif(isnumeric(obj2) && length(obj2) == 1)
				result = Source.Geometry.Point(obj1.X+obj2,obj1.Y+obj2,obj1.Z+obj2);
			elseif(isa(obj1,'Source.Geometry.Point') &&...
					isa(obj2,'Source.Geometry.Point'))
				result = Source.Geometry.Point(obj1.X+obj2.X,obj1.Y+obj2.Y,...
					obj1.Z+obj2.Z);
			elseif(isa(obj2,'Source.Geometry.PointCollection'))
				result = obj2 + obj1;
			else
				Source.Geometry.Point.handleInvalidData(...
					obj1, obj2, 'plus', 'add', 'to');
			end
		end
		function this = uminus(this)
			this.X = -this.X;
			this.Y = -this.Y;
			this.Z = -this.Z;
		end
		function this = log2(this)
			this.X = log2(this.X);
			this.Y = log2(this.Y);
			this.Z = log2(this.Z);
		end
		function result = mrdivide(obj1, obj2)
			if(isnumeric(obj1) && length(obj1) == 1)
				result = Source.Geometry.Point(obj1/obj2.X,obj1/obj2.Y,obj1/obj2.Z);
			elseif(isnumeric(obj2) && length(obj2) == 1)
				result = Source.Geometry.Point(obj1.X/obj2,obj1.Y/obj2,obj1.Z/obj2);
			elseif(isa(obj1,'Source.Geometry.Point') &&...
					isa(obj2,'Source.Geometry.Point'))
				result = Source.Geometry.Point(obj1.X/obj2.X,obj1.Y/obj2.Y,...
					obj1.Z/obj2.Z);
			else
				Source.Geometry.Point.handleInvalidData(...
					obj1, obj2, 'mrdivide', 'divide', 'by');
			end
		end
		function result = minus(obj1, obj2)
			if(isnumeric(obj1) && length(obj1) == 1)
				result = Source.Geometry.Point(obj1-obj2.X,obj1-obj2.Y,obj1-obj2.Z);
			elseif(isnumeric(obj2) && length(obj2) == 1)
				result = Source.Geometry.Point(obj1.X-obj2,obj1.Y-obj2,obj1.Z-obj2);
			elseif(isa(obj1,'Source.Geometry.Point') &&...
					isa(obj2,'Source.Geometry.Point'))
				result = Source.Geometry.Point(obj1.X-obj2.X,obj1.Y-obj2.Y,obj1.Z-obj2.Z);
			else
				Source.Geometry.Point.handleInvalidData(...
					obj1, obj2, 'minus', 'subtract', 'from');
			end
		end
		function result = times(obj1, obj2)
			if(isnumeric(obj1) && length(obj1) == 1)
				result = Source.Geometry.Point(obj1*obj2.X,obj1*obj2.Y,obj1*obj2.Z);
			elseif(isnumeric(obj2) && length(obj2) == 1)
				result = Source.Geometry.Point(obj1.X*obj2,obj1.Y*obj2,obj1.Z*obj2);
			elseif(isa(obj1,'Source.Geometry.Point') &&...
					isa(obj2,'Source.Geometry.Point'))
				result = Source.Geometry.Point(...
					obj1.X*obj2.X,obj1.Y*obj2.Y,obj1.Z*obj2.Z);
			else
				Source.Geometry.Point.handleInvalidData(...
					obj1, obj2, 'times', 'element-wise multiply', 'with');
			end
		end
		function result = mtimes(obj1, obj2)
			if(isnumeric(obj1) && length(obj1) == 1)
				result = Source.Geometry.Point(obj1*obj2.X,obj1*obj2.Y,obj1*obj2.Z);
			elseif(isnumeric(obj2) && length(obj2) == 1)
				result = Source.Geometry.Point(obj1.X*obj2,obj1.Y*obj2,obj1.Z*obj2);
			elseif(isa(obj1,'Source.Geometry.Point') &&...
					isa(obj2,'Source.Geometry.Point'))
				result = obj1.DotProduct(obj2);
			else
				Source.Geometry.Point.handleInvalidData(...
					obj1, obj2, 'mtimes', 'multiply', 'with');
			end
		end
		function isEqual = eq(point1, point2)
			isEqual = point1.X == point2.X &&...
				point1.Y == point2.Y &&...
				point1.Z == point2.Z;
		end
		function notEqual = ne(point1, point2)
			notEqual = point1.X ~= point2.X ||...
				point1.Y ~= point2.Y || point1.Z ~= point2.Z;
		end
		function dotProduct = DotProduct(this, otherPoint)
			dotProduct = conj(this.X*otherPoint.X + this.Y*otherPoint.Y +...
				this.Z*otherPoint.Z);
		end
		function crossProduct = CrossProduct(this, otherPoint)
			crossProduct = Source.Geometry.Point(...
				(this.Y*otherPoint.Z-otherPoint.Y*this.Z),...
				-(this.X*otherPoint.Z-otherPoint.X*this.Z),...
				(this.X*otherPoint.Y-otherPoint.X*this.Y));
		end
		function distance = Distance(this, otherPoint)
			distance = sqrt((this.X-otherPoint.X)^2+...
				(this.Y-otherPoint.Y)^2+...
				(this.Z-otherPoint.Z)^2);
		end
		function difference = Diff(this, otherPoint)
			difference = Source.Geometry.Point.New(...
				this.X-otherPoint.X,this.Y-otherPoint.Y,this.Z-otherPoint.Z);
		end
		function normValue = Norm(this)
			normValue = sqrt(this.X^2 + this.Y^2 + this.Z^2);
		end
		function isEqual = EqualTo(this, array3x1)
			isEqual = (this.X == array3x1(1) &&...
				this.Y == array3x1(2) &&...
				this.Z == array3x1(3));
		end
		function isEqual = ApproxEqualTo(this, otherPoint, tolerance)
			isEqual = (abs(this.X-otherPoint.X) <= tolerance &&...
				abs(this.Y-otherPoint.Y) <= tolerance &&...
				abs(this.Z-otherPoint.Z) <= tolerance);
		end
		function array = ToArray(this)
			array = [this.X, this.Y, this.Z];
		end
		function array = ToColumnArray(this)
			array = [this.X; this.Y; this.Z];
		end
		function struct = ToStruct(this)
			struct.X = this.X;
			struct.Y = this.Y;
			struct.Z = this.Z;
		end
		function sign = ToSign(this)
			sign = Source.Geometry.Point.New(this.X < 0, this.Y < 0, this.Z < 0);
		end
		function gmshString = ToGMSHString(this, nodeNr)
			gmshString = sprintf('%i %.16g %.16g %.16g',...
				nodeNr, this.X, this.Y, this.Z);
		end
		function str = char(this)
			str = sprintf('(% +.4g % +.4g % +.4g)', this.X, this.Y, this.Z);
		end
		function displayString = ToDisplayString(this, name, distanceUnit,...
				roundingDigits)
			% roundingDigits The amount of digits to use in rounding.
			% A positive amount rounds behind the decimal separator, a negative
			% amount rounds in front of the decimal separator.
			% e.g. round(30.23, 1) = 30.2, round(31.23,-1) = 30.
			vectorName = ['\textrm{' name '}'];
			str = '$\left[%s,%s,%s\right]$';
			str = sprintf(Source.Display.MathString.Escape(str),...
				distanceUnit, distanceUnit, distanceUnit);
			str = ['$' Source.Display.MathString.Vector('r', vectorName) '$: '...
				'$\left(%.16g, %.16g, %.16g\right)^\top$ ' str];
			if(exist('rounding', 'var'))
				displayString = sprintf(Source.Display.MathString.Escape(str),...
				round(this.X, roundingDigits),...
				round(this.Y, roundingDigits), round(this.Z, roundingDigits));
			else
				displayString = sprintf(Source.Display.MathString.Escape(str),...
				this.X, this.Y, this.Z);
			end
		end
		function newPoint = Rotate(this, rotationAxis, rotationAngle)
			rotationMatrix = Source.Geometry.Transform.GetRotationMatrix(...
				rotationAxis, rotationAngle);
			newPoint = this.FromArray(this.ToArray() * rotationMatrix);
		end
		function newPoint = ApplyMatrix(this, matrix)
			newPoint = Source.Geometry.Point(...
				this.X*matrix(1,1)+this.Y*matrix(2,1)+this.Z*matrix(3,1),...
				this.X*matrix(1,2)+this.Y*matrix(2,2)+this.Z*matrix(3,2),...
				this.X*matrix(1,3)+this.Y*matrix(2,3)+this.Z*matrix(3,3));
		end
		function newPoint = ReflectTo(this, otherNormal)
			newPoint = this.FromArray(this.ToArray() *...
				Source.Geometry.Transform.GetRotationMatrixToOtherNormal(...
				this.ToArray(), otherNormal.ToArray()));
		end
		function newPoint = ApplyMatrixTranslation(this, matrix)
			result = matrix * [this.X this.Y this.Z 1]';
			newPoint = this.FromArray(result(1:3));
		end
		function perpendicularDirection = PerpendicularDirection(this)
			if(this == Source.Geometry.Point.Origin())
				perpendicularDirection = Source.Geometry.Point.Origin();
				return;
			end
			if(this.X == 0)
				if(this.Y == 0)
					perpendicularDirection = Source.Geometry.Point.New(0, 1, 0);
				elseif(this.Z == 0)
					perpendicularDirection = Source.Geometry.Point.New(1, 0, 0);
				else
					perpendicularDirection = Source.Geometry.Point.New(0, 1,  -this.Y/this.Z);
				end
			elseif(this.Y == 0)
				if(this.Z == 0)
					perpendicularDirection = Source.Geometry.Point.New(0, 1, 0);
				else
					perpendicularDirection =...
						Source.Geometry.Point.New(1, 0, -this.X/this.Z);
				end
			elseif(this.Z == 0)
				perpendicularDirection =...
					Source.Geometry.Point.New(-this.Y/this.X, 1, 0);
			else
				perpendicularDirection =...
					Source.Geometry.Point.New(1, 1, -(this.X+this.Y)/this.Z);
			end
		end
		function perpendicularDirection = PerpendicularDirection2(this)
			if(this == Source.Geometry.Point.Origin())
				perpendicularDirection = Source.Geometry.Point.Origin();
				return;
			end
			if(this.X == 0)
				if(this.Y == 0)
					perpendicularDirection = Source.Geometry.Point.New(0, 1, 0);
				elseif(this.Z == 0)
					perpendicularDirection = Source.Geometry.Point.New(1, 0, 0);
				else
					perpendicularDirection =...
						Source.Geometry.Point.New(0, 1,  -this.Y/this.Z);
				end
			elseif(this.Y == 0)
				if(this.Z == 0)
					perpendicularDirection =...
						Source.Geometry.Point.New(0, 1, 0);
				else
					perpendicularDirection =...
						Source.Geometry.Point.New(1, 0, -this.X/this.Z);
				end
			elseif(this.Z == 0)
				perpendicularDirection =...
					Source.Geometry.Point.New(-this.Y/this.X, 1, 0);
			else
				perpendicularDirection =...
					Source.Geometry.Point.New(1, 1, -(this.X+this.Y)/this.Z);
			end
		end
		function normalizedPoint = Normalized(this)
			if(this == Source.Geometry.Point.Origin())
				normalizedPoint = Source.Geometry.Point.Origin();
				return;
			end
			normalizedPoint =...
				Source.Geometry.Point(this.X, this.Y, this.Z)/this.Norm();
		end
	end
	methods(Access = protected, Static)
		function handleInvalidData(obj1, obj2, operation, verb, preposition)
			if(isa(obj1,'Source.Geometry.Point'))
				error([Source.Geometry.Point.ERROR_CODE_PREFIX operation],...
				['Cannot %s Source.Geometry.Point'...
				' %s "%s"-object.'], verb, preposition, class(obj2));
			else
				error([Source.Geometry.Point.ERROR_CODE_PREFIX operation],...
				['Cannot %s multiply "%s"-object'...
				' %s Source.Geometry.Point.'], verb, class(obj1), preposition);
			end
		end
	end
	methods (Access = protected)
		function obj = Point(x, y, z)
			obj.X = x;
			obj.Y = y;
			obj.Z = z;
		end
	end
end