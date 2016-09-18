%% load frame
frame = imread('testframe.png');
sframe = single(255-frame(:,:,1));
subplot(2,2,1);
imshow(frame); grid on; axis on; title('frame');

%% kernel
kernel = single(circlefilter(48));

%% matlab full convolution
subplot(2,2,2);
disp('matlab conv2');
tic;
res1 = conv2(sframe, kernel, 'same');
toc;
res1 = (res1 + 44000) * 200 / 100000;
imshow(uint8(res1)); grid on; axis on; title('matlab conv2');

%% localconv full conv
subplot(2,2,3);
disp('localconv - full');
tic;
res2 = localconv(sframe, kernel, 0, 0, size(sframe,1), size(sframe,2));
toc;
res2 = (res2 + 44000) * 200 / 100000;
imshow(uint8(res2)); grid on; axis on; title('localconv - full');

%% localconv limited conv
subplot(2,2,4);
disp('localconv - limited');
tic;
res3 = localconv(sframe, kernel, 60, 330, 100, 100);
toc;
res3 = (res3 + 44000) * 200 / 100000;
imshow(uint8(res3)); grid on; axis on; title('localconv - limited');
