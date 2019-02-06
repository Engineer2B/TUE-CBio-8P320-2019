classdef Cell
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Helper:Cell:'
		CLASS_NAME = 'Source.Helper.Cell'
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
						appliedFunction(values{indexValue});
					end
				case 2
					for indexValue = 1:length(values)
						appliedFunction(values{indexValue}, indexValue);
					end
				case 3
					for indexValue = 1:length(values)
						appliedFunction(values{indexValue}, indexValue, values);
					end
				otherwise
					Source.Logging.Logger.ShowError(...
						'Function has invalid number of arguments',...
						[Source.Helper.Cell.ERROR_CODE_PREFIX...
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
						appliedFunction(values{indexValue});
					end
				case 2
					parfor indexValue = 1:length(values)
						appliedFunction(values{indexValue}, indexValue);
					end
				case 3
					parfor indexValue = 1:length(values)
						appliedFunction(values{indexValue}, indexValue, values);
					end
				otherwise
					Source.Logging.Logger.ShowError(...
						'Function has invalid number of arguments',...
						[Source.Helper.Cell.ERROR_CODE_PREFIX...
						'ForEach:NumberOfArgumentsInvalid']);
			end
		end
		function ForEachInverted(appliedFunction, values)
			nOfArgs = nargin(appliedFunction);
			for indexValue = length(values):-1:1
				value = values{indexValue};
				switch(nOfArgs)
					case 0
						appliedFunction();
					case 1
						appliedFunction(value);
					case 2
						appliedFunction(value, indexValue);
					case 3
						appliedFunction(value, indexValue, values);
					otherwise
						Source.Logging.Logger.ShowError(...
							'Function has invalid number of arguments',...
							[Source.Helper.Cell.ERROR_CODE_PREFIX...
							'ForEachInverted:NumberOfArgumentsInvalid']);
				end
			end
		end
		function filteredValues = Filter(filterFunction, values)
			filteredValues = values(cellfun(filterFunction, values));
		end
		function result = Reduce(appliedFunction, values, initialValue)
			count = length(values);
			if(count == 0)
				if(~exist('initialValue','var'))
					Source.Logging.Logger.ShowError(...
						['Atttempting reduce on empty collection'...
						' with no initial value.'],...
					[Source.Helper.Cell.ERROR_CODE_PREFIX...
					'Reduce:EmptyNoInitialValue']);
				else
					result = initialValue;
					return;
				end
			end
			nOfArgs = nargin(appliedFunction);			
			if(~exist('initialValue','var'))
				switch(nOfArgs)
					case 2
						result = appliedFunction(0, values{1});
						for index = 2:count
							result = appliedFunction(result, values{index});
						end
					case 3
						result = appliedFunction(0, values{1}, 1);
						for index = 2:count
							result = appliedFunction(result, values{index}, index);
						end
					case 4
						result = appliedFunction(0, values{1}, 1, values);
						for index = 2:count
							result = appliedFunction(result, values{index}, index, values);
						end
					otherwise
						Source.Logging.Logger.ShowError(...
							'Function has invalid number of arguments',...
							[Source.Helper.Cell.ERROR_CODE_PREFIX...
							'Reduce:NumberOfArgumentsInvalid']);
				end
			else
				result = initialValue;
				switch(nOfArgs)
					case 2
						for index = 1:count
							result = appliedFunction(result, values{index});
						end
					case 3
						for index = 1:count
							result = appliedFunction(result, values{index}, index);
						end
					case 4
						for index = 1:count
							result = appliedFunction(result, values{index}, index, values);
						end
					otherwise
						Source.Logging.Logger.ShowError(...
							'Function has invalid number of arguments',...
							[Source.Helper.Cell.ERROR_CODE_PREFIX...
							'Reduce:NumberOfArgumentsInvalid']);
				end
			end
		end
		function [filteredValues, indices] = Find(in, filterFunction)
			qValueFiltered = cellfun(filterFunction, in);
			indices = find(qValueFiltered);
			filteredValues = in(qValueFiltered);
		end
		function cellList = AddUniquely(cellList, values, compFn)
			if(~exist('compFn', 'var'))
				compFn = @(a,b) a==b;
			end
			for indexNewValue = 1:length(values)
				newValue = values{indexNewValue};
				isUnique = true;
				for indexValue = 1:length(cellList)
					if(compFn(cellList{indexValue}, newValue))
						isUnique = false;
						break;
					end
				end
				if(isUnique)
					cellList = [cellList newValue];
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
				obj(indexValue) = values{indexValue}.Copy();
			end
		end
		function obj = ToStruct(values)
			obj = cellfun(@(value) value.ToStruct(), values);
		end
		function cellV = FromArray(values)
			cellV = arrayfun(@(in) {in}, values);
		end
		function arr = ToArray(values)
			arr = eval([class(values{1}) '.empty(0,' num2str(length(values)) ')']);
			for inValue = 1:length(values)
				arr(inValue) = values{inValue};
			end
		end
	end
end
