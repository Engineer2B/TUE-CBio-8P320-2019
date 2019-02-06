classdef CDataMapping
	enumeration
		scaled
		direct
	end
	methods
		function str = char(obj)
			switch(obj)
					case Source.Enum.CDataMapping.scaled
						str = 'scaled';
					case Source.Enum.CDataMapping.direct
						str = 'direct';
				otherwise
					error('Source:Enum:CDataMapping:UnknownValue',...
					'Unknown CDataMapping value!');
			end
		end
	end
end
