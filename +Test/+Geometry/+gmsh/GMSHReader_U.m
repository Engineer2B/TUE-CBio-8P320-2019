classdef GMSHReader_U < matlab.unittest.TestCase
	properties
		gmshReaderShim
	end
	methods(TestMethodSetup)
		function Setup(this)
			logger = Source.Logging.Logger.Default();
			gmshReaderOptions = Source.Geometry.gmsh.GMSHReaderOptions.Default();
			this.gmshReaderShim = Shim.Geometry.gmsh.GMSHReader_S.New(...
				logger, gmshReaderOptions);
			this.gmshReaderShim.GMSHMedia = Source.Geometry.gmsh.GMSHSurface...
				.empty(1,0);
			this.gmshReaderShim.GMSHMedia(1) =...
				Source.Geometry.gmsh.GMSHSurface.NewRandomColor(...
				1,  [Source.Geometry.gmsh.GMSHVolume.New('Bone', 1),...
				Source.Geometry.gmsh.GMSHVolume.New('Muscle', 1)]);
		end
	end
	methods (Test)
		function GetReaderState_ParsesReadState(this)
			this.gmshReaderShim.State = Source.Enum.MSHReadState.Initial;
			expectedState = Source.Enum.MSHReadState.EndPhysicalNames;
			newState = this.gmshReaderShim.GetReaderState(...
				['$' char(expectedState)]);
			this.verifyEqual(newState, expectedState);
		end
		function GetReaderState_FailureReturnsPreviousState(this)
			this.gmshReaderShim.State = Source.Enum.MSHReadState.Initial;
			expectedState = Source.Enum.MSHReadState.Initial;
			newState = this.gmshReaderShim.GetReaderState(...
				'asd');
			this.verifyEqual(newState, expectedState);
		end
		function ReadHeader(this)
			line = '3';
			expectedNOfEntries = 3;
			nOfEntries = this.gmshReaderShim.ReadSectionHeader(line);
			this.verifyEqual(nOfEntries, expectedNOfEntries,...
				'abstol', Test.Settings.Tolerance);
		end
		function ReadPhysicalName(this)
			line = '2 1 "Bone_1+Muscle_1"';
			expectedGmshMedia =...
				Source.Geometry.gmsh.GMSHSurface.NewRandomColor(...
				1,  [Source.Geometry.gmsh.GMSHVolume.New('Bone', 1),...
				Source.Geometry.gmsh.GMSHVolume.New('Muscle', 1)]);
			gmshMedia = this.gmshReaderShim.ReadPhysicalName(line);
			this.verifyTrue(gmshMedia == expectedGmshMedia);
		end
		function ReadNode(this)
			expectedNode = [0.5, -1.224606353822377e-16, 0.5];
			line = Source.Geometry.Vec3.ToGMSHString(expectedNode, 1);
			node = this.gmshReaderShim.ReadNode(line);
			this.verifyTrue(all(node == expectedNode));
			expectedNode = [-0.3744778603944999, 0.33131002410787,...
				-5.551115123125783e-17];
			line = Source.Geometry.Vec3.ToGMSHString(expectedNode, 15);
			node = this.gmshReaderShim.ReadNode(line);
			this.verifyTrue(all(node == expectedNode));
			expectedNode = [-0.3744778603944999, 0.33131002410787,...
				-5.551115123125783e-17];
			line = Source.Geometry.Vec3.ToGMSHString(expectedNode, 15);
			node = this.gmshReaderShim.ReadNode(line);
			this.verifyTrue(all(node == expectedNode));
			expectedNode = [0.3926584654403728, 0.3095469746549165,...
				-0.1700000000000003];
			line = Source.Geometry.Vec3.ToGMSHString(expectedNode, 20);
			node = this.gmshReaderShim.ReadNode(line);
			this.verifyTrue(all(node == expectedNode));
		end
		function ReadElement(this)
			node1Index = 1;
			node2Index = 2;
			node3Index = 3;
			expectedElement = [node1Index, node2Index, node3Index];
			expectedTag = 1;
			expectedVolumeIndex = 1;
			expectedMedia = this.gmshReaderShim.GMSHMedia(1).Volumes;
			line = sprintf('1 2 2 %i %i %i %i %i',...
				expectedTag, expectedVolumeIndex, node1Index, node2Index,...
				node3Index);
			
			[element, volumes, volumeIndex] =...
				this.gmshReaderShim.ReadElement(line);
			this.verifyTrue(all(element == expectedElement));
			for indexMedium = 1:length(volumes)
				this.verifyEqual(volumes(indexMedium), expectedMedia(indexMedium));
			end
			this.verifyTrue(volumeIndex == expectedVolumeIndex);
		end
		function ReadElement_Bug(this)
			node1Index = 39;
			node2Index = 17;
			node3Index = 16;
			expectedElement = [node1Index, node2Index, node3Index];
			surfaceIndex = 10;
			expectedMedia = this.gmshReaderShim.GMSHMedia(1).Volumes;
			expectedTag = 1;
			line = sprintf('1 2 2 %i %i %i %i %i',...
				expectedTag, surfaceIndex, node1Index, node2Index,...
				node3Index);
			
			[element, volumes, volumeIndex] =...
				this.gmshReaderShim.ReadElement(line);
			this.verifyTrue(all(element == expectedElement));
			for indexMedium = 1:length(volumes)
				this.verifyEqual(volumes(indexMedium), expectedMedia(indexMedium));
			end
			this.verifyTrue(volumeIndex == expectedTag);
		end
	end
end