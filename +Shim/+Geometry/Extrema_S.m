classdef Extrema_S < Source.Geometry.Extrema
	methods(Access = public)
		function this = Extrema_S(varargin)
			this@Source.Geometry.Extrema(varargin{:});
		end
		function maxDistance = MaxDistance(this, varargin)
			maxDistance = this.maxDistance(varargin{:});
		end
	end
end

