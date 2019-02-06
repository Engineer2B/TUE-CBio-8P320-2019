classdef Boundary < handle & Source.Display.ColorObject
	properties (SetAccess = protected)
		HasOutsideBoundariesFn
		% The name of the medium.
		Medium
	end
	properties
		Id
		IsShown = true
	end
	properties(Dependent)
		MediumChar
	end
	methods
		function mediumString = get.MediumChar(this)
			mediumString = char(this.Medium.Name);
		end
	end
	methods(Access = protected)
		function dto = toDTO(this)
			dto.MediumName = this.Medium.Name;
			dto.Id = str2double(this.Id);
			dto.Color = this.Color;
		end
		function setBaseProperties(this, medium, id, color,...
				hasOutsideBoundariesFn)
			Source.Helper.Assert.IsOfType(medium, Source.Physics.Medium...
				.Base.BASE_CLASS_NAME, 'medium');
			this.Medium = Source.Helper.Assert.SetIfOfType(medium,...
				Source.Physics.Medium.Base.BASE_CLASS_NAME, 'medium');
			Source.Helper.Assert.IsOfType(id, 'double', 'id');
			this.Id = num2str(id);
			this.Color = color;
			this.HasOutsideBoundariesFn = hasOutsideBoundariesFn;
		end
	end
end

