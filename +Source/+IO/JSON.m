classdef JSON
	methods (Static)
		function jsonValues = Read(filePath)
			fid = fopen(filePath); 
			raw = fread(fid, inf);
			str = char(raw');
			fclose(fid);
			jsonValues = jsondecode(str);
		end
		function Write(data, filePath)
			jsonStr = jsonencode(data);
			fid = fopen(filePath, 'w');
			if fid == -1
				error('Cannot create JSON file');
			end
			fwrite(fid, jsonStr, 'char');
			fclose(fid);
		end
	end
end
