classdef OutsideBoundaries
	properties (Constant)
		MARKOIL_HAS_NO_OUTSIDE_BOUNDARIES_FN =...
			@(mesh) strcmp(mesh.Medium.Name, 'Markoil') == 0
	DEFAULT_HAS_OUTSIDE_BOUNDARIES_FN = @(mesh) true
	end
end