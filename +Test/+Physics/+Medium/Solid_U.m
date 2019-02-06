classdef Solid_U < matlab.unittest.TestCase
	properties(Constant)
		MEDIUM_FOLDER = fullfile(Test.Settings.MEDIUM_FOLDER, 'Physics',...
			'Medium', 'Solid')
	end
	methods(Test)
		function SetProperties_ShouldSetProperties(this)
			absorptionEx = 0.5;
			frequencyEx = 1;
			nameEx = 'Bone';
			longitudinalSpeedEx = 2;
			shearSpeedEx = 5;
			longitudinalAttenuationEx = 4;
			shearAttenuationEx = 6;
			densityEx = 3;
			medium = Shim.Physics.Medium.Solid_S.Empty();
			medium.SetProperties(nameEx, longitudinalSpeedEx, shearSpeedEx,...
				densityEx, longitudinalAttenuationEx, shearAttenuationEx,...
				absorptionEx, frequencyEx);
			this.verifyEqual(medium.LongitudinalSpeed, longitudinalSpeedEx);
			this.verifyEqual(medium.ShearSpeed, shearSpeedEx);
			this.verifyEqual(medium.LongitudinalMin2Attenuation,...
				-2*longitudinalAttenuationEx);
			this.verifyEqual(medium.ShearMin2Attenuation, -2 * shearAttenuationEx);
			this.verifyEqual(medium.LongitudinalSpeedDensity,...
				longitudinalSpeedEx*densityEx);
			this.verifyEqual(medium.ShearSpeedDensity,...
				shearSpeedEx*densityEx);
			this.verifyNotEmpty(medium.LongitudinalK);
			this.verifyNotEmpty(medium.ShearK);
			this.verifyNotEmpty(medium.FrequencyPerLongitudinalSpeed);
			this.verifyNotEmpty(medium.FrequencyPerShearSpeed);
			this.verifyNotEmpty(medium.LongitudinalPowerConstant);
			this.verifyNotEmpty(medium.ShearModulus);
			this.verifyNotEmpty(medium.RatioSpeedShearLongitudinal);
			this.verifyNotEmpty(medium.RatioSpeedLongitudinalShear);
			this.verifyNotEmpty(medium.Xi)
			this.verifyNotEmpty(medium.Eta);
		end
		function New_TheoreticalStuffForReference2ShouldGiveSameProperties(this)
			a = Single.Demo.TheoreticalStuffForReference2.Get();
			b = Shim.Physics.Medium.Solid_S.New('Test', a.cL, a.cS, a.rho_s,...
				a.alphaL, a.alphaS, Inf, a.f);
			this.assertEqual(b.Name, 'Test');
			this.verifyEqual(b.ShearMin2Attenuation, -2*a.alphaS);
			this.verifyEqual(b.LongitudinalMin2Attenuation, -2*a.alphaL);
			this.verifyEqual(b.ShearSpeed, a.cS);
			this.verifyEqual(b.LongitudinalSpeed, a.cL);
			this.verifyEqual(b.Density, a.rho_s);
			this.verifyEqual(b.ShearSpeedDensity, a.cS*a.rho_s);
			this.verifyEqual(b.LongitudinalSpeedDensity, a.cL*a.rho_s);
			this.verifyEqual(b.LongitudinalPowerConstant,...
				sqrt(a.Const3)*a.Const4, 'abstol', Test.Settings.Tolerance);
			this.verifyEqual(b.ShearPowerConstant, sqrt(a.Const6)*a.Const7,...
				'abstol', Test.Settings.Tolerance);
			this.verifyEqual(b.FrequencyPerShearSpeed, a.f/a.cS);
			this.verifyEqual(b.FrequencyPerLongitudinalSpeed, a.f/a.cL);
			this.verifyEqual(b.Xi, a.xi);
			this.verifyEqual(b.Eta, a.eta);
		end
		function ToDTO_ShouldReturnProperties(this)
			fn = fullfile(this.MEDIUM_FOLDER, 'FromFile.solid');
			solid = Source.Physics.Medium.Solid.FromFile(fn, 1);
			dto = solid.ToDTO();
			this.verifyEqual(dto.LongitudinalAttenuation, 1,...
				'Longitudinal attenuation unequal.');
			this.verifyEqual(dto.ShearAttenuation, 2,...
				'Shear attenuation unequal.');
			this.verifyEqual(dto.LongitudinalSpeed, 4,...
				'Longitudinal speed unequal.');
			this.verifyEqual(dto.ShearSpeed, 3,...
				'Shear speed unequal.');
		end
	end
end
