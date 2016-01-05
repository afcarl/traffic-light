
%count2cars.m
%Original m file for counting cars via Gaussian Mixture Models and using two webcams.
RED = 0; %CONSTANTS
GREEN = 1;
 
cam = webcam(2);
cam2 = webcam(3);
 
foregroundDetector = vision.ForegroundDetector('NumGaussians', 3, ...
    'NumTrainingFrames', 50); 
 
foregroundDetector2 = vision.ForegroundDetector('NumGaussians', 3, ...
    'NumTrainingFrames', 50); 
 
 
for i = 1:150
    frame = snapshot(cam); % read the next video frame
    frame2 = snapshot(cam2); % read the next video frame
    foreground = step(foregroundDetector, frame);
    foreground2 = step(foregroundDetector2, frame2); %IF YOU DO ABOVE CHANGE THIS foregro... to 2.
end
se = strel('square', 3);
se2 = strel('square', 3);
filteredForeground = imopen(foreground, se);
filteredForeground2 = imopen(foreground2, se2);
 
blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', false, 'CentroidOutputPort', false, ...
    'MinimumBlobArea', 150);
 
bbox = step(blobAnalysis, filteredForeground);
bbox2 = step(blobAnalysis, filteredForeground2);
result = insertShape(frame, 'Rectangle', bbox, 'Color', 'green');
result2 = insertShape(frame2, 'Rectangle', bbox2, 'Color', 'green');
numCars = size(bbox, 1);
numCars2 = size(bbox2, 1);
result = insertText(result, [10 10], numCars, 'BoxOpacity', 1, ...
    'FontSize', 14);
result2 = insertText(result2, [10 10], numCars2, 'BoxOpacity', 1, ...
    'FontSize', 14);
videoPlayer = vision.VideoPlayer('Name', 'Detected Cars');
videoPlayer2 = vision.VideoPlayer('Name', 'Detected Cars');
videoPlayer.Position(3:4) = [650,400];  % window size: [width, height]
videoPlayer2.Position(3:4) = [650,400];  % window size: [width, height]
se = strel('square', 3); % morphological filter for noise removal
se2 = strel('square', 3); % morphological filter for noise removal
 
light1 = RED; %light1 starts off Red
light2 = GREEN; %light2 starts off Green
light1_prev = light1;
light2_prev = light2;
 
% traffic1 = numCars; 
% traffic2 = numCars2;
% traffic1_prev = traffic1; 
% traffic2_prev = traffic2;
%updateDisplay()
 
liveloop = 1;
    
while liveloop
 
    frame =  snapshot(cam); % read the next video frame
    frame2 = snapshot(cam2);  % read the next video frame
 
    % Detect the foreground in the current video frame
    foreground = step(foregroundDetector, frame);
    foreground2 = step(foregroundDetector2, frame2);
 
    % Use morphological opening to remove noise in the foreground
    filteredForeground = imopen(foreground, se);
    filteredForeground2 = imopen(foreground2, se2);
 
    % Detect the connected components with the specified minimum area, and
    % compute their bounding boxes
    bbox = step(blobAnalysis, filteredForeground);
    bbox2 = step(blobAnalysis, filteredForeground2);
 
    % Draw bounding boxes around the detected cars
    result = insertShape(frame, 'Rectangle', bbox, 'Color', 'green');
    result2 = insertShape(frame2, 'Rectangle', bbox2, 'Color', 'green');
 
    % Display the number of cars found in the video frame
    numCars = size(bbox, 1);
    numCars2 = size(bbox2, 1);
    
    % Hold the previous frame's number of cars
    numCars_prev = numCars;
    numCars2_prev = numCars2;
    
    result = insertText(result, [10 10], numCars, 'BoxOpacity', 1, ...
        'FontSize', 14);
    result2 = insertText(result2, [10 10], numCars2, 'BoxOpacity', 1, ...
        'FontSize', 14);
 
    step(videoPlayer, result);  % display the results
    step(videoPlayer2, result2);  % display the results
    
    %--------------------------Control Code--------------------------------
    if (light1 == RED) %if light is red and number of cars changes
        if (numCars ~= numCars_prev)
            numCars = numCars + 1;
        end
    end   
    
    if (light2 == RED) %same as above 
        if (numCars2 ~= numCars2_prev)
            numCars2 = numCars2 + 1;
        end
    end       
    
    if (numCars > numCars2)
        light1 = GREEN;
        light2 = RED;
    else
        light1 = RED;
        light2 = GREEN;
    end 
    
    if (light1 ~= light1_prev)
       light1;
       light2;
    end    
    light1_prev = light1;
    light2_prev = light2;
    numCars_prev = numCars;
    numCars2_prev = numCars2;
  %------------------------------------------------------------------------  
end
