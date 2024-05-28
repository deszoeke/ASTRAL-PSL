"""parseGpsFiles.py
Parses data from Hemisphere gps files saved on the PSD data system.
Saves GPRMC lines with the following format to an output file.
0000078 $GPRMC,000000.00,A,5822.95924260,N,04515.92776422,W,1.58,223.96,151013,22.0,W,A*04

source file names follow the convention: gps0yydddhh_raw.txt
output file names follow the convention: gprmyydddhh_raw.txt

Using Anaconda iPython installation.
Versions:anaconda 1.6.0, python 2.7.5

Byron Blomquist, NOAA/ESRL/PSD3, Aug 2014
"""
import os

# assume current directory contains raw gps files,
# dump list of data file names into a list variable
files = [f for f in os.listdir('.') if f.startswith('gps')]

# parse data files and save into txt files
for file in files:
    # open output file, new name begins with gprm
    outp = 'gprm'+file[4:]
    fgprmc = open(outp, 'w')
    print(file)
    fin = open(file)
    for line in fin:
        cleanLine = line.strip()
        lineOut = cleanLine + '\n'
        fields = cleanLine.split(',')
        if '$GPRMC' in fields[0]:
            fgprmc.write(lineOut)

    print (outp+' finished')

fgprmc.close()
# end