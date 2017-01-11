from decimal import Decimal

fw = open('trace1','w')

port = 48882

with open('tcptrace.11111') as fr:
    content = fr.readlines()
    for line in content:
        pieces = line.split(" ")
        dest = pieces[2]
        dstport = Decimal(dest.split(":")[1])
        #print dstport
        if dstport == port:
        #print str(time) + ' ' + str(rtt)
            fw.write(line)
fw.close()
