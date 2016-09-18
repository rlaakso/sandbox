
%% TEST KALMAN FILTER ON SAVED NOSE DETECTION DATA

%% load video
addpath ../mmread
video = mmread('../convolution/test5.avi');

%% load data
track = csvread('trackdata.csv');
% swap cols
tmp = track(:,1); track(:,1) = track(:,2); track(:,2) = tmp;

%% track
xest = [ 0 ; 0 ; 0 ; 0 ]; % initial state estimate
A = [1 0 1 0 ; 0 1 0 1 ; 0 0 1 0 ; 0 0 0 1]; % state transition matrix
P = eye(4) * 20; % initial estimate variance
Q = eye(4) * 5;
R = [ 0.5 0 0 0 ; 0 0.5 0 0 ; 0 0 10 0 ; 0 0 0 10 ];  % measurement variance

N = size(track,1);
clf;

for t = 25:N

    imshow(video.frames(1+(t-1)*5).cdata); axis on; grid on; hold on; drawnow;
    
    % predict
    xest = A * xest;
    P = A * P * A' + Q;
    
    pgm = sqrt( P(1,1) ^ 2 + P(2,2) ^ 2 );
    disp(['Confidence: px ' num2str(P(1,1)) ', py ' num2str(P(2,2)) ', pgm ' num2str(pgm)]);
    if pgm < 20  % how confident are we?
        plot(xest(1), xest(2), 'r.', 'LineWidth', 2); 
        %hold on; axis on; grid on; axis([0 600 0 300]); set(gca,'YDir','reverse');
        ell = calcellipse(xest(1), xest(2), P(1,1)*2, P(2,2)*2, 0, 36);
        plot(ell(:,1), ell(:,2), 'm');
    end

    % measurement
    zx = track(t, 1);
    zy = track(t, 2);
    zvx = 0; zvy = 0;
    if t > 1
        zvx = zx - track(t-1, 1);
        zvy = zy - track(t-1, 2);
    end
    z = [zx ; zy ; zvx ; zvy];
    
    zval = track(t,3);

    % plot actual value
    plot(track(t, 1), track(t, 2), 'g+', 'LineWidth', 2); 
%    drawnow;
%    pause(0.5);

    if zval > 200
        % error
        err = sqrt( (track(t,1) - xest(1))^2 + (track(t,2) - xest(2))^2 );
        disp(['Tracking error: ' num2str(err)]);

        % update
        K = P / (P + R);
        xest = xest + K * (z - xest);
        P = P - K * P;
        plot(xest(1), xest(2), 'bv', 'MarkerSize', 5);      
%        drawnow;
%    pause(0.2);
    end
    
    drawnow;
end

disp('***');
hold off;
