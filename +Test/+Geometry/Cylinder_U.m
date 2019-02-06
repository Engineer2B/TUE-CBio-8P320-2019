classdef Cylinder_U < matlab.unittest.TestCase
	properties(Constant)
		STATE_FOLDER = fullfile(Test.Settings.STATE_FOLDER, 'Geometry',...
			'Cylinder')
	end
	methods(Test)
		function FindIntersection_ShouldMatchDistanceToCenter(this)
			media =	Test.Settings.MAIN_TEST_MEDIA;
			cyl = Source.Geometry.Cylinder.New([0 0 1], .5, [0 0 0],...
				media.GetSolid('Bone'), 1, Source.Helper.Random.Color,...
				@(cylO) strcmp(cylO.Medium.Name, 'Markoil') == 0);
			ray.Origin = [-1,0,0];
			for in = 1:100
				ray.Direction = Source.Geometry.Vec3.Normalize(...
					Source.Geometry.Vec3.Random()-.5);
				res = cyl.FindIntersection(ray);
				if(res.MinLambda ~= Inf)
					point = ray.Origin + res.MinLambda*ray.Direction;
					this.verifyEqual(norm((point - cyl.Center) -...
						point*(cyl.ShaftDirection - cyl.Center)'*...
						(cyl.ShaftDirection - cyl.Center)), cyl.Radius,...
						'abstol', Test.Settings.Tolerance,...
						Test.Geometry.Cylinder_U...
						.interSectionFailMessage(ray.Direction));
				end
			end
		end
	end
	methods(Static)
		function str = interSectionFailMessage(direction)
			str = ['Failed to find intersection for direction '...
				Source.Geometry.Vec3.ToString(direction)];
		end
	end
end
