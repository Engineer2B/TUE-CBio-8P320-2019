classdef Transducer_U < matlab.unittest.TestCase
	properties
		TheTransducer
		Media
	end
	methods(TestMethodSetup)
		function DefineSourceFunction(this)
			f = 1.2*1e6;
			a = 2 * 1e-3;
			naturalFocus = [0 0 0];
			logger = Source.Logging.Logger.Default();
			
			this.Media = Source.Physics.Media.FromFolder(logger,fullfile(...
				Settings.MEDIUM_FOLDER, 'Human'), f);
			transformation = Source.Geometry.Transformation.None();
			this.TheTransducer = Shim.Physics.Transducer_S.New(...
				logger, a, this.Media.GetFluid('Markoil'),...
				naturalFocus, Source.Physics.Transducer.POSITIONS,...
				transformation);
		end
	end
	methods (Test)
		function Copy_ShouldYieldSameObject(this)
			copyObj = this.TheTransducer.Copy(this.Media);
			this.verifyTrue(copyObj.EqualTo(this.TheTransducer));
		end
		function GetInitialRayBatch_TenRaysPerTransducer(this)
			power = 10;
			focusPosition = [0,-1,1];
			raysPerTransducer = 10;
			reductionFactor = 1;
			focusDiameter = 2e-3;
			thetaMax = pi/4;
			initialBatch = this.TheTransducer.GetInitialRayBatch(power,...
				raysPerTransducer, reductionFactor, focusPosition,...
				focusDiameter, thetaMax);
			emittedPower = power*this.TheTransducer.PowerFraction*...
				this.TheTransducer.NOfShifts;
			totalRays = Source.Helper.Counter.Init(0);
			structfun(@(rays) totalRays.Increment(length(rays)),...
				initialBatch.TransmittedFluid);
			totalPower = Source.Helper.Counter.Init(0);
			structfun(@(rays) arrayfun(...
				@(ray) totalPower.Increment(ray.InitialPower),rays),...
				initialBatch.TransmittedFluid);
			this.verifyEqual(totalRays.Value,...
				this.TheTransducer.NOfShifts*...
				raysPerTransducer * length(this.TheTransducer.ElementPositions));
			this.verifyEqual(totalPower.Value, emittedPower,...
				'abstol', Test.Settings.Tolerance*10,...
				['The total emitted power should be "'...
				num2str(emittedPower) '".']);
		end
		function GetInitialRayBatch_TenRaysPerTransducer4mm(this)
			power = 10;
			focusPosition = [0,-1,1];
			raysPerTransducer = 10;
			reductionFactor = 1;
			focusDiameter = 4e-3;
			thetaMax = pi/4;
			initialBatch = this.TheTransducer.GetInitialRayBatch(power,...
				raysPerTransducer, reductionFactor, focusPosition,...
				focusDiameter, thetaMax);
			emittedPower = power*this.TheTransducer.PowerFraction*...
				this.TheTransducer.NOfShifts;
			totalRays = Source.Helper.Counter.Init(0);
			structfun(@(rays) totalRays.Increment(length(rays)),...
				initialBatch.TransmittedFluid);
			totalPower = Source.Helper.Counter.Init(0);
			structfun(@(rays) arrayfun(...
				@(ray) totalPower.Increment(ray.InitialPower),rays),...
				initialBatch.TransmittedFluid);
			this.verifyEqual(totalRays.Value, raysPerTransducer *...
				this.TheTransducer.NOfShifts*...
				length(this.TheTransducer.ElementPositions));
			this.verifyEqual(totalPower.Value, emittedPower,...
				'abstol', Test.Settings.Tolerance*10,...
				['The total emitted power should be "'...
				num2str(emittedPower) '".']);
		end
		function GetInitialRayBatch_TenRaysPerTransducer8mm(this)
			power = 10;
			focusPosition = [0,-1,1];
			raysPerTransducer = 10;
			reductionFactor = 1;
			focusDiameter = 8e-3;
			thetaMax = pi/4;
			initialBatch = this.TheTransducer.GetInitialRayBatch(power,...
				raysPerTransducer, reductionFactor, focusPosition,...
				focusDiameter, thetaMax);
			emittedPower = power*this.TheTransducer.PowerFraction*...
				this.TheTransducer.NOfShifts;
			totalRays = Source.Helper.Counter.Init(0);
			structfun(@(rays) totalRays.Increment(length(rays)),...
				initialBatch.TransmittedFluid);
			totalPower = Source.Helper.Counter.Init(0);
			structfun(@(rays) arrayfun(...
				@(ray) totalPower.Increment(ray.InitialPower),rays),...
				initialBatch.TransmittedFluid);
			this.verifyEqual(totalRays.Value, raysPerTransducer *...
				this.TheTransducer.NOfShifts*...
				length(this.TheTransducer.ElementPositions));
			this.verifyEqual(totalPower.Value, emittedPower,...
				'abstol', Test.Settings.Tolerance*10,...
				['The total emitted power should be "'...
				num2str(emittedPower) '".']);
		end
		function getInitialPhases_EqualFociReturnsZeroes(this)
			naturalFocus = [0 0 0];
			this.TheTransducer.FocusPosition = naturalFocus;
			this.TheTransducer.NaturalFocus = naturalFocus;
			this.TheTransducer.FocusDiameter = 2e-3;
			phases = this.TheTransducer.GetInitialPhases();
			Source.Helper.List.ForEach(@(phase) this.assertTrue(...
				abs(phase-0) < Test.Settings.Tolerance ||...
				abs(phase-1) < Test.Settings.Tolerance,...
				'Expected phase to be 0'), phases);
		end
		function getInitialPhases_UnequalFociReturnsNonZeroes(this)
			this.TheTransducer.NaturalFocus = [0 0 0];
			this.TheTransducer.FocusPosition = [...
				1e-2 -1e-2 0];
			this.TheTransducer.FocusDiameter = 2e-3;
			phases = this.TheTransducer.GetInitialPhases();
			for intPhase = 1:length(phases)
				phase = phases(intPhase);
				this.assertTrue(phase ~= 0, 'Expected phase not to be 0.');
			end
		end
		function getInitialPhases_ApproxEqualFociReturnsApproxZeroes(this)
			this.TheTransducer.NaturalFocus = [0 0 0];
			this.TheTransducer.FocusPosition = [...
				Test.Settings.Tolerance/1e4 Test.Settings.Tolerance/1e4 0];
			this.TheTransducer.FocusDiameter = 2e-3;
			phases = this.TheTransducer.GetInitialPhases();
			for intPhase = 1:length(phases)
				phase = phases(intPhase);
				this.assertTrue(...
				phase ~=0&& (abs(phase-0) < Test.Settings.Tolerance ||...
				abs(phase-1) < Test.Settings.Tolerance),...
				'Expected phase to be 0')
			end
		end
		function getPowerFraction_ZeroReturnsZero(this)
			expectedPowerFraction = 0;
			powerFraction = this.TheTransducer.GetPowerFraction(0);
			this.verifyEqual(powerFraction, expectedPowerFraction, 'abstol',...
				Test.Settings.Tolerance, ['Expected power fraction to be zero'...
				' for an angle of 0 degrees']);
		end
		function getPowerFraction_IncreasingAngleIncreasesFraction(this)
			powerFraction1 = this.TheTransducer.GetPowerFraction(pi/4);
			powerFraction2 = this.TheTransducer.GetPowerFraction(pi/4+pi/8);
			this.verifyGreaterThanOrEqual(powerFraction2, powerFraction1,...
				'Expected power fraction to increase with greater angle');
		end
		function getS0_GreaterThanZero(this)
			s0 = this.TheTransducer.GetS0(2);
			this.verifyGreaterThan(s0, 0, 'Expected S0 to be greater than zero');
		end
		function getS0_ShouldBeCorrect(this)
			logger = Source.Logging.Logger.Default();
			a = 3.3*1e-3;
			f = 1.4*1e6;
			naturalFocus = [0 0 0];
			medium = Source.Physics.Medium.Fluid.New(...
				'Markoil', 1537, 1040, 0, 0, f);
			transducer = Shim.Physics.Transducer_S.New(...
				logger, a, medium, naturalFocus,...
				Source.Physics.Transducer.POSITIONS,...
				Source.Geometry.Transformation.None);
			s0 = transducer.GetS0(1);
			this.verifyGreaterThan(s0, 0, 'Expected S0 to be greater than zero');
		end
	end
end
