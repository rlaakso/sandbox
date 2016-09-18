% Init Kalman filter - TODO: parametrise error values
function [out] = filter_init()

out.xest = [ 0 ; 0 ; 0 ; 0 ]; % initial state estimate
out.A = [1 0 1 0 ; 0 1 0 1 ; 0 0 1 0 ; 0 0 0 1]; % state transition matrix
out.P = eye(4) * 20; % initial estimate variance
out.Q = eye(4) * 5;
out.R = [ 0.5 0 0 0 ; 0 0.5 0 0 ; 0 0 10 0 ; 0 0 0 10 ];  % measurement variance


end