classdef GMSHVolume
	properties
		MediumName
		VolumeIndex
	end
	methods(Access = public, Static)
		function obj = New(mediumName, volumeIndex)
			obj = Source.Geometry.gmsh.GMSHVolume(mediumName, volumeIndex);
		end
		function obj = FromPhysicalNameInfo(physicalNameInfo)
			obj = Source.Geometry.gmsh.GMSHVolume.New(...
				physicalNameInfo.MediumName,...
				str2double(physicalNameInfo.VolumeIndex));
		end
	end
	methods(Access = public)
		function isEqual = eq(this, otherGMSHVolume)
			isEqual = strcmp(this.MediumName, otherGMSHVolume.MediumName) == 1 &&...
				this.VolumeIndex == otherGMSHVolume.VolumeIndex;
		end
	end
	methods(Access = protected)
		function this = GMSHVolume(mediumName, volumeIndex)
			this.MediumName = mediumName;
			Source.Helper.Assert.IsOfType(volumeIndex, 'double', 'volumeIndex');
			this.VolumeIndex = volumeIndex;
		end
	end
end

