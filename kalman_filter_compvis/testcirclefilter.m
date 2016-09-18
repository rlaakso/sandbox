%% load video
addpath ../mmread
video = mmread('../convolution/test5.avi');

%% create filter
circle = circlefilter(50);
subplot(2,1,1);
imshow(uint8(circle*127+128)); grid on; axis on;


%% apply filter
subplot(2,1,2);
tmp = frame;
%tx = 76; ty = 354;
tx = 230; ty = 40;
out = 0;
out2 = 0;
for x=1:size(circle,1)
    for y=1:size(circle,2)
        val = double(255-tmp(tx+x, ty+y, 1)) / 255.0;
%        disp(['out = ' num2str(out) ' + ' num2str(val) ' * ' num2str(circle(x,y))]);
        out = out + val * circle(x,y);
        q = circle(x,y) == 1;
        out2 = out2 + q * circle(x,y);
        tmp(tx+x,ty+y,1) = circle(x,y)*127+128;
    end
end
out = out / (pi*r2^2);
disp(['function value = ' num2str(out)]);
imshow(tmp); axis on; grid on;