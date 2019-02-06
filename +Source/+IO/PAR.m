classdef PAR < handle
	properties
		FileName
		Logger
		FileId
		State
	end
	methods(Access = public, Static)
		function obj = New(fileName, logger)
			obj = Source.IO.PAR(fileName, logger);
		end
	end
	%{
.    Patient name                       :   BL_MR23_301118
.    Examination name                   :   301118
.    Protocol name                      :   WIP TemperatureMapping CLEAR
.    Examination date/time              :   2018.11.30 / 10:27:35
.    Series Type                        :   Image   MRSERIES
.    Acquisition nr                     :   12
.    Reconstruction nr                  :   1
.    Scan Duration [sec]                :   61.5
.    Max. number of cardiac phases      :   1
.    Max. number of echoes              :   1
.    Max. number of slices/locations    :   1
.    Max. number of dynamics            :   150
.    Max. number of mixes               :   1
.    Patient position                   :   Feet First Prone
.    Preparation direction              :   Feet-Head
.    Technique                          :   FEEPI
.    Scan resolution  (x, y)            :   160  156
.    Scan mode                          :   MS
.    Repetition time [ms]               :   37.094  
.    FOV (ap,fh,rl) [mm]                :   7.000  310.000  400.000
.    Water Fat shift [pixels]           :   5.500
.    Angulation midslice(ap,fh,rl)[degr]:   -0.000  0.000  0.000
.    Off Centre midslice(ap,fh,rl) [mm] :   -20.569  -8.897  0.000
.    Flow compensation <0=no 1=yes> ?   :   0
.    Presaturation     <0=no 1=yes> ?   :   0
.    Phase encoding velocity [cm/sec]   :   0.000000  0.000000  0.000000
.    MTC               <0=no 1=yes> ?   :   0
.    SPIR              <0=no 1=yes> ?   :   0
.    EPI factor        <0,1=no EPI>     :   11
.    Dynamic scan      <0=no 1=yes> ?   :   1
.    Diffusion         <0=no 1=yes> ?   :   0
.    Diffusion echo time [ms]           :   0.0000
.    Max. number of diffusion values    :   1
.    Max. number of gradient orients    :   1
.    Number of label types   <0=no ASL> :   0
	%}
	methods
		function parValues = Read(this)
			if(this.State ~= Source.Enum.IO.PARReadState.Initial)
				this.Logger.Log(['Already read the file "' this.FileName '".']);
				return
			end
			this.FileId = fopen(this.FileName);
			Source.Helper.Assert.FileIdAccessibility(this.FileId, this.FileName);
			% loop until end of file is reached
			while ~feof(this.FileId)
				% read the current line
				line = fgetl(this.FileId);
				newState = Source.IO.PAR.getReaderState(line);
				if(this.State ~= newState)
					this.State = newState;
					continue
				end
				this.parseLine(line);
			end
			fclose(this.FileId);
			this.State = Source.Enum.IO.PARReadState.Final;
		end
		function Write(data, filePath)
			jsonStr = jsonencode(data);
			fid = fopen(filePath, 'w');
			if fid == -1
				error('Cannot create JSON file');
			end
			fwrite(fid, jsonStr, 'char');
			fclose(fid);
		end
	end
	methods(Static, Access = protected)
		function state = getReaderState(line)
			switch(line(1))
				case '#'
					state = Source.Enum.IO.PARReadState.Comment;
					return
				case '.'
					state = Source.Enum.IO.PARReadState.Header;
					return
				case ' '
					state = Source.Enum.IO.PARReadState.Line;
					return
				otherwise
					state = Source.Enum.IO.PARReadState.Other;
					return
			end
		end
	end
	methods(Access = protected)
		function this = PAR(fileName, logger)
			this.FileName = fileName;
			this.Logger = logger;
			this.State = Source.Enum.MSHReadState.Initial;
		end
	end
end

