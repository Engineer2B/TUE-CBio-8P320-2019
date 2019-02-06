
fac = Source.Display.DisplayFacility.Default('Demo');
mp = Source.Display.MeshProjector.New(fac);

displayedPlane.Width = 4e-2;
displayedPlane.Height = .5e-3;
media = Source.Physics.Media.FromFolder(fac.Logger,...
	fullfile(Settings.MEDIUM_FOLDER, 'Utrecht'), 1.2e6);
topology = Source.Geometry.Topology.FromFile(...
	fullfile(...
	Settings.SURFACE_FOLDER, 'Utrecht', 'Experiment 1.1.surface'), media,...
	@(obj) strcmp(obj.Medium.Name, 'Air') == 0);

mp.ShowTopology(topology, displayedPlane.Width, displayedPlane.Height);
% Laat alle rays zien (dit duurt best lang), vandaar dat het uit staat.
%mp.ShowRays(rays, 1e-2);
mp.DisplayFacility.SetAxisLimits([-.05 .2 -.1 .1 -.2 .2]);


extrema = Source.Geometry.Extrema.FromTwoPoints(...
	repmat(-0.2,1,3),repmat(0.2,1,3));
logger = Source.Logging.Logger.Default();
patchOptsExtrema = Source.Display.Options.Patch.FromStyle(...
	fac.StyleSettings);
patchOptsExtrema.FaceColor = Source.Enum.Color.Face.red;
patchOptsExtrema.FaceAlpha = 0.1;
patchOptsExtrema.DisplayName = 'Focus';
mp.DisplayFacility.SetAxisLimits(extrema);
%mp.ShowExtrema(extrema, patchOptsExtrema);

transducer = Source.Physics.Transducer.FromTransducerFile(logger,...
	fullfile(Settings.TRANSDUCER_FOLDER,...
	'Sonalleve', 'Positions.transducer'), media);
nOfTransducerElements = length(transducer.ElementPositions);
lineOpts = arrayfun(@(linOpt) mp.DisplayFacility.LineOptions.copy(),...
	1:nOfTransducerElements);
patchOpts = arrayfun(@(patOpt) mp.DisplayFacility.PatchOptions.copy(),...
	1:2);
mp.ShowTransducer(transducer, 2e-3, [0 1e-2 0], lineOpts, patchOpts);