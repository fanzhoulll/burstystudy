clear
close all
k = 4;
Sigma = {'diagonal','full'};
SharedCovariance = {true,false};
bursty = importdata('1440_1800.mat');
%figure;
%histogram(bursty, 100, 'Normalization', 'pdf')
%hold on


% Starts fitting
options = statset('Display','final', 'MaxIter',1500);

gm = fitgmdist(bursty,k,'CovarianceType',Sigma{1},...
            'SharedCovariance',SharedCovariance{1},'Options',options);

%gm = fitgmdist(bursty,k,'Options',options);
gmPDF = @(x)pdf(gm,x);
clusterX = cluster(gm,bursty);


% Plot results
figure;
for i = 1:k
    index = find(clusterX==i);
    %if i ~= 4
    scatter(index, bursty(index), 'filled');
    %plot(bursty(index));
    %histogram(bursty(index), 20, 'Normalization', 'pdf');
    hold on;
    %end
    
end
%h = fplot(gmPDF, [0 12],'Linewidth',2);
hold off