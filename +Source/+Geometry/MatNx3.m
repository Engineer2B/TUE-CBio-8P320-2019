classdef MatNx3
	methods(Static)
		function matrix = FromStruct(arrX, arrY, arrZ)
			matrix = [arrX arrY arrZ];
		end
		function extrema = ToExtrema(matrix)
			extrema = Source.Geometry.Extrema.New(...
				Source.Geometry.Extremum.New(...
				min(matrix(:,1)), max(matrix(:,1))),...
				Source.Geometry.Extremum.New(...
				min(matrix(:,2)), max(matrix(:,2))),...
				Source.Geometry.Extremum.New(...
				min(matrix(:,3)), max(matrix(:,3))));
		end
		function equal = ApproxEq(mat1, mat2, tolerance)
			equal = all(all(abs(mat1 - mat2) <= tolerance));
		end
		function equal = Eq(mat1, mat2)
			equal = all(all(mat1 == mat2));
		end
		function rotMatrix = Rotate(mat, axis, angle)
			matrix = Source.Geometry.Transform.GetRotationMatrix(axis,...
				angle);
			rotMatrix = mat * matrix;
		end
		function ForEach(appliedFunction, values)
			nOfArgs = nargin(appliedFunction);
			switch(nOfArgs)
				case 0
					for indexValue = 1:size(values, 1)
						appliedFunction();
					end
				case 1
					for indexValue = 1:size(values, 1)
						appliedFunction(values(indexValue, :));
					end
				case 2
					for indexValue = 1:size(values, 1)
						appliedFunction(values(indexValue, :), indexValue);
					end
				case 3
					for indexValue = 1:size(values, 1)
						appliedFunction(values(indexValue, :), indexValue, values);
					end
				otherwise
					Source.Logging.Logger.ShowError(...
						'Function has invalid number of arguments',...
						[Source.Helper.List.ERROR_CODE_PREFIX...
						'ForEach:NumberOfArgumentsInvalid']);
			end
		end
	end
end
