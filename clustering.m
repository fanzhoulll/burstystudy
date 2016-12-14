clear;
trace_files = dir(fullfile('./matlabplot'));
color = {'green', 'red', 'blue', 'black', 'yellow'};
handled_files = [];
colorIndex = 1;
fileHandled = [];
dataset = [];
group = [];
groupId = 1;
for tracefile = trace_files'
    if (tracefile.isdir == 0)
        data = importdata(strcat('./matlabplot/', tracefile.name));
        fprintf('Handled data file: %s\n', tracefile.name);
        fileHandled = [fileHandled; strrep(cellstr(tracefile.name),'_','')];
        flowsize = data(:,1);
        tpAvg = data(:,3);
        rttAvg = data(:,4);
        newData = [rttAvg/1000, tpAvg/125000,flowsize/1000000];
        newGroup = groupId * ones(size(data, 1),1);
        groupId = groupId + 1;
        dataset = [dataset; newData];
        group = [group; newGroup];
        %a = scatter(tpAvg/125000, flowsize/1000000, 'filled', color{colorIndex});
        %a = scatter(rttAvg/1000, flowsize/1000000, 'filled', color{colorIndex});
        %a = scatter(rttAvg/1000, tpAvg/125000, 'filled', color{colorIndex});
        %scatter3(rttAvg/1000, tpAvg/125000, flowsize/1000000, 'filled', color{colorIndex});
        %xlabel('RTT (Seconds)')
        %ylabel('Throughput (Mbps)')
        %zlabel('Flow size (MB)')
        %set(gca,'XDir','reverse')
        colorIndex = colorIndex + 1;
        if colorIndex > 5
            colorIndex = 1;
        end
        hold all
    end
end
legend(fileHandled);
svmStruct = svmtrain(dataset,group,'ShowPlot',true);