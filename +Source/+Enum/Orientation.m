classdef Orientation
	enumeration
		Vertical
		Horizontal
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.Orientation.Vertical
					str = 'vertical';
				case Source.Enum.Orientation.Horizontal
					str = 'horizontal';
				otherwise
					error('Source:Enum:Orientation:Unknown','Unknown !');
			end
		end
	end
end

