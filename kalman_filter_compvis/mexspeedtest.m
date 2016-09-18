% create a frame
frame = single(rand(640,320));

tic;
negframe = mexneg(frame);
toc;
x = toc;

% test result
sumframe = frame + negframe;
ss = sum(sum(sumframe));
disp(['Result: ' num2str(ss) ' (should be 0)']);

disp(['Time : ' num2str(x) ', which is ' num2str(1/x) ' fps.']);