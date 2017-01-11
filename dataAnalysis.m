clear;
tracefile = '1440_1800';
data = importdata(strcat('./info/', tracefile));
fprintf('Handled data file: %s\n', tracefile);
time = data(:,1);
chunksize = data(:,3);
gap = data(:,5);
%cdfplot(gap)
upperbound = prctile(gap,98)
lowerbound = prctile(gap, 2)
% Rmove largest 2% and lowest 2%
filterIndex = find(gap<upperbound);
gap_filter = gap(filterIndex);
gap_left = gap_filter(find(gap_filter<1.6));
gap_right = gap_filter(find(gap_filter>1.6));
histogram(gap_filter, 20)
%normfit(gap_left)
%histfit(gap_right, 20)

%upperbound = prctile(chunksize,95);
%lowerbound = prctile(gap, 2)
%filterIndex = find(chunksize<upperbound & chunksize>lowerbound);
%chunksize_filter = chunksize(filterIndex);
%cdfplot(chunksize)
%histogram(chunksize_filter, 100);

% Markov analysis
length = size(gap_filter, 1);
prev = gap_filter(1:length-1);
post = gap_filter(2:length);
%scatter(prev,post)
%scatter(prev,post)

scatter(chunksize(filterIndex), gap_filter);