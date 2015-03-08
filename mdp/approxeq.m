%test2Classifier.m
%Tests a given user-defined detector on video input
%Contains the control code and outputs results from it.
function test2Classifier(options)
 
RED = 0; %CONSTANTS
GREEN = 1;
 
 
light1 = RED; %light1 starts off Red
light2 = GREEN; %light2 starts off Green
light1_prev1 = light1;
light2_prev1 = light2; 
light1_prev4 = light1;
light2_prev4 = light2;

    vid = videoinput('winvideo',1,'MJPG_640x480');
    vid2 = videoinput('winvideo',2,'MJPG_640x480');
    set(vid,'FramesPerTrigger', 1000);
    set(vid2,'FramesPerTrigger', 1000);
 
 
detector = options.detector;
 
% Put the video trigger into 'manual', this starts streaming the video
% without saving it. We can then request frames at will while only having
% to run the startup overhead this one time.
triggerconfig(vid,'manual');
triggerconfig(vid2, 'manual');
start(vid)
start(vid2)
 
% Initialize frame counter and fps variable
counter = 1;
fps = 0;
fps2 = 0;
 
% Set the total runtime in seconds 
runtime = 10000;
 
% Initialize figure to display video
 h1 = figure(1);
 
 
 
% Start the timer and start keeping track of the time at the beginning of
% every 10 frames
tic
timeTracker = toc;
 
buffer = 0; % this keeps track of the number of frames a light stays one color
 
% We run a while loop to get and display a frame from the camera. The while
% loop runs for <runtime> seconds.
while toc < runtime 
  % Compute the frame rate averaged over the last 10 frames
   if counter==10
       counter = 0;
       fps = 50/(toc-timeTracker);
       fps2 = 50/(toc-timeTracker);
       timeTracker = toc;
   end
   counter = counter + 1;
 
   % Get a new frame from the camera
   img = getsnapshot(vid);
   img2 = getsnapshot(vid2);
 
   % Detect user-defined object
   bbox = step(detector, img);
   bbox2 = step(detector, img2);
   numCars = size(bbox, 1);
   numCars2 = size(bbox2, 1);
   numCars_prev = numCars;
   numCars2_prev = numCars2;
   
   % Label detected objects
   detectedImg = insertShape(img, 'rectangle', bbox, 'Color', [255 0 0]);
   detectedImg2 = insertShape(img2, 'rectangle', bbox2, 'Color', [255 0 0]);
 
    
%    % Display image
%       Note: use imagesc() instead of imshow() (it's faster).
 
 
   imagesc(detectedImg); axis off
   title(['FPS: ' sprintf('%2.1f', fps)]); drawnow
   h2 = figure(2);
   imagesc(detectedImg2); axis off
   title(['FPS: ' sprintf('%2.1f', fps2)]); drawnow
   h1 = figure(1);
   
 %--------------------------Control Code--------------------------------
    
    if (light1 == RED) %if light is red and number of cars decreases, reset it to last count
        if (numCars < numCars_prev) % b/c they did not decrease
            numCars = numCars_prev;    
        end
    end   
    
    if (light2 == RED) %same as above 
        if (numCars2 < numCars2_prev)
            numCars2 = numCars2_prev;
        end
    end       
    
    if (numCars > numCars_prev + 2) % assume two boxes can't appear at once
        numCars = numCars_prev + 1; % increment normally
    end
    
    if (numCars2 > numCars2_prev + 2) % assume two boxes can't appear at once
        numCars2 = numCars2_prev + 1; % increment normally
    end   
 
    if (numCars > numCars2)
        light1 = GREEN;
        light2 = RED;
 
    else
        light1 = RED;
        light2 = GREEN; 
 
    end 
    
    if (light1 == light1_prev1) %count the number of consecutive frames with same light color
        buffer = buffer + 1;    
    else % if the light changes, reset buffer to 0
        buffer = 0;
    end    
 
    if (buffer > 15) % if the lights stays the same for 20 frames, then output the light colors
        if (light1 == light1_prev1) % The value '20' may be decreased/increased to experiment
        light1
        light2
        end
        buffer = 0;
    end 
    
    light1_prev1 = light1;
    light2_prev1 = light2;
    numCars_prev = numCars;
    numCars2_prev = numCars2;
  %------------------------------------------------------------------------    
  
end
 
% Stop the video stream
stop(vid)
stop(vid2);
 
 
end
