import os,subprocess

pcap_dir = './pcap/'
cmd_tcptrace = './tcptrace -n '
cmd_xpl2gpl = './xpl2gpl '
cmd_parse = './gpl2better.py '

def reverse(string):
    newString = ''
    pieces = string.split("2")
    newString = pieces[1] + '2' + pieces[0]
    return newString

def pickConn(pcapFile):
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
        pkt = int(pieces[6][0:-1])
        if pkt > maxPkts:
            maxPkts = pkt
            pickedConn = pieces[4][1:-1]
    pickedConn = reverse(pickedConn)
    return pickedConn, maxPkts
        

def anaTp(pcapFile, conn):
    cmds = []
    #doPlot = True
    cmds.append(cmd_tcptrace + '-T -y -A10 ' + pcap_dir + pcapFile)
    cmds.append(cmd_xpl2gpl + conn + '_tput.xpl')
    cmds.append(cmd_parse + conn + '_tput.datasets')
    smpFile = './results/' + pcapFile + '_' + conn + '_tp_smp'
    avgFile = './results/' + pcapFile + '_' + conn + '_tp_avg'
    cmds.append('mv smp ' + smpFile)
    cmds.append('mv avg ' + avgFile)
    for cmd in cmds:
        output = os.popen(cmd)
        output.read()
    #if doPlot:
        #cmd = 'plot ' + smpFile + 'using ($1-xx):($2/125000) title "tp" with linespoints' % ()
        

def anaSeq(pcapFile, conn):
    cmds = []
    cmds.append(cmd_tcptrace + '-S ' + pcap_dir + pcapFile)
    cmds.append(cmd_xpl2gpl + conn + '_tsg.xpl')
    cmds.append(cmd_parse + conn + '_tsg.datasets')
    cmds.append('mv smp ./results/' + pcapFile + '_seq_smp')
    cmds.append('mv avg ./results/' + pcapFile + '_seq_avg')
    for cmd in cmds:
        output = os.popen(cmd)
        output.read()

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

pcapFile = 'youtube.pcap'
(conn, sentPkt) = pickConn(pcapFile)
print 'Pcap: ' + pcapFile
print 'Connection: ' + conn
print 'Packets sent: ' + str(sentPkt)
#anaTp(pcapFile, conn)
anaSeq(pcapFile, conn)
#anaWnd(pcapFile, conn)
clean()
print 'Done'
