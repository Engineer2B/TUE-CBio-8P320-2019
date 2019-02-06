classdef WaveType < double
	enumeration
		Longitudinal(1)
		Shear(2)
	end
	methods
		function color = ToColor(this)
			switch(this)
				case Source.Enum.WaveType.Longitudinal
					color = Source.Enum.Color.Default.green;
				case Source.Enum.WaveType.Shear
					color = Source.Enum.Color.Default.white;
			end
		end
		function str = ToDisplayString(this)
			switch(this)
				case Source.Enum.WaveType.Longitudinal
					str = 'Longitudinal';
				case Source.Enum.WaveType.Shear
					str = 'Shear';
			end
		end
	end
	methods(Static)
		function waveType = From2017Struct(rayStruct)
			if(isempty(rayStruct.polarization))
				waveType = Source.Enum.WaveType.Longitudinal;
			else
				waveType = Source.Enum.WaveType.Shear;
			end
		end
	end
end