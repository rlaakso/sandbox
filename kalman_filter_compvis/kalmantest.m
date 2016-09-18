close all;

%% create state

% (hidden) state
x = [40 ; 40 ; 5 ; 5 ]; 

% state model - pos = pos + vel, vel = vel
A = [1 0 1 0 ; 0 1 0 1 ; 0 0 1 0 ; 0 0 0 1]; 

% initial estimates
xest = zeros(4,1); % initial state estimate
P = eye(4); % initial state covariance matrix estimate

% measurement noise covariance
R = eye(4) * 0.01; 
Q = eye(4) * 0.1; % covariance matrix, process estimate noise or something..


% rest are unused for this simulation :

H = eye(4); % measurement and prediction domains are the same
u = zeros(4,1); % control input - not known
B = zeros(4,4); % control input to state mapping

%% loop
for i = 1:15

    %% update hidden process
%    x(3) = x(3) + randn*0.5; % change speed randomly
%    x(4) = x(4) + randn*0.5;
    if i < 5
        x(3) = x(3) + 0.5;
        x(4) = x(4) + 0.5;
        x = A*x;
    
%    x = [100+50*cos(i/25*pi) ; 100+50*sin(i/25*pi) ; 0 ; 0];
    
        disp(x);
        % plot x
        plot(x(1),x(2),'r.','MarkerSize',30);
        axis([0 200 0 200]);
        grid on;
        hold on;
    end

    %% kalman - predict

    % predict new x
    xest = A*xest + B*u;
    P = A * P * A' + Q;
    
    disp(xest);
    disp(P);
    
    plot(xest(1),xest(2),'bx', 'MarkerSize', 10, 'LineWidth', 2);
    x1 = xest(1) - P(1,1);
    x2 = xest(1) + P(1,1);
    y1 = xest(2) - P(2,2);
    y2 = xest(2) + P(2,2);
    line([x1 x2], [xest(2) xest(2)]);
    line([xest(1) xest(1)], [y1 y2]);


    %% kalman - measure
    if i < 5
        z = x;% + randn(4,1)*0.2; % measurement + measurement error
        % measurement update
        K = P * H' * inv(H * P * H' + R);
        xest = xest + K * (z - H * xest);
        P = P - K * H * P;

        % plot estimate after observation
        plot(xest(1),xest(2),'g+', 'MarkerSize', 10, 'LineWidth', 2);
    end
    
    %% end of round - draw and wait a bit
    drawnow;
%    hold off;
    pause(0.2);
    

end