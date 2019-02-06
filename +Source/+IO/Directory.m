classdef Directory
	%DIRECTORY For retrieving information on the locations of folders.
	properties(Constant)
		ProjectName = 'PowerCalculator'
	end
	methods(Access = public, Static)
		%DROPBOX Returns the path to the dropbox root folder.
		function path = Dropbox()
			if(isunix)
				errorStruct.message = char(strcat(...
					"Failed to find the Dropbox folder, this method is only supported under Windows..."));
				errorStruct.identifier = 'GetDropboxFolderPath:NotWindows';
				error(errorStruct);
			end
			f = Source.Helper.Directory.getDropboxDataDir(false);
			hostdb = fopen([f '/host.db']);
			if(hostdb == -1)
				% try local version
				f = Source.Helper.Directory.getDropboxDataDir(true);
				hostdb = fopen([f '/host.db']);
			end
			if(hostdb == -1)
				errorStruct.message = char(strcat(...
					"Failed to find the Dropbox folder, perhaps it is not installed..."));
				errorStruct.identifier = 'GetDropboxFolderPath:PathNotFound';
				error(errorStruct);
			end
			%skip line
			fgetl(hostdb);
			s = fgetl(hostdb);
			path = sprintf('%s', Base64Decode(s));
		end
	end
	methods(Access = private, Static)
		function separator = getSeparator()
			if(isunix)
				separator = '/';
			else
				separator = '\';
			end
		end
		function f = getDropboxDataDir(local)
			f = Source.Helper.Directory.getApplicationDataDir(...
				'dropbox', 0, local);
		end
		function appDir = getApplicationDataDir(appicationName, doCreate, local)
			%GETAPPLICATIONDATADIR   return the application data directory.
			%   APPDIR = GETAPPLICATIONDATADIR(APPICATIONNAME, DOCREATE, LOCAL) returns
			%   the application's data directory using the registry on windows systems
			%   or using Java on non windows systems as a string and creates the
			%   directory if missing and requested, i.e. DOCREATE = true.
			%   APPICATIONNAME  should be a worldwide unique application name - using
			%                   the web domain name as part of the name is a
			%                   appropriate method, hierarchical naming is possible cf.
			%                   examples
			%   DOCREATE        boolean, the application data directory is created if
			%                   it is missing and DOCREATE is equal true
			%   LOCAL           boolean, if true the local, i.e. the machine related,
			%                   application data directory is returned and maybe
			%                   created - this argument is ignored on non windows
			%                   operating systems
			%   GETAPPLICATIONDATADIR throws an error if it is unable to create the
			%   application data directory while DOCREATE is being true.
			%
			%   Examples:
			%       getapplicationdatadir('Test', false, false)
			%   returns on windows
			%       C:\Documents and Settings\MYNAME\Application Data\Test
			%   without creating the directory even if it is missing.
			%
			%       getapplicationdatadir(...
			%           fullfile('com','mathworks','companyUnique1',''), true, true)
			%   returns on windows
			%       C:\Documents and Settings\MYNAME\Local Settings\Application
			%       Data\com\mathworks\companyUnique1
			%   creating the directory if it is missing.


			if ispc
					if local
							allAppDir = winqueryreg('HKEY_CURRENT_USER',...
									['Software\Microsoft\Windows\CurrentVersion\' ...
									'Explorer\Shell Folders'],'Local AppData');
					else
							allAppDir = winqueryreg('HKEY_CURRENT_USER',...
									['Software\Microsoft\Windows\CurrentVersion\' ...
									'Explorer\Shell Folders'],'AppData');
					end
					appDir = fullfile(allAppDir, appicationName,[]);
			else
					allAppDir = char(java.lang.System.getProperty('user.home'));
					appDir = fullfile(allAppDir, ['~' appicationName],[]);
			end
			if doCreate
					[success, msg, ~] = mkdir(appDir);
					if success ~= 1
							error('getapplicationdatadir:create', ...
									'Unable to create application data directory\n%s\nDetails: %s', ...
									appDir, msg);
					end
			end
		end
	end
end