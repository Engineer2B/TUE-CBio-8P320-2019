classdef LatticeOptions_U < matlab.unittest.TestCase
	properties
		LatticeOptions
		Logger
	end
	methods(TestClassSetup)
		function LoadConfiguration(this)
			this.Logger = Source.Logging.Logger.Default();
			this.LatticeOptions = Shim.Geometry.LatticeOptions_S.Mock();
		end
	end
	methods(Test)
		function Properties_ShouldBeSet(this)
			this.assertEqual(this.LatticeOptions.Spacing, [0.5 0.5 0.5]);
			this.assertTrue(Source.Geometry.Vec3.ApproxEq(...
				this.LatticeOptions.Steps, [4 4 4], Test.Settings.Tolerance));
			this.assertEqual(this.LatticeOptions.MaxFlatIndex, 64);
			this.assertEqual(this.LatticeOptions.CubeVolume, .5^3);
		end
		function GetTotalVolume_CubeLatticeShouldReturn1Volume(this)
			extrema = Shim.Geometry.Extrema_S.FromTwoPoints([0 0 0], [1 1 1]);
			spacing = [0.2 0.2 0.2];
			latticeOptions = Shim.Geometry.LatticeOptions_S.New(...
				extrema, spacing);
			this.verifyEqual(latticeOptions.GetTotalVolume(), 1, 'abstol',...
				Test.Settings.Tolerance);
		end
		function GetBoxIndexByFlatIndex(this)
			lattice = Source.Geometry.LatticeOptions.New(this.Logger,...
				Source.Geometry.Extrema.FromTwoPoints([0 0 0], [3 3 3]),...
				[1 1 1]);
			for index = 1:27
				[x y z] = ind2sub([3 3 3], index);
				boxIndex = lattice.GetBoxIndexByFlatIndex(index);
				this.verifyEqual([x y z], boxIndex);
			end
		end
	end
end
