import os,subprocess
from decimal import Decimal

LOCAL_IP = '129.10.99.176'
pcap_dir = './pcap/'
result_dir = './results/'
cmd_tcptrace = './tcptrace -n '
cmd_xpl2gpl = './xpl2gpl '
cmd_parse = './gpl2better.py '
BURST_SSH = 0.5
conns = []
pickedConns = []

def reverse(string):
    newString = ''
    pieces = string.split("2")
    newString = pieces[1] + '2' + pieces[0]
    return newString

def getValue(item):
    return item[1]

def getKey(item):
    return item[0]

def getAllConns(pcapFile):
    cmd = cmd_tcptrace + pcap_dir + pcapFile;
    output = os.popen(cmd)
    info = output.readlines()
    pickedConn = ''
    maxPkts = 0
    for line in info:
        line = line.strip()
        if not line:
            continue
        pieces = line.split(" ")
        pieces = filter(None, pieces)
        if ':' not in pieces[0]:
            continue
        # Check the downlink traffic
        ip = pieces[1].split(":")[0]
        if ip == LOCAL_IP:
            connName = reverse(pieces[4][1:-1])
        else:
            connName = pieces[4][1:-1]
        pkt = int(pieces[6][0:-1])
        conns.append((connName, pkt))
    return sorted(conns, key=getValue, reverse=True)


def anaTp(pcapFile, conn):
    cmds = []
    cmds.append(cmd_tcptrace + '-T -y -A10 ' + pcap_dir + pcapFile)
    cmds.append(cmd_xpl2gpl + conn + '_tput.xpl')
    cmds.append(cmd_parse + conn + '_tput.datasets')
    cmds.append('mv smp ' + result_dir + pcapFile + '_' + conn + '_tp_smp')
    cmds.append('mv avg '  + result_dir + pcapFile + '_' + conn + '_tp_avg')
    for cmd in cmds:
        output = os.popen(cmd)
        output.read()

def anaSeq(pcapFile, conn):
    cmds = []
    tsgFile = conn + '_tsg.xpl'
    if not os.path.isfile(tsgFile):
        cmds.append(cmd_tcptrace + '-S ' + pcap_dir + pcapFile)
    cmds.append(cmd_xpl2gpl + conn + '_tsg.xpl')
    cmds.append(cmd_parse + conn + '_tsg.datasets')
    smpFile = './results/' + pcapFile + '_' + conn + '_seq_smp'
    avgFile = './results/' + pcapFile + '_' + conn + '_seq_avg'
    cmds.append('mv smp ' + smpFile)
    cmds.append('mv avg ' + avgFile)
    for cmd in cmds:
        print "executing " + cmd
        output = os.popen(cmd)
        output.read()

def anaBurst(pcapFile, conn):
    # check if seq file exist or not, if not run anaSeq first
    seqFile = './results/' + pcapFile + '_' + conn + '_seq_smp'
    burstFile = './results/' + pcapFile + '_' + conn + '_burst'
    if not os.path.isfile(seqFile):
        anaSeq(pcapFile, conn)
    # Start analyze burst
    initTime = 0
    lastBurst_time = 0
    lastBurst_seq = 0
    lastTime = 0
    bursts = []
    fw = open(burstFile,'w')
    with open(seqFile) as fr:
        content = fr.readlines()
        for line in content:
            pieces = line.split(" ")
            time = Decimal(pieces[0])
            seq = Decimal(pieces[1])
            if not lastTime:
                lastBurst_seq = seq
                lastBurst_time = time
                lastTime = time
                initTime = time
                continue
            gap = time-lastTime
            if gap > BURST_SSH:
                # Find a new burst, record information
                #print lastBurst_time-initTime, lastTime-initTime, time-initTime
                lastBurst_byte = seq - lastBurst_seq
                lastBurst_duration = lastTime - lastBurst_time
                if lastBurst_duration > 0:
                    lastBurst_tp = lastBurst_byte/lastBurst_duration
                else:
                    lastBurst_tp = 0
                fw.write("%s %s %.2f %.2f %s\n" % (lastBurst_time, lastBurst_duration, lastBurst_byte/1000000, lastBurst_tp/125000, gap))
                lastBurst_time = time
                lastBurst_seq = seq
            lastTime = time
    fr.close()
    fw.close()


