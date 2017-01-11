clear;
trace_files = dir(fullfile('./info'));
%color = {'green', 'red', 'blue', 'black', 'magenta', 'yellow', 'cyan', 'orange'};
handled_files = [];
colorIndex = 1;
chunksizes = [];
gaps = [];

figure;
for tracefile = trace_files'
    if (tracefile.isdir == 0)
        data = importdata(strcat('./info/', tracefile.name));
        fprintf('Handled data file: %s\n', tracefile.name);
        chunksize = data(:,3);
        gap = data(:,5);
        chunksizes = [chunksizes; chunksize];
        gap_filter = gap(find(gap<prctile(gap,98)));
        plot(gap_filter)
        hold on
        gaps = [gaps; gap_filter];
    end
end

upperbound = prctile(chunksizes,98);
lowerbound = prctile(chunksizes,2);
filterIndex = find(chunksizes<upperbound & chunksizes>lowerbound);
chunksizes_filter = chunksizes(filterIndex);
histogram(chunksizes_filter, 100)


% upperbound = prctile(gaps,98)
% filterIndex = find(gaps<upperbound);
% gaps_filter = gaps(filterIndex);
%histogram(gaps, 100)

% Markov analysis
% length = size(gaps_filter, 1)
% prev = gaps_filter(1:length-1);
% post = gaps_filter(2:length);
%scatter(prev,post)
