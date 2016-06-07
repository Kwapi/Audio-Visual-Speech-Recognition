
%% SAMPLING PERIOD
overlapSizeSec = 0.01;  %10ms
samplingPeriod = overlapSizeSec;

%% TRAIN
cleanPath = 'training audio\training_audio_X.wav';
snr10BabblePath = 'train_audio_snr_10_babble\train_audio_10_snr_babble_X.wav';
inputTemplateAudio = snr10BabblePath;

inputTemplateVid ='train_video\train_video_X.mp4';

outputTemplateCombined = 'MFC\train\trainCombinedX.mfc';
outputTemplateVideo = 'MFC\train\trainVidUpsampledX.mfc';

for i=1:20
    
    %% AUDIO
    inputAudio = strrep(inputTemplateAudio,'X', num2str(i));
    [sample,fs] = audioread(input);
    sample = specsub(sample,fs);

    audioFeatures =  featureExtractionAudioToCombine(sample,fs);
    
    %% VIDEO
    inputVid = strrep(inputTemplateVid,'X', num2str(i));
    visualFeatures = featureExtractionVisualToCombine(inputVid);
    
    %% UPSAMPLE VIDEO
    visualFeaturesUpsampled = resample(visualFeatures,length(audioFeatures),length(visualFeatures));
    
    %% COMBINE
    allFeatures = horzcat(audioFeatures,visualFeaturesUpsampled);
    
    
    
    %% WRITE TO HTK
    outputVideo = strrep(outputTemplateVideo,'X', num2str(i));
    output = strrep(outputTemplateCombined,'X', num2str(i));
    
    %% JUST VIDEO (TEST)
    writeToHTKFile(outputVideo,visualFeaturesUpsampled,samplingPeriod);
    
    %% COMBINED 
    writeToHTKFile(output,allFeatures,samplingPeriod);
  
end

%% TEST
cleanPath = 'test audio\test_audio_X.wav';
snr10BabblePath = 'test_audio_snr_10_babble\test_audio_snr_10_babble_X.wav';
inputTemplateAudio = snr10BabblePath;

inputTemplateVid ='test_video\test_video_X_cc.mp4';

outputTemplateCombined = 'MFC\test\testCombinedX.mfc';
outputTemplateVideo = 'MFC\test\testVidUpsampledX.mfc';

for i=1:21
  
    %% AUDIO
    inputAudio = strrep(inputTemplateAudio,'X', num2str(i));
    [sample,fs] = audioread(input);
    sample = specsub(sample,fs);

    audioFeatures =  featureExtractionAudioToCombine(sample,fs);
    
    %% VIDEO
    inputVid = strrep(inputTemplateVid,'X', num2str(i));
    visualFeatures = featureExtractionVisualToCombine(inputVid);
    
    %% UPSAMPLE VIDEO
    visualFeaturesUpsampled = resample(visualFeatures,length(audioFeatures),length(visualFeatures));
    
    %% COMBINE
    allFeatures = horzcat(audioFeatures,visualFeaturesUpsampled);
    
    
    
    %% WRITE TO HTK
    outputVideo = strrep(outputTemplateVideo,'X', num2str(i));
    output = strrep(outputTemplateCombined,'X', num2str(i));
    
    %% JUST VIDEO (TEST)
    writeToHTKFile(outputVideo,visualFeaturesUpsampled,samplingPeriod);
    
    %% COMBINED 
    writeToHTKFile(output,allFeatures,samplingPeriod);
  
end