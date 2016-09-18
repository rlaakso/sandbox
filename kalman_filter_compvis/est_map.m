% estimate maximum a posterior from array (maximal element)
function [mapx mapy val] = est_map(array)

[y i] = max(array(:));
[mapx mapy] = ind2sub(size(array), i);
val = array(mapx, mapy);

end