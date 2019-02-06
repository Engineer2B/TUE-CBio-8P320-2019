classdef TriangleElement_U < matlab.unittest.TestCase 
	properties
		TriangleElement1
	end
	methods(TestMethodSetup)
		function LoadConfiguration(this)
			this.TriangleElement1 = Source.Geometry.TriangleElement.New(...
			 [1,0,0],...
			 [0,1,0],...
			 [0,0,1]);
		end
	end
	methods(Test)
		function eq(this)
			tr2 = Source.Geometry.TriangleElement.New(...
			 [1,0,0], [0,1,0], [0,0,1]);
		 this.verifyTrue(this.TriangleElement1 == tr2);
		end
		function ApplyMatrix(this)
			matrix = [2 1 0
				0 3 0
				0 0 4];
			this.TriangleElement1.ApplyMatrix(matrix);
			tr2 = Source.Geometry.TriangleElement.New([2 1 0], [0 3 0], [0 0 4]);
			this.verifyTrue(this.TriangleElement1 == tr2);
		end
		function ChangeInclination(this)
			tr = Source.Geometry.TriangleElement.New([0 0 0], [0 1 0], [0 0 1]);
			tr.ChangeInclination(pi/2);
			tr2 = Source.Geometry.TriangleElement.New([0 0 0], [0 1 0], [1 0 0]);
			this.verifyTrue(tr.ApproxEqualTo(tr2, Test.Settings.Tolerance));
		end
		function ChangeAzimuth(this)
			tr = Source.Geometry.TriangleElement.New([0 0 0], [0 1 0], [0 0 1]);
			tr.ChangeAzimuth(pi/2);
			tr2 = Source.Geometry.TriangleElement.New([0 0 0], [1 0 0], [0 0 1]);
			this.verifyTrue(tr.ApproxEqualTo(tr2, Test.Settings.Tolerance));		
		end
		function NormalVectors(this)
			normalVector1 = this.TriangleElement1.NormalVector1;
			normalVector2 = this.TriangleElement1.NormalVector2;
			norm1 = norm([normalVector1(1), normalVector1(2), normalVector1(3)]);
			norm2 = norm([normalVector2(1), normalVector2(2), normalVector2(3)]);
			this.verifyEqual(norm1, 1, 'abstol', Test.Settings.Tolerance);
			this.verifyEqual(norm2, 1, 'abstol', Test.Settings.Tolerance);
			this.verifyEqual(normalVector1, -normalVector2);
		end
		function Edges(this)
			this.verifyEqual(this.TriangleElement1.Edge1,...
				[-1,1,0]);
			this.verifyEqual(this.TriangleElement1.Edge2,...
				[-1,0,1]);
		end
		function FindIntersectionMTA(this)
			distance = this.TriangleElement1.FindIntersectionMTA(...
			this.TriangleElement1.Incenter - [3,0,0],...
			[1,0,0]);
			this.verifyEqual(distance, 3, 'abstol', Test.Settings.Tolerance);
		end
		function FindIntersectionMTAOld(this)
			distance = this.TriangleElement1.FindIntersectionMTAOld(...
			this.TriangleElement1.Incenter - [3,0,0],...
			[1,0,0]);
			this.verifyEqual(distance, 3, 'abstol', Test.Settings.Tolerance);
		end
	end
end
