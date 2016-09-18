
%%
x = 7;

A = 1.1;

xest = 5;

P = 0.25;
Q = 0.10;
R = 0.25;

z = x + randn*Q;

u = 0:0.01:20;

%% est
subplot(3,1,1);
v = pdf('norm', u, xest, P);
plot(u,v); grid on; axis([0 10 0 5]);
title('estimate pdf');

%% meas
subplot(3,1,2);
v = pdf('norm', u, z, Q);
plot(u,v); grid on; axis([0 10 0 5]);
title('measurement pdf');

%% combined pdf
subplot(3,1,3);
K = P / (P + R);
uf = xest + K * (z - xest);
sf = P - K * P;
v = pdf('norm', u, uf, sf);
plot(u,v); grid on; axis([0 10 0 5]);
title('combined pdf');
