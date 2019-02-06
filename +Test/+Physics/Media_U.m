classdef Media_U < matlab.unittest.TestCase
	properties
		UniqueMedia
		FluidMedia
		SolidMedia
	end
	properties(Constant)
		MEDIUM_FOLDER = fullfile(Test.Settings.MEDIUM_FOLDER, 'Physics',...
			'Media')
	end
	methods(TestMethodSetup)
		function LoadMedia(this)
			logger = Source.Logging.Logger.Default();
			this.UniqueMedia = Shim.Physics.Media_S.New(logger);
			this.FluidMedia = Shim.Physics.Media_S.New(logger);
 			fn = fullfile(this.MEDIUM_FOLDER, 'Unique_Fluid');
 			this.FluidMedia.AddFolder(fn, Test.Settings.FREQUENCY);
			this.SolidMedia = Shim.Physics.Media_S.New(logger);
 			fn = fullfile(this.MEDIUM_FOLDER, 'Unique_Solid');
 			this.SolidMedia.AddFolder(fn, Test.Settings.FREQUENCY);
		end
	end	
	methods (Test)
		function AddAndOverwrite_ShouldOverWriteFluidOnDuplicate(this)
			fluid1 = this.FluidMedia.GetFluid('EmptySpace');
			this.assertEqual(fluid1.Density, 1050);
			fluidDTO = fluid1.ToDTO();
			fluidDTO.Density = 999;
			fluid2 = Source.Physics.Medium.Fluid.FromDTO(fluidDTO);
			this.FluidMedia.AddAndOverwrite(fluid2);
			fluid1 = this.FluidMedia.GetFluid('EmptySpace');
			this.assertEqual(fluid1.Density, 999);
		end
		function AddAndOverwrite_ShouldOverWriteSolidOnDuplicate(this)
			solid1 = this.SolidMedia.GetSolid('Bone');
			this.assertEqual(solid1.Density, 2025);
			solidDTO = solid1.ToDTO();
			solidDTO.Density = 999;
			solid2 = Source.Physics.Medium.Solid.FromDTO(solidDTO);
			this.SolidMedia.AddAndOverwrite(solid2);
			solid1 = this.SolidMedia.GetSolid('Bone');
			this.assertEqual(solid1.Density, 999);
		end
		function GetFluid_ShouldReturnFluid(this)
			fluid1 = this.FluidMedia.GetFluid('EmptySpace');
			this.assertClass(fluid1, Source.Physics.Medium.Fluid.CLASS_NAME);
			fluid2 = this.FluidMedia.GetFluid('Muscle');
			this.assertClass(fluid2, Source.Physics.Medium.Fluid.CLASS_NAME);
		end
		function GetSolid_ShouldReturnSolid(this)
			solid1 = this.SolidMedia.GetSolid('Bone');
			this.assertClass(solid1, Source.Physics.Medium.Solid.CLASS_NAME);
			solid2 = this.SolidMedia.GetSolid('StrongBone');
			this.assertClass(solid2, Source.Physics.Medium.Solid.CLASS_NAME);
		end
		function GetFluid_ShouldThrowOnUnknownFluid(this)
			getFluidCb = @() this.SolidMedia.GetFluid('asd');
			this.assertError(getFluidCb,...
				[this.UniqueMedia.ERROR_CODE_PREFIX 'GetMedium:MediumNotFound']);
		end
		function GetSolid_ShouldThrowOnUnknownSolid(this)
			getSolidCb = @() this.SolidMedia.GetSolid('asd');
			this.assertError(getSolidCb,...
				[this.UniqueMedia.ERROR_CODE_PREFIX 'GetMedium:MediumNotFound']);
		end
		function addFolder_ShouldAddUniqueFluids(this)
			fn = fullfile(this.MEDIUM_FOLDER, 'Unique_Fluid');
			this.UniqueMedia.AddFolder(fn, Test.Settings.FREQUENCY);
			this.assertEqual(length(this.UniqueMedia.Fluids), 2);
		end
		function addFolder_ShouldAddUniqueSolids(this)
			fn = fullfile(this.MEDIUM_FOLDER, 'Unique_Solid');
			this.UniqueMedia.AddFolder(fn, Test.Settings.FREQUENCY);
			this.assertEqual(length(this.UniqueMedia.Solids), 2);
		end
		function addFolder_ShouldThrowForDuplicateFluid(this)
			fn = fullfile(this.MEDIUM_FOLDER, 'Duplicate_Fluid');
			addMediumCb = @() this.UniqueMedia.AddFolder(fn,...
				Test.Settings.FREQUENCY);
			this.assertError(addMediumCb,...
				[this.UniqueMedia.ERROR_CODE_PREFIX 'Add:DuplicateMedium']);
		end
		function addFolder_ShouldThrowForDuplicateSolid(this)
			fn = fullfile(this.MEDIUM_FOLDER, 'Duplicate_Solid');
			addMediumCb = @() this.UniqueMedia.AddFolder(fn,...
				Test.Settings.FREQUENCY);
			this.assertError(addMediumCb,...
				[this.UniqueMedia.ERROR_CODE_PREFIX 'Add:DuplicateMedium']);
		end
	end
end
