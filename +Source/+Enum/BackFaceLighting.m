classdef BackFaceLighting
	enumeration
		reverselit
		unlit
		lit
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.BackFaceLighting.reverselit
					str = 'reverselit';
				case Source.Enum.BackFaceLighting.unlit
					str = 'unlit';
				case Source.Enum.BackFaceLighting.lit
					str = 'lit';
				otherwise
					error('Source:Enum:BackFaceLighting:Unknown',...
						'Unknown BackFaceLighting!');
			end
		end
	end
end
