
x = 1:0.1:20;
pdf1 = pdf('norm', x, 10, 2);
pdf1 = pdf1 / sum(pdf1);
subplot(2,1,1); plot(x,pdf1); axis on; grid on; axis([0 20 0 0.05]); hold on;


n = 1000;
u = rand(n, 1);
u = sort(u);
out = zeros(n,1);
cdf = 0;
j = 1;
for i=1:numel(x)
    %disp([num2str(cdf) ' ' num2str(i) ' ' num2str(j)]);
    while j <= n && u(j) < cdf 
        %disp(['u(' num2str(j) ') = ' num2str(u(j)) ', x(' num2str(i) ') = ' num2str(x(i))]);
        out(j) = x(i);
        j = j+1;
    end
    dx = pdf1(i);
    cdf = cdf + dx;
    %disp(['cdf = ' num2str(cdf)]);
end

plot(out, 0, 'r^', 'MarkerSize', 5); 
hold off;

subplot(2,1,2);
hist(out,20);
axis([0 20 0 200]); grid on;


