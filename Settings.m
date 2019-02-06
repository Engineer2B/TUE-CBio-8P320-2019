classdef Settings
	%SETTINGS MATLAB settings for the entire repository.
	properties(Constant)
		TOLERANCE = 1e-12
		ROOT_FOLDER = fullfile(replace(mfilename('fullpath'),'Settings',''))
		DATA_FOLDER = fullfile(Settings.ROOT_FOLDER, 'Data')
		MSH_FOLDER = fullfile(Settings.DATA_FOLDER, 'Raw', 'gmsh','MSH')
		STATE_FOLDER = fullfile(Settings.DATA_FOLDER, 'State')
		PROFILE_FOLDER = fullfile(Settings.ROOT_FOLDER, 'Profile')
		SURFACE_FOLDER = fullfile(Settings.DATA_FOLDER, 'Surface')
		TRANSDUCER_FOLDER = fullfile(Settings.DATA_FOLDER, 'Transducer');
		PRESET_FOLDER = fullfile(Settings.DATA_FOLDER, 'Preset');
	end
end
