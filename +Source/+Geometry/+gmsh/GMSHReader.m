classdef GMSHReader < handle
	%GMSHREADER GMSHReader .MSH file reader.
	% This reader is expecting a .MSH file with a trianglesurface mesh as
	% input.
	properties
		FileName
		Logger
		FileId
		State
		GMSHMedia
		MeshDatas
		Surfaces
		SurfaceMeshes
		Media
		Options
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Geometry:gmsh:GMSHReader:'
		CLASS_NAME = 'Source.Geometry.gmsh.GMSHReader'
	end
	properties(Access = protected)
		VolumeIndices
	end
	properties(Access = protected, Constant)
		SectionHeaderRegex = '^(\d+)$'
		PhysicalNamesRegex = '\d\s(\d)\s\"(.*)\"'
		PhysicalSurfaceRegex = '(?<MediumName>\w+)_(?<VolumeIndex>\d+)'
		SplitNamesRegex = '+'
		NodeRegex = ['\d (?<X>[-]*[0-9]{1,}\.{0,1}[0-9]*([eE][-+]+[0-9]+)*) '...
			'(?<Y>[-]*[0-9]{1,}\.{0,1}[0-9]*([eE][-+]+[0-9]+)*) '...
			'(?<Z>[-]*[0-9]{1,}\.{0,1}[0-9]*([eE][-+]+[0-9]+)*)']
		ELEMENT_REGEX = ['\d+\s(?<Type>\d+)\s(?<NOfTags>\d+)\s(?<Tag>\d+)\s'...
			'(?<SurfaceIndex>\d+)\s(?<Node1>\d+)\s(?<Node2>\d+)\s(?<Node3>\d+)']
	end
	methods(Access = public, Static)
		function obj = New(fileName, logger, options)
			obj = Source.Geometry.gmsh.GMSHReader(fileName, logger, options);
		end
	end
	methods
		function delete(this)
			if(~isempty(this.FileId) &&...
					this.State ~= Source.Enum.MSHReadState.Final)
				fclose(this.FileId);
			end
		end
		function Reset(this)
			this.State = Source.Enum.MSHReadState.Initial;
			this.VolumeIndices = Source.Helper.Collection.New('double');
		end
		function surfaceCollection = Read(this)
			if(this.State ~= Source.Enum.MSHReadState.Initial)
				this.Logger.Log(['Already read the file "' this.FileName '".']);
				return
			end
			this.FileId = fopen(this.FileName);
			Source.Helper.Assert.FileIdAccessibility(this.FileId, this.FileName);
			% loop until end of file is reached
			while ~feof(this.FileId)
				% read the current line
				line = fgetl(this.FileId);
				newState = this.getReaderState(line);
				if(this.State ~= newState)
					this.State = newState;
					continue
				end
				this.parseLine(line);
			end
			fclose(this.FileId);
			this.State = Source.Enum.MSHReadState.Final;
			surfaceCollection = this.Surfaces;
		end
		function [surfaceMeshes, surfaceCollection] = ExportMeshes(this, media)
			Source.Helper.Assert.IsOfType(media,...
				Source.Physics.Media.CLASS_NAME, 'media');
			if(this.State == Source.Enum.MSHReadState.Initial)
				this.Read();
			end
			surfaceCollection = this.Surfaces;
			if(~isempty(this.SurfaceMeshes))
				surfaceMeshes = this.SurfaceMeshes;
				return;
			end
			this.SurfaceMeshes = Source.Geometry.TriangleSurfaceMesh...
				.empty(0, length(this.MeshDatas));
			for inMeshData = 1:length(this.MeshDatas)
				this.MeshDatas(inMeshData).SetMediumName(...
					this.MeshDatas(inMeshData).BoundaryMedia);
				this.MeshDatas(inMeshData).SetId(inMeshData);
				this.SurfaceMeshes(inMeshData) =...
					this.MeshDatas(inMeshData).Copy(media);
			end
			surfaceMeshes = this.SurfaceMeshes;
		end
	end
	methods(Access = protected)
		function this = GMSHReader(fileName, logger, options)
			this.FileName = fileName;
			this.Logger = logger;
			this.State = Source.Enum.MSHReadState.Initial;
			this.Media = {};
			Source.Helper.Assert.IsOfType(options,...
				Source.Geometry.gmsh.GMSHReaderOptions.CLASS_NAME, 'options');
			this.VolumeIndices = Source.Helper.Collection.New('double');
			this.Options = options;
		end
		function state = getReaderState(this, line)
			if(line(1) ~= '$')
				state = this.State;
				return
			end
			try
				state = Source.Enum.MSHReadState.(line(2:end));
			catch exception
				if(strcmp(exception.identifier,...
						"MATLAB:subscripting:classHasNoPropertyOrMethod") == 1)
					state = this.State;
					return
				end
				rethrow(exception);
			end
		end
		function parseLine(this, line)
			switch this.State
				case { Source.Enum.MSHReadState.Initial,...
							Source.Enum.MSHReadState.MeshFormat,...
							Source.Enum.MSHReadState.EndElements,...
							Source.Enum.MSHReadState.EndPhysicalNames,...
							Source.Enum.MSHReadState.EndNodes,...
							Source.Enum.MSHReadState.EndMeshFormat }
				case Source.Enum.MSHReadState.PhysicalNames
					contentName = 'physical name';
					nOfEntries = this.readSectionHeader(line, contentName);
					this.GMSHMedia = Source.Geometry.gmsh.GMSHSurface.empty(...
						nOfEntries, 0);
					this.Surfaces = Source.Geometry.gmsh.OpenMesh.empty(...
						nOfEntries, 0);
					for indexLine = 1:nOfEntries
						line = fgetl(this.FileId);
						GMSHSurface = this.readPhysicalName(line);
						this.GMSHMedia(indexLine) = GMSHSurface;
						for indexVolume = 1:length(GMSHSurface.Volumes)
							this.Media = Source.Helper.Cell.AddUniquely(this.Media,...
								{GMSHSurface.Volumes(indexVolume).MediumName},...
								@(a,b) strcmp(a,b) == 1);
						end
					end
					this.MeshDatas = Source.Geometry.gmsh.OpenMesh...
						.empty(length(this.Media), 0);
					for indexMedium = 1:length(this.Media)
						medium = this.Media{indexMedium};
						this.MeshDatas(indexMedium) = Source.Geometry...
							.gmsh.OpenMesh.Unfilled(this.FileName, medium,...
							Source.Helper.Random.Color(),...
							this.Options.HasOutsideBoundariesFn);
					end
				case Source.Enum.MSHReadState.Nodes
					contentName = 'nodes';
					nOfEntries = this.readSectionHeader(line, contentName);
					nodes = zeros(nOfEntries,3);
					for indexLine = 1:nOfEntries
						line = fgetl(this.FileId);
						nodes(indexLine,:) = this.readNode(line);
					end
					for indexMeshData = 1:length(this.MeshDatas)
						this.MeshDatas(indexMeshData).SetNodes(nodes);
					end
				case Source.Enum.MSHReadState.Elements
					contentName = 'triangle elements';
					nOfEntries = this.readSectionHeader(line, contentName);
					this.parseElementLines(nOfEntries);
				otherwise
					error([this.ERROR_CODE_PREFIX 'MSHReadStateUnsupported'],...
					['State "' char(this.State) '" is not yet supported.']);
			end
		end
		function parseElementLines(this, nOfEntries)
			for indexLine = 1:nOfEntries
				line = fgetl(this.FileId);
				[elementIndices, volumes, volumeIndex] =...
					this.readElement(line);
				for indexVolume = 1:length(volumes)
					elementMedium = volumes(indexVolume).MediumName;
					[~, indexMedium] = Source.Helper.Cell.Find(this.Media,...
						@(medium) strcmp(medium, elementMedium) == 1);
					this.MeshDatas(indexMedium).SetElementIndices(...
						[this.MeshDatas(indexMedium).ElementIndices; elementIndices]);
				end
				% Let's hope volume ids are monotonically increasing.
				this.VolumeIndices.AddUniquely(volumeIndex);
				nOfIndices = this.VolumeIndices.Count;
				if(length(this.Surfaces) < nOfIndices)
					this.Surfaces(volumeIndex) =...
						Source.Geometry.gmsh.OpenMesh.Unfilled(this.FileName,...
						[volumes(1).MediumName, volumes(2).MediumName],...
						Source.Helper.Random.Color(),...
						this.Options.HasOutsideBoundariesFn);
				end
				[~, surfaceIndex] = this.VolumeIndices.SingleOrThrow(...
					@(anIndex) anIndex == volumeIndex);
				this.Surfaces(surfaceIndex).SetElementIndices(...
					[this.Surfaces(surfaceIndex).ElementIndices; elementIndices]);
			end
			for indexSurface = 1:length(this.Surfaces)
				surface = this.Surfaces(indexSurface);
				surface.SetNodes(this.MeshDatas(1).Nodes);
			end
		end
		function nOfEntries = readSectionHeader(this, line, contentName)
			[tokens, ~] = regexp(line, this.SectionHeaderRegex, 'tokens',...
				'match');
			if(isempty(tokens))
				error([this.ERROR_CODE_PREFIX 'SectionAbsent'],...
				['File "' this.FileName '" does not contain a required "'...
				contentName '" section.']);
			end
			nOfEntries = str2double(tokens{1}{1});
			if(nOfEntries < 1)
				error([this.ERROR_CODE_PREFIX 'EntriesAbsent'],...
				['No "' contentName '" entries were defined for "' this.FileName '".']);
			end
		end
		function GMSHSurface = readPhysicalName(this, line)
			[tokens, ~] = regexp(line, this.PhysicalNamesRegex, 'tokens',...
				'match');
			physicalId = str2double(tokens{1}{1});
			splitStrings = regexp(tokens{1}{2}, this.SplitNamesRegex, 'split');
			physicalNameInfos = cellfun(@(splitString)...
				regexp(splitString, this.PhysicalSurfaceRegex, 'names'),...
				splitStrings);
			volumes = arrayfun(@(physicalNameInfo)...
				Source.Geometry.gmsh.GMSHVolume.FromPhysicalNameInfo(...
				physicalNameInfo), physicalNameInfos);
			GMSHSurface = Source.Geometry.gmsh.GMSHSurface.NewRandomColor(...
				physicalId,  volumes);
		end
		function node = readNode(this, line)
			result = regexp(line, this.NodeRegex, 'names');
			node = [str2double(result.X), str2double(result.Y),...
				str2double(result.Z)];
		end
		function [elementIndices, volumes, volumeIndex] = readElement(this,...
				line)
			result = regexp(line, this.ELEMENT_REGEX, 'names');
			elementIndices = [str2double(result.Node1),...
				str2double(result.Node2), str2double(result.Node3)];
			tag = str2double(result.Tag);
			gmshMedia = this.GMSHMedia(arrayfun(...
				@(gmshMedium) gmshMedium.PhysicalId == tag, this.GMSHMedia));
			if(length(gmshMedia) ~= 1)
				this.Logger.Error(['Expecting GMSHMedia to contain exactly 1'...
					'GMSHMedium with the given tag: ' num2str(tag) '.'],...
				Source.Geometry.gmsh.GMSHReader.ERROR_CODE_PREFIX);
			end
			volumes = gmshMedia.Volumes;
			volumeIndex = tag;
		end
	end
end

