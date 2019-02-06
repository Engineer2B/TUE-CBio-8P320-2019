classdef Base_U < matlab.unittest.TestCase
	properties(Constant)
		MEDIUM_FOLDER = fullfile(Test.Settings.MEDIUM_FOLDER, 'Physics',...
			'Medium', 'Base')
	end
	methods(Test)
		function ToDTO_ShouldReturnBasePropertiesForFluid(this)
			fn = fullfile(this.MEDIUM_FOLDER, 'FromFile.fluid');
			fluid = Shim.Physics.Medium.Fluid_S.FromFile(fn,...
				Test.Settings.FREQUENCY);
			dto = fluid.ToBaseDTO();
			this.assertEqual(dto.Name, 'FromFileFluid');
			this.verifyEqual(dto.Absorption, 0.1);
			this.verifyEqual(dto.Frequency, Test.Settings.FREQUENCY);
			this.verifyEqual(dto.Lambda, 9);
		end
		function ToDTO_ShouldReturnBasePropertiesForSolid(this)
			fn = fullfile(this.MEDIUM_FOLDER, 'FromFile.solid');
			solid = Shim.Physics.Medium.Solid_S.FromFile(fn,...
				Test.Settings.FREQUENCY);
			dto = solid.ToBaseDTO();
			this.assertEqual(dto.Name, 'FromFileSolid');
			this.verifyEqual(dto.Absorption, 0.2);
			this.verifyEqual(dto.Frequency, Test.Settings.FREQUENCY);
			this.verifyEqual(dto.Lambda, -316);
		end
	end
end
