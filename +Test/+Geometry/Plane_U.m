classdef Plane_U < matlab.unittest.TestCase
	methods(Test)
		function FindIntersection(this)
			media =	Test.Settings.MAIN_TEST_MEDIA;
			plane = Source.Geometry.Plane.New([-1 -1 -1], [0 0 0],...
				media.GetSolid('Bone'), 1, Source.Helper.Random.Color,...
			@(planeO) strcmp(planeO.Medium.Name, 'Markoil') == 0);
			obj.Origin = [-4,0,0];
			for in = 1:100
				obj.Direction = Source.Geometry.Vec3.Random()-.5;
				res = plane.FindIntersection(obj);
				if(obj.Direction*plane.Normal'<0)
					this.verifyEqual((obj.Origin + res.MinLambda*obj.Direction)*...
						plane.Normal', 0, 'abstol', Test.Settings.Tolerance,...
						Test.Geometry.Plane_U.interSectionFailMessage(obj.Direction));
				else
					this.verifyEqual(res.MinLambda, Inf);
				end
			end
		end
	end
	methods(Static)
		function str = interSectionFailMessage(direction)
			str = [ 'Failed to find intersection for direction '...
				Source.Geometry.Vec3.ToString(direction)];
		end
	end
end
