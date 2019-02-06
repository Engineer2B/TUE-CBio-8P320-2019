classdef AlphaDataMapping
	enumeration
		scaled
		direct
		none
	end
	methods
		function str = char(obj)
			switch(obj)
					case Source.Enum.AlphaDataMapping.scaled
						str = 'scaled';
					case Source.Enum.AlphaDataMapping.direct
						str = 'direct';
					case Source.Enum.AlphaDataMapping.none
						str = 'none';
				otherwise
					error('Source:Enum:AlphaDataMapping:UnknownValue',...
					'Unknown AlphaDataMapping value!');
			end
		end
	end
end
