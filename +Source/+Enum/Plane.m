classdef Plane
	enumeration
		Coronal
		Sagittal
		Transverse
	end
	methods
		function str = char(obj)
			switch(obj)
				case Source.Enum.Plane.Coronal
					str = 'coronal';
				case Source.Enum.Plane.Sagittal
					str = 'sagittal';
				case Source.Enum.Plane.Transverse
					str = 'transverse';
				otherwise
					Source.Logging.Logger.NotImplementedForEnumValue(obj);
			end
		end
	end
end
