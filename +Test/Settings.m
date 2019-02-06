classdef Settings < matlab.unittest.TestCase
	%SETTINGS Settings that can be used when running tests.
	%   Detailed explanation goes here
	properties(Constant)
		Tolerance = 1e-12
		FREQUENCY = 1.2e6
		STATE_FOLDER = fullfile(Settings.STATE_FOLDER, 'Test')
		MESH_FILE = fullfile(Settings.DATA_FOLDER, 'Raw', 'Mat',...
			'Mesh.Simple.mat')
		GMSH_FILE = fullfile(Settings.DATA_FOLDER, 'Raw', 'gmsh',...
			'MSH', 'oneCylinder.msh')
		MEDIUM_FOLDER = fullfile(Settings.MEDIUM_FOLDER, 'Test')
		MAIN_TEST_MEDIA = Source.Physics.Media.FromFolder(...
			Source.Logging.Logger.Default(),...
			fullfile(Settings.MEDIUM_FOLDER, 'Test', 'MAIN'), 1.2e6)
		TRANSDUCER_FOLDER = fullfile(Settings.TRANSDUCER_FOLDER, 'Test')
		SURFACE_FOLDER = fullfile(Settings.SURFACE_FOLDER, 'Test')
		PRESET_FOLDER = fullfile(Settings.PRESET_FOLDER, 'Test')
		CONFIGURATION_FOLDER = fullfile(Settings.CONFIGURATION_FOLDER,...
			'Test')
	end
	methods(Test)
		function Constant_PathShouldNotContainTheWordSettingsInName(this)
			occurences = count(mfilename('fullpath'), 'Settings');
			this.assertEqual(occurences, 1,...
				['None of the superfolders that contain this program should'...
				'contain the word "Settings"!']);
		end
	end
end
