classdef LineJoinType
	enumeration
		Round
		Miter
		Chamfer
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.LineJoinType.Round
					str = 'round';
				case Source.Enum.LineJoinType.Miter
					str = 'miter';
				case Source.Enum.LineJoinType.Chamfer
					str = 'chamfer';
				otherwise
					error('Source:Enum:LineJoinType:Unknown','Unknown line join type!');
			end
		end
	end
end
