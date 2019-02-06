classdef Exportable < handle
	properties
		OutputCell
	end
	methods
		function AddIfNonEmpty(this, name, value)
			if(~isempty(value))
				this.OutputCell = [this.OutputCell, {name, value}];
			end
		end
		function AddTextIfNonEmpty(this, name, value)
			if(~isempty(value))
				textCell = value.ToCell();
				this.OutputCell = [this.OutputCell, {name, text(textCell{:})}];
			end
		end
		function AddFirstIfNoneEmpty(this, value)
			if(~isempty(value))
				this.OutputCell = [value, this.OutputCell];
			end
		end
		function AddFirstAsCellIfNoneEmpty(this, value)
			if(~isempty(value))
				this.OutputCell = [num2cell(value), this.OutputCell];
			end
		end
		function Apply(this, handle)
			% APPLY Apply the options to a corresponding properties handle.
			cellValues = this.ToCell();
			set(handle, cellValues{:});
		end
	end
	methods(Access = protected)
		function this = Exportable()
		end
	end
end
