function [stop] = enc_single(scr,key,inst_enc_single,enc,fc,stim,tar_textures)
%enc_single.m runs the single task: shows kaleidoscope images for 2s with
% 3.5 ISI in the center of a black screen
% arguments: scr             = structure for initialized screen
%            key             = struture for active keys
%            inst_enc_single = string of instructions for task
%            enc             = structure for constants for the encoding task
%            fc              = structure for fixation cross
%            stim            = structure for constants for stimuli
%            tar_textures    = imagetextures that will be shown
    
    % random order in which targets will be shown
    tar_seq = randperm(enc.n);
    
    % show instructions
    Screen('FillRect', scr.window, scr.black);
    DrawFormattedText(scr.window, inst_enc_single, 'center', scr.text_y, scr.white);
    Screen('Flip',scr.window);
    % wait for keypress
    stop = wait_for_key(key);
    % when escape pressed, abort the program
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
        
        % Draw on screen the kaleidoscope in the center
        Screen('DrawTexture', scr.window, tar_textures{tar_seq(i)}, [], stim.center_Rect);

        % Flip image to the screen after 3.5sec
        vbl = Screen('Flip', scr.window, vbl + enc.isi);
    end
    % end for loop but show last stimulus also for 2sec
    Screen('FillRect', scr.window, scr.black);
    Screen('Flip', scr.window, vbl + enc.dur);
end

