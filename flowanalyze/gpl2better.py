#!/usr/bin/python
import sys

def saveListToFile(timeDataDict, nameOfFile):
    #startTime = 946684800
    fileOut = open(nameOfFile, 'w')
    for key in sorted(timeDataDict.keys()):
        line = str(key) + " " + str(timeDataDict[key]) + "\n"
        fileOut.write(line)
    fileOut.close()

dataFile = sys.argv[1].strip()
print dataFile
data = open(sys.argv[1].strip())
#data = open("b2a_tput.datasets")
sample = {}
average = {}
countOfBlank = 0
lastLineIsBlank = False
for line in data:
    if line == "\n":
        if lastLineIsBlank == False:
            countOfBlank += 1
        lastLineIsBlank = True
    else:
        time = float(line.split(" ")[0])
        value = float(line.split(" ")[1])
        if countOfBlank % 2 == 0:
            average.update({time:value})
        else:
            sample.update({time:value})
        lastLineIsBlank = False
data.close()
saveListToFile(sample, "smp")
saveListToFile(average, "avg")
