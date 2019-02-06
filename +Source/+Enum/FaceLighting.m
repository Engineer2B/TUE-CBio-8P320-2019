classdef FaceLighting
	enumeration
		flat
		gouraud
		none
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:FaceLighting:'
		CLASS_NAME = 'Source.Enum.FaceLighting'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.FaceLighting.flat
					str = 'flat';
				case Source.Enum.FaceLighting.gouraud
					str = 'gouraud';
				case Source.Enum.FaceLighting.none
					str = 'none';
				otherwise
					error([Source.Enum.FaceLighting.ERROR_CODE_PREFIX 'Unknown'],...
						'Unknown FaceLighting!');
			end
		end
	end
end
