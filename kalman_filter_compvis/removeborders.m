% remove borders of width bw from frame (for convolution)
function [out] = removeborders(frame, bw)
    
out = frame;
w = size(frame, 1);
h = size(frame, 2);

% horizontal
for x = [1:bw w-bw:w]
    for y = 1:h
        out(x,y) = 0;
    end
end

% vertical
for x = 1:w
    for y = [1:bw h-25:h]
        out(x,y) = 0;
    end
end

end