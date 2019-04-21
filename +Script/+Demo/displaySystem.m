%% launch the GUI
GUI = TopologyTransformGUI.initiateGUI('Arrow','arrow');
uiwait() % wait for GUI to be closed

%% configuration files
fac = Source.Display.DisplayFacility.Default('Demo');
mp = Source.Display.MeshProjector.New(fac);

displayedPlane.Width = 4e-2;
displayedPlane.Height = .5e-3;
media    = Source.Physics.Media.FromFolder(fac.Logger, fullfile(Settings.MEDIUM_FOLDER, 'Utrecht'), 1.2e6);
topology = Source.Geometry.Topology.FromFile(fullfile(Settings.SURFACE_FOLDER, 'Utrecht', 'Experiment 1.1.surface'), media, @(obj) strcmp(obj.Medium.Name, 'Air') == 0);
extrema  = Source.Geometry.Extrema.FromTwoPoints(repmat(-0.2,1,3),repmat(0.2,1,3));
mp.DisplayFacility.SetAxisLimits(extrema);

% open GUI configuration file
topology.TransformationsFromJSON(fullfile(Settings.CONFIGURATION_FOLDER,'Arrow','arrow.json'));

% save topology configuration file
topology.TransformationsToJSON(fullfile(Settings.CONFIGURATION_FOLDER,'arrow.json'));

% open topology configuration file
topology.TransformationsFromJSON(fullfile(Settings.CONFIGURATION_FOLDER,'arrow.json'));
mp.ShowTopology(topology, displayedPlane.Width, displayedPlane.Height);

% extrema = Source.Geometry.Extrema.FromTwoPoints(...
% 	repmat(-0.2,1,3),repmat(0.2,1,3));
% logger = Source.Logging.Logger.Default();
% patchOptsExtrema = Source.Display.Options.Patch.FromStyle(...
% 	fac.StyleSettings);
% patchOptsExtrema.FaceColor = Source.Enum.Color.Face.red;
% patchOptsExtrema.FaceAlpha = 0.1;
% patchOptsExtrema.DisplayName = 'Focus';
% mp.DisplayFacility.SetAxisLimits(extrema);
% %mp.ShowExtrema(extrema, patchOptsExtrema);

% transducer = Source.Physics.Transducer.FromTransducerFile(logger,...
% 	fullfile(Settings.TRANSDUCER_FOLDER,...
% 	'Sonalleve', 'Positions.transducer'), media);
% nOfTransducerElements = length(transducer.ElementPositions);
% lineOpts = arrayfun(@(linOpt) mp.DisplayFacility.LineOptions.copy(),...
% 	1:nOfTransducerElements);
% patchOpts = arrayfun(@(patOpt) mp.DisplayFacility.PatchOptions.copy(),...
% 	1:2);
% mp.ShowTransducer(transducer, 2e-3, [0 1e-2 0], lineOpts, patchOpts);