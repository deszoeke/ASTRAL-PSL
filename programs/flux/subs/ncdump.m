function ncdump(ncfl)
%{
    Reads variable attributes from a netCDF file and saves
    information to a tab delimited file in the same directory

    input parameters:
        ncfl = string path to netCDF file

    Similar to the linux command of the same name ncdump 
    https://www.unidata.ucar.edu/software/netcdf/workshops/2011/utilities/NcdumpExamples.html 
    It is useful to generate a text representation of any netcdf files.
    The text representation has the extension CDL but you can also change to txt if preferred. 
    Here is an example in the terminal: ncdump -h your_file.nc > your_file.cdl

%}

[fpath,fname,~] = fileparts(ncfl);
nci = ncinfo(ncfl);  % read file attributes into matlab structure

N = length(nci.Variables);
var =  cell(N,1);
size = cell(N,1);
dType =  cell(N,1);
fillVal =  cell(N,1);
units =  cell(N,1);
longName =  cell(N,1);
missVal =  cell(N,1);

% read variable names and selected attributes
for ii = 1:N
    var{ii} = nci.Variables(ii).Name;
    size{ii} = sprintf('%8i',nci.Variables(ii).Size);
    dType{ii} = nci.Variables(ii).Datatype;
    fillVal{ii} = sprintf('%16.9e',nci.Variables(ii).FillValue);
    % read and save additional attributes if they exist
    attrs = {nci.Variables(ii).Attributes.Name};
    vals = {nci.Variables(ii).Attributes.Value};
    xx = find(strcmp(attrs,'units'));
    if ~isempty(xx); units{ii} = vals{xx}; end
    xx = find(strcmp(attrs,'long_name'));
    if ~isempty(xx); longName{ii} = vals{xx}; end
    xx = find(strcmp(attrs,'missing_value'));
    if ~isempty(xx); missVal{ii} = sprintf('%16.9e',vals{xx}); end
end

% find any '%' characters and insert another '%' to escape errors in fprintf
for ii = 1:N
    str = var{ii};
    xx = find(strcmp(str,'%'));
    if ~isempty(xx)
        if xx==1; var{ii} = ['%',str];  % '%' is at beginning or length == 1
        elseif xx==length(str); var{ii} = [str,'%'];  % '%' is at end of string and length >1
        elseif xx>1; var{ii} = [str(1:xx-1),'%',str(xx:end)]; % '%' is in middle of string
        end
    end
    str = units{ii};
    xx = find(strcmp(str,'%'));
    if ~isempty(xx)
        if xx==1; units{ii} = ['%',str];  % '%' is at beginning or length == 1
        elseif xx==length(str); units{ii} = [str,'%'];  % '%' is at end of string and length >1
        elseif xx>1; units{ii} = [str(1:xx-1),'%',str(xx:end)]; % '%' is in middle of string
        end
    end
    str = longName{ii};
    xx = find(strcmp(str,'%'));
    if ~isempty(xx)
        if xx==1; longName{ii} = ['%',str];  % '%' is at beginning or length == 1
        elseif xx==length(str); longName{ii} = [str,'%'];  % '%' is at end of string and length >1
        elseif xx>1; longName{ii} = [str(1:xx-1),'%',str(xx:end)]; % '%' is in middle of string
        end
    end
end

% write to ouput tab delimited text file that can open in Excel
hdr1 = ['Variables and Attributes: ',fname,'\n'];
hdr2 = 'name \t size \t type \t fill value \t units \t long name \t missing value\n';
fout = fopen(fullfile(fpath,[fname,'_vars.txt']),'w');
fprintf(fout,hdr1);
fprintf(fout,hdr2);
for ii = 1:N
    str = [var{ii},'\t',size{ii},'\t',dType{ii},'\t',fillVal{ii},'\t',units{ii},...
           '\t',longName{ii},'\t',missVal{ii},'\n'];
    fprintf(fout,str);
end
fclose all;

end