def anaWnd(pcapFile, conn):
    cmds = []
    cmds.append(cmd_tcptrace + '-H ' + pcap_dir + pcapFile)
    cmds.append(cmd_xpl2gpl + conn + '_rcwnd.xpl')
    cmds.append(cmd_parse + conn + '_rcwnd.datasets')
    cmds.append('mv smp ./results/' + pcapFile + '_wnd_smp')
    cmds.append('mv avg ./results/' + pcapFile + '_wnd_avg')
    for cmd in cmds:
        output = os.popen(cmd)
        output.read()

def clean():
    cmds = []
    cmds.append('rm ./*.xpl')
    cmds.append('rm ./*.labels')
    cmds.append('rm ./*.gpl')
    cmds.append('rm ./*.datasets')
    for cmd in cmds:
        output = os.popen(cmd)
        print output.read()

def aggTp(pickedConns):
    # Get all tuple of time & flow
    connTpTuples = []
    for conn in pickedConns:
        fname = result_dir + pcapFile + '_' + conn + '_tp_smp'
        if not os.path.isfile(fname):
            print "Cannot find %s, continue.." % (fname)
            continue
        with open(fname) as f:
            content = f.readlines()
            for line in content:
                pieces = line.split(" ")
                time = Decimal(pieces[0])
                tp = Decimal(pieces[1])
                connTpTuples.append((time, tp))
    connTpTuples.sort(key=getKey)
    startTime = connTpTuples[0][0]
    f = open(result_dir + pcapFile + '_agg_tp_smp','w')
    for connTp in connTpTuples:
        f.write(str(connTp[0] - startTime) + ' ' + str(connTp[1]) + '\n')
    f.close()

def plotSeq(conns, conns_choosen):
    # Currently only support one/two connections
    if not conns_choosen or conns_choosen > 2:
        return
    plotCmd = "plot "
    freezeScreen = "pause -1"
    colorIndex = 1
    for i in range(0, conns_choosen):
        conn = conns[i][0]
        seqFile = './results/' + pcapFile + '_' + conn + '_seq_smp'
        with open(seqFile, 'r') as f:
            first_line = f.readline()
            pieces = first_line.split(" ")
            initTime = pieces[0].strip()
            initSeq =  pieces[1].strip()
            plotCmd += "\"%s\" using ($1-%s):($2-%s) title \"%s\" with points linecolor %d ," \
            % (seqFile, initTime, initSeq, conn, colorIndex)
            colorIndex += 1
    # Stupid way to plot, but at least it works now
    f = open('plotSeq.gp','w')
    f.write(plotCmd[:-2] + '\n')
    f.write(freezeScreen)
    f.close() # you can omit in most cases as the destructor will call it
    os.system("gnuplot plotSeq.gp")
    #plotProcess.communicate(freezeScreen)

pcapFile = 'youtube2160'
conns_choosen = 2
conns = getAllConns(pcapFile)
print 'Pcap: ' + pcapFile
for i in range(0, conns_choosen):
    conn = conns[i][0]
    sentPkt = conns[i][1]
    pickedConns.append(conn)
    print 'Analyze connection: ' + conn + ', packets sent: ' + str(sentPkt)
    #anaTp(pcapFile, conn)
    anaSeq(pcapFile, conn)
    anaBurst(pcapFile, conn)
plotSeq(conns, conns_choosen)
#aggTp(pickedConns)
#anaTp(pcapFile, 'aj2ai')
#anaSeq(pcapFile, conn)
#anaWnd(pcapFile, conn)
clean()
print 'Done'
