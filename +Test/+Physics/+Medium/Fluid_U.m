classdef Fluid_U < matlab.unittest.TestCase
	properties(Constant)
		MEDIUM_FOLDER = fullfile(Test.Settings.MEDIUM_FOLDER, 'Physics',...
			'Medium', 'Fluid')
	end
	methods(Test)
		function SetProperties_ShouldSetProperties(this)
			absorptionEx = 0.5;
			attenuationEx = 4;
			frequencyEx = 1;
			nameEx = 'Muscle';
			speedEx = 2;
			densityEx = 3;
			medium = Shim.Physics.Medium.Fluid_S.Empty();
			medium.SetProperties(nameEx, speedEx, densityEx, attenuationEx,...
				absorptionEx, frequencyEx);
			this.verifyEqual(medium.Speed, speedEx);
			this.verifyEqual(medium.Min2Attenuation, -2*attenuationEx);
			this.verifyEqual(medium.FrequencyPerSpeed,...
				frequencyEx / speedEx);
			this.verifyEqual(medium.SpeedDensity, speedEx*densityEx);
			this.verifyEqual(medium.K, 2*pi*frequencyEx/speedEx);
			this.verifyEqual(medium.SqTwoTimesSpeedDensity,...
				sqrt(2*speedEx*densityEx));
			this.verifyEqual(medium.FluidHeatProductionConstant,...
				attenuationEx/(speedEx*densityEx));
		end
		function New_TheoreticalStuffForReference2ShouldGiveSameProperties(this)
			a = Single.Demo.TheoreticalStuffForReference2.Get();
			b = Shim.Physics.Medium.Fluid_S.New('Test', a.c_g, a.rho_g,...
				a.alpha_g, Inf, a.f);
			this.verifyEqual(b.Speed, a.c_g);
			this.verifyEqual(b.Min2Attenuation, -2*a.alpha_g);
			this.verifyEqual(b.Frequency*2*pi, a.f * 2 * pi);
			this.verifyEqual(b.Density, a.rho_g);
			this.verifyEqual(b.SpeedDensity, a.Z_g);
			this.verifyEqual(b.FluidHeatProductionConstant,...
				a.Const1, 'abstol', Test.Settings.Tolerance);
			this.verifyEqual(b.K, a.k_g);
		end
		function ToDTO_ShouldReturnProperties(this)
			fn = fullfile(this.MEDIUM_FOLDER, 'FromFile.fluid');
			fluid = Source.Physics.Medium.Fluid.FromFile(fn, 1);
			dto = fluid.ToDTO();
			this.verifyEqual(dto.Attenuation, 2, 'Attenuation unequal.');
			this.verifyEqual(dto.Speed, 3, 'Speed unequal.');
		end
	end
end
