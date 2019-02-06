classdef ClippingStyle
	enumeration
		box3d
		rectangle
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:ClippingStyle:'
		CLASS_NAME = 'Source.Enum.ClippingStyle'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.ClippingStyle.box3d
					str = '3dbox';
				case Source.Enum.ClippingStyle.rectangle
					str = 'rectangle';
				otherwise
					error([Source.Enum.ClippingStyle 'UnknownValue'],...
					'Unknown clipping style!');
			end
		end
	end
end

