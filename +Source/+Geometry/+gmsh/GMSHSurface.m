classdef GMSHSurface
	properties (Access = public)
			PhysicalId
			Volumes
			Colors
	end
	methods (Access = public, Static)
		function obj = New(physicalId, volumes, colors)
				obj = Source.Geometry.gmsh.GMSHSurface(physicalId, volumes,...
					colors);
		end
		function obj = NewRandomColor(physicalId, volumes)
				obj = Source.Geometry.gmsh.GMSHSurface(physicalId, volumes,...
					Source.Helper.Random.Color());
		end
	end
	methods (Access = public)
		function isEqual = eq(GMSHSurface1, GMSHSurface2)
		 Source.Helper.Assert.IsOfType(...
			 GMSHSurface1, 'Source.Geometry.gmsh.GMSHSurface', 'GMSHSurface1');
		 Source.Helper.Assert.IsOfType(...
			 GMSHSurface2, 'Source.Geometry.gmsh.GMSHSurface', 'GMSHSurface2');
			isEqual = GMSHSurface1.equalTo(GMSHSurface2);
		end
	end
	methods (Access = protected)
		function this = GMSHSurface(physicalId, volumes, colors)
				this.PhysicalId = physicalId;
				for indexVolume = 1:length(volumes)
					volume = volumes(indexVolume);
					Source.Helper.Assert.IsOfType(volume,...
					'Source.Geometry.gmsh.GMSHVolume', 'volume');
				end
				this.Volumes = volumes;
				this.Colors = colors;
		end
		function isEqual = equalTo(this, otherGMSHSurface)
			% EQUALTO Verifies that the GMSHSurfaces are equal with regard to
			% their physical id and volumes.
			isEqual = this.PhysicalId == otherGMSHSurface.PhysicalId;
			if(~isEqual)
				return;
			end
			isEqual = length(this.Volumes) ==...
				length(otherGMSHSurface.Volumes);
			if(~isEqual)
				return;
			end
			for indexVolume = 1:length(this.Volumes)
				isEqual = isEqual && this.Volumes(indexVolume) ==...
					otherGMSHSurface.Volumes(indexVolume);
			end
		end
	end
end