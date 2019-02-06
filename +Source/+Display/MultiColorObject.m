classdef MultiColorObject < handle
	%MULTICOLOROBJECT Inherit from this object to add convertColor method to
	%your object.
	methods(Access = protected)
		function color = convertColor(this, colorIn, fieldName)
			if(isa(colorIn, Source.Enum.Color.Default.CLASS_NAME))
				color = char(colorIn);
			elseif(isnumeric(colorIn) && ismatrix(colorIn) &&...
					length(colorIn) == 3)
				color = colorIn;
			elseif(isa(colorIn, 'char'))
				color = char(Source.Enum.Color.Default(colorIn));
			elseif(isa(colorIn, Source.Geometry.Point.CLASS_NAME))
				color = colorIn.ToArray();
			else
				error([this.ERROR_CODE_PREFIX fieldName ':Invalid'],...
					['Invalid ' fieldName '!']);
			end
		end
		function color = convertMarkerColor(this, colorIn, fieldName)
			if(isa(colorIn, Source.Enum.Color.Marker.CLASS_NAME))
				color = char(colorIn);
			elseif(isa(colorIn, 'char'))
				color = char(Source.Enum.Color.Marker(colorIn));
			elseif(isa(colorIn, Source.Geometry.Point.CLASS_NAME))
				color = colorIn.ToArray();
			elseif(isnumeric(colorIn) && ismatrix(colorIn) &&...
					length(colorIn) == 3)
				color = colorIn;
			else
				error([this.ERROR_CODE_PREFIX fieldName ':Invalid'],...
					['Invalid ' fieldName '!']);
			end
		end
		function color = convertFaceColor(this, colorIn, fieldName)
			if(isa(colorIn, Source.Enum.Color.Face.CLASS_NAME))
				color = char(colorIn);
			elseif(isa(colorIn, 'char'))
				color = char(Source.Enum.Color.Face(colorIn));
			elseif(isa(colorIn, Source.Geometry.Point.CLASS_NAME))
				color = colorIn.ToArray();
			elseif(isnumeric(colorIn) && ismatrix(colorIn) &&...
					length(colorIn) == 3)
				color = colorIn;
			else
				try
					color = char(Source.Enum.Color.Face(char(colorIn)));
				catch
					error([this.ERROR_CODE_PREFIX fieldName ':Invalid'],...
					['Invalid ' fieldName '!']);
				end
			end
		end
		function color = convertEdgeColor(this, colorIn, fieldName)
			if(isa(colorIn, Source.Enum.Color.Edge.CLASS_NAME))
				color = char(colorIn);
			elseif(isa(colorIn, 'char'))
				color = char(Source.Enum.Color.Edge(colorIn));
			elseif(isa(colorIn, Source.Geometry.Point.CLASS_NAME))
				color = colorIn.ToArray();
			elseif(isnumeric(colorIn) && ismatrix(colorIn) &&...
					length(colorIn) == 3)
				color = colorIn;
			else
				try
					color = char(Source.Enum.Color.Edge(char(colorIn)));
				catch
					error([this.ERROR_CODE_PREFIX fieldName ':Invalid'],...
					['Invalid ' fieldName '!']);
				end
			end
		end
		function color = convertColorbarColor(this, colorIn, fieldName)
			if(isa(colorIn, Source.Enum.Color.Colorbar.CLASS_NAME))
				color = char(colorIn);
			elseif(isa(colorIn, 'char'))
				color = char(Source.Enum.Color.Colorbar(colorIn));
			elseif(isa(colorIn, Source.Geometry.Point.CLASS_NAME))
				color = colorIn.ToArray();
			elseif(isnumeric(colorIn) && ismatrix(colorIn) &&...
					length(colorIn) == 3)
				color = colorIn;
			else
				error([this.ERROR_CODE_PREFIX fieldName ':Invalid'],...
					['Invalid ' fieldName '!']);
			end
		end
	end
end
