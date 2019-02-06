classdef StructParser
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Helper:StructParser:'
		CLASS_NAME = 'Source.Helper.StructParser'
	end
	methods(Access = public, Static)
		function inputStruct = ReplaceFieldValue(inputStruct,...
				selectReplaces)
			fieldNameCell = fieldnames(inputStruct);
			for fieldNameIndex = 1:length(fieldNameCell)
				fieldName = fieldNameCell{fieldNameIndex};
				fieldValue = inputStruct.(fieldName);
				className = class(fieldValue);
				switch(className)
					case 'struct'
						inputStruct.(fieldName) = Source.Helper.StructParser...
						.ReplaceFieldValue(inputStruct.(fieldName), selectReplaces);
					case 'cell'
						inputStruct.(fieldName) = selectReplaces.Reduce(...
							@(result, selectReplace) selectReplace.ApplyCell(...
							fieldName, result), fieldValue);
					case {'char', 'double'}
						inputStruct.(fieldName) = selectReplaces.Reduce(...
							@(result, selectReplace) selectReplace.ApplyStruct(...
							fieldName, result), fieldValue);	
					otherwise
						Source.Logging.Logger.ShowError(sprintf(...
							"StructParser encountered unexpected class '%s'.",...
							className),...
							[Source.Helper.StructParser.ERROR_CODE_PREFIX...
							'UnexpectedClass']);
				end
			end
		end
		function inStruct = RemoveEmptyFields(inStruct)
			fieldNames = fieldnames(inStruct);
			for inField = 1:length(fieldNames)
				if(isempty(inStruct.(fieldNames{inField})))
					inStruct = rmfield(inStruct, fieldNames{inField});
				end
			end
		end
	end
end
