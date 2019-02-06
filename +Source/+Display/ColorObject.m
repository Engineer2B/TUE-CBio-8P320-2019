classdef ColorObject < handle
	%COLOROBJECT Inherit from this object to add color property to your
	% object.
	properties
		Color
	end
	properties(Constant)
		ROOT_CLASS_NAME = 'Source.Display.ColorObject'
	end
	methods
		function set.Color(this, colorIn)
			if(isa(colorIn, Source.Enum.Color.Default.CLASS_NAME))
				this.Color = char(colorIn);
			elseif(isa(colorIn, 'char'))
				this.Color = char(Source.Enum.Color.Default(colorIn));
			elseif(isnumeric(colorIn) && ismatrix(colorIn) &&...
					length(colorIn) == 3)
				this.Color = colorIn;
			else
				error([this.ERROR_CODE_PREFIX 'SetColor:Invalid'],...
					'Invalid color value!');
			end
		end
		function this = UpdateColor(this, colorIn)
			this.Color = colorIn;
		end
	end
end

