classdef Projection
	enumeration
		orthographic
		perspective
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:Projection:'
		CLASS_NAME = 'Source.Enum.Projection'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.Projection.orthographic
					str = 'orthographic';
				case Source.Enum.Projection.perspective
					str = 'perspective';
				otherwise
					error([ Source.Enum.Projection.ERROR_CODE_PREFIX 'Unknown'],...
						'Unknown Projection!');
			end
		end
	end
end
