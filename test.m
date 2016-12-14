clear;
trace_files = dir(fullfile('./ns3'));
color = {'green', 'red', 'blue'};
handled_files = [];
colorIndex = 1;
fileHandled = [];
for tracefile = trace_files'
    if (tracefile.isdir == 0)
        data = importdata(strcat('./ns3/', tracefile.name));
        fprintf('Handled data file: %s\n', tracefile.name);
        fileHandled = [fileHandled; strrep(cellstr(tracefile.name),'_','')];
        time = data(:,1);
        value = data(:,2);
        window_size = 10;
        movAvg = tsmovavg(data,'s',window_size,1);
        a = movAvg(:,1);
        b = movAvg(:,2);
        plot(a,b);
        xlabel('Time (Second)');
        ylabel('Avg throughput (Mbps)');
        %xlabel('BurstAvgSize (Mb)')
        %xlabel('BurstInterval (S)')
        %set(gca,'XDir','reverse')
        colorIndex = colorIndex + 1;
        if colorIndex > size(color,2)
            colorIndex = 1;
        end
        hold all
    end
end
%hist(tpAvg, 20)
legend(fileHandled);