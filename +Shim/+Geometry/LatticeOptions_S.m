classdef LatticeOptions_S < Source.Geometry.LatticeOptions
	methods(Access = public, Static)
		function obj = New(extrema, spacing)
			obj = Source.Geometry.LatticeOptions();
			obj.Extrema = extrema;
			obj.Spacing = spacing;
			obj.InvSpacing = 1./spacing;
			obj.Steps = [...
				extrema.X.Distance()/obj.Spacing(1),...
				extrema.Y.Distance()/obj.Spacing(2),...
				extrema.Z.Distance()/obj.Spacing(3)];
			obj.InvSqCubeArea = 1/sqrt(2*(obj.Spacing(1)*obj.Spacing(2)+...
				obj.Spacing(2)*obj.Spacing(3)+...
				obj.Spacing(1)*obj.Spacing(3)));
			obj.CubeVolume = obj.Spacing(1)*obj.Spacing(2)*obj.Spacing(3);
			obj.InvSqCubeVolume = 1/sqrt(obj.CubeVolume);
			val = (extrema.Maximum-...
				extrema.Minimum)./obj.Spacing;
			obj.MaxFlatIndex = val(1)*val(2)*val(3);
			obj.checkMaxFlatIndex();
			obj.XTimesYSteps = obj.Steps(1)*obj.Steps(2);
		end
		function obj = Mock()
			boxExtrema = Source.Geometry.Extrema.FromTwoPoints(...
				[-1 -1 -1], [1 1 1]);
			spacing = [0.5 0.5 0.5];
			obj = Shim.Geometry.LatticeOptions_S.New(boxExtrema,...
				spacing);
		end
		function obj = FromLatticeOptions(latticeOptions)
			obj = Shim.Geometry.LatticeOptions_S.New(...
				latticeOptions.Extrema,...
				latticeOptions.Spacing);
		end
	end
	methods(Access = public)
		function obj = LatticeOptions_S()
			obj = obj@Source.Geometry.LatticeOptions();
		end
		function indices = ArraySlice(this, varargin)
			indices = this.arraySlice(varargin{:});
		end
		function extrema = CalculateInnerExtrema(this, varargin)
			extrema = this.calculateInnerExtrema(varargin{:});
		end
		function list = OverDisplacements(this, varargin)
			list = this.overDisplacements(varargin{:});
		end
		function centers = CalculateCenters(this, varargin)
			centers = this.calculateCenters(varargin{:});
		end
		function center = CalculateCenter(this, varargin)
			center = this.calculateCenter(varargin{:});
		end
		function ShowExtremas(this, projector)
			projector.DisplayFacility.NoShow = true;
			lineOptions = Source.Display.Options.Line.Presentation();
			lineOptions.LineStyle = Source.Enum.LineStyle.DashDot;
			lineOptions.LineWidth = 1;
			projector.DisplayFacility.ShowGrid(this.Extrema, this.Spacing);
			limits = this.Extrema.Copy();
			limits.Widen([2 2 2]);
			projector.DisplayFacility.NoShow = false;
			projector.DisplayFacility.SetAxisLimits(limits);
		end
		function ShowCubeAtPosition(this, projector, position, patchOptions)
			extrema = this.GetExtremaByBoxIndex(...
				this.GetBoxIndexByPosition(position));
			projector.ShowExtrema(extrema, patchOptions);
		end
		function ShowCubeAtPositions(this, projector, positions, patchOptions)
			if(~exist('patchOptions', 'var'))
				patchOptions = projector.DisplayFacility.Options.New();
			end
			projector.ShowExtremas(positions.Map(...
				Source.Geometry.Extrema.CLASS_NAME,...
				@(position) this.GetExtremaByBoxIndex(...
				this.GetBoxIndexByPosition(position))), patchOptions);
		end
	end
end
