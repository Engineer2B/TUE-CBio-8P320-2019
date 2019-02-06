classdef Media < handle
	% MEDIA A wrapper class for a collection of Media.
	properties(SetAccess = protected)
		Fluids
		Solids
		Logger
		NameToMediumMap
		NumberToMediumMap
		NameToNumberMap
		Count
	end
	properties(Constant)
		CLASS_NAME = 'Source.Physics.Media'
		ERROR_CODE_PREFIX = 'Source:Physics:Media:'
	end
	methods(Access = public)
		function id = GetId(this, mediumName)
			id = this.NameToNumberMap(mediumName);
		end
		function AddAndOverwrite(this, medium)
			mediumType = class(medium);
			switch(mediumType)
				case Source.Physics.Medium.Fluid.CLASS_NAME
					index = this.getIndexOfMediumByName(this.Fluids, medium.Name);
					if(index == -1)
						this.Fluids = [this.Fluids, medium];
					else
						this.Fluids(index) = medium;
					end
				case Source.Physics.Medium.Solid.CLASS_NAME
					index = this.getIndexOfMediumByName(this.Solids, medium.Name);
					if(index == -1)
						this.Solids = [this.Solids, medium];
					else
						this.Solids(index) = medium;
					end
				otherwise
					this.throwUnknownMediumTypeError(mediumType);
			end
			this.setMediumMaps();
		end
		function Add(this, medium)
			mediumType = class(medium);
			switch(mediumType)
				case Source.Physics.Medium.Fluid.CLASS_NAME
					newFluids = [this.Fluids, medium];
					if(~this.isMediaListUnique(newFluids))
						this.throwDuplicateMediumError(medium);
					end
					this.Fluids = newFluids;
				case Source.Physics.Medium.Solid.CLASS_NAME
					newSolids = [this.Solids, medium];
					if(~this.isMediaListUnique(newSolids))
						this.throwDuplicateMediumError(medium);
					end
					this.Solids = newSolids;
				otherwise
					this.throwUnknownMediumTypeError(mediumType);
			end
			this.setMediumMaps();
		end
		function medium = GetSolid(this, name)
			for inSolid = 1:length(this.Solids)
				if(strcmp(this.Solids(inSolid).Name, name))
					medium = this.Solids(inSolid);
					return;
				end
			end
			this.throwMediumNotFoundError(name);
		end
		function medium = GetFluid(this, name)
			for inFluid = 1:length(this.Fluids)
				if(strcmp(this.Fluids(inFluid).Name, name))
					medium = this.Fluids(inFluid);
					return;
				end
			end
			this.throwMediumNotFoundError(name);
		end
	end
	methods(Access = public, Static)
		function obj = Empty(logger)
			obj = Source.Physics.Media();
			obj.Logger = logger;
		end
		function obj = FromFolder(logger, folderName, frequency)
			obj = Source.Physics.Media();
			obj.Logger = Source.Helper.Assert.SetIfOfType(logger,...
				Source.Logging.Logger.CLASS_NAME, 'logger');
			obj.addFolder(folderName, frequency);
		end
		function obj = FromConfig(config)
			obj = Source.Physics.Media.FromFolder(config.Logger,...
				config.MediumFolderPath, config.Frequency);
		end
	end
	methods(Access = protected, Static)
		function isUnique = isMediaListUnique(mediaList)
			isUnique = length(mediaList) == length(Source.Helper.List.Unique(...
				mediaList, @(med1, med2) strcmp(med1.Name, med2.Name) == 1));
		end
		function index = getIndexOfMediumByName(mediaList, name)
			index = -1;
			for inMedia = 1:length(mediaList)
				if(strcmp(mediaList(inMedia).Name, name) == 1)
					index = inMedia;
					return;
				end
			end
		end
	end
	methods(Access = protected)
		function obj = Media()
		end
		function setMediumMaps(this)
			solidCells = Source.Helper.Cell.FromArray(this.Solids);
			fluidCells = Source.Helper.Cell.FromArray(this.Fluids);
			mediaCells = [fluidCells, solidCells];
			this.Count = length(this.Fluids)+length(this.Solids);
			this.NumberToMediumMap = containers.Map(1:this.Count, mediaCells);
			keyNames = {};
			values = [1:length(this.Fluids), length(this.Fluids)+1:1:this.Count];
			for inFluid = 1:length(this.Fluids)
				keyNames = [keyNames, {this.Fluids(inFluid).Name}];
			end
			for inSolid = 1:length(this.Solids)
				keyNames = [keyNames, {this.Solids(inSolid).Name}];
			end
			this.NameToNumberMap = containers.Map(keyNames, values);
			this.NameToMediumMap = containers.Map(keyNames, mediaCells);
		end
		function addFolder(this, folderName, frequency)
			files = dir(folderName);
			nOfFiles = length(files);
			for inFile = 1:nOfFiles
				file = files(inFile);
				[~, ~, ext] = fileparts(file.name);
				switch(ext)
					case Source.Physics.Medium.Fluid.FILE_EXTENSION
						fn = fullfile(folderName, file.name);
						this.Add(Source.Physics.Medium.Fluid.FromFile(fn, frequency));
					case Source.Physics.Medium.Solid.FILE_EXTENSION
						fn = fullfile(folderName, file.name);
						this.Add(Source.Physics.Medium.Solid.FromFile(fn, frequency));
					otherwise
						continue
				end
			end
			this.setMediumMaps();
		end
		function throwDuplicateMediumError(this, medium)
			this.Logger.Error(sprintf('Medium "%s" has already been added.',...
				medium.Name), [this.ERROR_CODE_PREFIX 'Add:DuplicateMedium']);
		end
		function throwMediumNotFoundError(this, name)
			this.Logger.Error(sprintf('Medium "%s" can not be found.', name),...
				[this.ERROR_CODE_PREFIX 'GetMedium:MediumNotFound']);
		end
		function throwUnknownMediumTypeError(this, mediumType)
				this.Logger.Error([Source.Physics.Media.ERROR_CODE_PREFIX ...
					'Add:UnknownMediumType'],...
					['Unknown Medium type "' mediumType...
					'", supported are "' Source.Physics.Medium.Fluid.CLASS_NAME...
					'" and "' Source.Physics.Medium.Solid.CLASS_NAME '".']);
		end
	end
end
