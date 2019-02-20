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

tbx_z_rot = uicontrol('String','0','style','Edit','FontSize',20,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0],'Position',[10 110 70 50]);
tbx_y_rot = uicontrol('String','0','style','Edit','FontSize',20,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0],'Position',[80 110 70 50]);
tbx_x_rot = uicontrol('String','0','style','Edit','FontSize',20,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0],'Position',[150 110 70 50]);
rotate_stuff(mp,fac,displayedPlane,[0 0 0],tbx_z_rot,tbx_y_rot,tbx_x_rot)
view(45,20)
change = pi/18;
btn_z_min  = uicontrol('Callback',@(btn_z_min,event)  rotate_stuff(mp,fac,displayedPlane,[str2double(tbx_z_rot.String)*pi/180-change str2double(tbx_y_rot.String)*pi/180        str2double(tbx_x_rot.String)*pi/180],tbx_z_rot,tbx_y_rot,tbx_x_rot),       'String','z-','FontSize',20,'ForegroundColor',[0 1 1],'BackgroundColor',[1 0 0],'Position',[10 10 70 50]);
btn_z_plus = uicontrol('Callback',@(btn_z_plus,event) rotate_stuff(mp,fac,displayedPlane,[str2double(tbx_z_rot.String)*pi/180+change str2double(tbx_y_rot.String)*pi/180        str2double(tbx_x_rot.String)*pi/180],tbx_z_rot,tbx_y_rot,tbx_x_rot),       'String','z+','FontSize',20,'ForegroundColor',[0 1 1],'BackgroundColor',[1 0 0],'Position',[10 60 70 50]);
btn_y_min  = uicontrol('Callback',@(btn_y_min,event)  rotate_stuff(mp,fac,displayedPlane,[str2double(tbx_z_rot.String)*pi/180        str2double(tbx_y_rot.String)*pi/180-change str2double(tbx_x_rot.String)*pi/180],tbx_z_rot,tbx_y_rot,tbx_x_rot),       'String','y-','FontSize',20,'ForegroundColor',[1 0 1],'BackgroundColor',[0 1 0],'Position',[80 10 70 50]);
btn_y_plus = uicontrol('Callback',@(btn_y_plus,event) rotate_stuff(mp,fac,displayedPlane,[str2double(tbx_z_rot.String)*pi/180        str2double(tbx_y_rot.String)*pi/180+change str2double(tbx_x_rot.String)*pi/180],tbx_z_rot,tbx_y_rot,tbx_x_rot),       'String','y+','FontSize',20,'ForegroundColor',[1 0 1],'BackgroundColor',[0 1 0],'Position',[80 60 70 50]);
btn_x_min  = uicontrol('Callback',@(btn_x_min,event)  rotate_stuff(mp,fac,displayedPlane,[str2double(tbx_z_rot.String)*pi/180        str2double(tbx_y_rot.String)*pi/180        str2double(tbx_x_rot.String)*pi/180-change],tbx_z_rot,tbx_y_rot,tbx_x_rot),'String','x-','FontSize',20,'ForegroundColor',[1 1 0],'BackgroundColor',[0 0 1],'Position',[150 10 70 50]);
btn_x_plus = uicontrol('Callback',@(btn_x_plus,event) rotate_stuff(mp,fac,displayedPlane,[str2double(tbx_z_rot.String)*pi/180        str2double(tbx_y_rot.String)*pi/180        str2double(tbx_x_rot.String)*pi/180+change],tbx_z_rot,tbx_y_rot,tbx_x_rot),'String','x+','FontSize',20,'ForegroundColor',[1 1 0],'BackgroundColor',[0 0 1],'Position',[150 60 70 50]);

function rotate_stuff(mp,fac,displayedPlane,eul,tbx_z_rot,tbx_y_rot,tbx_x_rot)
    [az,el] = view;
    for i=1:3
        if eul(i)>pi
            eul(i)=eul(i)-2*pi;    
        elseif eul(i)<-pi
            eul(i)=eul(i)+2*pi; 
        end
    end
    tbx_z_rot.String = round(eul(1)/pi*180);
    tbx_y_rot.String = round(eul(2)/pi*180);
    tbx_x_rot.String = round(eul(3)/pi*180);
    % reload every time it rotates, which is slow
    media = Source.Physics.Media.FromFolder(fac.Logger,...
        fullfile(Settings.MEDIUM_FOLDER, 'Utrecht'), 1.2e6);
    topology = Source.Geometry.Topology.FromFile(...
        fullfile(...
        Settings.SURFACE_FOLDER, 'Utrecht', 'Experiment 1.1.surface'), media,...
        @(obj) strcmp(obj.Medium.Name, 'Air') == 0);
    rot_mat = topology.Rotate(eul);
    ct = cos([eul(1:2) 0]);
    st = sin([eul(1:2) 0]);
    axis_mat_y = [0 -1 0;0 1 0]*[ct(:,2).*ct(:,1) ct(:,2).*st(:,1) -st(:,2);st(:,3).*st(:,2).*ct(:,1) - ct(:,3).*st(:,1) st(:,3).*st(:,2).*st(:,1) + ct(:,3).*ct(:,1) st(:,3).*ct(:,2);ct(:,3).*st(:,2).*ct(:,1) + st(:,3).*st(:,1) ct(:,3).*st(:,2).*st(:,1) - st(:,3).*ct(:,1) ct(:,3).*ct(:,2)];
    axis_mat_x = [-1 0 0;1 0 0]*rot_mat;
    
    plot3([0 0],[0 0],[-1 1],'r')
    axis vis3d
    view(az,el)    
    hold(mp.DisplayFacility.AxesHandle, 'on');
    plot3(axis_mat_y(:,1),axis_mat_y(:,2),axis_mat_y(:,3),'g')
    plot3(axis_mat_x(:,1),axis_mat_x(:,2),axis_mat_x(:,3),'b')
    
    hold(mp.DisplayFacility.AxesHandle, 'off'); 
    extrema = Source.Geometry.Extrema.FromTwoPoints(...
        repmat(-0.2,1,3),repmat(0.2,1,3));
    grid(fac.AxesHandle,'on')
    mp.DisplayFacility.SetAxisLimits(extrema);
    mp.ShowTopology(topology, displayedPlane.Width, displayedPlane.Height);
    view(az,el)
end

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