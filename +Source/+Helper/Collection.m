classdef Collection < handle
	%COLLECTION A collection of objects.
	% To avoid having to implement array initialization
	% behavior in each class.
	% https://nl.mathworks.com/help/matlab/matlab_oop/creating-object-arrays.html
	properties
		Values
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Helper:Collection:'
		CLASS_NAME = 'Source.Helper.Collection'
	end
	properties(Access = protected)
		Type
	end
	properties(Dependent, SetAccess = protected)
		Count
	end
	methods
		function count = get.Count(this)
			count = length(this.Values);
		end
	end
	methods(Access = public, Static)
		function obj = New(type)
		% NEW create a new collection containing objects of type 'type'.
			obj = Source.Helper.Collection(char(type));
		end
		function obj = FromCollection(collection)
			obj = Source.Helper.Collection(collection.Type);
			obj.setValues(collection.Values);
		end
		function obj = FromStructArray(type, structArray)
			obj = Source.Helper.Collection.New(type);
			obj.Values = arrayfun(@(val) eval([type '.FromStruct(val)']),...
				structArray);
		end
	end
	methods(Access = public)
		function isEqual = EqualTo(this, other)
			isEqual = true;
			if(this.Count ~= other.Count)
				isEqual = false;
			end
			for indexValue = 1:this.Count
				isEqual = isEqual &&...
					this.Values(indexValue) == other.Values(indexValue);
				if(isEqual == false)
					return;
				end
			end
		end
		function this = Add(this, value)
			this.Values = [this.Values value];
		end
		function this = AddCollection(this, collection)
			this.Values = [this.Values collection.Values];
		end
		function this = Unique(this, comparisonFn)
			if(~exist('comparisonFn', 'var'))
				comparisonFn = @(this, that) this == that;
			end
			fullRange = 1:this.Count;
			for indexValue1 = fullRange
				value1 = this.Values(indexValue1);
				eqPositions = false(1, length(fullRange));
				for indexValue2 = fullRange
					value2 = this.Values(indexValue2);
					eqPositions(indexValue2) = comparisonFn(value1, value2);
				end
				nOfEqPositions = sum(eqPositions);
				if(nOfEqPositions > 1)
					eqPositions(indexValue1) = false;
					fullRange(fullRange>(length(fullRange) - nOfEqPositions + 1)) = [];
					this.Values(eqPositions) = [];
					if(indexValue1 == length(fullRange))
						break;
					end
				end
			end
		end
		function this = AddUniquely(this, value, compFn)
			if(~exist('compFn', 'var'))
				compFn = @(a,b) a==b;
			end
			for indexNewValue = 1:length(value)
				newValue = value(indexNewValue);
				isUnique = true;
				for indexValue = 1:this.Count
					if(compFn(this.Values(indexValue), newValue))
						isUnique = false;
						break;
					end
				end
				if(isUnique)
					this.Values = [this.Values newValue];
				end
			end
		end
		function this = Remove(this, index)
			this.Values(index) = [];
		end
		function obj = Copy(this)
			obj = Source.Helper.Collection.FromCollection(this);
		end
		function obj = DeepCopy(this)
			obj = Source.Helper.Collection.New(this.Type);
			obj.Values = eval([this.Type '.empty(0,' num2str(this.Count) ')']);
			for indexValue = 1:this.Count
				obj.Values(indexValue) = this.Values(indexValue).Copy();
			end
		end
		function obj = ToStruct(this)
			obj = arrayfun(@(value) value.ToStruct(), this.Values);
		end
		function [filteredValues, indices] = Find(this, filterFunction)
			qValueFiltered = arrayfun(filterFunction, this.Values);
			indices = find(qValueFiltered);
			filteredValues = Source.Helper.Collection.New(this.Type);
			filteredValues.setValues(this.Values(qValueFiltered));
		end
		function [filteredValue, index] = SingleOrThrow(this, filterFunction)
			qValueFiltered = arrayfun(filterFunction, this.Values);
			index = find(qValueFiltered);
			nOfValues = length(index);
			if(nOfValues~=1)
				Source.Logging.Logger.ShowError(...
					sprintf("Expected 1 value but found %i values.", nOfValues),...
					[this.ERROR_CODE_PREFIX 'SingleOrThrow:Throw']);
			end
			filteredValue =  this.Values(qValueFiltered);
		end
		function convertedValues = Map(this, newType, conversionFunction,...
				uniformOutput)
			if(~exist('uniformOutput', 'var'))
				uniformOutput = true;
			end
			newValues = arrayfun(conversionFunction, this.Values,...
				'UniformOutput', uniformOutput);
			convertedValues = Source.Helper.Collection.New(newType);
			convertedValues.setValues(newValues);
		end
		function outputValues = ParMap(this, newType, conversionFunction,...
				outputValues)
			nOfArgs = nargin(conversionFunction);
			values = this.Values;
			if(~exist('outputValues','var'))
				outputValues = eval([newType '.empty('...
					num2str(length(values)) ',0)']);
			end
			switch(nOfArgs)
				case 1
					parfor indexValue = 1:this.Count
						outputValues(indexValue,1) = feval(conversionFunction,...
							values(indexValue));
					end
				case 2
					parfor indexValue = 1:this.Count
						outputValues(indexValue,1) = feval(conversionFunction,...
							values(indexValue), indexValue);
					end
				case 3
					parfor indexValue = 1:this.Count
						outputValues(indexValue,1) = feval(conversionFunction,...
							values(indexValue), indexValue, values);
					end
				otherwise
					Source.Logging.Logger.ShowError(...
						'Function has invalid number of arguments',...
						[this.ERROR_CODE_PREFIX 'ParMap:NumberOfArgumentsInvalid']);
			end
			convertedValues = Source.Helper.Collection.New(newType);
			convertedValues.setValues(outputValues);
		end
		function filteredValues = Filter(this, filterFunction)
			newValues = this.Values(arrayfun(filterFunction, this.Values));
			filteredValues = Source.Helper.Collection.New(this.Type);
			filteredValues.setValues(newValues);
		end
		function ForEach(this, appliedFunction)
			nOfArgs = nargin(appliedFunction);
			values = this.Values;
			switch(nOfArgs)
				case 0
					for indexValue = 1:this.Count
						appliedFunction();
					end
				case 1
					for indexValue = 1:this.Count
						appliedFunction(values(indexValue));
					end
				case 2
					for indexValue = 1:this.Count
						appliedFunction(values(indexValue), indexValue);
					end
				case 3
					for indexValue = 1:this.Count
						appliedFunction(values(indexValue), indexValue, values);
					end
				otherwise
					Source.Logging.Logger.ShowError(...
						'Function has invalid number of arguments',...
						[this.ERROR_CODE_PREFIX 'ForEach:NumberOfArgumentsInvalid']);
			end
		end
		function ForEachInverted(this, appliedFunction)
			nOfArgs = nargin(appliedFunction);
			for indexValue = this.Count:-1:1
				value = this.Values(indexValue);
				switch(nOfArgs)
					case 0
						appliedFunction();
					case 1
						appliedFunction(value);
					case 2
						appliedFunction(value, indexValue);
					case 3
						appliedFunction(value, indexValue, this.Values);
					otherwise
						Source.Logging.Logger.ShowError(...
							'Function has invalid number of arguments',...
							[this.ERROR_CODE_PREFIX...
							'ForEachInverted:NumberOfArgumentsInvalid']);
				end
			end
		end
		function result = Reduce(this, appliedFunction, initialValue)
			count = this.Count;
			if(count == 0)
				if(~exist('initialValue','var'))
					Source.Logging.Logger.ShowError(...
						['Atttempting reduce on empty collection'...
						' with no initial value.'],...
					[this.ERROR_CODE_PREFIX 'Reduce:EmptyNoInitialValue']);
				else
					result = initialValue;
					return;
				end
			end
			if(~exist('initialValue','var'))
				result = this.Values(1);
				for index = 2:count
					result = appliedFunction(result, this.Values(index));
				end
			else
				result = initialValue;
				for index = 1:count
					result = appliedFunction(result, this.Values(index));
				end
			end
		end
		function result = plus(this, obj2)
			if(~isa(this,'Source.Helper.Collection'))
				Source.Logging.Logger.ShowError(...
					'Plus operation is implemented in one direction only.',...
					[this.ERROR_CODE_PREFIX 'plus:NotImplemented']);
			end
			result = Source.Helper.Collection(this.Type);
			if(isa(obj2,this.Type))
				result.setValues(this.Values);
				result.Add(obj2);
			elseif(isa(obj2,'Source.Helper.Collection'))
				result.setValues([this.Values, obj2.Values]);
			else
				Source.Logging.Logger.ShowError(...
					['Not a supported operation for non-'...
							'(' this.Type ' or Source.Helper.Collection) objects.'],...
					[this.ERROR_CODE_PREFIX 'plus:NotSupportedForType']);
			end
		end
		function isEqual = eq(this, that)
			isEqual = false;
			if(this.Count ~= that.Count)
				return;
			end
			isEqual = true;
			for indexValue = 1:this.Count
				if(this.Values(indexValue) ~= that.Values(indexValue))
					isEqual = false;
					break;
				end
			end
		end
		function isEqual = neq(this, that)
			isEqual = ~this.eq(that);
		end
		function obj = subsasgn(obj, s, val)
			switch s(1).type
				case '.'
					obj = builtin('subsasgn', obj, s, val);
				case {'()','{}'}
					if(length(obj) == 1)
						if length(s)<2
							% Redefine the struct s to make the call: obj.Data(i)
							snew = substruct('.','Values','()',s(1).subs(:));
							obj = subsasgn(obj, snew, val);
						else
							subObj = builtin('subsref', obj.Values, s(1));
							obj.Values(s(1).subs{:}) = subsasgn(subObj, s(2:end), val);
						end
					end
			end
		end
		function varargout = subsref(this,s)
			if(nargout == 2)
				[arg1,arg2] = this.baseSubsRef(s);
				varargout{1} = arg1;
				varargout{2} = arg2;
			else
				varargout{:} = this.baseSubsRef(s);
			end
		end
	end
	methods(Access = protected)
		function obj = Collection(type)
			values = eval([type '.empty(0,0)']);
			obj.Values = values;
			obj.Type = type;
		end
		function this = setValues(this, values)
			this.Values = values;
		end
		function varargout = baseSubsRef(this, s)
					 % obj(i) is equivalent to obj.Values(i)
		 switch s(1).type
			case '.'
				ses = length(s);
				if(ses > 2 && rem(ses, 2) == 0)
					switch(s(1).subs)
						case {'Find','SingleOrThrow'}
							[theObject, ~] = builtin('subsref', this, s(1:2));
							if(isa(theObject, 'Source.Helper.Collection'))
								varargout{1} = subsref(theObject, s(3:end));
							else
								varargout{1} = builtin('subsref', this, s(3:end));
							end
						case {'ForEach','ForEachInverted'}
							Source.Logging.Logger.ShowError(...
								[s(1).subs ' does not produce output'],...
								[this.ERROR_CODE_PREFIX 'subsref:NoOutputForForeach']);
						otherwise
							% This covers Map and Reduce.
							theObject = builtin('subsref', this, s(1:2));
							if(isa(theObject, 'Source.Helper.Collection'))
								if(nargout < 2)
									varargout{1} = subsref(theObject, s(3:end));
								else
									[varargout{1}, varargout{2}] =...
										subsref(theObject, s(3:end));
								end
							else
								if(nargout < 2)
									varargout{1} = builtin('subsref', this, s(3:end));
								else
									[varargout{1}, varargout{2}] =...
										builtin('subsref', this, s(3:end));
								end
							end
					end
				elseif(ses == 2)
					switch(s(1).subs)
						case {'Find', 'SingleOrThrow'}
							if(nargout < 2)
								[varargout{1}, ~] = builtin('subsref', this, s);
							else
								[varargout{1}, varargout{2}] = builtin('subsref', this, s);
							end
						case {'ForEach', 'ForEachInverted'}
							builtin('subsref', this, s);
							if(nargout>0)
								varargout{1} = 1;
							end
						otherwise
							% This covers Map and Reduce.
							varargout{1} = builtin('subsref', this, s);
					end
				else
					varargout{1} = builtin('subsref', this, s);
				end
			case {'()','{}'}
				if(length(this) == 1)
					if(isvector(s(1).subs{1}))
						if(length(s(1).subs{1}) == 1)
						obj = this.Values(s(1).subs{1});
						if(length(s) == 1)
							varargout{1} = obj;
						elseif(ismethod(obj,s(2).subs))
							try
								varargout{1} = builtin('subsref', obj, s(2:end));
							catch
								builtin('subsref', obj, s(2:end));
							end
						else
							obj = builtin('subsref', obj, s(2));
							if(length(s) == 2)
								varargout{1} = obj;
							elseif(ismethod(obj, 'subsref'))
								varargout{1} = obj.subsref(s(3:end));
							else
								varargout{1} = builtin('subsref', obj, s(3:end));
							end
						end
						else
							obj = Source.Helper.Collection(this.Type);
							obj.setValues(this.Values(s(1).subs{1}));
							if(length(s) == 1)
								varargout{1} = obj;
							else
								try
									varargout{1} = builtin('subsref', obj, s(2:end));
								catch
									builtin('subsref', obj, s(2:end));
								end
							end
						end
					else
						s(1).type = '()';
						varargout{1} = builtin('subsref', this.Values, s);
					end
				else % An array of collections
					if length(s) == 1
						s(1).type = '()';
						varargout{1} = builtin('subsref', this, s);
					else
						Source.Logging.Logger.ShowError(...
							'This is not a supported subscripted reference.',...
							[this.ERROR_CODE_PREFIX 'subsref:NotSupported']);
					end
				end
		 end
		end
	end
end
