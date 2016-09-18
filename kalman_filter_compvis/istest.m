%% importance sampling test

pdf1 = pdf('norm', 1:0.1:10, 5, 2);

x = sample(pdf1, 10);
