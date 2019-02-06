classdef MediumName < double
	enumeration
		TestSolid(-2)
		TestFluid(-1)
		EmptySpace(1)
		Muscle(2)
		Bone(3)
		Markoil(4)
		Water(5)
		Marrow(6)
		Aluminum(7)
		Fat(8)
		Agar2Silica(9)
		Air(10)
		TrabecularBone(11)
	end
	methods(Access = public)
		function displayString = ToDisplayString(this)
			switch(this)
				case Source.Enum.MediumName.EmptySpace
					displayString = 'Empty space';
				case Source.Enum.MediumName.Muscle
					displayString = 'Muscle';
				case Source.Enum.MediumName.Bone
					displayString = 'Bone';
				case Source.Enum.MediumName.Markoil
					displayString = 'Markoil';
				case Source.Enum.MediumName.Water
					displayString = 'Water';
				case Source.Enum.MediumName.Marrow
					displayString = 'Marrow';
				case Source.Enum.MediumName.Aluminum
					displayString = 'Aluminum';
				case Source.Enum.MediumName.Fat
					displayString = 'Fat';
				case Source.Enum.MediumName.Agar2Silica
					displayString = 'Agar with $2\%$ silica';
				case Source.Enum.MediumName.Air
					displayString = 'Air';
				case Source.Enum.MediumName.TestFluid
					displayString = 'Test fluid';
				case Source.Enum.MediumName.TestSolid
					displayString = 'Test solid';
                case Source.Enum.MediumName.TrabecularBone
					displayString = 'Trabecularbone';
			end
		end
		function str = ToCString(obj)
			switch(obj)
					case Source.Enum.MediumName.Bone
						str = 'FMedium::Bone';
					case Source.Enum.MediumName.Muscle
						str = 'FMedium::Muscle';
					case Source.Enum.MediumName.Agar2Silica
						str = 'FMedium::Agar2Silica';
					case Source.Enum.MediumName.Air
						str = 'FMedium::Air';
				otherwise
					error('Source:Enum:MediumName:UnknownValue',...
					'Unknown MediumName value!');
			end
		end
	end
	methods(Static)
		function obj = parse(str)
			switch(str)
				case 'FMedium::Bone'
					obj = Source.Enum.MediumName.Bone;
				case 'FMedium::Muscle'
					obj = Source.Enum.MediumName.Muscle;
				case 'FMedium::Markoil'
					obj = Source.Enum.MediumName.Markoil;
				case 'FMedium::Water'
					obj = Source.Enum.MediumName.Water;
				case 'FMedium::Agar2Silica'
					obj = Source.Enum.MediumName.Agar2Silica;
				case 'FMedium::Air'
					obj = Source.Enum.MediumName.Air;
				case 'FMedium::TrabecularBone'
					obj = Source.Enum.MediumName.TrabecularBone;
				otherwise
					Source.Enum.MediumName(str);
			end
		end
		function max = MaxValue()
			max = 11;
		end
		function allValues = All()
			allValues = Source.Enum.MediumName(1:Source.Enum.MediumName.MaxValue);
		end
		function mediumName = From2017Struct(rayStruct)
			% In RayTracing_V_2017 the actual value of the material gets
			% lost when generating sons in Reflection_Refraction, however we can
			% sortf of infer its value from the actual_object property.
			switch(rayStruct.actual_object)
				case 1
					mediumName = Source.Enum.MediumName.Markoil;
				case 2
					mediumName = Source.Enum.MediumName.Fat;
				case {3, 5}
					mediumName = Source.Enum.MediumName.Muscle;
				case {4, 6}
					mediumName = Source.Enum.MediumName.Bone;
				otherwise
					error('Source:Enum:MediumName:From2017Struct:Unsupported',...
					['Value: ' num2str(rayStruct.actual_object)...
						' is not supported atm']);
			end
		end
	end
end