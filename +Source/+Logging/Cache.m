classdef Cache
	%CACHE Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		Property1
	end
	
	methods
		function SaveStruct(this, struct, name)
			jsonText = jsonencode(struct);
			fileID = fopen('exp.txt','w');
			fprintf(fileID,'%6s %12s\n','x','exp(x)');
			fprintf(fileID,'%6.2f %12.8f\n',A);
			fclose(fileID);
		end
		function LoadStruct(this, name)
			
		end
	end
end

