function [k] = mat2txt(file_name, yn_loadnew, dir_name, struct)

%%% if you need to load a new mat file for the conversion, do it
if strcmp(yn_loadnew, 'y') == 1
    %%% load the .mat file from its directory
    load([dir_name file_name '.mat']);
    %%% make string of name of structure
    struct_name = char(struct);
    eval(['the_m = ' struct_name ';']);
%%% else, the structure already exists in the program by name "structname"
elseif strcmp(yn_loadnew, 'n') == 1
    % do nothing
    the_m = struct;
end
    
% the_m

fs = fields(the_m);
nfs = length(fs);
nt = length(the_m.(fs{1}));

%%% put entire structure into same ordered array with columns and rows
k = nan(nt, nfs);
for j = 1:nfs
    k(:,j) = the_m.(fs{j});
end

%%% open .txt file with same name as .mat, then print vectors
dfl = [dir_name file_name '.txt'];
flist = fopen(dfl,'w');
fmtStr = '';
fmtStr = strcat('\r\n', fmtStr);
for i = 1:nfs
   fmtStr = strcat('%20.4f ', fmtStr);
end
fprintf(flist,fmtStr,k');
fclose('all');
disp(['Text file written as ' dfl]);
