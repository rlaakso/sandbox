% estimate conditional mean in neighbourhood of (cx,cy) with width bw
function [cmx cmy cmval] = est_cm_local(array, cx, cy, bw)

sumx = 0;
sumy = 0;
wx = 0;
wy = 0;
for x = cx-10:cx+10
    for y = cy-10:cy+10
        if x >= 1 && y >= 1 && x < size(array,1) && y < size(array,2)
            val = double(array(x,y));
            sumx = sumx + x * val;
            sumy = sumy + y * val;
            wx = wx + val;
            wy = wy + val;
        end
    end
end
cmx = sumx/wx;
cmy = sumy/wy;

cmval = array(round(cmx),round(cmy));

end