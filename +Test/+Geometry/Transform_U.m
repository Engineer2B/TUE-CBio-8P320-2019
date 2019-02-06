classdef Transform_U < matlab.unittest.TestCase 
	methods(Test)
		function GetArbitraryRotationMatrix_ShouldEqualRodriguesRotate(...
				this)
			angles = random('unif', 0, 2*pi, 100, 1);
			directions = random('unif', 0, 1, 100, 3);
			input = [1 0 0];
			for inDir = 1:size(directions, 1)
				dirVec = Source.Geometry.Vec3.Normalize(...
					directions(inDir,:));
				angle = angles(inDir);
				mat = Source.Geometry.Transform.GetArbitraryAngleRotationMatrix(...
					dirVec, angle);
				vecRot = Source.Geometry.Vec3.RodriguesRotate(input, dirVec,...
					angle);
				this.verifyEqual(mat*input', vecRot');
			end
		end
	end
end
