classdef LatticeOptions < handle
	%LATTICE Describes the lattice box and its parameters.
	%   In this lattice box the heat production is calculated.
	% Data is stored in a flat array to enable use of sparse arrays which are
	% constrained to 2 dimensions.
	% In MATLAB storage is column major order
	% (https://stackoverflow.com/a/21413441/1750173).
	% This class stores (x, y, z) values as follows:
	% 1:(x1,y1,z1) 4:(x1,y2,z1) 7:(x1,y3,z1)
	% 2:(x2,y1,z1) 5:(x2,y2,z1) 8:(x2,y3,z1)
	% 3:(x3,y1,z1) 6:(x3,y2,z1) 9:(x3,y3,z1)
	% This clashes with contour plot functions that expect data presented as:
	% 1:(x1,y1,z1) 4:(x2,y1,z1) 7:(x3,y1,z1)
	% 2:(x1,y2,z1) 5:(x2,y2,z1) 8:(x3,y2,z1)
	% 3:(x1,y3,z1) 6:(x2,y3,z1) 9:(x3,y3,z1)
	% Solution: swap X and Y arguments when using meshgrid to generate the
	% contour meshes i.e.:
	% [Y, X] = meshgrid(y, x), instead of [X, Y] = meshgrid(x,y).
	properties
		Logger
	end
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Geometry:LatticeOptions:'
		CLASS_NAME = 'Source.Geometry.LatticeOptions'
	end
	properties
		% The spacing of the grid in [m].
		% For now we only support equal spacing in all directions.
		Spacing
		% A Point indicating the number of steps in (x,y,z)-direction.
		Steps
		% The volume of each box in the grid in [m^3].
		CubeVolume
		% The inverse of the square of the area of each box in the grid.
		InvSqCubeArea
		% The inverse of the square of the cube volume of each box in the grid.
		InvSqCubeVolume
		% An Extrema indicating the (x,y,z)-extrema of the box.
		Extrema
		InvSpacing
		MaxFlatIndex
		XTimesYSteps
	end
	methods(Access = public, Static)
		function obj = New(logger, extrema, spacing)
			obj = Source.Geometry.LatticeOptions();
			obj.setProperties(logger, extrema, spacing);
		end
		function obj = FromDTO(logger, dto)
			obj = Source.Geometry.LatticeOptions();
			extrema = Source.Geometry.Extrema.FromDTO(dto.Extrema);
			spacing = Source.Geometry.Vec3.FromDTO(dto.Spacing);
			obj.setProperties(logger, extrema, spacing);
		end
		function obj = Daniela20180904()
			[~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, xxb, yyb, zzb] =...
				External.ModenaPaper.Define_table();
			xxb = (xxb+14)/100;
			yyb = yyb/100;
			zzb = zzb/100;
			extrema = Source.Geometry.Extrema.FromTwoPoints(...
				[min(xxb), min(yyb), min(zzb)],[max(xxb), max(yyb), max(zzb)]);
			spacing = [xxb(2)-xxb(1) yyb(2)-yyb(1) zzb(2)-zzb(1)];
			obj = Source.Geometry.LatticeOptions();
			obj.Extrema = extrema;
			obj.Spacing = spacing;
			obj.InvSpacing = 1./spacing;
			obj.Steps = [...
				extrema.X.Distance()/obj.Spacing(1),...
				extrema.Y.Distance()/obj.Spacing(2),...
				extrema.Z.Distance()/obj.Spacing(3)];
			obj.Steps = floor(obj.Steps);
			obj.InvSqCubeArea = 1/sqrt(2*(obj.Spacing(1)*obj.Spacing(2)+...
				obj.Spacing(2)*obj.Spacing(3)+...
				obj.Spacing(1)*obj.Spacing(3)));
			obj.CubeVolume = obj.Spacing(1)*obj.Spacing(2)*obj.Spacing(3);
			obj.InvSqCubeVolume = 1/sqrt(obj.CubeVolume);
			val = round((extrema.Maximum-...
				extrema.Minimum).*obj.InvSpacing);
			obj.MaxFlatIndex = val(1)*val(2)*val(3);
			obj.checkMaxFlatIndex();
			obj.XTimesYSteps = obj.Steps(1)*obj.Steps(2);
		end
		function obj = FromConfigurationAndRays(rays, configuration)
			rayExtremas = rays.Map(Source.Geometry.Extrema.CLASS_NAME, @(ray)...
				ray.ToExtrema(configuration.Logger));
			extrema = Source.Geometry.Extrema.Zero();
			rayExtremas.ForEach(@(extremaValue)...
				extrema.UpdateByExtrema(extremaValue));
			configurationExtrema = configuration.ToExtrema();
			extrema.UpdateByExtrema(configurationExtrema);
			obj = Source.Geometry.LatticeOptions();
			obj.setProperties(configuration.Logger, extrema,...
				configuration.LatticeSpacing);
		end
		function obj = FromConfiguration(configuration)
			obj = Source.Geometry.LatticeOptions();
			obj.setProperties(configuration.Logger,...
				configuration.LatticeExtrema, configuration.LatticeSpacing);
		end
		function obj = FromXYValues(logger, xyValueTable, zExtremum, zSpacing)
			minX = min(xyValueTable.x);
			xExp = ceil(log2(max(xyValueTable.x) - minX));
			maxX = minX+2^xExp;
			minY = min(xyValueTable.y);
			yExp = ceil(log2(max(xyValueTable.y) - minY));
			maxY = minY+2^yExp;
			obj = Source.Geometry.LatticeOptions.New(logger,...
				Source.Geometry.Extrema.FromTwoPoints(...
				[minX, minY, zExtremum.Min],...
				[maxX, maxY, zExtremum.Max]),...
				[2^(xExp-8), 2^(yExp-8), zSpacing]);
		end
	end
	methods(Access = public)
		function filtRays = FilterRays(this, rays)
			filtRays = this.Extrema.FilterRays(rays);
		end
		function dto = ToDTO(this)
			dto.Extrema = this.Extrema.ToDTO();
			dto.Spacing = Source.Geometry.Vec3.ToDTO(this.Spacing);
		end
		function filteredValues = FilterXYValues(this, xyValueTable,...
				tolerances)
			% xyValueTable must be of the form x, y, value.
			filteredValues = xyValueTable((xyValueTable.x + tolerances(1) >...
				this.Extrema.X.Min) &...
				(xyValueTable.x - tolerances(1) < this.Extrema.X.Max) &...
				(xyValueTable.y + tolerances(2) > this.Extrema.Y.Min) &...
				(xyValueTable.y - tolerances(2) < this.Extrema.Y.Max), :);
		end
		function [zgrid, xgrid, ygrid] = ApplyGrid(this, xyValueTable)
			xVals = this.GetXCenters();
			yVals = this.GetYCenters();
			[xgrid, ygrid] = meshgrid(xVals, yVals);
			zgrid  = griddata(xyValueTable.x, xyValueTable.y,...
				xyValueTable.value, xgrid, ygrid, 'cubic');
% 			[zgrid, xgrid, ygrid] = External.gridfit(xyValueTable.x,...
% 				xyValueTable.y, xyValueTable.value, this.GetXCenters(),...
% 				this.GetYCenters());
		end
		function innerExtremas = CalculateInnerExtremas(this)
			innerExtremas = Source.Helper.Collection.New(...
				Source.Geometry.Extrema.CLASS_NAME);
			minimalPoint = this.Extrema.Minimum;
			cubeSize = [this.Spacing(1) this.Spacing(2) this.Spacing(3)];
			this.overDisplacements(@(indexXDisplacement, indexYDisplacement,...
				indexZDisplacement) this.calculateInnerExtrema(...
				indexXDisplacement,indexYDisplacement, indexZDisplacement,...
				minimalPoint, cubeSize), innerExtremas);
		end
		function volume = GetTotalVolume(this)
			volume = this.CubeVolume*this.Steps(1)*this.Steps(2)*this.Steps(3);
		end
		function edges = GetXEdges(this)
			edges = linspace(this.Extrema.X.Min, this.Extrema.X.Max,...
				this.Steps(1)+1);
		end
		function edges = GetYEdges(this)
			edges = linspace(this.Extrema.Y.Min, this.Extrema.Y.Max,...
				this.Steps(2)+1);
		end
		function edges = GetZEdges(this)
			edges = linspace(this.Extrema.Z.Min, this.Extrema.Z.Max,...
				this.Steps(3)+1);
		end
		function xRange = GetXCenters(this)
			xRange = linspace(this.Extrema.X.Min+this.Spacing(1)/2,...
				this.Extrema.X.Max-this.Spacing(1)/2,...
				this.Steps(1));
		end
		function yRange = GetYCenters(this)
			yRange = linspace(this.Extrema.Y.Min+this.Spacing(2)/2,...
				this.Extrema.Y.Max-this.Spacing(2)/2,...
				this.Steps(2));
		end
		function zRange = GetZCenters(this)
			zRange = linspace(this.Extrema.Z.Min+this.Spacing(3)/2,...
				this.Extrema.Z.Max-this.Spacing(3)/2,...
				this.Steps(3));
		end
		function indices = GetPlanarSliceIndices(this, plane, offset)
			switch(plane)
				case Source.Enum.Plane.Coronal
					offsetInSteps = 1 + Source.Helper.Math.Clip(...
						offset, 0, this.Steps(1)-1);
					indices = this.arraySliceIndices(offsetInSteps, 1);
				case Source.Enum.Plane.Sagittal
					offsetInSteps = 1 + Source.Helper.Math.Clip(...
						offset, 0, this.Steps(2)-1);
					indices = this.arraySliceIndices(offsetInSteps, 2);
				case Source.Enum.Plane.Transverse
					offsetInSteps = 1 + Source.Helper.Math.Clip(...
						offset, 0, this.Steps(3)-1);
					indices = this.arraySliceIndices(offsetInSteps, 3);
				otherwise
					this.Logger.LogNotImplementedForEnumValue(plane);
			end
		end
		function matrix = GetPlanarSliceValues(this, array, plane, offset)
			switch(plane)
				case Source.Enum.Plane.Coronal % YZ plane
					offsetInSteps = 1 + Source.Helper.Math.Clip(...
						offset, 0, this.Steps(1)-1);
					matrix = this.arraySlice(array, offsetInSteps, 1);
				case Source.Enum.Plane.Sagittal % XZ plane
					offsetInSteps = 1 + Source.Helper.Math.Clip(...
						offset, 0, this.Steps(2)-1);
					matrix = this.arraySlice(array, offsetInSteps, 2);
				case Source.Enum.Plane.Transverse % XY plane
					offsetInSteps = 1 + Source.Helper.Math.Clip(...
						offset, 0, this.Steps(3)-1);
					matrix = this.arraySlice(array, offsetInSteps, 3);
				otherwise
					this.Logger.LogNotImplementedForEnumValue(plane);
			end
		end
		function flatIndex = GetFlatIndexByPosition(this, position)
			flatIndex = this.GetFlatIndexByBoxIndex(...
				this.GetBoxIndexByPosition(position));
		end
		function center = GetCenterByBoxIndex(this, boxIndex)
			center = boxIndex .* this.Spacing - this.Spacing/2 +...
				this.Extrema.Minimum;
		end
		function boxIndex = GetBoxIndexByPosition(this, position)
			boxIndex = 1+floor((position-this.Extrema.Minimum)./this.Spacing);
		end
		function flatIndex = GetFlatIndexByBoxIndex(this, boxIndex)
			flatIndex = sub2ind([this.Steps(1) this.Steps(2) this.Steps(3)],...
				boxIndex(1), boxIndex(2), boxIndex(3));
		end
		function boxIndex = GetBoxIndexByFlatIndex(this, flatIndex)
			boxIndex = [0 0 0];
			[boxIndex(1), boxIndex(2), boxIndex(3)] = ind2sub(...
				[this.Steps(1) this.Steps(2) this.Steps(3)], flatIndex);
		end
		function extrema = GetExtremaByBoxIndex(this, boxIndex)
			extrema = Source.Geometry.Extrema.FromTwoPoints(...
				[this.Extrema.X.Min+boxIndex(1)*this.Spacing(1)-this.Spacing(1),...
				this.Extrema.Y.Min+boxIndex(2)*this.Spacing(2)-this.Spacing(2),...
				this.Extrema.Z.Min+boxIndex(3)*this.Spacing(3)-this.Spacing(3)],...
				[this.Extrema.X.Min+boxIndex(1)*this.Spacing(1),...
				this.Extrema.Y.Min+boxIndex(2)*this.Spacing(2),...
				this.Extrema.Z.Min+boxIndex(3)*this.Spacing(3)]);
		end
		function center = CalculateCenter(this, indexXDisplacement,...
				indexYDisplacement, indexZDisplacement)
			center = this.Extrema.Minimum + [...
				(indexXDisplacement + .5)*this.Spacing(1),...
				(indexYDisplacement + .5)*this.Spacing(2),...
				(indexZDisplacement + .5)*this.Spacing(3)];
		end
		function isEqual = eq(this, that)
			isEqual = all(this.Spacing == that.Spacing) &&...
				all(this.Steps == that.Steps);
		end
	end
	methods(Access = protected)
		function this = LatticeOptions()
		end
		function setProperties(this, logger, extrema, spacing)
			this.Logger = logger;
			this.Extrema = extrema;
			this.Spacing = spacing;
			this.InvSpacing = 1./spacing;
			this.Steps = [extrema.X.Distance()/this.Spacing(1),...
				extrema.Y.Distance()/this.Spacing(2),...
				extrema.Z.Distance()/this.Spacing(3)];
			this.InvSqCubeArea = 1/sqrt(2*(this.Spacing(1)*this.Spacing(2)+...
				this.Spacing(2)*this.Spacing(3)+...
				this.Spacing(1)*this.Spacing(3)));
			this.CubeVolume = this.Spacing(1)*this.Spacing(2)*this.Spacing(3);
			this.InvSqCubeVolume = 1/sqrt(this.CubeVolume);
			val = (extrema.Maximum-extrema.Minimum).*this.InvSpacing;
			this.MaxFlatIndex = val(1)*val(2)*val(3);
			this.checkMaxFlatIndex();
			this.XTimesYSteps = this.Steps(1)*this.Steps(2);
		end
		function steps = getRelativeClippedStepsX(this, xPosition)
			% Determines the number of X-spacing spaced steps to get from
			% the minimal lattice X-position to the given X-position.
			% xPosition - The X-position.
			steps = 1 + Source.Helper.Math.Clip(...
				(xPosition - this.Extrema.X.Min), 0, this.Steps(1)-1);
		end
		function steps = getRelativeClippedStepsY(this, yPosition)
			% Determines the number of Y-spacing spaced steps to get from
			% the minimal lattice Y-position to the given Y-position.
			% yPosition - The Y-position.
			steps = 1 + Source.Helper.Math.Clip(...
				(yPosition - this.Extrema.Y.Min), 0, this.Steps(2)-1);
		end
		function steps = getRelativeClippedStepsZ(this, zPosition)
			% Determines the number of Z-spacing spaced steps to get from
			% the minimal lattice Z-position to the given Z-position.
			% zPosition - The Z-position.
			steps = 1 + Source.Helper.Math.Clip(...
				(zPosition - this.Extrema.Z.Min), 0, this.Steps(3)-1);
		end
		function S = arraySlice(this, array, offset, dim)
			s = this.Steps;
			if(dim > 3)
				this.Logger.ShowError(sprintf(['Slice dimension %i > 3 and the'...
					' lattice has only 3 dimensions by which it can be sliced.' ],...
					dim), [this.ERROR_CODE_PREFIX 'arraySliceIndices:OutOfBounds']);
			end
			S = zeros(s(1:3~=dim));
			c = 1;
			q = prod(arrayfun(@(j) s(j), 1:dim-1));
			p = q*s(dim);
			t = p*prod(s(dim+1:3));
			z = 1+q*(offset-1);
			y = q-1;
			for k = 1:t/p
				S(c:c + y) = array( z+p*(k-1):z+p*(k-1) + y );
				c = c + y + 1;
			end
		end
		function S = arraySliceIndices(this, offset, dim)
			s = this.Steps;
			if(dim > 3)
				this.Logger.ShowError(sprintf(['Slice dimension %i > 3 and the'...
					' lattice has only 3 dimensions by which it can be sliced.' ],...
					dim), [this.ERROR_CODE_PREFIX 'arraySliceIndices:OutOfBounds']);
			end
			S = zeros(1, prod(s(1:3~=dim)));
			c = 1;
			q = prod(arrayfun(@(j) s(j), 1:dim-1));
			p = q*s(dim);
			t = p*prod(s(dim+1:3));
			z = 1+q*(offset-1);
			y = q-1;
			for k = 1:t/p
				S(c:c + y) = z+p*(k-1):z+p*(k-1) + y;
				c = c + y + 1;
			end
		end
		function innerExtrema = calculateInnerExtrema(this,...
				indexXDisplacement, indexYDisplacement, indexZDisplacement,...
				minimalPoint, cubeSize)
				displacement = [0 0 0];
				displacement(1) = this.Spacing(1)*indexXDisplacement;
				displacement(2) = this.Spacing(2)*indexYDisplacement;
				displacement(3) = this.Spacing(3)*indexZDisplacement;
				localMinimalPoint = minimalPoint + displacement;
				innerExtrema = Source.Geometry.Extrema.FromTwoPoints(...
							localMinimalPoint, localMinimalPoint + cubeSize);
		end
		function list = overDisplacements(this, func, list)
			Source.Helper.Assert.IsOfType(list,...
				Source.Helper.Collection.CLASS_NAME, 'list');
			for indexZDisplacement = 0:this.Steps(3)-1
				for indexYDisplacement = 0:this.Steps(2)-1
					for indexXDisplacement = 0:this.Steps(1)-1
						list.Add(func(indexXDisplacement, indexYDisplacement,...
							indexZDisplacement));
					end
				end
			end
		end
		function centers = calculateCenters(this)
			centers = Source.Geometry.PointCollection.New();
			centers = this.overDisplacements(@(indexXDisplacement,...
				indexYDisplacement, indexZDisplacement) this.CalculateCenter(...
				indexXDisplacement, indexYDisplacement, indexZDisplacement),...
				centers);
		end
		function checkMaxFlatIndex(this)
			if(rem(this.MaxFlatIndex, 1) > 0)
				this.Logger.Error(['The specified lattice limits are not'...
					' divisible by the specified spacing size.'],...
					[Source.Geometry.LatticeOptions.ERROR_CODE_PREFIX...
					'SpacingAndLimitsDontMatch']);
			end
			if(this.MaxFlatIndex > 2^32)
				this.Logger.Warning(['The lattice you are sampling will require'...
					'more than 4 GB of memory.']);
			end
		end
	end
end
