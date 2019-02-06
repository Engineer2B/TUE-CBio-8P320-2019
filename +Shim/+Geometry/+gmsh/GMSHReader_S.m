classdef GMSHReader_S < Source.Geometry.gmsh.GMSHReader
	methods(Access = public, Static)
		function obj = New(logger, options)
			obj = Shim.Geometry.gmsh.GMSHReader_S('', logger, options);
		end
	end
	methods(Access = public)
		function this = GMSHReader_S(varargin)
			this = this@Source.Geometry.gmsh.GMSHReader(varargin{:});
		end
		function state = GetReaderState(this, line)
			state = this.getReaderState(line);
		end
		function ParseLine(this, line)
			this.parseLine(line);
		end
		function gmshMedia = ReadPhysicalName(this, line)
			gmshMedia = this.readPhysicalName(line);
		end
		function node = ReadNode(this, line)
			node = this.readNode(line);
		end
		function [element, media, volumeIndex] = ReadElement(this, line)
			[element, media, volumeIndex] = this.readElement(line);
		end
		function nOfEntries = ReadSectionHeader(this, line)
			nOfEntries = this.readSectionHeader(line);
		end
	end
end