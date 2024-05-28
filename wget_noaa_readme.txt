How to Access Cruise data via FTP or wget
Browsers are ending their support of FTP links so PSL has set up our data links to work similarly to the way the FTP ones did. For the cruise files, the FTP prefix of

ftp1.psl.noaa.gov/data/psd3/cruises/
is the same as the web prefix
https://downloads.psl.noaa.gov/data/psd3/cruises/.
Users still have the option of using an ftp client to access the data. FTP to ftp1.psl.noaa.gov/data/psd3/cruises/ and then you can move around the directories. Alternatively, users can right click the web link and the ftp link is provided and is copied to your clipbopard. Or, simply remove prefix ftp1.psl.noaa.gov/data/ to the directory path listed at the top of each webpage and insert ftp1.psl.noaa.gov/data/psd3/cruises/ .

Some helpful ftp commands are ncftpget "ftp://ftp1.psl.noaa.gov/psd3/cruises/ATOMIC_2020/RHB/flux/netcdf/EUREC4A_ATOMIC_RonBrown_atm_ocean_near_surface_profiles_20200109-20200212_v1.2.nc"

For bulk downloads ncftpget "ftp://ftp1.psl.noaa.gov/psd3/cruises/ATOMIC_2020/RHB/flux/netcdf/*"M/code>

Users can also use wget (or curl) to get files from the command line using the http path. Copy the link shown in your browser to use with wget.

wget https://downloads.psl.noaa.gov/psd3/cruises/ATOMIC_2020/RHB/flux/netcdf/EUREC4A_ATOMIC_RonBrown_atm_ocean_near_surface_profiles_20200109-20200212_v1.2.ncM/code>
Note that wget can be run with helpful options including the equivalent of wildcards.

wget -r --no-parent -A '*.nc' https://downloads.psl.noaa.gov/psd3/cruises/ATOMIC_2020/RHB/flux/netcdf/
will download all *.nc files in that directory keeping the web structure. To downloadfiles into your current directory, use the following.

wget -r -P . --no-parent -A '*.nc' https://downloads.psl.noaa.gov/psd3/cruises/ATOMIC_2020/RHB/flux/netcdf/
Replace the dot with a preferred directory if you'd like. For example

wget -r -P /username/atmoic/rhbflux/ --no-parent -A '*.nc' https://downloads.psl.noaa.gov/psd3/cruises/ATOMIC_2020/RHB/flux/netcdf/
put the files into username/atmoic/rhbflux
See wget, curl doc links here.

Please email psl.data@noaa.gov if you have questions