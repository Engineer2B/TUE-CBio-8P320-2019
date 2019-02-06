classdef Transducer < handle
	%TRANSDUCER A class for implementing the ability of transducers to
	%generate rays.
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Physics:Transducer:'
		CLASS_NAME = 'Source.Physics.Transducer'
		BesselR1 = 3.8317 %first zero bessels
		SHIFT_4mm = 1e-3*[0 sqrt(2) -2 sqrt(2) 0 -sqrt(2) 2 -sqrt(2)
			2 -sqrt(2) 0 sqrt(2) -2 sqrt(2) 0 -sqrt(2)]
		SHIFT_8mm = 1e-3*[0.4 0.37 0.28 0.15 0 -0.15 -0.28 -0.37 -0.4 -0.37...
			-0.28 -0.15 0 0.15 0.28 0.37
			0 0.15 0.28 0.37 0.4 0.37 0.28 0.15 0 -0.15 -0.28 -0.37 -0.4 -0.37...
			-0.28 -0.15]
	end
	properties (Access = public)
		% Total power produced by the transducer.
		Power
		% An angle between 0 and pi/2.
		% The beam will be simulated for angles between 0 and ThetaMax.
		ThetaMax
		% The pressure scaling factor.
		S0
		% The natural position of the focus in [m, m, m].
		NaturalFocus
		% The intended position of the focus in [m, m, m].
		FocusPosition
		% Diameter of the focus region in [m]
		FocusDiameter
		% PointCollection of positions of the transducer elements.
		% See Source.Geometry.PointCollection
		ElementPositions
		Logger
		% Radius of the transducer element in [m]
		ElementRadius
		% The initial medium
		InitialMedium
		ka
		FluxF
		MaxFlux
	end
	properties (Access = protected)
		% The fraction of the power that is simulated according to ThetaMax.
		p_PowerFraction
		p_NOfShifts
		p_Powers
		p_FocusDiameters
		p_Frequencies
		p_Transformation
	end
	methods(Access = public, Static)
		function obj = New(logger, elementRadius, initialMedium,...
				naturalFocus, elementPositions, transformation)
			obj = Source.Physics.Transducer();
			obj.setProperties(logger, elementRadius, initialMedium,...
				naturalFocus, elementPositions, transformation);
		end
		function obj = WithDefaultElementPositions(logger, elementRadius,...
				initialMedium, naturalFocus)
			obj = Source.Physics.Transducer.New(logger, elementRadius,...
				initialMedium, naturalFocus, Source.Physics.Transducer.POSITIONS);
		end
		function obj = FromTransducerFile(logger, filePath, media)
			obj = Source.Physics.Transducer();
			obj.fromDTO(logger, Source.IO.JSON.Read(filePath), media);
		end
		function pressure = GetSourcePressure(x, y, alpha, S, p_t, r_t, k)
			d_p_p_t = [x-p_t(1), y-p_t(2)];
			r = sqrt(d_p_p_t(1)^2+d_p_p_t(2)^2);
			theta = atan(d_p_p_t(2)/d_p_p_t(1));
			pressure = (r_t*S*exp(-1i*k*r)*exp(-alpha*r)*...
				besselj(1,k*r_t*sin(theta)))/(k*r*sin(theta));
		end
		function handles = ShowElements(tr, lineOptionsList)
			nOfElements = length(tr.ElementPositions);
			handles = gobjects(nOfElements,1);
			for inEl = 1:length(tr.ElementPositions)
