clear;
tracefile1 = 'ad_hulu_info';
data = importdata(strcat('./matlabplot/', tracefile1));
fprintf('Handled data file: %s\n', tracefile1);
flowsize1 = data(:,1)/1000000;
tpAvg1 = data(:,3)/125000;  % Mbps
rttAvg1 = data(:,4)/1000;  %s
flowsize1 = sort(flowsize1,'descend');
tpAvg1 = sort(tpAvg1,'descend');
rttAvg1 = sort(rttAvg1,'descend');
tracefile2 = 'ad_youtube_info';
data = importdata(strcat('./matlabplot/', tracefile2));
fprintf('Handled data file: %s\n', tracefile2);
flowsize2 = data(:,1)/1000000;
tpAvg2 = data(:,3)/125000;  % Mbps
rttAvg2 = data(:,4)/1000;
flowsize2 = sort(flowsize2,'ascend');
tpAvg2 = sort(tpAvg2,'ascend');
rttAvg2 = sort(rttAvg2,'ascend');
minLength = min(length(rttAvg1), length(rttAvg2));
maxLength = max(length(rttAvg1), length(rttAvg2));
corrcoef(rttAvg1(1:minLength), rttAvg2(1:minLength))
x1 = 1:1:length(rttAvg1);
x2 = 1:1:length(rttAvg2);
