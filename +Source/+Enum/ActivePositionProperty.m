classdef ActivePositionProperty
	enumeration
		outerposition
		position
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:ActivePositionProperty:'
		CLASS_NAME = 'Source.Enum.ActivePositionProperty'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.ActivePositionProperty.outerposition
					str = 'outerposition';
				case Source.Enum.ActivePositionProperty.position
					str = 'position';
				otherwise
					error([Source.Enum.ActivePositionProperty 'UnknownValue'],...
					'Unknown active position property!');
			end
		end
	end
end

