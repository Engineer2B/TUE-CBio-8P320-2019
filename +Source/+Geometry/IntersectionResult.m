classdef IntersectionResult < handle
	properties
		MinLambda
		OutwardNormalVector
		NewMedium
		Id
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Geometry:IntersectionResult:'
		CLASS_NAME = 'Source.Geometry.IntersectionResult'
	end
	methods(Static)
		function obj = New(minLambda, outwardNormalVector, newMedium, id)
			obj = Source.Geometry.IntersectionResult();
			obj.MinLambda = minLambda;
			obj.OutwardNormalVector = outwardNormalVector;
			obj.NewMedium = newMedium;
			obj.Id = id;
		end
		function obj = Default(newMedium, id)
			obj = Source.Geometry.IntersectionResult();
			obj.MinLambda = Inf;
			obj.OutwardNormalVector = [0, 0, 0];
			obj.NewMedium = newMedium;
			obj.Id = id;
		end
	end
	methods(Access = protected)
		function this = IntersectionResult()
		end
	end
end
