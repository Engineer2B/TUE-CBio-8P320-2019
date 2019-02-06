classdef LatticeOptions_GetPlanarSliceIndices_U < matlab.unittest.TestCase
	properties
		Point1
		Point2
		Spacing
		Lat
	end
	properties(TestParameter)
		Offset = arrayfun(@(a) {a}, 0:3)
	end
	methods(TestClassSetup)
		function LoadConfiguration(this)
			this.Point1 = [0 0 0];
			this.Point2 = [2 3 4];
			this.Spacing = [1 1 1];
			this.Lat = Shim.Geometry.LatticeOptions_S.New(...
				Source.Geometry.Extrema.FromTwoPoints(this.Point1, this.Point2),...
				this.Spacing);
		end
	end
	methods(Test)
		function GetPlanarSliceIndices_ShouldGetAllCoronalSlices(this, Offset)
			if(Offset + 1 <= this.Lat.Steps(1))
				indices = this.Lat.GetPlanarSliceIndices(...
					Source.Enum.Plane.Coronal, Offset*this.Spacing(1));
				[xIndices, yIndices, zIndices] = ind2sub(...
					[this.Lat.Steps(1) this.Lat.Steps(2) this.Lat.Steps(3)], indices);
				yTz = this.Lat.Steps(2)*this.Lat.Steps(3);
				this.assertEqual(length(xIndices), yTz,...
					sprintf('#x != #y*#z: %i != %i', length(xIndices), yTz));
				this.assertEqual(length(unique(indices)), yTz,...
					sprintf('#x != #y*#z: %i != %i', length(unique(indices)), yTz));
				this.assertEqual(xIndices, (Offset+1)*ones(1,yTz),...
					'x indices not all ones');
				this.assertEqual(yIndices, repmat(1:this.Lat.Steps(2),...
					1,this.Lat.Steps(3)),...
					'unexpected y indices');
				expectedZIndices = zeros(1,this.Lat.Steps(3));
				for index = 1:this.Lat.Steps(3)
					expectedZIndices(1+(index-1)*this.Lat.Steps(2):...
						index*this.Lat.Steps(2)) = index;
				end
				this.assertEqual(zIndices, expectedZIndices,...
					'unexpected z indices');
			end
		end
		function GetPlanarSliceIndices_ShouldGetAllSagittalSlices(this, Offset)
			if(Offset + 1 <= this.Lat.Steps(2))
				indices = this.Lat.GetPlanarSliceIndices(...
					Source.Enum.Plane.Sagittal, Offset*this.Spacing(2));
				[~, yIndices, ~] = ind2sub(...
					[this.Lat.Steps(1) this.Lat.Steps(2) this.Lat.Steps(3)], indices);
				xTz = this.Lat.Steps(1)*this.Lat.Steps(3);
				this.assertEqual(length(yIndices), xTz);
				this.assertEqual(length(unique(indices)), xTz);
				this.assertEqual(yIndices, (Offset+1)*ones(1,xTz));
			end
% 			this.assertEqual(yIndices, repmat(1:this.Lat.Steps(2),...
% 				1,this.Lat.Steps(3)));
% 			expectedZIndices = zeros(1,this.Lat.Steps(3));
% 			for index = 1:this.Lat.Steps(3)
% 				expectedZIndices(1+(index-1)*this.Lat.Steps(3):...
% 					index*this.Lat.Steps(3)) = index;
% 			end
% 			this.assertEqual(zIndices, expectedZIndices);
		end
		function GetPlanarSliceIndices_ShouldGetAllTransverseSlices(this, Offset)
			if(Offset + 1 <= this.Lat.Steps(3))
				indices = this.Lat.GetPlanarSliceIndices(...
					Source.Enum.Plane.Transverse, Offset*this.Spacing(3));
				[~, ~, zIndices] = ind2sub(...
					[this.Lat.Steps(1) this.Lat.Steps(2) this.Lat.Steps(3)], indices);
				xTy = this.Lat.Steps(1)*this.Lat.Steps(2);
				this.assertEqual(length(zIndices), xTy);
				this.assertEqual(length(unique(indices)), length(indices));
				this.assertEqual(zIndices, (Offset+1)*ones(1,xTy));
	% 			this.assertEqual(yIndices, repmat(1:this.Lat.Steps(2),...
	% 				1,this.Lat.Steps(3)));
	% 			expectedZIndices = zeros(1,this.Lat.Steps(3));
	% 			for index = 1:this.Lat.Steps(3)
	% 				expectedZIndices(1+(index-1)*this.Lat.Steps(3):...
	% 					index*this.Lat.Steps(3)) = index;
	% 			end
	% 			this.assertEqual(zIndices, expectedZIndices);
			end
		end
	end
end