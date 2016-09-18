% Predict next value with Kalman filter
function [out x y varx vary pgm] = filter_predict(filter)

% predict
filter.xest = filter.A * filter.xest;
filter.P = filter.A * filter.P * filter.A' + filter.Q;
    
filter.pgm = sqrt( filter.P(1,1) ^ 2 + filter.P(2,2) ^ 2 );

out = filter;
x = filter.xest(1);
y = filter.xest(2);
varx = filter.P(1,1);
vary = filter.P(2,2);
pgm = filter.pgm;

end