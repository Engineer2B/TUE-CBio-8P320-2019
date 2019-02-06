classdef Assert
	properties(Constant)
		CLASS_NAME = 'Source.Helper.Assert'
		ERROR_CODE_PREFIX = 'Source:Helper:Assert:'
	end
	methods(Access = public, Static)
		function object = SetIfOfType(object, type, objectName)
			Source.Helper.Assert.IsOfType(object, type, objectName);
		end
		function FileIdAccessibility(fileId, fileName)
			%FILEIDACCESSIBILITY Verifies that the fileId is not
			% smaller than 2, throws an error if it is.
			if ( fileId < 3 )
				Source.Logging.Logger.ShowError(...
					['Error could not open file ', char(fileName)],...
					[Source.Helper.Assert.ERROR_CODE_PREFIX 'FileNotFound']);
			end
		end
		function Field(object, objectName, fieldName)
			charFieldName = char(fieldName);
			charObjectName = char(objectName);
			if(~isfield(object, charFieldName))
				error([ charObjectName ' does not contain field '''...
					charFieldName '''.' ]);
			end
		end
		function IsOfType(object, type, objectName)
			if(~isa(object, char(type)))
				error(['Input ' char(objectName) ...
					' is not of type ''' char(type) ''''...
					' but of type ''' class(object) '''!']);
			end
		end
		function WithinBounds(logger, identifier, valueName, value,...
				lowerBound, upperBound)
			if(~(value >= lowerBound && value <= upperBound))
				logger.Error([valueName '''s value, ' num2str(value)...
					', lies outside the range [' num2str(lowerBound)...
					',' num2str(upperBound) ']'], identifier);
			end
		end
	end
end