%  				if(inEl > 100 && inEl < 128)
%  					lineOptionsList(inEl).Color = Source.Enum.Color.Default.red;
%  				end
			%for inEl = 128:128
				element = tr.ElementPositions(inEl, :);
				normalV = Source.Geometry.Vec3.Normalize(tr.NaturalFocus-element);
				handles(inEl) = Source.Geometry.Plane.ShowCircle(normalV,...
				 element, 0, 0, tr.ElementRadius, lineOptionsList(inEl));
				linOpt = lineOptionsList(inEl);
				linOptCell = linOpt.ToCell();
				fnLn = @(r1,r2) line([r1(1) r2(1)], [r1(2) r2(2)],[r1(3) r2(3)],...
					linOptCell{:});
				%fnLn(element, tr.NaturalFocus);
				fnLn(element, element + normalV*1e-2);
			end
		end
		function handles = ShowFoci(tr, focusDiameter, focusPosition,...
				patchOptionsList)
			pN = tr.NaturalFocus;
			fD = focusDiameter;
			% [x,y,z] = ellipsoid(xc,yc,zc,xr,yr,zr,n) generates a surface mesh
			% described by three n+1-by-n+1 matrices, enabling surf(x,y,z) 
			% to plot an ellipsoid with center (xc,yc,zc) and semi-axis lengths
			% (xr,yr,zr).
			[X, Y, Z] = ellipsoid(pN(1), pN(2), pN(3), fD, fD, 2*fD, 60);
			patchN = surf2patch(X, Y, Z);
			patchOptsN = patchOptionsList(1);
			patchOptsN.Vertices = patchN.vertices;
			patchOptsN.Faces = patchN.faces;
			patchF = patchN;
			patchF.vertices = bsxfun(@(A,b) A+b, patchN.vertices, focusPosition);
			patchOptsF = patchOptionsList(2);
			patchOptsF.Vertices = patchF.vertices;
			patchOptsF.Faces = patchF.faces;
			handles = gobjects(2,1);
			patchOptsFCell = patchOptsF.ToCell();
			handles(1) = patch(patchOptsFCell{:});
			patchOptsNCell = patchOptsN.ToCell();
			handles(2) = patch(patchOptsNCell{:});
		end
		function handleObj = Show(tr, focusDiameter, focusPosition,...
				lineOptionsList, patchOptionsList)
			handleObj.Elements = Source.Physics.Transducer.ShowElements(tr,...
				lineOptionsList);
			handleObj.Foci = Source.Physics.Transducer.ShowFoci(tr,...
				focusDiameter, focusPosition, patchOptionsList);
		end
	end
	methods(Access = public)
		function handleObj = ShowDebug(this, focusDiameter, focusPosition,...
				lineOptionsList, patchOptionsList)
			handleObj = Source.Physics.Transducer.Show(this, focusDiameter,...
				focusPosition, lineOptionsList, patchOptionsList);
		end
		function initialBatch = GetInitialRayBatch(this, power,...
				raysPerElement, reductionFactor, focusPosition, focusDiameter,...
				thetaMax)
			this.Logger.Log("Retrieving initial rays in batch format...",...
				"Retrieving initial rays...");
			if(exist('thetaMax', 'var'))
				this.ThetaMax = thetaMax;
			end
			this.FocusPosition = focusPosition;
			%this.Frequency = this.setIfInRange(transducer.Frequency,...
			%	this.p_Frequencies);
			this.FocusDiameter = this.setIfInRange(focusDiameter,...
				this.p_FocusDiameters, 'FocusDiameter');
			this.CalculateNOfShifts();
			this.Power = this.setIfInRange(power, this.p_Powers, 'Power');
			this.S0 = this.getS0(power/size(this.ElementPositions, 1));
			this.p_PowerFraction = this.getPowerFraction(this.ThetaMax);
			phases = this.getInitialPhases();
			[directions, powerScaling] = this.getInitialDirectionsFromSource(...
				this.p_NOfShifts*raysPerElement*size(this.ElementPositions,1),...
				reductionFactor);
			[initialBatch, totalPower] = this.getRayBatch(phases, directions,...
				powerScaling, this.p_NOfShifts*raysPerElement);
			finalPowerScaling = (this.p_PowerFraction*power*this.p_NOfShifts)/...
				totalPower;
			fieldNames = fieldnames(initialBatch.TransmittedFluid);
			for inElement = 1:length(fieldNames)
				fieldName = fieldNames{inElement};
				for inRay = 1:length(initialBatch.TransmittedFluid.(fieldName))
					initialBatch.TransmittedFluid.(fieldName)(inRay)...
						.ScalePower(finalPowerScaling);
				end
			end
		end
		function this = MoveFocus(this, newPosition)
			this.FocusPosition = newPosition;
		end
		function displayString = ToDisplayString(this, unitOfDistance,...
				roundingDigits)
			if(exist('roundingDigits','var'))
				transducerTransformationString = this.p_Transformation...
					.ToDisplayString('beam', 'm', roundingDigits);
			else
				transducerTransformationString = this.p_Transformation...
					.ToDisplayString('beam', 'm');
			end
			displayString = [transducerTransformationString...
				' ', Source.Geometry.Vec3.ToDisplayString(...
				this.NaturalFocus, 'r', 'focus', unitOfDistance)];
		end
		function obj = Copy(this, media)
			obj = Source.Physics.Transducer();
			obj.fromDTO(this.Logger, this.ToDTO(), media);
		end
		function dto = ToDTO(this)
			dto.Powers = this.p_Powers;
			dto.Frequencies = this.p_Frequencies;
			dto.FocusDiameters = this.p_FocusDiameters;
			dto.ElementRadius = this.ElementRadius;
			dto.Transformation = this.p_Transformation.ToDTO();
			dto.NaturalFocus = Source.Geometry.Vec3.ToDTO(...
				this.NaturalFocus);
			dto.ElementCoordinates.X = this.ElementPositions(:,1);
			dto.ElementCoordinates.Y = this.ElementPositions(:,2);
			dto.ElementCoordinates.Z = this.ElementPositions(:,3);
			dto.ImmersionMedium = this.InitialMedium.Name;
		end
		function this = ApplyTransformation(this, transformation)
			this.p_Transformation = transformation;
			transformation.ApplyToHandleObj(this);
		end
		function this = ChangeInclination(this, inclinationAngle)
			rotMatrix = Source.Geometry.Transform.GetRotationMatrix('y',...
				inclinationAngle);
			this.ElementPositions = this.ElementPositions * rotMatrix;
		end
		function this = ChangeAzimuth(this, azimuthAngle)
			rotMatrix = Source.Geometry.Transform.GetRotationMatrix('z',...
				azimuthAngle);
			this.ElementPositions = this.ElementPositions * rotMatrix;
		end
		function this = Translate(this, translation)
			this.ElementPositions = this.ElementPositions + translation;
		end
		function this = Rescale(this, scaleFactor)
			this.ElementPositions = this.ElementPositions * scaleFactor;
		end
		function isEqual = EqualTo(this, that)
			isEqual = this.ThetaMax == that.ThetaMax &...
			all(this.NaturalFocus == that.NaturalFocus) &...
			all(all(this.ElementPositions == that.ElementPositions)) &...
			this.ElementRadius == that.ElementRadius &...
			strcmp(this.InitialMedium.Name, that.InitialMedium.Name) == 1 &...
			this.ka == that.ka &...
			this.MaxFlux == that.MaxFlux;
		end
	end
	methods(Access = protected)
		function this = Transducer()
		end
		function fromDTO(this, logger, dto, media)
			transducerElementPositions = Source.Geometry.MatNx3.FromStruct(...
				dto.ElementCoordinates.X,...
				dto.ElementCoordinates.Y,...
				dto.ElementCoordinates.Z);
			naturalFocus = Source.Geometry.Vec3.FromDTO(dto.NaturalFocus);
			this.p_Powers = dto.Powers;
			this.p_FocusDiameters = dto.FocusDiameters;
			this.p_Frequencies = dto.Frequencies;
			this.setProperties(logger,...
				dto.ElementRadius,...
				media.GetFluid(dto.ImmersionMedium),...
				naturalFocus,...
				transducerElementPositions,...
				Source.Geometry.Transformation.FromDTO(dto.Transformation));
			this.throwErrorIfNonSpherical();
		end
		function setProperties(this, logger, elementRadius, initialMedium,...
				naturalFocus, elementPositions, transformation)
			Source.Helper.Assert.IsOfType(logger,...
				Source.Logging.Logger.CLASS_NAME, logger');
			Source.Helper.Assert.IsOfType(elementPositions,...
				'double', 'elementPositions');
			Source.Helper.Assert.IsOfType(naturalFocus,...
				'double', 'naturalFocus');
			this.Logger = logger;
			this.NaturalFocus = naturalFocus;
			this.ElementPositions = elementPositions;
			this.ElementRadius = elementRadius;
			Source.Helper.Assert.IsOfType(initialMedium,...
				Source.Physics.Medium.Fluid.CLASS_NAME, 'initialMedium');
			this.InitialMedium = initialMedium;
			this.ka = 2*pi*this.ElementRadius*initialMedium.Frequency/...
				initialMedium.Speed;
			this.ThetaMax = asin(this.BesselR1/this.ka);
			this.FluxF = @(theta) sin(theta).*abs(...
					besselj(1,this.ka*sin(theta))./sin(theta)).^2;
			if(this.ka > 10)
				this.MaxFlux = 0.5;
			else
				this.MaxFlux = integral(this.FluxF, 0, pi/2);
			end
			this.ApplyTransformation(transformation);
		end
		function throwErrorIfNonSpherical(this)
			if(size(this.ElementPositions,1) == 1)
				this.Logger.Warning('Working with single element transducer.');
				return;
			end
			d1 = norm(this.ElementPositions(1,:) - this.NaturalFocus);
			d2 = norm(this.ElementPositions(2,:) - this.NaturalFocus);
			if(abs(d1 - d2) > 1e-6)
				this.Logger.Error(['Transducer elements aren''t all equidistant'...
					' from the natural focus point.'], [this.ERROR_CODE_PREFIX...
					'TransducerIsNonSpherical']);
			end
		end
		function value = setIfInRange(this, value, minMaxMult, valueName)
			if(isempty(minMaxMult))
				this.Logger.Warning(sprintf('%s value has no constraints.',...
					valueName));
			elseif(~(value >= minMaxMult.Minimum &&...
					value <= minMaxMult.Maximum &&...
					mod(value, minMaxMult.MultipleOf) == 0))
				this.Logger.Error(...
					sprintf("%s value %g is not within %g:%g:%g",...
					valueName, value, minMaxMult.Minimum, minMaxMult.MultipleOf,...
					minMaxMult.Maximum), [this.ERROR_CODE_PREFIX,...
					'ValueOutsideSuppportedRange']);
			end
		end
		function CalculateNOfShifts(this)
			switch(this.FocusDiameter)
				case 2e-3
					this.p_NOfShifts;
				case 4e-3
					this.p_NOfShifts = size(this.SHIFT_4mm, 2);
				case 8e-3
					this.p_NOfShifts = size(this.SHIFT_8mm, 2);
				otherwise
					this.Logger.Error('Unsupported focus diameter',...
						[this.ERROR_CODE_PREFIX 'GetInitialRayList']);
			end
		end
		function [initialBatch, totalPower] = getRayBatch(this, phases,...
			directions, powerScalings, raysPerTransducer)
			totalPower = 0;
			nOfTransducers = length(phases)/this.p_NOfShifts;
			initialBatch = Source.Physics.RayBatch.New();
			raysPerShift = raysPerTransducer/this.p_NOfShifts;
			for inEl = 1:nOfTransducers
				fieldName = ['E' num2str(inEl)];
				initialBatch.TransmittedFluid.(fieldName) =...
					Source.Physics.Ray.Fluid.empty(0, raysPerTransducer);
				elementPosition = this.ElementPositions(inEl,:);
				for inShift = 1:this.p_NOfShifts
					index = inShift+(inEl-1)*this.p_NOfShifts;
					phase = phases(index);
					indices = (1:raysPerShift) + (inShift-1)*raysPerShift +...
						(inEl-1)*this.p_NOfShifts*raysPerShift;
					directionList = directions(indices,:);
					powerScalingList = powerScalings(indices);
					for inDirection = 1:size(directionList,1)
						totalPower = totalPower + powerScalingList(inDirection);
						inRay = inDirection + (inShift-1)*raysPerShift;
						initialBatch.TransmittedFluid.(fieldName)(inRay) =...
							Source.Physics.Ray.Fluid.New(elementPosition,...
							directionList(inDirection,:), phase,...
							powerScalingList(inDirection), this.InitialMedium);
					end
				end
			end
		end
		function [directions, powerScaling] =...
				getInitialDirectionsFromSource(this, numberOfRays, reductionFactor)
			phi = 2*pi*rand(numberOfRays,1);
			N = eye(3);
			cosThetaMax = cos(this.ThetaMax/reductionFactor);
			thetas = acos(1-(1-cosThetaMax)*...
				 rand(numberOfRays,1));
			B = this.ka*sin(thetas);
			powerScaling = (2*besselj(1,B)./B).^2;
			powerScaling(isnan(powerScaling)) = 1;
			directions = repmat(N(1,:),numberOfRays,1) +...
				 tan(thetas).*(cos(phi).*repmat(N(2,:),numberOfRays,1) +...
				sin(phi).*repmat(N(3,:),numberOfRays,1));
		end
		function phases = getInitialPhases(this)
			% Philips Sonnaleve transducer elements are distributed on a sphere
			% and the natural focus is located in the center of this sphere.
			% Therefor all transducer elements have the same travel time towards
			% the natural focus; tNatural.
			switch(this.FocusDiameter)
				case 2e-3
					shift = [0; 0];
				case 4e-3
					shift = this.SHIFT_4mm;
				case 8e-3
					shift = this.SHIFT_8mm;
			end
			this.p_NOfShifts = size(shift, 2);
			nOfElementPositions = size(this.ElementPositions,1);
			phases = zeros(nOfElementPositions*this.p_NOfShifts, 1);
			phaseKonversion = 2*pi*this.InitialMedium.Frequency/...
				this.InitialMedium.Speed;
			for inShift = 1:this.p_NOfShifts
				for inEl = 1:nOfElementPositions
					focShifted = this.FocusPosition;
					focShifted(1) = focShifted(1) + shift(1, inShift);
					focShifted(2) = focShifted(2) + shift(2, inShift);
					tNatural = Source.Geometry.Vec3.Distance(...
						this.ElementPositions(inEl,:), this.NaturalFocus);
					tShifted = Source.Geometry.Vec3.Distance(...
						this.ElementPositions(inEl,:), focShifted);
					phases(inShift+(inEl-1)*this.p_NOfShifts) = mod(...
						phaseKonversion*(tNatural-tShifted), 1);
				end
			end
		end
		function powerFraction = getPowerFraction(this, thetaMax)
			Source.Helper.Assert.WithinBounds(...
				this.Logger, [this.ERROR_CODE_PREFIX 'ThetaOutOfBounds'],...
				'theta', thetaMax, 0, pi/2);
			if(thetaMax == 0)
				powerFraction = 0;
				return;
			end
			powerFraction = integral(this.FluxF, 0, thetaMax)/this.MaxFlux;
		end
		function s0 = getS0(this, requiredPower)
			% Computes S0 such that flat transducer element generates
			% requiredPower, the pressure field of this element
			% (far field approx):
			% p(r, theta) = area S0 exp(i k r)/(2 pi r) D(theta) with:
			% area = pi Radius^2
			s0 = 2*this.InitialMedium.Frequency*sqrt(...
				pi*requiredPower*this.InitialMedium.Density/(this.MaxFlux*...
				this.InitialMedium.Speed))/this.ElementRadius;
		end
		function S0=computeS0(this, RequiredPower)
			 % R=transd element radius, k=wave number=2 pi/lambda
			 % Z= acoustic impedance, 
			 % computes S0 such that flat transducer element generates RequiredPower
			 % pressure field of this element (far field approx):
			 % p(r, theta) = A S0 exp(i k r)/(2 pi r)  D(theta) with:
			 % A= area=pi Radius^2
			 % D(theta)= 2 J1(Radius*k sin(theta)) / (Radius*k*sin(theta))
			 % D = directivity = determines pressure field in direction theta
			 % J1=Besselfunction, n=1
			 Radius = this.ElementRadius;
			 ka=this.ka;
			 A= pi*Radius^2;
			 f=@(theta) sin(theta).*(2*besselj(1,ka*sin(theta))./(ka*sin(theta))).^2;
			 Int=quad(f,0.00000001,pi/2);
			 Z = this.InitialMedium.Density * this.InitialMedium.Speed;
			 S0= sqrt(4*pi*Z*RequiredPower/Int)/A;
			 % done
		end
	end
	properties(Constant)
		POSITIONS = [-14e-2,0,0]+[
			0.0022274 -0.0117387 0.0219294
			0.0022622 -0.0053313 0.0244925
			0.0033154 -0.0181597 0.0242393
			0.0034219 -0.011085 0.0286977
			0.0036069 -0.004656 0.0312289
			0.0049452 -0.0161212 0.0331709
			0.004971 -0.0225193 0.0293266
			0.0053121 -0.0046288 0.0379177
			0.0059006 -0.0114894 0.0385403
			0.0068023 -0.0211886 0.0375424
			0.0069536 -0.0271609 0.0340727
			0.0073389 -0.0044273 0.0445134
			0.0078469 -0.0170118 0.0429669
			0.0083547 -0.011008 0.0463501
			0.0090845 -0.0237783 0.04354
			0.009241 -0.0319383 0.0384972
			0.0097004 -0.0054946 0.0509099
			0.0102437 -0.0181169 0.0493466
			0.0108579 -0.0120869 0.0526898
			0.0109335 -0.0302671 0.0450082
			0.0120778 -0.0368986 0.0432944
			0.0121176 -0.0244383 0.051467
			0.0123373 -0.0048485 0.0572601
			0.0135687 -0.0114314 0.0590293
			0.0136528 -0.0202682 0.0567942
			0.0136738 -0.0320502 0.0511321
			0.0150314 -0.0412372 0.0477738
			0.0152968 -0.0043945 0.0634808
			0.0160154 -0.0304857 0.057432
			0.0163805 -0.018113 0.0631675
			0.0165414 -0.0247296 0.061208
			0.0166568 -0.0369588 0.0549591
			0.0022274 -0.023807 0.0072059
			0.0022622 -0.0210886 0.013549
			0.0033154 -0.0299806 0.0042989
			0.0034219 -0.0281306 0.012454
			0.0036069 -0.0253745 0.0187898
			0.0049452 -0.0348548 0.0120559
			0.004971 -0.0366606 0.0048134
			0.0053121 -0.0300849 0.0235388
			0.0059006 -0.0353763 0.0191279
			0.0068023 -0.041529 0.0115639
			0.0069536 -0.0432987 0.0048873
			0.0073389 -0.0346063 0.0283451
			0.0078469 -0.0424113 0.018353
			0.0083547 -0.0405583 0.0249907
			0.0090845 -0.0476012 0.0139737
			0.009241 -0.0498055 0.0046378
			0.0097004 -0.039884 0.0321135
			0.0102437 -0.047704 0.0220827
			0.0108579 -0.0458041 0.0287106
			0.0109335 -0.0532276 0.0104236
			0.0120778 -0.056705 0.0045225
			0.0121176 -0.0536731 0.0191121
			0.0123373 -0.0439174 0.0370606
			0.0135687 -0.0498232 0.0336568
			0.0136528 -0.0544914 0.0258278
			0.0136738 -0.0588187 0.0134929
			0.0150314 -0.0629403 0.004622
			0.0152968 -0.047995 0.0417803
			0.0160154 -0.0621672 0.0190539
			0.0163805 -0.0574739 0.0318583
			0.0165414 -0.0607671 0.0257941
			0.0166568 -0.0649958 0.0127281
			0.0022274 -0.0219294 -0.0117387
			0.0022622 -0.0244925 -0.0053313
			0.0033154 -0.0242393 -0.0181597
			0.0034219 -0.0286977 -0.011085
			0.0036069 -0.0312289 -0.004656
			0.0049452 -0.0331709 -0.0161212
			0.004971 -0.0293266 -0.0225193
			0.0053121 -0.0379177 -0.0046288
			0.0059006 -0.0385403 -0.0114894
			0.0068023 -0.0375424 -0.0211886
			0.0069536 -0.0340727 -0.0271609
			0.0073389 -0.0445134 -0.0044273
			0.0078469 -0.0429669 -0.0170118
			0.0083547 -0.0463501 -0.011008
			0.0090845 -0.04354 -0.0237783
			0.009241 -0.0384972 -0.0319383
			0.0097004 -0.0509099 -0.0054946
			0.0102437 -0.0493466 -0.0181169
			0.0108579 -0.0526898 -0.0120869
			0.0109335 -0.0450082 -0.0302671
			0.0120778 -0.0432944 -0.0368986
			0.0121176 -0.051467 -0.0244383
			0.0123373 -0.0572601 -0.0048485
			0.0135687 -0.0590293 -0.0114314
			0.0136528 -0.0567942 -0.0202682
			0.0136738 -0.0511321 -0.0320502
			0.0150314 -0.0477738 -0.0412372
			0.0152968 -0.0634808 -0.0043945
			0.0160154 -0.057432 -0.0304857
			0.0163805 -0.0631675 -0.018113
			0.0165414 -0.061208 -0.0247296
			0.0166568 -0.0549591 -0.0369588
			0.0022274 -0.0072059 -0.023807
			0.0022622 -0.013549 -0.0210886
			0.0033154 -0.0042989 -0.0299806
			0.0034219 -0.012454 -0.0281306
			0.0036069 -0.0187898 -0.0253745
			0.0049452 -0.0120559 -0.0348548
			0.004971 -0.0048134 -0.0366606
			0.0053121 -0.0235388 -0.0300849
			0.0059006 -0.0191279 -0.0353763
			0.0068023 -0.0115639 -0.041529
			0.0069536 -0.0048873 -0.0432987
			0.0073389 -0.0283451 -0.0346063
			0.0078469 -0.018353 -0.0424113
			0.0083547 -0.0249907 -0.0405583
			0.0090845 -0.0139737 -0.0476012
			0.009241 -0.0046378 -0.0498055
			0.0097004 -0.0321135 -0.039884
			0.0102437 -0.0220827 -0.047704
			0.0108579 -0.0287106 -0.0458041
			0.0109335 -0.0104236 -0.0532276
			0.0120778 -0.0045225 -0.056705
			0.0121176 -0.0191121 -0.0536731
			0.0123373 -0.0370606 -0.0439174
			0.0135687 -0.0336568 -0.0498232
			0.0136528 -0.0258278 -0.0544914
			0.0136738 -0.0134929 -0.0588187
			0.0150314 -0.004622 -0.0629403
			0.0152968 -0.0417803 -0.047995
			0.0160154 -0.0190539 -0.0621672
			0.0163805 -0.0318583 -0.0574739
			0.0165414 -0.0257941 -0.0607671
			0.0166568 -0.0127281 -0.0649958
			0.0022274 0.0117387 -0.0219294
			0.0022622 0.0053313 -0.0244925
			0.0033154 0.0181597 -0.0242393
			0.0034219 0.011085 -0.0286977
			0.0036069 0.004656 -0.0312289
			0.0049452 0.0161212 -0.0331709
			0.004971 0.0225193 -0.0293266
			0.0053121 0.0046288 -0.0379177
			0.0059006 0.0114894 -0.0385403
			0.0068023 0.0211886 -0.0375424
			0.0069536 0.0271609 -0.0340727
			0.0073389 0.0044273 -0.0445134
			0.0078469 0.0170118 -0.0429669
			0.0083547 0.011008 -0.0463501
			0.0090845 0.0237783 -0.04354
			0.009241 0.0319383 -0.0384972
			0.0097004 0.0054946 -0.0509099
			0.0102437 0.0181169 -0.0493466
			0.0108579 0.0120869 -0.0526898
			0.0109335 0.0302671 -0.0450082
			0.0120778 0.0368986 -0.0432944
			0.0121176 0.0244383 -0.051467
			0.0123373 0.0048485 -0.0572601
			0.0135687 0.0114314 -0.0590293
			0.0136528 0.0202682 -0.0567942
			0.0136738 0.0320502 -0.0511321
			0.0150314 0.0412372 -0.0477738
			0.0152968 0.0043945 -0.0634808
			0.0160154 0.0304857 -0.057432
			0.0163805 0.018113 -0.0631675
			0.0165414 0.0247296 -0.061208
			0.0166568 0.0369588 -0.0549591
			0.0022274 0.023807 -0.0072059
			0.0022622 0.0210886 -0.013549
			0.0033154 0.0299806 -0.0042989
			0.0034219 0.0281306 -0.012454
			0.0036069 0.0253745 -0.0187898
			0.0049452 0.0348548 -0.0120559
			0.004971 0.0366606 -0.0048134
			0.0053121 0.0300849 -0.0235388
			0.0059006 0.0353763 -0.0191279
			0.0068023 0.041529 -0.0115639
			0.0069536 0.0432987 -0.0048873
			0.0073389 0.0346063 -0.0283451
			0.0078469 0.0424113 -0.018353
			0.0083547 0.0405583 -0.0249907
			0.0090845 0.0476012 -0.0139737
			0.009241 0.0498055 -0.0046378
			0.0097004 0.039884 -0.0321135
			0.0102437 0.047704 -0.0220827
			0.0108579 0.0458041 -0.0287106
			0.0109335 0.0532276 -0.0104236
			0.0120778 0.056705 -0.0045225
			0.0121176 0.0536731 -0.0191121
			0.0123373 0.0439174 -0.0370606
			0.0135687 0.0498232 -0.0336568
			0.0136528 0.0544914 -0.0258278
			0.0136738 0.0588187 -0.0134929
			0.0150314 0.0629403 -0.004622
			0.0152968 0.047995 -0.0417803
			0.0160154 0.0621672 -0.0190539
			0.0163805 0.0574739 -0.0318583
			0.0165414 0.0607671 -0.0257941
			0.0166568 0.0649958 -0.0127281
			0.0022274 0.0219294 0.0117387
			0.0022622 0.0244925 0.0053313
			0.0033154 0.0242393 0.0181597
			0.0034219 0.0286977 0.011085
			0.0036069 0.0312289 0.004656
			0.0049452 0.0331709 0.0161212
			0.004971 0.0293266 0.0225193
			0.0053121 0.0379177 0.0046288
			0.0059006 0.0385403 0.0114894
			0.0068023 0.0375424 0.0211886
			0.0069536 0.0340727 0.0271609
			0.0073389 0.0445134 0.0044273
			0.0078469 0.0429669 0.0170118
			0.0083547 0.0463501 0.011008
			0.0090845 0.04354  0.0237783
			0.009241 0.0384972 0.0319383
			0.0097004 0.0509099 0.0054946
			0.0102437 0.0493466 0.0181169
			0.0108579 0.0526898 0.0120869
			0.0109335 0.0450082 0.0302671
			0.0120778 0.0432944 0.0368986
			0.0121176 0.051467 0.0244383
			0.0123373 0.0572601 0.0048485
			0.0135687 0.0590293 0.0114314
			0.0136528 0.0567942 0.0202682
			0.0136738 0.0511321 0.0320502
			0.0150314 0.0477738 0.0412372
			0.0152968 0.0634808 0.0043945
			0.0160154 0.057432 0.0304857
			0.0163805 0.0631675 0.018113
			0.0165414 0.061208 0.0247296
			0.0166568 0.0549591 0.0369588
			0.0022274 0.0072059 0.023807
			0.0022622 0.013549 0.0210886
			0.0033154 0.0042989 0.0299806
			0.0034219 0.012454 0.0281306
			0.0036069 0.0187898 0.0253745
			0.0049452 0.0120559 0.0348548
			0.004971 0.0048134 0.0366606
			0.0053121 0.0235388 0.0300849
			0.0059006 0.0191279 0.0353763
			0.0068023 0.0115639 0.041529
			0.0069536 0.0048873 0.0432987
			0.0073389 0.0283451 0.0346063
			0.0078469 0.018353 0.0424113
			0.0083547 0.0249907 0.0405583
			0.0090845 0.0139737 0.0476012
			0.009241 0.0046378 0.0498055
			0.0097004 0.0321135 0.039884
			0.0102437 0.0220827 0.047704
			0.0108579 0.0287106 0.0458041
			0.0109335 0.0104236 0.0532276
			0.0120778 0.0045225 0.056705
			0.0121176 0.0191121 0.0536731
			0.0123373 0.0370606 0.0439174
			0.0135687 0.0336568 0.0498232
			0.0136528 0.0258278 0.0544914
			0.0136738 0.0134929 0.0588187
			0.0150314 0.004622 0.0629403
			0.0152968 0.0417803 0.047995
			0.0160154 0.0190539 0.0621672
			0.0163805 0.0318583 0.0574739
			0.0165414 0.0257941 0.0607671
			0.0166568 0.0127281 0.0649958]
	end
end