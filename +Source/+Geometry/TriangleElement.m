classdef TriangleElement < handle
	%TRIANGLEELEMENT A collection of 3 points that together form a triangle.
	properties(SetAccess = protected)
		PointA
		PointB
		PointC
		Edge1 % The edge between point A and point B.
		Edge2 % The edge between point A and point C.
		Incenter % The point where the internal angle bisectors of the triangle
		% cross, i.e. the point equidistant from the triangle's sides.
		NormalVector1
		NormalVector2
		Area
	end
	properties(Constant)
		CLASS_NAME = 'Source.Geometry.TriangleElement'
		ERROR_CODE_PREFIX = 'Source:Geometry:TriangleElement:'
	end
	methods (Access = public, Static)
		function obj = New(pointA, pointB, pointC)
			obj = Source.Geometry.TriangleElement();
			obj.PointA = pointA;
			obj.PointB = pointB;
			obj.PointC = pointC;
			obj.calculateFeatures();
		end
		function obj = Empty()
			obj = Source.Geometry.TriangleElement.New(...
				[0 0 0], [0 0 0], [0 0 0]);
		end
		function obj = FromDTO(dto)
			obj = Source.Geometry.TriangleElement();
			obj.PointA = dto.PointA;
			obj.PointB = dto.PointB;
			obj.PointC = dto.PointC;
			obj.Edge1 = dto.Edge1;
			obj.Edge2 = dto.Edge2;
			obj.Incenter = dto.Incenter;
			obj.NormalVector1 = dto.NormalVector1;
			obj.NormalVector2 = dto.NormalVector2;
			obj.Area = dto.Area;
		end
	end
	methods (Access = public)
		function dto = ToDTO(this)
			dto.PointA = this.PointA;
			dto.PointB = this.PointB;
			dto.PointC = this.PointC;
			dto.Edge1 = this.Edge1;
			dto.Edge2 = this.Edge2;
			dto.Incenter = this.Incenter;
			dto.NormalVector1 = this.NormalVector1;
			dto.NormalVector2 = this.NormalVector2;
			dto.Area = this.Area;
		end
		function copy = Copy(this)
			copy = Source.Geometry.TriangleElement.FromDTO(this.ToDTO());
		end
		function meshProjector = Show(this, meshProjector)
			if(~exist('meshProjector','var'))
				meshProjector = Source.Display.MeshProjector.Default();
			end
			meshProjector.ShowTriangleElement(this);
		end
		%{
				This method implements the Moeller Trumbore intersection
				algorithm that gives the lambda value (>0) for the first
				intersection of this ray with a limit, triangle or cylinder.

				Remark: the intersection point cannot be the starting point of
				the ray means lambda > epsilon, where epsilon is typically
				1e-1.
		%}
		function lambda = FindIntersectionMTA(this, origin, direction)
			lambda = Inf;
			% Begin calculating the determinant which is also used
			% to calculate the u parameter.
			crossDvE = [direction(2)*this.Edge2(3) - direction(3)*this.Edge2(2),...
				direction(3)*this.Edge2(1) - direction(1)*this.Edge2(3),...
				direction(1)*this.Edge2(2) - direction(2)*this.Edge2(1)];
			inverseDeterminant = 1/(crossDvE*this.Edge1');
			% Calculate the direction from the ray's origin to vertex 1.
			lambdas = origin - this.PointA;
			% Calculate the u parameter
			u = (lambdas*crossDvE') * inverseDeterminant;
			if( u >=0 && u <=1 ) % Test bound.
				q = [lambdas(2)*this.Edge1(3) - lambdas(3)*this.Edge1(2),...
				lambdas(3)*this.Edge1(1) - lambdas(1)*this.Edge1(3),...
				lambdas(1)*this.Edge1(2) - lambdas(2)*this.Edge1(1)];
				v = inverseDeterminant * (q * direction');
				if( v >= 0 && u + v <=1 )
					% The intersection of the ray with the infinite plane
					% spanned by the triangle lies inside of the triangle.
					lambda = inverseDeterminant * (this.Edge2 * q');
				end
			end
		end
		function lambda = FindIntersectionMTAOld(this, origin, direction)
			lambda = Inf;
			% Find vectors of the two edges sharing vertex 1.
			array1x3DoubleEdge1 = [...
				this.PointB(1)-this.PointA(1),...
				this.PointB(2)-this.PointA(2),...
				this.PointB(3)-this.PointA(3)];
			array1x3DoubleEdge2 = [...
				this.PointC(1)-this.PointA(1),...
				this.PointC(2)-this.PointA(2),...
				this.PointC(3)-this.PointA(3)];
			% Begin calculating the determinant which is also used
			% to calculate the u parameter.
			array1x3DoubleP   = [...
				direction(2)*array1x3DoubleEdge2(3) - direction(3)*array1x3DoubleEdge2(2),...
				direction(3)*array1x3DoubleEdge2(1) - direction(1)*array1x3DoubleEdge2(3),...
				direction(1)*array1x3DoubleEdge2(2) - direction(2)*array1x3DoubleEdge2(1)];
			doubleDeterminant = array1x3DoubleEdge1(1)*array1x3DoubleP(1)+...
					array1x3DoubleEdge1(2)*array1x3DoubleP(2)+...
					array1x3DoubleEdge1(3)*array1x3DoubleP(3);
			doubleInverseDeterminant = 1/doubleDeterminant;
			% Calculate the distance from vertex 1 to the ray's
			% origin.
			array1x3DoubleLambda = [...
				origin(1)-this.PointA(1),...
				origin(2)-this.PointA(2),...
				origin(3)-this.PointA(3)];
			% Calculate the u parameter and test bound.
			doubleU = (array1x3DoubleLambda(1)*array1x3DoubleP(1)+...
					array1x3DoubleLambda(2)*array1x3DoubleP(2)+...
					array1x3DoubleLambda(3)*array1x3DoubleP(3))*...
					doubleInverseDeterminant;
			if(doubleU >= 0 && doubleU <= 1)
				% Prepare to test the v parameter.
				array1x3DoubleQ       = [...
					array1x3DoubleLambda(2)*array1x3DoubleEdge1(3) - array1x3DoubleLambda(3)*array1x3DoubleEdge1(2),...
					array1x3DoubleLambda(3)*array1x3DoubleEdge1(1) - array1x3DoubleLambda(1)*array1x3DoubleEdge1(3),...
					array1x3DoubleLambda(1)*array1x3DoubleEdge1(2) - array1x3DoubleLambda(2)*array1x3DoubleEdge1(1)];
				% Calculate v parameter and test bound.
				doubleV = doubleInverseDeterminant*...
						(direction(1)*array1x3DoubleQ(1)+...
						direction(2)*array1x3DoubleQ(2)+...
						direction(3)*array1x3DoubleQ(3));
				if(doubleV >= 0 && doubleU + doubleV <= 1)
					% The intersection lies inside of the
					% triangle.
					lambda = doubleInverseDeterminant*...
							(array1x3DoubleEdge2(1)*array1x3DoubleQ(1)+...
							array1x3DoubleEdge2(2)*array1x3DoubleQ(2)+...
							array1x3DoubleEdge2(3)*array1x3DoubleQ(3));
				end
			end
		end
		function isEqual = eq(this, that)
			isEqual = all(this.PointA == that.PointA) &&...
				all(this.PointB == that.PointB) &&...
				all(this.PointC == that.PointC) &&...
				all(this.Edge1 == that.Edge1) &&...
				all(this.Edge2 == that.Edge2) &&...
				all(this.Incenter == that.Incenter) &&...
				all(this.NormalVector1 == that.NormalVector1) &&...
				all(this.NormalVector2 == that.NormalVector2);
		end
		function isNotEqual = ne(this, that)
			isNotEqual = ~(this == that);
		end
		function isEqual = ApproxEqualTo(this, that, tolerance)
			isEqual = all(abs(this.PointA-that.PointA) <= tolerance) &&...
				all(abs(this.PointB-that.PointB) <= tolerance) &&...
				all(abs(this.PointC-that.PointC) <= tolerance) &&...
				all(abs(this.Edge1-that.Edge1) <= tolerance) &&...
				all(abs(this.Edge2-that.Edge2) <= tolerance) &&...
				all(abs(this.Incenter-that.Incenter) <= tolerance) &&...
				all(abs(this.NormalVector1-that.NormalVector1) <= tolerance) &&...
				all(abs(this.NormalVector2-that.NormalVector2) <= tolerance);
		end
		function this = ApplyMatrix(this, matrix)
			this.PointA = this.PointA*matrix;
			this.PointB = this.PointB*matrix;
			this.PointC = this.PointC*matrix;
			this.calculateFeatures();
		end
		function this = ChangeInclination(this, inclinationAngle)
			matrix = Source.Geometry.Transform.GetRotationMatrix('y',...
				inclinationAngle);
			this.PointA = this.PointA*matrix;
			this.PointB = this.PointB*matrix;
			this.PointC = this.PointC*matrix;
			this.Edge1 = this.Edge1*matrix;
			this.Edge2 = this.Edge2*matrix;
			this.Incenter = this.Incenter*matrix;
			this.NormalVector1 = Source.Geometry.Vec3.Normalize(...
				this.NormalVector1*matrix);
			this.NormalVector2 = Source.Geometry.Vec3.Normalize(...
				this.NormalVector2*matrix);
		end
		function this = ChangeAzimuth(this, azimuthAngle)
			matrix = Source.Geometry.Transform.GetRotationMatrix('z',...
				azimuthAngle);
			this.PointA = this.PointA*matrix;
			this.PointB = this.PointB*matrix;
			this.PointC = this.PointC*matrix;
			this.Edge1 = this.Edge1*matrix;
			this.Edge2 = this.Edge2*matrix;
			this.Incenter = this.Incenter*matrix;
			this.NormalVector1 = Source.Geometry.Vec3.Normalize(...
				this.NormalVector1*matrix);
			this.NormalVector2 = Source.Geometry.Vec3.Normalize(...
				this.NormalVector2*matrix);
		end
		function this = Translate(this, translation)
			this.PointA = this.PointA + translation;
			this.PointB = this.PointB + translation;
			this.PointC = this.PointC + translation;
			this.Incenter = this.Incenter + translation;
			% Not translating normal vectors.
        end
% % % % %
        function this = Rotate(this, rotationMatrix)
            this.PointA = this.PointA*rotationMatrix;
            this.PointB = this.PointB*rotationMatrix;
            this.PointC = this.PointC*rotationMatrix;
            this.Incenter = this.Incenter*rotationMatrix;
            this.Edge1 = this.PointA-this.PointB;
            this.Edge2 = this.PointA-this.PointC;
        end
% % % % % 
		function this = Rescale(this, factor)
			this.PointA = this.PointA * factor;
			this.PointB = this.PointB * factor;
			this.PointC = this.PointC * factor;
			this.Edge1 = this.Edge1 * factor;
			this.Edge2 = this.Edge2 * factor;
			[~,this.Area] = this.getArea();
			this.Incenter = this.Incenter * factor;
			% Not rescaling normal vectors.
		end
		function extrema = ToExtrema(this)
			matrix = [this.PointA; this.PointB; this.PointC;...
				(this.NormalVector1 + this.Incenter);...
				(this.NormalVector2 + this.Incenter)];
			extrema = Source.Geometry.Extrema.FromMatrixLx3(matrix);
		end
	end
	methods (Access = protected)
			function this = TriangleElement()
			end
			function [areaVector, area] = getArea(this)
				areaVector = cross(this.Edge1, this.Edge2);
				area = norm(areaVector)/2;
			end
			function incenter = getIncenter(this)
				incenter = (this.PointA + this.PointB + this.PointC)/3;
			end
			function calculateFeatures(this)
				this.Edge1 = this.PointB - this.PointA;
				this.Edge2 = this.PointC - this.PointA;
				[areaVector, this.Area] = this.getArea();
				this.NormalVector1 = areaVector/(this.Area*2);
				this.NormalVector2 = -this.NormalVector1;
				this.Incenter = this.getIncenter();
			end
	end
end