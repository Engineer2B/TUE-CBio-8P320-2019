classdef RayBatch < handle
	properties
		% Array of rays.
		ReflectedLongitudinal
		% Array of rays.
		ReflectedShear
		% Array of rays.
		ReflectedFluid
		% Struct of arrays of rays.
		TransmittedShear
		% Struct of arrays of rays.
		TransmittedLongitudinal
		% Struct of arrays of rays.
		TransmittedFluid
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Physics:RayBatch:'
		CLASS_NAME = 'Source.Physics.RayBatch'
	end
	methods(Access = public, Static)
		function obj = New()
			obj = Source.Physics.RayBatch();
		end
	end
	methods(Access = public)
		function copyRay = Copy(this)
			copyRay = Source.Physics.RayBatch.FromDTO(this.ToDTO());
		end
		function dto = ToDTO(this)
			dto.ReflectedLongitudinal = this.ReflectedLongitudinal;
			dto.ReflectedShear = this.ReflectedShear;
			dto.ReflectedFluid = this.ReflectedFluid;
			dto.TransmittedShear = this.TransmittedShear;
			dto.TransmittedLongitudinal = this.TransmittedLongitudinal;
			dto.TransmittedFluid = this.TransmittedFluid;
		end
		function isEmpty = IsEmpty(this)
			isEmpty = isempty(this.ReflectedLongitudinal) &&...
				isempty(this.ReflectedShear) &&...
				isempty(this.ReflectedFluid) &&...
				isempty(this.TransmittedShear) &&...
				isempty(this.TransmittedLongitudinal) &&...
				isempty(this.TransmittedFluid);
		end
	end
	methods(Access = protected)
		function this = RayBatch()
		end
	end
end