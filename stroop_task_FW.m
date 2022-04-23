% clear workspace and screen
sca;
close all;
clear all;

%keyboard settings
ListenChar(2);

% set random seed
rng('default');

% subject info, change everytime
id = 'TEST2';
savename = [id '_Stroop.mat'];

% psychtoolbox setup
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);

% detect screens
screens = Screen('Screens');
screenNumber = max(screens);

% set window size
windowsize = [];

% color indices
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white/2;

% open window and flip time settings
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, windowsize);
ifi = Screen('GetFlipInterval', window);
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);
isiTimeSecs = 1;
isiTimeFrames = round(isiTimeSecs / ifi);
waitframes = 1;
[xCenter, yCenter] = RectCenter(windowRect);

% experiment design
congruency = [1 2]; % 1=congruent, 2=incongruent
colors = [1 2 3]; % 1=red, 2=green, 3=blue

% make emat
emat = make_emat(congruency, colors);

% total trials per condition
ntrials = 20;
emat = repmat(emat, ntrials, 1);

% shuffle trials
total_trials = size(emat,1);
trial_order = randperm(total_trials);
emat = emat(trial_order, :);

% stimulus parameters
colornames = {'red', 'green', 'blue'};
text_color = {[1 0 0],[0 1 0],[0 0 1]};

% keyboard respond information
r = KbName('R');
g = KbName('G');
b = KbName('B');


% start the experiment (for-loop)
for which_trial = 1:total_trials
    which_congruency = emat(which_trial,1); % 1 = first number in emat
    which_word = emat(which_trial,2); % 2 = second number in emat
    
    present_text = colornames(which_word); 
    
    if which_congruency == 1 %congruent
        present_color = text_color{which_word};
        
    elseif which_congruency == 2 %incongruent
        temp_color = randperm(3);
        rand_color = temp_color(1);
        present_color = text_color{rand_color};
    end
    
    respToBeMade = true;
    
    if which_trial == 1
        Screen('TextSize', window, 70);
        DrawFormattedText(window, 'Name the font color of the word \n\n using r for red, g for green, and b for blue \n\n Press Any Key To Begin',...
            'center', 'center', black);
        Screen('Flip', window);
        KbStrokeWait;
    end
    
    Screen('DrawDots', window, [xCenter; yCenter], 10, white, [], 2);
    vbl = Screen('Flip', window);
    for frame = 1:isiTimeFrames - 1
        Screen('DrawDots', window, [xCenter; yCenter], 10, white, [], 2);
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end
    
    tStart = GetSecs;
    while respToBeMade == true
        % present trial
        Screen('TextSize', window, 90);
        DrawFormattedText(window, char(present_text), 'center', 'center', present_color);
        % participant respond
        [keyIsDown,secs, keyCode] = KbCheck(-3);
          if keyCode(r)
            response = 1;
            respToBeMade = false;
        elseif keyCode(g)
            response = 2;
            respToBeMade = false;
        elseif keyCode(b)
            response = 3;
            respToBeMade = false;
          end
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
    end
    when = GetSecs - tStart;
    % record response
    emat(which_trial, 3) = when;
    emat(which_trial, 4) = response;
    
    % correctness
    if emat(which_trial, 1) == 1 %congruent condition
        ink_color = which_word;
    elseif emat(which_trial, 1) == 2 % incongruent condition
        ink_color = rand_color;
  
    end
    emat(which_trial, 5) = ink_color;
    
    if response == ink_color
        emat(which_trial, 6)=1;
    else
        emat(which_trial, 6)=0;
    end

    end
 
    
    Screen('FillRect', window, grey);
    Screen('Flip', window);
    WaitSecs(0.1);
    


% save
save(savename,'emat');

% finish up
Screen('TextSize', window, 70);
DrawFormattedText(window, 'Congrats! You are done! \n\n Press Any Key To exit',...
            'center', 'center', black);
        Screen('Flip', window); 
        KbStrokeWait;
ListenChar(0);
% close experiment
sca;
