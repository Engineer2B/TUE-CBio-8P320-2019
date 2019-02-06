classdef Interpreter
	enumeration
		% Interpret characters using a subset of TeX markup.
		Tex
		% Interpret characters using LaTeX markup.
		% To use LaTeX markup, set the Interpreter property to 'latex'.
		% Use dollar symbols around the text, for example, use
		% '$\int_1^{20} x^2 dx$' for inline mode or '$$\int_1^{20} x^2 dx$$'
		% for display mode.
		% The displayed text uses the default LaTeX font style.
		% The FontName, FontWeight, and FontAngle properties
		% do not have an effect.
		% To change the font style, use LaTeX markup.
		% The maximum size of the text that you can use with
		% the LaTeX interpreter is 1200 characters.
		% For multiline text, this reduces by about 10 characters per line.
		Latex
		% Display literal characters.
		None
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Enum:Interpreter:'
		CLASS_NAME = 'Source.Enum.Interpreter'
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.Interpreter.Tex
					str = 'tex';
				case Source.Enum.Interpreter.Latex
					str = 'latex';
				case Source.Enum.Interpreter.None
					str = 'none';
				otherwise
					error([Source.Enum.Interpreter.ERROR_CODE_PREFIX 'Unknown'],...
						'Unknown interpreter!');
			end
		end
	end
end

