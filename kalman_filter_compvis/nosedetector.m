%%
%% DEPRECATED - CAN BE REMOVED
%%

%% load video
addpath ../mmread
video = mmread('../convolution/test5.avi');

%% create filter
H = 60; W = 60;
%close all;
clear nosefilter;
nosefilter = zeros(W,H);
cx = W/2; cy = H/2;
for x=1:W
    for y=1:H
        d = sqrt((x-cx)^2+(y-cy)^2)
        if d < 14 || x < W/2 %(x < W/2 && y > H/4 && y < H*3/4); 
            nosefilter(x,y) = 1;
%        elseif x > W/3 && x < W*3/4
%            nosefilter(x,y) = 3;
        else
            nosefilter(x,y) = -5;
        end
    end
end
%K = sum(sum(abs(nosefilter)));
%nosefilter = nosefilter / K;
imshow(nosefilter*1024); grid on; axis on;
        
%% convolution
dframe = double(video.frames(150).cdata);
orig = dframe;
dframe = 255 - dframe(:,:,1);


% drop out pixels that are less than 50% lit --- replace this with
% background removal
for x = 1:size(dframe,1)
    for y = 1:size(dframe,2)
        if dframe(x,y) < 200
            dframe(x,y) = 0;
        end
    end
end

% perform convolution
convres = conv2(dframe, nosefilter, 'same');
cmin = min(min(convres));
convres = (convres - cmin);
cmax = max(max(convres));
foo = round(255 / cmax);
convres = convres * foo;
cmax = max(max(convres));

% thresholding
thimage = convres;
for x = 1:size(convres,1)
    for y = 1:size(convres,2)
        %if convres(x,y) > 0.50*cmax && dframe(x,y) > 100
        if convres(x,y) > 200
            thimage(x,y) = 50;
        else
            thimage(x,y) = 0;
        end
    end
end

% plot
subplot(2,2,1);
imshow(uint8(orig));
grid on; axis on;

subplot(2,2,2);
imshow(uint8(dframe));
grid on; axis on;

subplot(2,2,3);
imshow(uint8(convres));
grid on; axis on;

subplot(2,2,4);
imshow(thimage);
grid on; axis on;