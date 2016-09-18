% Update Kalman filter with observation
function [out] = filter_update(filter, z)

    % update
    K = filter.P / (filter.P + filter.R);
    filter.xest = filter.xest + K * (z - filter.xest);
    filter.P = filter.P - K * filter.P;
    
    out = filter;
end