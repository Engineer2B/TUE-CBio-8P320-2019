classdef Action
	properties
		Type
		Value
		Log
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Logging:Action:'
		CLASS_NAME = 'Source.Logging.Action'
	end
	methods(Access = public, Static)
		function obj = New(type, value, log)
			obj = Source.Logging.Action(type, value, log);
		end
		function obj = Default(type, value)
			obj = Source.Logging.Action(type, value, true);
		end
	end
	methods(Access = protected)
		function this = Action(type, value, log)
			this.Type = type;
			this.Value = value;
			this.Log = log;
		end
	end
end
