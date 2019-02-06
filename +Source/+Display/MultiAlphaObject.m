classdef MultiAlphaObject < handle
	%MULTIALPHAOBJECT Inherit from this object to add convertAlpha method to
	% your object.
	methods(Access = protected)
		function alpha = convertAlpha(this, alphaIn, fieldName)
			if(isa(alphaIn, 'Source.Enum.Alpha'))
				alpha = char(alphaIn);
			elseif(isnumeric(alphaIn) && length(alphaIn) == 1)
				alpha = alphaIn;
			else
				error([this.ERROR_CODE_PREFIX fieldName ':Invalid'],...
				['Invalid ' fieldName ' value!']);
			end
		end
		function alpha = convertEdgeAlpha(this, alphaIn, fieldName)
			if(isa(alphaIn, Source.Enum.EdgeAlpha.CLASS_NAME))
				alpha = char(alphaIn);
			elseif(isnumeric(alphaIn) && length(alphaIn) == 1)
				alpha = alphaIn;
			else
				error([this.ERROR_CODE_PREFIX fieldName ':Invalid'],...
				['Invalid ' fieldName ' value!']);
			end
		end
	end
end
