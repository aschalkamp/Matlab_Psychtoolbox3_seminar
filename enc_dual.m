function [stop, rsp_dual] = enc_dual(scr,key,snd,inst_enc_dual,enc,fc,stim,audio,tar_textures)
%enc_dual.m runs the dual task: shows kaleidoscope images for 2s with 3.5s
% ISI in the center of a black screen and presents spoken numbers at same time. 
% Records keypresses and whether the 1-back task for the auditory input is
% correctly performed. Returns structure with RT and whether correctly
% answered and whether program should be aborted.
% arguments: scr             = structure for initialized screen
%            key             = struture for active keys
%            inst_enc_dual   = string of instructions for task
%            enc             = structure for constants for the encoding task
%            fc              = structure for fixation cross
%            stim            = structure for constants for stimuli
%            audio           = audio stimuli that will be presented
%            tar_textures    = imagetextures that will be shown

    % make storage, 99 as the number which indicated not yet run trials
    rsp_dual.RT = 99 * ones(1,enc.n); rsp_dual.correct = 99 * ones(1,enc.n); 
    % get random sequence for tones
    tones_seq = randperm(enc.n);
    % storage for whether number odd or even in previous trial
    even = false(1,enc.n);
    % random order in which targets are shown
    tar_seq = randperm(enc.n);
    
    % present instructions on screen (audio already tested beforehand)
    DrawFormattedText(scr.window, inst_enc_dual, 'center', scr.text_y, scr.white);
    Screen('Flip',scr.window);
    % wait for keypress and abort if escape is pressed
    stop = wait_for_key(key);
    if stop
        ListenChar(0);
        sca;
        return
    end
    
    % start presenting stimuli
    Screen('FillRect', scr.window, scr.black);
    vbl = Screen('Flip', scr.window);
    for i=1:enc.n
        % show fixation cross
        Screen('DrawLines', scr.window, fc.allCoords, ...
            fc.lineWidthPix, scr.white, [scr.xCenter scr.yCenter], 2);
        % Flip fixation cross to the screen after 2sec
        vbl = Screen('Flip', scr.window, vbl + enc.dur);
        
        % Draw on screen the kaleidoscope texture in the center
        Screen('DrawTexture', scr.window, tar_textures{tar_seq(i)}, [], stim.center_Rect);
        
        % get sound according to random sequence and store whether odd (0)
        % or even (1)
        num = transpose(audio{tones_seq(i)}(:,1));
        even(i) = ~logical(mod(tones_seq(i),2));
        % put sound into audio buffer
        PsychPortAudio('FillBuffer', snd.pahandle, [num;num]);
        
        % Flip image to the screen after 3.5sec
        vbl_old = vbl;
        vbl = Screen('Flip', scr.window, vbl + enc.isi);
        % at same time present audio
        PsychPortAudio('Start', snd.pahandle, 1, vbl_old + enc.isi, snd.waitForDeviceStart);
        PsychPortAudio('Stop', snd.pahandle, 1, 1);
        
        % storing response
        % check whether answered in given timeframe
        timedout = false;
        while (~timedout)
            % check if a key is pressed
            [keyIsDown, keyTime, keyCode] = KbCheck(); 
            if(keyIsDown) 
                break; 
            end
            if( (keyTime - vbl) > enc.dur) 
                timedout = true; 
            end
        end
        % store RT and whether correct key pressed
        % for first trial no correct number response as no number yet
        % heard, so store NaNs as response
        % when multiple keys pressed, also store as NaN
        if(~timedout) && (i > 1) && sum(keyCode)==1
            rsp_dual.RT(i) = keyTime - vbl;
            if even(i-1)
                cor_num = key.right;
            else
                cor_num = key.left;
            end
            rsp_dual.correct(i) = keyCode(cor_num); % 1 correct, 0 wrong
        else
            rsp_dual.RT(i) = NaN;
            rsp_dual.correct(i) = NaN;
        end
    end
    % end for loop but show last stimulus also for 2sec
    Screen('FillRect', scr.window, scr.black);
    Screen('Flip', scr.window, vbl + enc.dur);
end

