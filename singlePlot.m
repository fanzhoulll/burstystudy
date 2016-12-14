clear;
trace_files = dir(fullfile('./info'));
handled_files = [];
colorIndex = 1;
fileHandled = [];
Threashold = 1 * 1000000; % 0.5MByte
for tracefile = trace_files'
    if (tracefile.isdir == 0)
        data = importdata(strcat('./info/', tracefile.name));
        fprintf('Handled data file: %s\n', tracefile.name);
        fileHandled = [fileHandled; strrep(cellstr(tracefile.name),'_','')];
        flowsize = data(:,1);
        tpAvg = data(:,3);
        rttAvg = data(:,4);
        index = find(flowsize > Threashold);
        %a = scatter(tpAvg(index)/125000, flowsize(index)/1000000, 'filled', 'red');
        %a = scatter(rttAvg(index)/1000, flowsize(index)/1000000, 'filled', 'red');
        %a = scatter(rttAvg(index)/1000, tpAvg(index)/125000, 'filled', 'red');
        %scatter3(rttAvg(index)/1000, tpAvg(index)/125000, flowsize(index)/1000000, 'filled', 'red');
        %hold on
        %index = find(flowsize < Threashold);
        %index = find(flowsize < Threashold);
        %scatter3(rttAvg(index)/1000, tpAvg(index)/125000, flowsize(index)/1000000, 'filled', 'green');
        scatter(tpAvg(index)/125000, flowsize(index)/1000000, 'filled', 'green');
        %xlabel('RTT (Seconds)')
        xlabel('Throughput (Mbps)')
        ylabel('Flow size (MB)')
        %set(gca,'XDir','reverse')
        hold all
    end
end
%hist(tpAvg, 20)
legend(fileHandled);