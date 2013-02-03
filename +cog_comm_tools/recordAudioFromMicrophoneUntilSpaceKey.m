% Function for recording audio from the microphone until a button the space
% key is pressed on the keyboard (or the buffer runs out of space). Returns the response time it takes to acheive an amplitude of
% 'voiceTrigger' 
%
% participantId = unique participantId
%
% audioBufferLength = how long to record for
%
% fileName = full path filename for saved file
%
% voiceTrigger (optional) = the amplitude below which is considered to be
%                           silence. (between 0 and 1)
%
%
% Author: Brian Armstrong
%
function responseTime = recordAudioFromMicrophoneUntilSpaceKey(participantId, sessionId, audioBufferLength, fileName, voiceTrigger)

% voiceTrigger is optional
if (nargin <5)
    voiceTrigger = .01;
end

% amount of time to record after the participant presses a button
stopDelay = 0.5;

% Open the default audio device [], with mode 2 (== Only audio capture),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
% a frequency of 44100 Hz and 2 sound channels for stereo capture.
% This returns a handle to the audio device:
freq = 44100;
pahandle = PsychPortAudio('Open', [], 2, 0, freq, 1);

% Preallocate an internal audio recording  buffer with a capacity of audioBufferLength seconds:
PsychPortAudio('GetAudioData', pahandle, (audioBufferLength+stopDelay));

% Start audio capture immediately and wait for the capture to start.
% We set the number of 'repetitions' to zero,
% i.e. record until recording is manually stopped.
PsychPortAudio('Start', pahandle, 0, 0, 1);

% get start time
startsecs = GetSecs();

level = 0;
recordedAudio = [];  

% Repeat as long as below trigger-threshold:
while (level < voiceTrigger && (GetSecs() - startsecs) < audioBufferLength)
    % Fetch current audiodata:
    audiodata = PsychPortAudio('GetAudioData', pahandle);

    % Compute maximum signal amplitude in this chunk of data:
    if ~isempty(audiodata)
        level = max(abs(audiodata(1,:)));
    else
        level = 0;
    end
        
    % Below trigger-threshold?
    if (level < voiceTrigger)
        % Wait for a millisecond before next scan
        WaitSecs(0.0001);
    end
    recordedAudio = [recordedAudio audiodata];
end

% Record the response time
responseTime = (GetSecs() - startsecs);

proceed = false;

dt = 0.10;

% supress text from matlab window
ListenChar(2);

while (proceed == false && (GetSecs() - startsecs < audioBufferLength))
    if (cog_comm_tools.checkForKeyPress('space'))
        proceed = true;
    end
    WaitSecs(dt);
end

% un-supress text from matlab window
ListenChar(1);

% give them a chance to finish if they pressed the button too early...
WaitSecs(stopDelay);

% Stop capture
PsychPortAudio('Stop', pahandle);

% last fetch operation to get remaining data from the capture engine
audiodata = PsychPortAudio('GetAudioData', pahandle);
recordedAudio = [recordedAudio audiodata];

% Close the audio device
PsychPortAudio('Close', pahandle);

% Store recorded sound to wavfile
wavwrite(transpose(recordedAudio), 44100, 16, ['participants' filesep participantId filesep sessionId filesep 'audio' filesep fileName '.wav']);