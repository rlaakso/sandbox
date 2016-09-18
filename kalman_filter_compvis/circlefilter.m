function [out] = circlefilter(R)
    out = zeros(R, R);
    r1 = R/2;
    r2 = (R/2)/sqrt(2);
    cx = R/2; cy = R/2;
    for x = 1:size(out,1)
        for y = 1:size(out,2)
            d = sqrt( (cx-x)^2 + (cy-y)^2 );
            if d < r2
                out(x,y) = 1;
            elseif d < r1
                out(x,y) = -1;
            else
                out(x,y) = 0;
            end
        end
    end
end