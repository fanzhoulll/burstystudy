k = 4;
length = size(bursty, 1);
scatter(bursty(1:length-1), bursty(2:length), 'filled')

prev = clusterX(1:length-1);
post = clusterX(2:length);

markov = [prev,post];

for i = 1:k
    source = i;
    total_source = size(find(clusterX == source), 1)
    for j = 1:k
        sub = find(ismember(markov, [i,j], 'rows') == 1);
        total_sub = size(sub, 1);
        fprintf('%d -> %d = %.2f\n',i,j,total_sub/total_source);
    end
end