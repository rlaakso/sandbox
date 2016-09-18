%%
%% CIRCLE BASED DETECTION 
%
% use circle kernel with convolution to find the nose from frame
%

%% load video
addpath ../mmread
video = mmread('../convolution/test5.avi');

%% create filter
circle = single(circlefilter(48));
subplot(2,2,2);
imshow(uint8(circle*127+128)); grid on; axis on;

%% track position
track=ones(video.nrFramesTotal,3)*-1;
ti = 1;

conf_threshold = 190;
cmval = 0;

%% show frame
for fi = 1:video.nrFramesTotal
    
%disp(['Processing frame ' num2str(fi)]);

tic;

frame = video.frames(fi).cdata;
%for x=1:size(frame,1)
%    for y=1:size(frame,2)
%        if frame(x,y,1) > 128
%            frame(x,y,:) = 255;
%        end
%    end
%end
%subplot(3,1,1);
%imshow(frame); grid on; axis on;


% compute response
%subplot(3,1,2);

% do only a local convolution?
local_conv =  cmval > conf_threshold;

tic;
sf = single(255-frame(:,:,1))/255.0;

if local_conv == 1
    % local    
    resp = localconv(sf, circle, round(cmx)-48, round(cmy)-48, 48*2, 48*2);
else
    % full
    resp = conv2(sf, circle, 'same');
    resp = removeborders(resp, 25);
end

convtime = toc;

%resp = (resp+430) * (255/840);
%resp = uint8(resp);
%imshow(resp); axis on; grid on; hold on;


% Estimates

% MAP
[mapx mapy] = est_map(resp);
% CM computed in neighbourhood of MAP -- should we compute this over full frame?
[cmx cmy cmval] = est_cm_local(resp, mapx, mapy, 50);


% add to tracking 
track(ti, :) = [cmx, cmy, double(cmval)];
ti = ti+1;

fulltime = toc;



% plot estimates
%plot(mapy, mapx, 'rx', 'LineWidth', 2, 'MarkerSize', 10);
%plot(cmy, cmx, 'b+', 'LineWidth', 1, 'MarkerSize', 10);
%disp(['Max val = ' num2str(cmval)]);
%str = sprintf('f(CMx,CMy) = %d', cmval);
%text(cmy+20, cmx-20, str, 'Color', 'green', 'FontWeight', 'bold');
% difference between map and cm
%diff = sqrt( (cmx-mapx)^2 + (cmy-mapy)^2 );
%disp(sprintf('MAP = %f, %f; CM = %f, %f; difference = %f', mapx, mapy, cmx, cmy, diff));


% overlay original frame
%subplot(3,1,3);
imshow(frame); hold on;
if cmval > conf_threshold  % arbitary threshold limit
    plot(cmy, cmx, 'ro', 'LineWidth', 1, 'MarkerSize', 10);
end
grid on; axis on;


%disp(['Frame processed in ' num2str(fulltime) ' or ' num2str(1/fulltime) ' fps.']);

str = sprintf('frame: %d', fi);
text(505, 20, str, 'Color', 'green');

str = sprintf('fps: %f', 1/fulltime);
text(505, 40, str, 'Color', 'green');

str = sprintf('conv time: %f s', convtime);
text(505, 60, str, 'Color', 'green');

str = sprintf('other time: %f s', fulltime-convtime);
text(505, 80, str, 'Color', 'green');

drawnow;
%pause(0.2);
end

%% plot track
figure(2);
scatter(track(:,2), track(:,1), track(:,3)-150, 1:size(track,1), 'filled'); grid on; axis on; axis([0 size(frame,2) 0 size(frame,1)]);
set(gca,'YDir','reverse');