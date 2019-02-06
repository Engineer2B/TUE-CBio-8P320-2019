classdef Transducer_S < Source.Physics.Transducer
	properties
		PowerFraction
		NOfShifts
	end
	methods(Static)
		function obj = New(varargin)
			obj = Shim.Physics.Transducer_S();
			obj.setProperties(varargin{:});
		end
	end
	methods
		function powerFraction = get.PowerFraction(this)
			powerFraction = this.p_PowerFraction;
		end
		function nOfShifts = get.NOfShifts(this)
			nOfShifts = this.p_NOfShifts;
		end
	end
	methods(Access = public)
		function obj = Transducer_S(varargin)
			obj = obj@Source.Physics.Transducer(varargin{:});
		end
		function phases = GetInitialPhases(this)
			phases = this.getInitialPhases();
		end
		function powerFraction = GetPowerFraction(this, theta)
			powerFraction = this.getPowerFraction(theta);
		end
		function s0 = GetS0(this, requiredPower)
			s0 = this.getS0(requiredPower);
		end
		function s0 = ComputeS0(this, requiredPower)
			s0 = this.computeS0(requiredPower);
		end
		function varargout = GetRayBatches(this, varargin)
			varargout = this.getRayBatches(varargin{:});
		end
		function varargout = GetRayTrees(this, varargin)
			varargout = this.getRayTrees(varargin{:});
		end
		function varargout = GetRayList(this, varargin)
			varargout = this.getRayList(varargin);
		end
	end
end
