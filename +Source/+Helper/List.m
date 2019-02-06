classdef List
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Helper:List:'
		CLASS_NAME = 'Source.Helper.List'
	end
	methods(Static)
		function ForEach(appliedFunction, values)
			nOfArgs = nargin(appliedFunction);
			switch(nOfArgs)
				case 0
					for indexValue = 1:length(values)
						appliedFunction();
					end
				case 1
					for indexValue = 1:length(values)
						appliedFunction(values(indexValue));
					end
				case 2
					for indexValue = 1:length(values)
						appliedFunction(values(indexValue), indexValue);
					end
				case 3
					for indexValue = 1:length(values)
						appliedFunction(values(indexValue), indexValue, values);
					end
				otherwise
					Source.Logging.Logger.ShowError(...
						'Function has invalid number of arguments',...
						[Source.Helper.List.ERROR_CODE_PREFIX...
						'ForEach:NumberOfArgumentsInvalid']);
			end
		end
		function ParForEach(appliedFunction, values)
			nOfArgs = nargin(appliedFunction);
			switch(nOfArgs)
				case 0
					parfor indexValue = 1:length(values)
						appliedFunction();
					end
				case 1
					parfor indexValue = 1:length(values)
						appliedFunction(values(indexValue));
					end
				case 2
					parfor indexValue = 1:length(values)
						appliedFunction(values(indexValue), indexValue);
					end
				case 3
					parfor indexValue = 1:length(values)
						appliedFunction(values(indexValue), indexValue, values);
					end
				otherwise
					Source.Logging.Logger.ShowError(...
						'Function has invalid number of arguments',...
						[Source.Helper.List.ERROR_CODE_PREFIX...
						'ForEach:NumberOfArgumentsInvalid']);
			end
		end
		function ForEachInverted(appliedFunction, values)
			nOfArgs = nargin(appliedFunction);
			switch(nOfArgs)
				case 0
					for indexValue = length(values):-1:1
						appliedFunction();
					end
				case 1
					for indexValue = length(values):-1:1
						appliedFunction(values(indexValue));
					end
				case 2
					for indexValue = length(values):-1:1
						appliedFunction(values(indexValue), indexValue);
					end
				case 3
					for indexValue = length(values):-1:1
						appliedFunction(values(indexValue), indexValue, values);
					end
				otherwise
					Source.Logging.Logger.ShowError(...
						'Function has invalid number of arguments',...
						[Source.Helper.List.ERROR_CODE_PREFIX...
						'ForEachInverted:NumberOfArgumentsInvalid']);
			end
		end
		function filteredValues = Filter(filterFunction, values)
			filteredValues = values(arrayfun(filterFunction, values));
		end
		function result = Reduce(appliedFunction, values, initialValue)
			count = length(values);
			if(count == 0)
				if(~exist('initialValue','var'))
					Source.Logging.Logger.ShowError(...
						['Atttempting reduce on empty collection'...
						' with no initial value.'],...
					[Source.Helper.List.ERROR_CODE_PREFIX...
					'Reduce:EmptyNoInitialValue']);
				else
					result = initialValue;
					return;
				end
			end
			if(~exist('initialValue','var'))
				result = values(1);
				for index = 2:count
					result = appliedFunction(result, values(index));
				end
			else
				result = initialValue;
				for index = 1:count
					result = appliedFunction(result, values(index));
				end
			end
		end
		function values = Unique(values, comparisonFn)
			if(~exist('comparisonFn', 'var'))
				comparisonFn = @(this, that) this == that;
			end
			fullRange = 1:length(values);
			for indexValue1 = fullRange
				if(indexValue1 > length(values))
					return;
				end
				value1 = values(indexValue1);
				eqPositions = false(1, length(fullRange));
				for indexValue2 = fullRange
					value2 = values(indexValue2);
					eqPositions(indexValue2) = comparisonFn(value1, value2);
				end
				nOfEqPositions = sum(eqPositions);
				if(nOfEqPositions > 1)
					eqPositions(indexValue1) = false;
					fullRange(fullRange>(length(fullRange) - nOfEqPositions + 1))...
						= [];
					values(eqPositions) = [];
					if(indexValue1 == length(fullRange))
						break;
					end
				end
			end
		end
		function obj = DeepCopy(values)
			obj = eval([class(values) '.empty(0,' num2str(length(values)) ')']);
			for indexValue = 1:length(values)
				obj(indexValue) = values(indexValue).Copy();
			end
		end
		function obj = ToStruct(values)
			obj = arrayfun(@(value) value.ToStruct(), values);
		end
	end
end
