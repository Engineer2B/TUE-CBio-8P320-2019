classdef Patch < matlab.mixin.Copyable &...
		Source.Display.MultiAlphaObject & Source.Display.MultiColorObject &...
		Source.Display.Exportable
	% See also https://nl.mathworks.com/help/matlab/ref/matlab.graphics.primitive.patch-properties.html
	properties
		% Face
		FaceColor = 'none'
		FaceAlpha = 1
		FaceLighting = Source.Enum.FaceLighting.flat
		BackFaceLighting = Source.Enum.BackFaceLighting.reverselit
		% Eges
		EdgeColor = 'cyan'
		EdgeAlpha = 1
		EdgeLighting = Source.Enum.FaceLighting.none
		LineStyle = Source.Enum.LineStyle.Solid
		LineWidth = 0.5
		AlignVertexCenters = Source.Enum.Toggle.Off
		% Markers
		Marker = Source.Enum.Marker.None
		MarkerSize = 6
		MarkerEdgeColor = 'auto'
		% This value is only used for markers with an internal surface.
		MarkerFaceColor = 'none'
		% Color and Transparency Mapping
		% Face and vertex colors
		FaceVertexCData = []
		% Patch color data
		CData
		% Direct or scaled color data mapping
		CDataMapping = Source.Enum.CDataMapping.scaled
		% Face and vertex transparency values
		FaceVertexAlphaData = []
		% Interpretation of FaceVertexAlphaData values
		AlphaDataMapping = Source.Enum.AlphaDataMapping.none
		% Face and Vertex Normals
		FaceNormals
		FaceNormalsMode = Source.Enum.Mode.auto
		VertexNormals
		VertexNormalsMode = Source.Enum.Mode.auto
		% Ambient lighting
		% Strength of ambient light
		AmbientStrength = 0.3
		% Strength of diffuse light
		DiffuseStrength = 0.6
		% Strength of specular reflection
		SpecularStrength = 0.9
		% Color of specular reflections
		SpecularColorReflectance = 1
		% Expansiveness of specular reflection
		SpecularExponent = 10
		% Data
		% Patch can either use faces and vertices or X, Y, Z data
		Faces
		Vertices
		XData
		YData
		ZData
		% Legend
		IncludeInLegend = Source.Enum.Toggle.On
		% Legend label, specified as a character vector or string.
		% If you do not specify the text, then the legend uses a label of the 
		% form 'dataN'.
		% The legend does not display until you call the legend command or 
		% the ShowLegend function on the DisplayFacility.
		% See also Source.Display.DisplayFacility.
		DisplayName = ''
		Visible = Source.Enum.Toggle.On
		Opacity = 1;
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Display:Options:Patch:'
		CLASS_NAME = 'Source.Display.Options.Patch'
	end
	methods(Access = public, Static)
		function obj = New()
			obj = Source.Display.Options.Patch();
		end
		function obj = FromStyle(styleSettings)
			obj = Source.Display.Options.Patch();
			obj.EdgeColor = styleSettings.ForegroundColor;
		end
	end
	methods
		function set.FaceColor(this, colorIn)
			this.FaceColor = this.convertFaceColor(colorIn, 'FaceColor');
		end
		function set.EdgeColor(this, colorIn)
			this.EdgeColor = this.convertFaceColor(colorIn, 'EdgeColor');
		end
		function set.MarkerEdgeColor(this, colorIn)
			this.MarkerEdgeColor = this.convertMarkerColor(colorIn,...
				'MarkerEdgeColor');
		end
		function set.MarkerFaceColor(this, colorIn)
			this.MarkerFaceColor = this.convertMarkerColor(colorIn,...
				'MarkerFaceColor');
		end
		function set.FaceAlpha(this, alphaIn)
			this.FaceAlpha = this.convertAlpha(alphaIn, 'FaceAlpha');
		end
		function set.EdgeAlpha(this, alphaIn)
			this.EdgeAlpha = this.convertAlpha(alphaIn, 'EdgeAlpha');
		end
	end
	methods(Access = public)
		function AddRandomMarkers(this, inputLength)
			this.Marker = Source.Enum.Marker(1+floor(rand*13));
			this.MarkerIndices = 1:ceil(inputLength/...
				((1+rand)*log10(inputLength))):inputLength;
		end
		function cellObject = ToCell(this)
			this.OutputCell = {...
				'FaceColor', this.FaceColor,...
				'FaceAlpha', this.FaceAlpha,...
				'FaceLighting', char(this.FaceLighting),...
				'BackFaceLighting', char(this.BackFaceLighting),...
				'EdgeColor', this.EdgeColor,...
				'BackFaceLighting', char(this.BackFaceLighting),...
				'LineStyle', char(this.LineStyle),...
				'LineWidth', this.LineWidth,...
				'AlignVertexCenters', char(this.AlignVertexCenters),...
				'Marker', char(this.Marker),...
				'MarkerSize', this.MarkerSize,...
				'MarkerEdgeColor', this.MarkerEdgeColor,...
				'MarkerFaceColor', this.MarkerFaceColor,...
				'DisplayName', this.DisplayName,...
				'Visible', char(this.Visible),...
				'AmbientStrength', this.AmbientStrength,...
				'DiffuseStrength', this.DiffuseStrength,...
				'SpecularStrength', this.SpecularStrength,...
				'SpecularColorReflectance', this.SpecularColorReflectance,...
				'SpecularExponent', this.SpecularExponent};
			this.AddIfNonEmpty('Faces', this.Faces);
			this.AddIfNonEmpty('Vertices', this.Vertices);
			this.AddIfNonEmpty('XData', this.XData);
			this.AddIfNonEmpty('YData', this.YData);
			this.AddIfNonEmpty('ZData', this.ZData);
			this.AddIfNonEmpty('CData', this.CData);
			this.AddIfNonEmpty('CDataMapping', char(this.CDataMapping));
			cellObject = this.OutputCell;
		end
	end
	methods(Access = protected)
		function this = Patch()
		end
	end
end
