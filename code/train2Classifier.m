
% train2Classifier.m
% Trains a user-defined detector using the Cascade Trainer GUI
%

% Step 0 - Preliminaries
 
% We start off by making two directories in which to store images, one for
% positive image examples and one for negative examples.
% 
 mkdir(pwd, 'Positive Images'); addpath([pwd '\Positive Images'])
 mkdir(pwd, 'Negative Images'); addpath([pwd '\Negative Images'])
% 
% % %% Step 1 - Take positive video example
% % %
% % % We will take a video using the included function takeSnapshots.m. This
% % % function will use a webcam to take video and save individual jpg images.
% % % When taking the video make sure the user's face is in every frame and
% % % approximately facing forward. Trying to turn your face to get a too wide
% % % a range of images is likely to make training fail.
% % 
%Set options
options.runtime = 217;  % Total runtime to collect video (in seconds)
options.numImgs = 3300; % Total number of images to save
options.vid = videoinput('winvideo', 2, 'MJPG_640x480'); % Change this line
                       to use different camera settings
options.vid2 = videoinput('winvideo', 2, 'MJPG_640x480');
options.filename = [pwd '\Positive Images\']; % Location of the positive 
                       %image directory
 
%Take video
takeSnapshots(options);
 
%% Step 2 - Label objects
%
% We need to go through the images we just saved and label the user's face.
% We can do the labeling either autonomously using a pretrained detector or
% manually (using the function CascadeTrainGUI available from
% MatlabCentral). 
 
%Set the method to use
method = 'manual'; % {'autonomous', 'manual'}
% 
% %****************************************%
% % Method 1 - Using a pretrained detector %
% %****************************************%
if strcmp(method, 'autonomous')
    % Set options
    options.usePretrainedObjectDetector = true;
    options.detector = vision.CascadeObjectDetector('FrontalFaceCART');
 
    % Label faces using the included function labelPositiveExamples.m
    data = labelPositiveExamples(options);
end
 
%**************************************%
% Method 2 - Manually labeling objects %
%**************************************%
 if strcmp(method, 'manual')
% %     % Load the CascadeTrainGUI. 
% %     % 
% %     % Once in the GUI hit the 'Load Directory' in the bottom left; select 
% %     % the 'Positive Images' directory. All of the images from the video 
% %     % should pop up automatically. For each frame, click on the image to 
% %     % change the mouse cursor from 'pointer' mode to 'select' mode, then 
% %     % drag a bounding box around the user's face; once you are happy with 
% %     % the bounding box hit the 'right arrow' below the image to move onto 
% %     % the next frame; repeat for all frames in the directory.
% %     %
% %     % After labeling every frame, go to "File>>Save/Export Session As", at 
    % the prompt save the results as 'data'. 
      matlab.apputil.run('CascadeTrainGUIAPP')
% %     
%     % Full session info will be saved as a mat file in the 
%     % 'cascadetraingui' directory; you can delete this mat file as we won't
%     % be using it. What we will use is the 'data' struct that appears in 
%     % the workspace. We save it:
    save('datastruct.mat', 'data');
end
 
%% Step 3 - Take negative video example
 
% Next we take a video explicitly WITHOUT the user. Make sure not to be in
% the video. As the video is taking move the camera to give slight 
% variation in the captured images.
% 
% Set options
options.runtime = 300;
options.numImgs = 100000; 
options.filename = [pwd '\Negative Images\'];
 
% Take video
takeSnapshots(options);
 
% Step 4 - Train classifier
 
%Next we train a classifier using trainCascadeObjectDetector.
 
%Load the bounding box data (if it's not already in the workspace). Note:
%the 'data' struct has the location of the positive image locations.
load('datastruct.mat')
% % 
% % Set the negative image directory
negativeFolder = [pwd '\Negative Images\'];
 
% The following command can take several minutes
trainCascadeObjectDetector( ...
    'userDefinedDetector9.xml', ...
    data, ...
    negativeFolder, ...
    'FalseAlarmRate', 0.3, ...
    'NumCascadeStages', 10, ...
    'MergeThreshold', 8);
    
 
% Step 5 - Test classifier on live video
 
% Finally we test our classifier on live video.
% 
% Load the newly-trained detector
options.detector = vision.CascadeObjectDetector('userDefinedDetector8.xml');
 
 
% Test classifier on video
test2Classifier(options)
