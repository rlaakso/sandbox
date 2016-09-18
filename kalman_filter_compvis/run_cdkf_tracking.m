%% Run nose/circle detection with Kalman filter tracking on a test video

%% load video
addpath ../mmread
video = mmread('../convolution/test5.avi');

%% record output
recordvideo = 0;

if recordvideo == 1
    aviobj = avifile('mymovie.avi','fps',25,'compression','none'); 
end


%% create filter
KW = 48;
circle = single(circlefilter(KW));
%subplot(2,2,2);
%imshow(uint8(circle*127+128)); grid on; axis on;

% track position
track=ones(video.nrFramesTotal,3)*-1;
ti = 1;

filter = filter_init();

conf_threshold = 190;
cmval = 0;

% loop through frames
for fi = 1:video.nrFramesTotal
    
%disp(['Processing frame ' num2str(fi)]);

tic;

frame = video.frames(fi).cdata;


% predict nose position with kalman filter
[filter px py pvarx pvary pgm] = filter_predict(filter);

if pgm < 20 % do we have good prediction on the nose position
    prediction_is_good = 1;
else
    prediction_is_good = 0;
end


% invert and normalise frame
sf = single(255-frame(:,:,1))/255.0;

nose_found_in_frame = 0;


% if we have an estimate for nose position search there first
if prediction_is_good == 1
    resp = localconv(sf, circle, px-KW, py-KW, KW*2, KW*2);

    [mapx mapy] = est_map(resp);
    [cmx cmy cmval] = est_cm_local(resp, mapx, mapy, 50);
    
    if cmval > conf_threshold
        % ok we think we found the nose
        nose_found_in_frame = 1;
    end
end


% either we didn't have prediction for nose position or 
% we didn't find it from where we though it should be
if nose_found_in_frame == 0
    % do full frame convolution
    resp = conv2(sf, circle, 'same');
    resp = removeborders(resp, 25);
    
    [mapx mapy] = est_map(resp);
    [cmx cmy cmval] = est_cm_local(resp, mapx, mapy, 50);
end

% update filter if nose found with sufficient confidence
if cmval > conf_threshold
    zx = cmx;
    zy = cmy;
    zvx = 0; zvy = 0;
    if ti > 1
        % estimate velocity
        zvx = zx - track(ti-1, 1);
        zvy = zy - track(ti-1, 2);
    end
    z = [zx ; zy ; zvx ; zvy];
    filter = filter_update(filter, z);
end

% add data to tracking 
track(ti, :) = [cmx, cmy, double(cmval)];
ti = ti+1;


% processing done
fulltime = toc;


% show frame
imshow(frame); hold on; grid on; axis on;

% show detection & tracking estimates
if pgm < 20 % good enough estimate from kalman filter ?
    plot(py, px, 'r.', 'LineWidth', 2); 
    ell = calcellipse(py, px, pvary*2, pvarx*2, 0, 36);
    plot(ell(:,1), ell(:,2), 'm:');
end

if cmval > conf_threshold  % did we find the nose in this frame ?
    plot(cmy, cmx, 'gx', 'LineWidth', 2, 'MarkerSize', 10);
end


% performance text
str = sprintf('frame: %d', fi);
text(505, 20, str, 'Color', 'green');

str = sprintf('fps: %f', 1/fulltime);
text(505, 40, str, 'Color', 'green');

str = sprintf('time: %f s', fulltime);
text(505, 60, str, 'Color', 'green');

str = sprintf('kalman filter:\n%f\n%f\n%f\n%f', px, py, pvarx, pvary);
text(505, 110, str, 'Color', 'red');

str = sprintf('nose detection CM:\n%f\n%f\n%f', cmx, cmy, cmval);
text(505, 180, str, 'Color', 'red');


drawnow;
%pause(0.2);

 if recordvideo == 1
    axis equal;
    aviobj = addframe(aviobj,gcf);
 end
    
end

if recordvideo == 1
    aviobj = close(aviobj);
end