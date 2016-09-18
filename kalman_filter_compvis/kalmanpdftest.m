
%% process

clear x xest xpred;
x(1,:) = [1 1 0.5 0.5];
xest(1,:) = [1 1 0 0];
xpred(1,:) = xest(1,:);
N = numel(x(1));
A = [1 0 1 0 ; 0 1 0 1 ; 0 0 1 0 ; 0 0 0 1 ];
disp(x(1,:));
P = eye(4);
Q = eye(4);
R = eye(4);

for t=2:70
    w = 0.10 * randn(1,4);
    x(t,:) = A*x(t-1,:)' + w';
    
    xest(t,:) = A*xest(t-1,:)';
    xpred(t,:) = xest(t,:); % save prediction
    P = A*P*A' + Q;
    
    v = 0.10 * randn(1,4);
    z = x(t,:) + v;
    K = P / (P + R);
    P = P - K * P;
    xest(t,:) = xest(t,:)' + K * (z - xest(t,:))';
end

plot(x(:,1), x(:,2), 'b-');
hold on; grid on; axis([0 40 0 40]);
plot(xpred(:,1), xpred(:,2), 'r-');
legend('process', 'kalman filter');
hold off;
