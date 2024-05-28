function filecat(varargin)
% FILECAT  concatenates files.
%
% Syntax
%   FILECAT('source','destination')
%   FILECAT('source','destination','Overwrite')
%
% Description
%   FILECAT('source','destination') concatenates all the files from the 
%   specified source to the destination file.  'source' and 'destination' are 
%   the absolute or relative pathnames for the files.  Use the wildcard * at 
%   the end of source to concatenate all matching files.  If the final 
%   destination file already exist, a dialog box will ask the user if he 
%   wants to write over the file or abort.
%
%   FILECAT('source','destination','Overwrite') concatenates source to 
%   destination without the overwriting dialog box.  When 'Overwrite' is 
%   activated, the user allow the possible writing over the destination file. 
%   This is useful when the function is used inside a loop.
%
% Examples
%   data1=[1 2 3];save('C:\mydata1.txt', 'data1', '-ascii');
%   data2=[4 5 6];save('C:\mydata2.txt', 'data2', '-ascii');
%       filecat('C:\mydata*.txt','C:\allmydata.txt')
%   %Here is another way of doing the same thing: 
%       filecat('C:\mydata*.txt','allmydata.txt')
%   %If C:\ is your current working directory:
%       filecat('mydata*.txt','allmydata.txt')
%
% Version for Microsoft Windows 2000 and Windows XP only. If working with
% Microsoft Windows 95, Windows 98 and Windows ME, use the pipe symbol "|"
% for DOS commands instead of the amperstand symbol "&"
%
% Ludovic Bariteau on 02/14/2008
% ludovic.bariteau@noaa.gov
% Revision history, original version 02/14/2008
% 02/19/08 Changed 'Overwriting' by 'Overwrite', and put capital letter to
% the dialog box button names (lines 85-86).
% 02/19/08 Add lines by D. Welsh to check if the platform is Windows or
% UNIX (lines 101-104)
% 08/28/08 An extra character was put at end of the destination file. Added binary option /b to dos copy function  (lines 100)
% 09/22/09 change logic at line 46 to fix bug. Replaced '(nargin==2 && ~ischar(varargin{1}) && ~ischar(varargin{2}))'
%  by '(nargin==2 && (~ischar(varargin{1}) || ~ischar(varargin{2})))'
% 09/22/09 improved checks on inputs. Before, for instance if nargin was 3,
% I was not checking if varargin{1} was a string or not. But it was done
% for nargin=2. Should be done anytime...

%do some checks on inputs
switch nargin
    case 1
        error('Use 2 inputs for filecat(''source'',''destination'')'); 
    case 2
        if (~ischar(varargin{1}) || ~ischar(varargin{2}))
            error('This function requires string inputs.');
        end
    case 3
        if (~ischar(varargin{1}) || ~ischar(varargin{2}))
            error('This function requires string inputs.');
        elseif ~ischar(varargin{3})
            error('This function requires string inputs.');
        elseif ~strcmp(varargin{3},'Overwrite')
            error(['Invalid parameter ' varargin{3} '.'])
        end    
    otherwise %case nargin>3
        error('Use 2 or 3 inputs only for filecat'); 
end;
% % 
% % if nargin<2
% %     error('Use 2 inputs for filecat(''source'',''destination'')'); 
% % elseif (nargin==2 && (~ischar(varargin{1}) || ~ischar(varargin{2})))
% %     error('This function requires string inputs.');
% % elseif (nargin==3 && ~ischar(varargin{3}))
% %     error('This function requires string inputs.');
% % elseif (nargin==3 && strcmp(varargin{3},'Overwrite')==0)
% %     error(['Invalid parameter ' varargin{3} '.'])
% % elseif (nargin>3)
% %     error('Use 3 inputs only for filecat(''source'',''destination'',''Overwrite'')'); 
% % end;

pathin = fileparts(varargin{1});
[pathout, nameout, extout] = fileparts(varargin{2});

if isempty(pathin)
    pathin=pwd;
end;

if isempty(pathout)
    pathout=pathin;
end;

if isempty(nameout)
    nameout='default';
end;

% LIST OF FILES IN THE SPECIFIED DIRECTORY 
files=dir(varargin{1});
c = struct2cell(files);c=c(1,:);

% CHECK IF INPUT FILES EXIST?
if isempty(c)
    error('The specified input file(s) cannot be found. Check out your directory or syntax!')
end;


% CHECK IF DESTINATION FILE ALREADY EXISTS IN SOURCE DIRECTORY.
if exist(fullfile(pathin,[nameout extout]),'file')==2
    c(strcmp(c,[nameout extout]))=[];
end;

% CHECK IF DESTINATION FILE ALREADY EXISTS IN DESTINATION DIRECTORY?
if nargin==2
    if exist(fullfile(pathout,[nameout extout]),'file')==2
        a=questdlg(['The file, "' nameout extout '" already exists in destination ' pathout],'', ...
        'Overwrite','Abort','Abort');
        if strcmp(a,'Abort')==1
            return
        end;    
    end; 
end;


%Concatenate to desire directory/file name. The use of & allow to use
%multiple command at one command prompt.
if ispc
    s=sprintf('%s+',c{:});
    dos(['cd /d ' pathin ' & copy /b ' s(1:end-1) ' ' fullfile(pathout, [nameout extout])]);
else
    s=sprintf('%s ',c{:});
    system([ 'cd ' pathin '; cat ' s(1:end-1) ' > ' fullfile(pathout, [nameout extout]) ]);
end;
