function [stop, rsp_test] = twoafct(scr,key,inst,test,rsp_time,fc,stim,tar_textures,dist_textures)
%twoafct.m runs the 2-alternative-forced-choice task: presents target and
% distractor pairs and stores whether keypress correctly identifies target
% guess condition and remember condition implemented with same function, 
% can be called by using different arguments for rsp_time (2s, 30s) and
% instructions.
% Returns structure with RT and whether correctly answered and whether to
% abort the program.
% arguments: scr             = structure for initialized screen
%            key             = struture for active keys
%            inst            = string of instructions for task
%            test            = structure for constants for the test
%            fc              = structure for fixation cross
%            stim            = structure for constants for stimuli
%            tar_textures    = imagetextures that will be shown
%            dist_textures   = imagetextures that will be shown as distractors

    % make storage: 99 indicates that the trial was not yet performed and
    % no data is available
    rsp_test.RT = 99 * ones(1,test.n); rsp_test.correct = 99 * ones(1,test.n);
    % random order for both targets and distractors
    stim_seq = randperm(test.n);
    
    % present instructions on screen
    DrawFormattedText(scr.window,inst, 'center', scr.text_y, scr.white);
    Screen('Flip',scr.window);
    % wait for keypress and abort if escape pressed
    stop = wait_for_key(key);
    if stop
        ListenChar(0);
        sca;
        return
    end

    % get targets and corresponding foils
    % TODO: would be different if enough stimuli there, then decide
    % randomly which of the encoded targets to use for testing, here use
    % all which have a distractor
    test_tar_textures = tar_textures(1:4,:);
    test_dist_textures = dist_textures(1:4,:);
    % get random sequence to decide whether target on left (=0) or right
    % (=1)
    seq = logical([zeros(1,test.n/2) ones(1,test.n/2)]);
    seq = seq(randperm(test.n));
    
    % start presenting stimuli
    Screen('FillRect',scr.window,scr.black);
    vbl = Screen('Flip', scr.window);
    for i=1:test.n
        Screen('FillRect',scr.window,scr.black)
        % show fixation cross
        Screen('DrawLines', scr.window, fc.allCoords, ...
            fc.lineWidthPix, scr.white, [scr.xCenter scr.yCenter], 2);
        % Flip fixation cross to the screen after 2sec
        vbl = Screen('Flip', scr.window, vbl + test.dur);
    
        % determine where to locate target and dist according to random
        % sequence
        if seq(i)
            % target on right
            tar_loc = stim.right_Rect;
            dist_loc = stim.left_Rect;
        else
            % target on left
            tar_loc = stim.left_Rect;
            dist_loc = stim.right_Rect;
        end
    
        % Draw on screen the two kaleidoscopes at their positions
        Screen('DrawTexture', scr.window, test_tar_textures{stim_seq(i)}, [], tar_loc);
        Screen('DrawTexture', scr.window, test_dist_textures{stim_seq(i)}, [], dist_loc);
    
        % Flip images to the screen after 3 sec
        vbl = Screen('Flip', scr.window, vbl + test.isi);
    
        % check after stimulus presented for rsp_time seconds for keypress
        timedout = false;
        while (~timedout)
            % check if a key is pressed
            [keyIsDown, keyTime, keyCode] = KbCheck();
            if(keyIsDown)
                break;
            end
            if( (keyTime - vbl) > rsp_time)
                timedout = true;
            end
        end
        % when response is made in time and it is not ambiguous (only one key
        % pressed), store RT and whether target correctly identified
        if(~timedout) && sum(keyCode)== 1
            rsp_test.RT(i) = keyTime - vbl;
            if seq(i)
                cor_key = key.right;
            else
                cor_key = key.left;
            end
            rsp_test.correct(i) = keyCode(cor_key); % 1 correct, 0 wrong
            % if no idea which one is target, arrow up pressed, store as 2
            if keyCode(key.none)
                rsp_test.correct(i) = 2;
            end
        else
            rsp_test.RT(i) = NaN;
            rsp_test.correct(i) = NaN;
        end
    end
    % end for loop but show last stimulus also for 2 sec
    Screen('FillRect',scr.window,scr.black);
    Screen('Flip', scr.window, vbl + test.dur);
end

