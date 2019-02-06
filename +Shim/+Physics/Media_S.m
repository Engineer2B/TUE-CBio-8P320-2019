classdef Media_S < Source.Physics.Media
	methods(Access = public, Static)
		function obj = New(logger)
			obj = Shim.Physics.Media_S();
			obj.Logger = logger;
		end
		function obj = FromFolder(logger, folderName, frequency)
			obj = Shim.Physics.Media_S();
			obj.Logger = logger;
			obj.addFolder(folderName, frequency);
		end
	end
	methods(Access = public)
		function obj = Media_S()
			obj = obj@Source.Physics.Media();
		end
		function AddFolder(this, varargin)
			this.addFolder(varargin{:});
		end
	end
end
