"""parseHedFiles.py
Parses data from Hemisphere heading files saved on the PSD data system.
Saves $PSAT lines with the following format to an output file.
0000559 $PSAT,HPR,050000.40,,,,*73

source file names follow the convention: hed0yydddhh_raw.txt
output file names follow the convention: hed1yydddhh_raw.txt

Byron Blomquist, NOAA/ESRL/PSD3, Aug 2019
"""
import os

# assume current directory contains raw gps files,
# dump list of data file names into a list variable
files = [f for f in os.listdir('.') if f.startswith('hed0')]

# parse data files and save into txt files
for file in files:
    # open output file, new name begins with gprm
    outp = 'hed1'+file[4:]
    fgprmc = open(outp, 'w')
    print(file)
    fin = open(file)
    for line in fin:
        cleanLine = line.strip()
        lineOut = cleanLine + '\n'
        fields = cleanLine.split(',')
        if '$PSAT' in fields[0]:
            fgprmc.write(lineOut)

    print(outp+' finished')

fgprmc.close()
# end