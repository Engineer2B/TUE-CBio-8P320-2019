classdef TopologyTransformGUI < handle
    properties        
        GUI        
        Media
        Extrema
        GridSteps
        Topology
        FileName
        FolderName
        MeshProjector
        Zoom           = 0.9;
        PlotArea       = [-1 -1 -1;1 1 1];
        Rotation       = [0 0 0 5];
        RotationOrigin = [0 0 0 0.05];
        Translation    = [0 0 0 0.05];
    end
    methods(Access = public, Static)
        function obj = initiateGUI(fold_name,file_name)
            obj = TopologyTransformGUI();
            obj.FolderName      = fold_name;
            obj.FileName        = file_name;
            obj.MeshProjector   = Source.Display.MeshProjector.New(Source.Display.DisplayFacility.Default('Topology transform GUI'));
            obj.Media           = Source.Physics.Media.FromFolder(obj.MeshProjector.DisplayFacility.Logger, fullfile(Settings.MEDIUM_FOLDER, 'Utrecht'), 1.2e6);
            obj.Topology        = Source.Geometry.Topology.FromFile(fullfile(Settings.SURFACE_FOLDER, fold_name, strcat(file_name,'.surface')), obj.Media, @(object) strcmp(object.Medium.Name, 'Air') == 0);
            if ~exist(fullfile(Settings.CONFIGURATION_FOLDER,fold_name), 'dir')
               mkdir(fullfile(Settings.CONFIGURATION_FOLDER,fold_name))
            end
            obj.GetGUIelements();
            obj.AutoArea();
            obj.UpdateGridSteps(4);
            obj.SetupFromJSON();
            obj.MeshProjector.DisplayFacility.SetViewPoint(45,20);
        end
    end
    methods(Access = protected)
        function ShowNewTransformation(this)
            this.Transform();
            if this.GUI.cbx_auto_area.Value == 1
                this.AutoArea();
                this.UpdateGridSteps(4);
            end
            this.DrawFigure();
            this.DrawRotationAxes();
            this.UpdateTextboxes();
        end
        function Transform(this)
            this.Topology.Translate(-this.Topology.Translation);
            this.Topology.Rotate(this.Rotation(1:3)*pi/180);
            this.Topology.Translate(this.Translation(1:3)+this.RotationOrigin(1:3)-this.RotationOrigin(1:3)*Source.Geometry.Transform.rotMatFromEulerZYX(this.Rotation(1:3)*pi/180));
        end
        function AutoArea(this)
            all_nodes = [];
            for i = 1:length(this.Topology.Meshes)
                all_nodes = [all_nodes;this.Topology.Meshes(i,1).Nodes];
            end
            min_vals = min([all_nodes;this.RotationOrigin(1:3)+this.Translation(1:3)]);
            max_vals = max([all_nodes;this.RotationOrigin(1:3)+this.Translation(1:3)]);
            averages = (min_vals+max_vals)/2;
            distance = max(max_vals-min_vals)/2/this.Zoom;
            this.PlotArea = [averages-distance;averages+distance];
            this.Extrema = Source.Geometry.Extrema.FromTwoPoints(this.PlotArea(1,:),this.PlotArea(2,:));
        end
        function UpdateGridSteps(this, steps)
            this.GridSteps.X = (this.Extrema.Maximum(1)-this.Extrema.Minimum(1))/steps;
            this.GridSteps.Y = (this.Extrema.Maximum(2)-this.Extrema.Minimum(2))/steps;
            this.GridSteps.Z = (this.Extrema.Maximum(3)-this.Extrema.Minimum(3))/steps;
        end
        function DrawFigure(this)
            [az,el] = view;
            cla(gca);
            this.MeshProjector.DisplayFacility.SetAxisLimits(this.Extrema);
            this.MeshProjector.ShowTopology(this.Topology, 4e-2,.5e-3);
            axis vis3d
            this.MeshProjector.DisplayFacility.SetViewPoint(az,el)
            this.MeshProjector.DisplayFacility.ShowGrid(this.Extrema,this.GridSteps)
            rotate3d on
        end
        function DrawRotationAxes(this)
            tot_trans  = this.RotationOrigin(1:3)+this.Translation(1:3);
            axis_size  = 999;
            axis_mat_x = [axis_size 0 0]*Source.Geometry.Transform.rotMatFromEulerZYX(this.Rotation(1:3)*pi/180);
            axis_mat_y = [0 axis_size 0]*Source.Geometry.Transform.rotMatFromEulerZYX([this.Rotation(1:2)*pi/180 0]);            
            
            line([tot_trans(1) tot_trans(1)],              [tot_trans(2) tot_trans(2)],              [tot_trans(3) tot_trans(3)+axis_size],    'Color','white')
            line([tot_trans(1) tot_trans(1)],              [tot_trans(2) tot_trans(2)],              [tot_trans(3) tot_trans(3)-axis_size],    'Color','white','LineStyle','--')
            line([tot_trans(1) tot_trans(1)+axis_mat_y(1)],[tot_trans(2) tot_trans(2)+axis_mat_y(2)],[tot_trans(3) tot_trans(3)+axis_mat_y(3)],'Color','red')
            line([tot_trans(1) tot_trans(1)-axis_mat_y(1)],[tot_trans(2) tot_trans(2)-axis_mat_y(2)],[tot_trans(3) tot_trans(3)-axis_mat_y(3)],'Color','red','LineStyle','--')
            line([tot_trans(1) tot_trans(1)+axis_mat_x(1)],[tot_trans(2) tot_trans(2)+axis_mat_x(2)],[tot_trans(3) tot_trans(3)+axis_mat_x(3)],'Color','green')
            line([tot_trans(1) tot_trans(1)-axis_mat_x(1)],[tot_trans(2) tot_trans(2)-axis_mat_x(2)],[tot_trans(3) tot_trans(3)-axis_mat_x(3)],'Color','green','LineStyle','--')
        end
        function UpdateTextboxes(this)
            for i=1:4
                while this.Rotation(i)>180
                    this.Rotation(i)=this.Rotation(i)-360;
                end
                while this.Rotation(i)<-180
                    this.Rotation(i)=this.Rotation(i)+360;
                end
            end
            this.GUI.tbx_zoom.String = sprintf('%.2f',this.Zoom);
            this.GUI.tbx_area_x_min.String = sprintf('%.2f',this.PlotArea(1,1));
            this.GUI.tbx_area_y_min.String = sprintf('%.2f',this.PlotArea(1,2));
            this.GUI.tbx_area_z_min.String = sprintf('%.2f',this.PlotArea(1,3));
            this.GUI.tbx_area_x_max.String = sprintf('%.2f',this.PlotArea(2,1));
            this.GUI.tbx_area_y_max.String = sprintf('%.2f',this.PlotArea(2,2));
            this.GUI.tbx_area_z_max.String = sprintf('%.2f',this.PlotArea(2,3));
            
            this.GUI.tbx_rot_z.String = sprintf('%.2f',this.Rotation(1));
            this.GUI.tbx_rot_y.String = sprintf('%.2f',this.Rotation(2));
            this.GUI.tbx_rot_x.String = sprintf('%.2f',this.Rotation(3));
            this.GUI.tbx_rot_d.String = sprintf('%.2f',this.Rotation(4));
            
            this.GUI.tbx_origin_x.String = sprintf('%.2f',this.RotationOrigin(1));
            this.GUI.tbx_origin_y.String = sprintf('%.2f',this.RotationOrigin(2));
            this.GUI.tbx_origin_z.String = sprintf('%.2f',this.RotationOrigin(3));
            this.GUI.tbx_origin_d.String = sprintf('%.2f',this.RotationOrigin(4));
            
            this.GUI.tbx_trans_x.String = sprintf('%.2f',this.Translation(1));
            this.GUI.tbx_trans_y.String = sprintf('%.2f',this.Translation(2));
            this.GUI.tbx_trans_z.String = sprintf('%.2f',this.Translation(3));                        
            this.GUI.tbx_trans_d.String = sprintf('%.2f',this.Translation(4));
        end
        function XAxisToView(this)
            [az,el] = view;
            this.Rotation(1,1) = az-90;
            this.Rotation(1,2) = -el;
            this.ShowNewTransformation();
        end
        function ViewToXAxis(this)
            az = this.Rotation(1,1)+90;
            el = -this.Rotation(1,2);
            this.MeshProjector.DisplayFacility.SetViewPoint(az,el);
        end
        function RotationOriginToObject(this)
            this.Rotation(1:3) = this.Topology.Rotation*180/pi;
            this.RotationOrigin(1:3) = [0 0 0];
            this.Translation(1:3) = this.Topology.Translation;
            this.ShowNewTransformation();
        end
        function SetupFromJSON(this)
            JSONdir = fullfile(Settings.CONFIGURATION_FOLDER,this.FolderName,strcat(this.FileName,'.json'));
            if isfile(JSONdir)
                config_values = Source.IO.JSON.Read(JSONdir);
                if isfield(config_values,'Zoom')
                    this.Zoom = config_values.Zoom;
                    this.PlotArea = config_values.PlotArea;
                    this.Rotation = config_values.Rotation';
                    this.RotationOrigin = config_values.RotationOrigin';
                    this.Translation = config_values.Translation';
                else
                    this.Zoom = 0.9;
                    this.GUI.cbx_auto_area.Value = 1;
                    this.Rotation = [config_values.Rotation*180/pi;10]';
                    this.RotationOrigin = [0 0 0 0.1];
                    this.Translation = [config_values.Translation;0.1]';
                end
            else                
                disp('No configuration file found in:');
                disp(JSONdir);
            end            
            this.ShowNewTransformation();
        end
        function SetupToJSON(this)
            JSONdir = fullfile(Settings.CONFIGURATION_FOLDER,this.FolderName,strcat(this.FileName,'.json'));
            Source.IO.JSON.Write(struct('Zoom',this.Zoom,'PlotArea',this.PlotArea,'Rotation',this.Rotation,'RotationOrigin',this.RotationOrigin,'Translation',this.Translation),JSONdir);
        end
        function ResetTransformations(this)
            this.Rotation(1:3)     = [0 0 0];
            this.RotationOrigin(1:3) = [0 0 0];
            this.Translation(1:3)  = [0 0 0];
            this.ShowNewTransformation();
        end
        function ChangeZoom(this)
            old_zoom = this.Zoom;
            this.Zoom = str2double(this.GUI.tbx_zoom.String);
            if this.GUI.cbx_auto_area.Value == 1
                this.AutoArea();
                this.UpdateGridSteps(4);
            else
                averages = (this.PlotArea(1,:)+this.PlotArea(2,:))/2;
                distance = (this.PlotArea(2,:)-this.PlotArea(1,:))/2*old_zoom/this.Zoom;            
                this.PlotArea = [averages-distance;averages+distance];
                this.Extrema = Source.Geometry.Extrema.FromTwoPoints(this.PlotArea(1,:),this.PlotArea(2,:));
                this.UpdateGridSteps(4);
            end
            this.ShowNewTransformation();
        end
        function ChangeRotationValue(this)            
            this.Rotation     = [str2double(this.GUI.tbx_rot_z.String)   str2double(this.GUI.tbx_rot_y.String)   str2double(this.GUI.tbx_rot_x.String)   str2double(this.GUI.tbx_rot_d.String)];
            this.ShowNewTransformation();
        end
        function ChangeRotationOriginValue(this)            
            this.RotationOrigin = [str2double(this.GUI.tbx_origin_x.String)  str2double(this.GUI.tbx_origin_y.String)  str2double(this.GUI.tbx_origin_z.String)  str2double(this.GUI.tbx_origin_d.String)];
            this.ShowNewTransformation();
        end
        function ChangeTranslationValue(this)
            this.Translation  = [str2double(this.GUI.tbx_trans_x.String) str2double(this.GUI.tbx_trans_y.String) str2double(this.GUI.tbx_trans_z.String) str2double(this.GUI.tbx_trans_d.String)];
            this.ShowNewTransformation();
        end
        function ChangePlotAreaValue(this)
            this.PlotArea     = [str2double(this.GUI.tbx_area_x_min.String) str2double(this.GUI.tbx_area_y_min.String) str2double(this.GUI.tbx_area_z_min.String);
                                 str2double(this.GUI.tbx_area_x_max.String) str2double(this.GUI.tbx_area_y_max.String) str2double(this.GUI.tbx_area_z_max.String)];
            this.GUI.cbx_auto_area.Value = 0;
            this.Extrema = Source.Geometry.Extrema.FromTwoPoints(this.PlotArea(1,:),this.PlotArea(2,:));
            this.UpdateGridSteps(4);
            this.ShowNewTransformation();
        end
        function RotationButton(this,index,val_sign)
            this.Rotation(index) = this.Rotation(index)+val_sign*this.Rotation(4);
            this.ShowNewTransformation();
        end
        function RotationOriginButton(this,index,val_sign)
            this.RotationOrigin(index) = this.RotationOrigin(index)+val_sign*this.RotationOrigin(4);
            this.ShowNewTransformation();
        end
        function TranslationButton(this,index,val_sign)
            this.Translation(index) = this.Translation(index)+val_sign*this.Translation(4);
            this.ShowNewTransformation();
        end
        function GetGUIelements(this)
            scale      = 1;
            padding    = 15*scale;
            font_size  = 14*scale;
            box_width  = 70*scale;
            box_height = 30*scale;
            block_dist = 10*scale;
            
            uicontrol('String','Plot area',      'style','Text','FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0],'Position',[padding 3*block_dist+padding+14*box_height  100 box_height-3],'HorizontalAlignment','left');
            uicontrol('String','Rotation',       'style','Text','FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0],'Position',[padding 2*block_dist+padding+11*box_height  100 box_height-3],'HorizontalAlignment','left');
            uicontrol('String','Rotation origin','style','Text','FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0],'Position',[padding block_dist+padding+7*box_height     120 box_height-3],'HorizontalAlignment','left');
            uicontrol('String','Translation',    'style','Text','FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0],'Position',[padding padding+3*box_height                100 box_height-3],'HorizontalAlignment','left');
            
            this.GUI.btn_save          = uicontrol('String','Save',                     'Position',[padding                4*block_dist+padding+19*box_height 1.5*box_width box_height],'Callback',@(es,ed) this.SetupToJSON(),              'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.btn_open          = uicontrol('String','Open',                     'Position',[padding+1.5*box_width  4*block_dist+padding+19*box_height 1.5*box_width box_height],'Callback',@(es,ed) this.SetupFromJSON(),            'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.btn_origin_to_cam = uicontrol('String','X-axis to view',           'Position',[padding                4*block_dist+padding+18*box_height 3*box_width   box_height],'Callback',@(es,ed) this.XAxisToView(),              'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.btn_cam_to_axis   = uicontrol('String','View to X-axis',           'Position',[padding                4*block_dist+padding+17*box_height 3*box_width   box_height],'Callback',@(es,ed) this.ViewToXAxis(),              'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.btn_origin_to_obj = uicontrol('String','Rotation origin to object','Position',[padding                4*block_dist+padding+16*box_height 3*box_width   box_height],'Callback',@(es,ed) this.RotationOriginToObject(),   'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.btn_reset         = uicontrol('String','Reset transformation',     'Position',[padding                4*block_dist+padding+15*box_height 3*box_width   box_height],'Callback',@(es,ed) this.ResetTransformations(),     'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            
            this.GUI.cbx_auto_area     = uicontrol('String','Auto','style','checkbox',  'Position',[padding+1.15*box_width 3*block_dist+padding+14*box_height box_width     box_height],'Callback',@(es,ed) this.ShowNewTransformation(),    'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.tbx_zoom          = uicontrol('String','0.9',  'style','Edit',     'Position',[padding+2*box_width    3*block_dist+padding+14*box_height box_width     box_height],'Callback',@(es,ed) this.ChangeZoom(),               'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.tbx_area_x_max    = uicontrol('String','1.00', 'style','Edit',     'Position',[padding                3*block_dist+padding+13*box_height box_width     box_height],'Callback',@(es,ed) this.ChangePlotAreaValue(),      'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]); 
            this.GUI.tbx_area_y_max    = uicontrol('String','1.00', 'style','Edit',     'Position',[padding+box_width      3*block_dist+padding+13*box_height box_width     box_height],'Callback',@(es,ed) this.ChangePlotAreaValue(),      'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.tbx_area_z_max    = uicontrol('String','1.00', 'style','Edit',     'Position',[padding+2*box_width    3*block_dist+padding+13*box_height box_width     box_height],'Callback',@(es,ed) this.ChangePlotAreaValue(),      'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.tbx_area_x_min    = uicontrol('String','-1.00','style','Edit',     'Position',[padding                3*block_dist+padding+12*box_height box_width     box_height],'Callback',@(es,ed) this.ChangePlotAreaValue(),      'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]); 
            this.GUI.tbx_area_y_min    = uicontrol('String','-1.00','style','Edit',     'Position',[padding+box_width      3*block_dist+padding+12*box_height box_width     box_height],'Callback',@(es,ed) this.ChangePlotAreaValue(),      'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.tbx_area_z_min    = uicontrol('String','-1.00','style','Edit',     'Position',[padding+2*box_width    3*block_dist+padding+12*box_height box_width     box_height],'Callback',@(es,ed) this.ChangePlotAreaValue(),      'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);            
            
            this.GUI.tbx_rot_d         = uicontrol('String','5.00','style','Edit',     'Position',[padding+2*box_width    2*block_dist+padding+11*box_height box_width     box_height],'Callback',@(es,ed) this.ChangeRotationValue(),      'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.tbx_rot_z         = uicontrol('String','0.00', 'style','Edit',     'Position',[padding                2*block_dist+padding+10*box_height box_width     box_height],'Callback',@(es,ed) this.ChangeRotationValue(),      'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]); 
            this.GUI.tbx_rot_y         = uicontrol('String','0.00', 'style','Edit',     'Position',[padding+box_width      2*block_dist+padding+10*box_height box_width     box_height],'Callback',@(es,ed) this.ChangeRotationValue(),      'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.tbx_rot_x         = uicontrol('String','0.00', 'style','Edit',     'Position',[padding+2*box_width    2*block_dist+padding+10*box_height box_width     box_height],'Callback',@(es,ed) this.ChangeRotationValue(),      'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);            
            
            this.GUI.btn_rot_z_plus    = uicontrol('String','z+',                       'Position',[padding                2*block_dist+padding+9*box_height  box_width     box_height],'Callback',@(es,ed) this.RotationButton(1,1),        'FontSize',font_size,'ForegroundColor',[0 0 0],'BackgroundColor',[1 1 1]);
            this.GUI.btn_rot_y_plus    = uicontrol('String','y+',                       'Position',[padding+box_width      2*block_dist+padding+9*box_height  box_width     box_height],'Callback',@(es,ed) this.RotationButton(2,1),        'FontSize',font_size,'ForegroundColor',[0 1 1],'BackgroundColor',[1 0 0]);
            this.GUI.btn_rot_x_plus    = uicontrol('String','x+',                       'Position',[padding+2*box_width    2*block_dist+padding+9*box_height  box_width     box_height],'Callback',@(es,ed) this.RotationButton(3,1),        'FontSize',font_size,'ForegroundColor',[1 0 1],'BackgroundColor',[0 1 0]);
            this.GUI.btn_rot_z_min     = uicontrol('String','z-',                       'Position',[padding                2*block_dist+padding+8*box_height  box_width     box_height],'Callback',@(es,ed) this.RotationButton(1,-1),       'FontSize',font_size,'ForegroundColor',[0 0 0],'BackgroundColor',[1 1 1]);
            this.GUI.btn_rot_y_min     = uicontrol('String','y-',                       'Position',[padding+box_width      2*block_dist+padding+8*box_height  box_width     box_height],'Callback',@(es,ed) this.RotationButton(2,-1),       'FontSize',font_size,'ForegroundColor',[0 1 1],'BackgroundColor',[1 0 0]);
            this.GUI.btn_rot_x_min     = uicontrol('String','x-',                       'Position',[padding+2*box_width    2*block_dist+padding+8*box_height  box_width     box_height],'Callback',@(es,ed) this.RotationButton(3,-1),       'FontSize',font_size,'ForegroundColor',[1 0 1],'BackgroundColor',[0 1 0]);
            
            this.GUI.tbx_origin_d      = uicontrol('String','0.05','style','Edit',      'Position',[padding+2*box_width    block_dist+padding+7*box_height    box_width     box_height],'Callback',@(es,ed) this.ChangeRotationOriginValue(),'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]); 
            this.GUI.tbx_origin_x      = uicontrol('String','0.00','style','Edit',      'Position',[padding                block_dist+padding+6*box_height    box_width     box_height],'Callback',@(es,ed) this.ChangeRotationOriginValue(),'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);            

            this.GUI.tbx_origin_y      = uicontrol('String','0.00','style','Edit',      'Position',[padding+box_width      block_dist+padding+6*box_height    box_width     box_height],'Callback',@(es,ed) this.ChangeRotationOriginValue(),'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.tbx_origin_z      = uicontrol('String','0.00','style','Edit',      'Position',[padding+2*box_width    block_dist+padding+6*box_height    box_width     box_height],'Callback',@(es,ed) this.ChangeRotationOriginValue(),'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]); 
            
            this.GUI.btn_origin_x_plus = uicontrol('String','x+',                       'Position',[padding                block_dist+padding+5*box_height    box_width     box_height],'Callback',@(es,ed) this.RotationOriginButton(1,1),  'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.btn_origin_y_plus = uicontrol('String','y+',                       'Position',[padding+box_width      block_dist+padding+5*box_height    box_width     box_height],'Callback',@(es,ed) this.RotationOriginButton(2,1),  'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.btn_origin_z_plus = uicontrol('String','z+',                       'Position',[padding+2*box_width    block_dist+padding+5*box_height    box_width     box_height],'Callback',@(es,ed) this.RotationOriginButton(3,1),  'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.btn_origin_x_min  = uicontrol('String','x-',                       'Position',[padding                block_dist+padding+4*box_height    box_width     box_height],'Callback',@(es,ed) this.RotationOriginButton(1,-1), 'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.btn_origin_y_min  = uicontrol('String','y-',                       'Position',[padding+box_width      block_dist+padding+4*box_height    box_width     box_height],'Callback',@(es,ed) this.RotationOriginButton(2,-1), 'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.btn_origin_z_min  = uicontrol('String','z-',                       'Position',[padding+2*box_width    block_dist+padding+4*box_height    box_width     box_height],'Callback',@(es,ed) this.RotationOriginButton(3,-1), 'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            
            this.GUI.tbx_trans_d       = uicontrol('String','0.05','style','Edit',      'Position',[padding+2*box_width    padding+3*box_height               box_width     box_height],'Callback',@(es,ed) this.ChangeTranslationValue(),   'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]); 
            this.GUI.tbx_trans_x       = uicontrol('String','0.00','style','Edit',      'Position',[padding                padding+2*box_height               box_width     box_height],'Callback',@(es,ed) this.ChangeTranslationValue(),   'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);            
            this.GUI.tbx_trans_y       = uicontrol('String','0.00','style','Edit',      'Position',[padding+box_width      padding+2*box_height               box_width     box_height],'Callback',@(es,ed) this.ChangeTranslationValue(),   'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.tbx_trans_z       = uicontrol('String','0.00','style','Edit',      'Position',[padding+2*box_width    padding+2*box_height               box_width     box_height],'Callback',@(es,ed) this.ChangeTranslationValue(),   'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]); 
            
            this.GUI.btn_trans_x_plus  = uicontrol('String','x+',                       'Position',[padding                padding+box_height                 box_width     box_height],'Callback',@(es,ed) this.TranslationButton(1,1),     'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.btn_trans_y_plus  = uicontrol('String','y+',                       'Position',[padding+box_width      padding+box_height                 box_width     box_height],'Callback',@(es,ed) this.TranslationButton(2,1),     'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.btn_trans_z_plus  = uicontrol('String','z+',                       'Position',[padding+2*box_width    padding+box_height                 box_width     box_height],'Callback',@(es,ed) this.TranslationButton(3,1),     'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.btn_trans_x_min   = uicontrol('String','x-',                       'Position',[padding                padding                            box_width     box_height],'Callback',@(es,ed) this.TranslationButton(1,-1),    'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.btn_trans_y_min   = uicontrol('String','y-',                       'Position',[padding+box_width      padding                            box_width     box_height],'Callback',@(es,ed) this.TranslationButton(2,-1),    'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
            this.GUI.btn_trans_z_min   = uicontrol('String','z-',                       'Position',[padding+2*box_width    padding                            box_width     box_height],'Callback',@(es,ed) this.TranslationButton(3,-1),    'FontSize',font_size,'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0]);
        end
    end
end











