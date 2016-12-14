clear;
trace_files = dir(fullfile('./info'));
color = {'green', 'red', 'blue', 'black', 'magenta', 'yellow', 'cyan', 'orange'};
handled_files = [];
colorIndex = 1;
fileHandled = [];
Threashold = 0 * 1000000; % 0.5MByte
for tracefile = trace_files'
    if (tracefile.isdir == 0)
        data = importdata(strcat('./info/', tracefile.name));
        fprintf('Handled data file: %s\n', tracefile.name);
        fileHandled = [fileHandled; strrep(cellstr(tracefile.name),'_','')];
        flowsize = data(:,1);
        tpAvg = data(:,2);
        burstSamples = data(:,3);
        burstAvgSize = data(:,4);
        burstInterval = data(:,5);
        rttAvg = data(:,6);
        if ~isempty(strfind(tracefile.name,'Web'))
            index = find(rttAvg < 200)';
        else
            index = find(flowsize > Threashold);
        end
        %a = scatter(tpAvg(index)/125000, flowsize(index)/1000000, 'filled', color{colorIndex});
        a=cdfplot(rttAvg(index));
        [cdf, tp] = ecdf(rttAvg(index));
        fid=fopen(tracefile.name,'w');
        fprintf(fid, '%f %f \n', [tp cdf]');
        fclose(fid);
        %a = plot(tp, cdf);
        %save(tracefile.name,'tp','cdf','-ascii');
        %break;
        %a = scatter3(rttAvg(index), tpAvg(index)/125000, flowsize(index)/1000000, 'filled', 's', color{colorIndex});
        %a = scatter(rttAvg(index)/1000, tpAvg(index)/125000, 'filled', color{colorIndex});
        %a = scatter(burstAvgSize(index)/1000000, burstInterval(index), 'filled', color{colorIndex});
        %a = scatter(burstSamples(index), tpAvg(index)/125000, 'filled', color{colorIndex});
        %a = scatter(burstInterval(index), tpAvg(index)/125000, 'filled', color{colorIndex});
        %scatter3(flowsize(index)/125000, tpAvg(index)/125000, burstInterval(index), 'filled', color{colorIndex});
        %scatter3(burstInterval(index), tpAvg(index)/125000, burstAvgSize(index)/1000000, 'filled', color{colorIndex});
        %a = scatter(tpAvg(index)/125000, flowsize(index)/125000, 'filled', color{colorIndex});
        %scatter3(burstInterval(index), burstAvgSize(index)/125000, tpAvg(index)/125000, 'filled', color{colorIndex});
        %hist(tpAvg(index))
        %xlabel('Burst Interval (Seconds)')
        %xlabel('BurstInterval (S)')
        %xlabel('RTT (ms)')
        xlabel('Throughput (Mbps)')
        %ylabel('Flow size (Mb)')
        ylabel('Percentage')
        %set(gca,'XDir','reverse')
        colorIndex = colorIndex + 1;
        if colorIndex > size(color,2)
            colorIndex = 1;
        end
        hold all
    end
end
%index = find(tpAvg(index)/125000 > 30)
%hist(tpAvg, 20)
legend(fileHandled);