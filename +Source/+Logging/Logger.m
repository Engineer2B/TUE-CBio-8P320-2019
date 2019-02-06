classdef Logger
	%LOGGER Summary of this class goes here
	%   Detailed explanation goes here
	properties
		Verboseness
		Prefix
		Style
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Logging:Logger:'
		CLASS_NAME = 'Source.Logging.Logger'
	end
	methods
		function value = get.Prefix(obj)
			if(isa(obj.Prefix, 'function_handle'))
				value = char(obj.Prefix());
			else
				value = char(obj.Prefix);
			end
		end
	end
	methods(Access = public)
		function LogAction(this, action)
			switch(this.Verboseness)
				case Source.Enum.VerbosityEnum.Verbose
					stack = dbstack;
					methodName = replace(stack(2).name, '.Dispatch', '');
					message = ['Dispatching action ' methodName '.'...
						char(action.Type) ' with values: '];
					External.cprintf.cprintf(this.Style,...
						'%s%s\n', this.Prefix, message);
					if(~isa(action.Value, 'double'))
						disp(action.Value)
					elseif(action.Value ~=0)
						disp(action.Value)
					end
				case {Source.Enum.VerbosityEnum.Normal,...
						Source.Enum.VerbosityEnum.Warning,...
						Source.Enum.VerbosityEnum.Error}
					% We are only printing the messages, warnings and errors here.
				otherwise
					error([this.ERROR_CODE_PREFIX 'LogAction'],...
					'Unknown/undefined VerbosityEnum level');
			end
		end
		function Log(this, verboseMessage, normalMessage)
			switch(this.Verboseness)
				case Source.Enum.VerbosityEnum.Verbose
					External.cprintf.cprintf(this.Style,...
						'%s%s\n', this.Prefix, verboseMessage);
				case Source.Enum.VerbosityEnum.Normal
					if(exist('normalMessage', 'var'))
						External.cprintf.cprintf(this.Style,...
							'%s%s\n', this.Prefix, normalMessage);
					end
				case {Source.Enum.VerbosityEnum.Warning,...
						Source.Enum.VerbosityEnum.Error}
					% We are only printing the warnings and errors here.
				otherwise
					error([this.ERROR_CODE_PREFIX 'Log'],...
					'Unknown/undefined VerbosityEnum level');
			end
		end
		function Warning(this, warningMessage)
			switch(this.Verboseness)
				case Source.Enum.VerbosityEnum.Error
					% We are only printing the errors here.
				case { Source.Enum.VerbosityEnum.Normal,...
						Source.Enum.VerbosityEnum.Verbose,...
						Source.Enum.VerbosityEnum.Warning }
					warning([this.Prefix char(warningMessage)]);
				otherwise
					error([this.ERROR_CODE_PREFIX 'Warning'],...
					'Unknown/undefined VerbosityEnum level');
			end
		end
		function Error(this, errorMessage, identifier)
			message = strcat(this.Prefix, errorMessage);
			Source.Logging.Logger.ShowError(message, identifier);
		end
		function LogNotImplementedForEnumValue(this, enumValue)
			stack = dbstack;
			Source.Logging.Logger.NotImplementedForEnumValue(enumValue,...
				this.Prefix, stack);
		end
	end
	methods(Access = public, Static)
		function NotImplementedForEnumValue(enumValue, prefix, dbStack)
			if(~exist('prefix', 'var'))
				prefix = '';
			end
			if(~exist('dbStack', 'var'))
				dbStack = dbstack;
			end
			if(~isempty(regexp(dbStack(2).name,'.*\.char$', 'match')))
				strVal = char(['the error is in the function char itself, '...
					'so there is no character version of this enum']);
			else
				strVal = char(enumValue);
			end
			identifier = regexprep(dbStack(2).name,'\.',':');
			message = [prefix 'There is no implementation of function "',...
				identifier '" for value "' strVal '"!'];
			Source.Logging.Logger.ShowError(message, identifier);
		end
		function Print3x3Matrix(inputMatrix, digits)
			nStr = ['%.' num2str(digits) 'f'];
			fprintf([ '\n' nStr '\t' nStr '\t' nStr '\n'...
				nStr '\t' nStr '\t' nStr '\n'...
				nStr '\t' nStr '\t' nStr '\n'],inputMatrix');
		end
		function obj = FromHandles(structHandles)
			Source.Logging.Logger.ValidateHandles(structHandles);
			structParsSession = structHandles.structParsSession;
			obj = Source.Logging.Logger(...
				structParsSession.VerbosityEnum, structParsSession.prefix,...
				structParsSession.style);
		end
		function structHandles = AddToHandles(structHandles)
			if(~isfield(structHandles, 'logger'))
				structHandles.logger = Source.Logging.Logger(...
					Source.Enum.VerbosityEnum.Verbose, '', [128,128,128]/255);
			end
		end
		function obj = New(verboseness, prefix, style)
			obj = Source.Logging.Logger(verboseness, prefix, style);
		end
		function obj = RandomColor(verboseness, prefix)
			obj = Source.Logging.Logger(verboseness, prefix,...
				Source.Helper.Random.Color());
		end
		function obj = Default()
			obj = Source.Logging.Logger(Source.Enum.VerbosityEnum.Verbose,...
				@() strcat(Source.Logging.DateTime.Now(), " "),...
				Source.Helper.Random.Color());
		end
		function obj = TimeWithPrefix(prefix)
			obj = Source.Logging.Logger(Source.Enum.VerbosityEnum.Verbose,...
				@() strcat(Source.Logging.DateTime.Now(), prefix),...
				Source.Helper.Random.Color());
		end
		function ShowError(errorMessage, identifier)
				errorStruct.message = char(errorMessage);
				errorStruct.identifier = char(identifier);
				error(errorStruct);
		end
	end
	methods(Access = private, Static)
		function ValidateHandles(structHandles)
			Source.Helper.Assert.Field(structHandles, 'structHandles', 'structParsSession');
			Source.Helper.Assert.Field(structHandles.structParsSession,...
				'structHandles.structParsSession', 'VerbosityEnum');
			Source.Helper.Assert.Field(structHandles.structParsSession,...
				'structHandles.structParsSession', 'prefix');
			Source.Helper.Assert.Field(structHandles.structParsSession,...
				'structHandles.structParsSession', 'style');
		end
	end
	methods(Access = private)
		function this = Logger(verboseness, prefix, style)
			this.Verboseness = verboseness;
			this.Prefix = prefix;
			this.Style = style;
		end
	end
end
