% experiment.m
% Geschrieben von Ann-Kathrin Schalkamp
% 19. August 2019
%
% Das Programm verwendet die PTB-3 (Brainard, 1997;
% Pelli, 1997), um ein Experiment zur unbewussten
% Wiedererkennung von Stimuli durchzuführen. Das Experiment ist
% angelehnt an Experimente von Joel L. Voss. Es soll geprüft werden, ob
% eine zweite Aufgabe, neben dem Merken von Stimuli, die Anzahl korrekter
% Antworten in einer 2-alternative-forced-choice-task erhöht. Es soll
% erforscht werden, ob die Verwendung des unbewussten Gedächtnisses 
% mittels Zeitbegrenzung und Instruktionen beeinflusst werden kann.
% Abhängige Variablen: Reaktionszeit und Prozent korrekter Antworten
% Unabhängige Variablen: - Antwortzeit für Test (30s vs 2s)
%                        - Instruktionen
%                        - Dual oder Single Task in Encodingphase
%
% Als Stimuli dienen Kaleidoskope auf schwarzem Hintergrund, 
% welche als Paare sortiert vorliegen, sodass
% bei der Abfrage ähnlich aussehende, aber neue Stimuli als Distraktoren
% gezeigt werden können. Es werden pro Teilnehmer 4 Blöcke durchgeführt mit
% jeweils Enkodierung und Abfrage. Zwei Blöcke für die guess condition mit
% entsprechender Instruktion und 2 Sekunden Antwortzeit und zwei Blöcke für
% die remember condition mit passenden Instruktionen und 30 Sekunden
% Antwortzeit. Jeweils einer der Blöcke wird mit der dual task in der
% Enkodierung und der andere mit der single task Enkodierung durchgeführt.
% Die conditionen sind gebalanced.
%
% In der Enkodierung werden 14 Kaleidoskope für jeweils 2 Sekunden gezeigt 
% mit 3,5 Sekunden Interstimulusinterval. Für die dual task kommt die
% auditive Aufgabe hinzu, wobei zu jeder Kaleidoskoppräsentation eine Zahl
% abgespielt wird und der Teilnehmer per Tastendruck angeben muss, ob die
% zuvor gehörte Zahl (außer im ersten Versuch) gerade (right arrow) oder 
% ungerade (left arrow) war (1-back task).
% In der 2-alternative forced choice Aufgabe wird ein Kaleidoskopepaar
% präsentiert (gleich wahrscheinlich target rechts oder links). In der
% remember condition erscheinen die Stimuli für mindestens 2 und maximal 30
% Sekunden und in der guess condition für 2 Sekunden. In dieser Zeit muss
% per Tasteneingabe entschieden werden, wo das target ist 
% (left image = left arrow, right image = right arrow, 
% do not remember = up arrow).
%
% Damit der code funktioniert, ist es am einfachsten einen Order an dem
% gewünschten Ort zu erstellen, der den Stimuli-Ordner, alle Funktionen
% (dialogue, deg2pix, wait_for_key, enc_single, enc_dual, twoafct) und 
% den Code enthält.
% Dort wird der Ordner DATA erstellt, der die einzelnen Antworten der
% Subjekts enthält. Dazu bitte den Ort, an dem Stimuli und Code gespeichert sind einmal
% angeben/ändern (gespeichert unter der Variable yourFolder im Bereich STIMULUS SETUP).
% Per Abfrage wird eine SubjectID erstellt, unter der die
% Daten im Ordner DATA gespeichert werden.
%
% Im Code selbst ist angemerkt (TODO), wenn bei der Umsetzung der Experimentidee
% Probleme aufgetaucht sind, die bisher nicht behoben werden konnten. Diese
% Probleme beruhen darauf, dass es nicht gelungen ist die Kaleidoskopbilder
% selbst zu generieren oder vom Autor zur Verfügung gestellt zu bekommen.
% Als Ersatz werden screenshots von Bildern aus dem paper verwendet, die
% jedoch in ihrer Anzahl stark limitiert sind, sodass die geplante Anzahl
% an Stimuli nicht gezeigt werden kann und auch die zufällige Auswahl an
% target und distraktor nicht umgesetzt werden konnte.
%
% Referenzen:
% Jeneson, A., Kirwan, C. B. & Squire, L. R. (2010). Recognition without awareness:
% An elusive phenomenon. Learning & memory, 17 (9), 454-459.
% Voss, J. L., Baym, C. L. & Paller, K. A. (2008). Accurate forced-choice recognition
% without awareness of memory retrieval. Learning & Memory, 15
% (6), 454-459.
% Voss, J. L. & Paller, K. A. (2009). An electrophysiological signature of unconscious
% recognition memory. Nature neuroscience, 12 (3), 349.
% Voss, J. L. & Paller, K. A. (2010). What makes recognition without awareness
% appear to be elusive? strategic factors that influence the accuracy of
% guesses. Learning & Memory, 17 (9), 460-468.

% needed to keep it running on windows when some timing and
% synchronization errors occur. Otherwise program would stop
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 3);
% use function dialogue() to let the subject generate its subject ID and
% ask for the handedness before the experiment
[subID, hand] = dialogue();

try
    %------------------------------------------------%
    %%%%%%%%%%%%%%%%%%%%% Setup %%%%%%%%%%%%%%%%%%%%%%
    %------------------------------------------------%
    % structures will be used (for screen 'scr', sound 'snd' and more)
    % in order to use less memory and allow for
    % fast and easy access, also improves readability
    
    % Clear screens. Do not clear workspace as often unnecessary and time
    % consuming
    sca;
    
    % SCREEN SETUP
    % get the right screen number
    scr.screens = Screen('Screens');
    % Draw to external screen if avaliable
    scr.screenNumber = max(scr.screens);

    % Define colors
    scr.white = WhiteIndex(scr.screenNumber);
    scr.black = BlackIndex(scr.screenNumber);

    % initialize Screen with black background
    [scr.window, scr.windowRect] = PsychImaging('OpenWindow', scr.screenNumber, scr.black);
    % size of screen window
    [scr.screenXpixels, scr.screenYpixels] = Screen('WindowSize', scr.window);
    % centre coordinates of window
    [scr.xCenter, scr.yCenter] = RectCenter(scr.windowRect);
    % set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', scr.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % set preferences
    Screen('Preference', 'SkipSyncTests', 0);
    Screen('Preference', 'VisualDebugLevel', 3);
    % set maximum priority level
    topPriorityLevel = MaxPriority(scr.window);
    
    % AUDIO SETUP
    InitializePsychSound(1);
    % Number of channels and frequency of the sound
    snd.nrchannels = 2;
    snd.freq = 48000;
    snd.waitForDeviceStart = 1;
    snd.pahandle = PsychPortAudio('Open', [], 1, 1, snd.freq, snd.nrchannels);
    % volume set to 0.7 of maximum
    PsychPortAudio('Volume', snd.pahandle, 0.7);
    
    % TIMING SETUP
    % get refreshrate of screen to make accurate timing for stimulus
    % presentation
    scr.interFrameInterval = Screen('GetFlipInterval', scr.window);
    
    % KEYBOARD SETUP
    % only record allowed keys, do not store any other keypresses
    KbName('UnifyKeyNames');
    key.left = KbName('LeftArrow');
    key.right = KbName('RightArrow');
    key.stop = KbName('ESCAPE');
    key.none = KbName('UpArrow');
    key.cont = KbName('SPACE');
    activeKeys = [key.left key.right key.stop key.none key.cont];
    RestrictKeysForKbCheck(activeKeys);
    % suppress echo to the command line for keypresses and hide cursor
    ListenChar(2);
    HideCursor;
    
    % INSTRUCTIONS SETUP
    % size and font of instructions
    scr.text_size = 30;
    scr.text_font = 'Courier';
    Screen('TextSize', scr.window, scr.text_size);
    Screen('TextFont', scr.window, scr.text_font);
    % horizontal placement of text, do not begin in middle but a bit higher
    scr.text_y = scr.screenYpixels * 0.25;
    
    % instructions used to welcome participants, and give brief instruction
    % about tasks, nonetheless the tasks should be explained to the
    % participant beforehand
    % For test condition: two independent variables are defined, as the used
    % instructions will partly determine which condition is used, guess or
    % remember for the 2-alternative-forced choice task
    inst_enc_single = ['You will now see kaleidoscope images.'...
        '\n Try to remember them as good as you can.'...
        '\n\n Press SPACE to begin.'];
    inst_enc_dual = ['You will now see kaleidoscope images.'...
        '\n Try to remember them as good as you can.'...
        '\n You will also hear numbers. Indicate whether the preceeding number'...
        '\n was odd (LEFT Arrow) or even (RIGHT Arrow) after you heard the new number.'...
        '\n Please do not answer too early and only after the new number was presented.'...
        '\n Press any key for the first trial.'...
        '\n\n Press SPACE to begin.'];
    inst_test_rem = ['You will now see two images at the same time.'...
        '\n Indicate by key presses (LEFT or RIGHT Arrow)\n if you remember the right or left image.'...
        '\n Only answer if you really remember otherwise press Arrow Up.'...
        '\n\n Press SPACE to begin.'];
    inst_test_guess = ['You will now see two images at the same time.'...
        '\n Indicate by key presses (LEFT or RIGHT Arrow)\n if you remeber the right or left image.'...
        '\n Answer as fast as possible and follow your gut.'...
        '\n\n Press SPACE to begin.'];
    inst_exp_begin = ['Welcome to our experiment!'...
        '\n If you have no further questions'...
        '\n regarding the procedure of the experiment'...
        '\n press SPACE to begin.'];
    inst_exp_end = ['Thank you for participating in our experiment!'...
        '\n Please contact the experimentor.'];
    
    % STIMULUS SETUP
    % location: CHANGE HERE to adapt to own folder structure
    yourFolder = 'C:\Users\schal\Documents\Studium\Master\2nd_semester\empKog\experiment\Abgabe_Schalkamp';
    % calculation of visual angle: use visual angle to determine stimulus size
    % get size of monitor (should be tested/set MANUALLY when actual 
    % experiment PC used as those generated numbers are not reliable)
    [widthMonitor, heightMonitor] = Screen('DisplaySize', scr.screenNumber);
    % Define the distance between the participants eye and the monitor in mm
    distance = 600;
    % calculate the visual angle subtended by a single pixel
    pixWidth =  widthMonitor/scr.screenXpixels;
    pixHeight = heightMonitor/scr.screenYpixels;
    pix2degCoeffWidth = 2* atan((0.5*pixWidth)/distance)*(180/pi);
    pix2degCoeffHeight = 2* atan((0.5*pixHeight)/distance)*(180/pi);
    deg2pixCoeffWidth = 1/pix2degCoeffWidth;
    deg2pixCoeffHeight = 1/pix2degCoeffHeight;
    
    % fixation cross (also stored as a structure)
    fc.angle = 1;
    % get height and width using the visual angle and the coefficients
    [fc.pixwidth, fc.pixheight] = deg2pix(fc.angle, deg2pixCoeffWidth, deg2pixCoeffHeight);
    fc.xCoords = [-fc.pixwidth fc.pixwidth 0 0];
    fc.yCoords = [0 0 -fc.pixheight fc.pixheight];
    fc.allCoords = [fc.xCoords; fc.yCoords];
    fc.lineWidthPix = 4;
    
    % kaleidoscope images (targets and distractors) extracted from folder and put into datastorage
    % TODO: when correct and enough stimuli, decide here which half used as dist and
    % tar randomly for each subject. Not possible with used stimuli as only
    % half of them are present in pairs which can be used for testing and
    % only 8 ones in total, so cannot use different ones for each trial
    % possible solution: store images as matrices and access them via a
    % randomly generated sequence to load tar and dist into separate
    % imageDatastores, then randomly permutate the two lists in unison and
    % divide them into 4 (number of experimental trials) blocks
    location_tar = sprintf('%s/stimuli/target/*.PNG', yourFolder);
    data_tar = imageDatastore(location_tar);
    tar = readall(data_tar);
    location_dist = sprintf('%s/stimuli/distractor/*.PNG', yourFolder);
    data_dist = imageDatastore(location_dist);
    dist = readall(data_dist);
    % make images already here into textures to get better timing when running
    % experiment 
    % TODO: later when same number tar & dist images, use 1 for loop for
    % both together to improve efficiency
    dist_textures = cell(length(dist),1);
    tar_textures = cell(length(tar),1);
    for s=1:length(dist)
        dist_textures{s} = Screen('MakeTexture', scr.window, dist{s});
    end
    for s=1:length(tar)
        tar_textures{s} = Screen('MakeTexture', scr.window, tar{s});
    end
    
    % define visual angle of stimulus and where the images will be placed on the
    % screen (center for encoding and left and right for testing)
    stim.angle = 6;
    [stim.width, stim.height] = deg2pix(stim.angle, deg2pixCoeffWidth, deg2pixCoeffHeight);
    theRect = [0 0 stim.width stim.height];
    stim.center_Rect = CenterRectOnPointd(theRect, scr.screenXpixels / 2,...
        scr.screenYpixels / 2);
    stim.left_Rect = CenterRectOnPointd(theRect, scr.screenXpixels * 0.25,...
        scr.screenYpixels / 2);
    stim.right_Rect = CenterRectOnPointd(theRect, scr.screenXpixels * 0.75,...
        scr.screenYpixels / 2);
    
    % get audio stimuli (numbers) for dual task from folder. Are stored in ascending order such
    % that index corresponds to the stimulus and can decide based on index
    % whether odd or even
    location_audio_num = sprintf('%s/stimuli/numbers/', yourFolder);
    location_audio = sprintf('%s/stimuli/numbers/*.wav', yourFolder);
    audio_file = dir(location_audio);
    NF = length(audio_file);
    audio = cell(NF,1);
    for k = 1 : NF
        audio{k} = audioread(fullfile(location_audio_num, audio_file(k).name));
    end
    
    % SET UP OUTPUT FILE
    % check if DATA folder already exists, otherwise create it
    datafolder = sprintf('%s/DATA', yourFolder);
    if ~exist(datafolder, 'dir')
        mkdir(datafolder);
    end
    % expName and subject ID are used to create the data file for each
    % subject
    expName = 'RecogAware_';
    subName = sprintf('%s%s', expName, subID);
    dataFileName = [subName '.csv'];
    dataFile = fullfile(datafolder,dataFileName);
    % open data file and write first line to store important information
    % for each subject, add header to lateron better know where which data
    % is stored
    cHeader = {'ID' 'encRT' 'enccor' 'testRT' 'testcor'};
    textHeader = strjoin(cHeader, ',');
    fid = fopen(dataFile,'w'); 
    fprintf(fid, ['Experiment:\t' expName '\n']);
    fprintf(fid, ['date:\t' datestr(now) '\n']);
    fprintf(fid, ['Subject:\t' subID '\n']);
    fprintf(fid, ['Handedness:\t' hand '\n']);
    fprintf(fid,'%s\n',textHeader);
    fclose(fid);
    
    %------------------------------------------------%
    %%%%%%%%%%%% Experimental Variables %%%%%%%%%%%%%%
    %------------------------------------------------%
    % define independent variables and make storage for dependent variables
    Test_Levels = [1 2]; % 1 = remember 2 = guess condition
    Enc_Levels = [1 2]; % 1 = single 2 = dual task
    % experimental design
    nConditions = length(Enc_Levels) * length(Test_Levels); % 4
    experimentalTrials = nConditions; % must be multiple of total
    % balance conditions
    % ensure that random sequences are really random
    rng(sum(clock.*100),'twister');
    trialsPerCondition = ceil(experimentalTrials/nConditions);
    [Enc, Test] = BalanceFactors(trialsPerCondition, 1, Enc_Levels, Test_Levels); % 1 for random, 0 in order
    
    % ENCODING SINGLE TASK
    enc.n = 8;
    enc.dur = 2. - scr.interFrameInterval/2;
    enc.isi = 3.5 - scr.interFrameInterval/2;
    % ENCODING DUAL TASK (same number of trial and timing as for single task)
    % 2-ALTERNATIVE FORCED CHOICE: remember condition
    test.n = 4;
    test.dur = 2. - scr.interFrameInterval/2;
    test.isi = 3. - scr.interFrameInterval/2;
    % independent variable: give much time for participants to explicitly
    % remember which image they remember
    test.rem_time = 30. - scr.interFrameInterval/2;
    % 2-ALTERNATIVE FORCED CHOICE: guess condition (same number of trials and timing
    % as for remember condition)
    % independent variable: enforce using implicit memory by only giving 
    % 2 seconds to answer
    test.guess_time = 2. - scr.interFrameInterval/2;
    
    % storage matrix: content will be then written into datafile.
    % for each subject: 
    % for each trial (ID, rsp_enc_RT, rsp_enc_cor, rsp_test_RT, rsp_test_cor)
    % single task will not generate data, but make storage anyway for
    % symmetricity.
    % Data can be accessed via masking on the condition ID (index 1) and the index 
    % (2&3 for encoding RT (in sec) and correct answers (0;1;99;NaN) and 4&5 for testing RT and
    % correct answers (0=wrong;1=correct;2=did not remember;99=no data yet;
    % NaN=incorrect response).
    % For each variable there will be as
    % much storage as for the number of encoding trials as this number will
    % be the largest, for testing the remaining empty cells will be filled
    % with number 99, which is also used for not yet run trials. 
    responses_mat = 99 * ones(experimentalTrials*enc.n, 5);
    
    %------------------------------------------------%
    %%%%%%%%%%%%%%% Experiment Begin %%%%%%%%%%%%%%%%%
    %------------------------------------------------%
     % start with black background
    Screen('FillRect', scr.window, scr.black);
    
    % present instructions on screen together with tone to check audio.
    % Wait for keypress to start experiment (says it waits for SPACE but
    % any active key could be pressed)
    DrawFormattedText(scr.window, inst_exp_begin, 'center', scr.text_y, scr.white);
    myBeep = MakeBeep(50, 1, snd.freq);
    PsychPortAudio('FillBuffer', snd.pahandle, [myBeep; myBeep]);
    Screen('Flip', scr.window);
    PsychPortAudio('Start', snd.pahandle, 1, 0, snd.waitForDeviceStart);
    PsychPortAudio('Stop', snd.pahandle, 1, 1);
    KbStrokeWait();
    
    % iterate over the different blocks and trials
    % IDs for conditions: 1 single_rem, 2 single_guess, 3 dual_rem, 4
    % dual_guess
    for trial=1:experimentalTrials
        % write to datafile after each pair of encoding and testing.
        % Do not store after each shown stimulus or response as each run is
        % only short and not much information would be lost. Opening the
        % file during the experimental trial would be time consuming and
        % may affect the timing accuracy, so do it between the condition
        % trials where timing is not critical
        storage_start = (trial - 1) * enc.n + 1;
        storage_end = trial * enc.n;
        % there are less test than encoding trials so account for that when
        % saving to the matrix
        storage_end_test = storage_end - (enc.n - test.n);
        
        % run through each condition calling the respective encoding or
        % testing function with the accoring arguments
        if Enc(trial) == 1 && Test(trial) == 1
            % condition 1: enc=single, test=remember
            responses_mat(storage_start:storage_end,1) = ones(enc.n,1);
            % run single task
            stop = enc_single(scr,key,inst_enc_single,enc,fc,stim,tar_textures);
            % store output, there is none, so leave the 99
            % when they did not start the run but pressed escape to exit,
            % exit all screens, enable keyboard input and abort the program
            if stop
                ListenChar(0);
                sca;
                return
            end
            % run 2-alternative-forced choice: remember condition
            % subjects can try to remember for a longer time & instructions
            % suggest only to answer when confident
            rsp_time = test.rem_time;
            [stop, rsp_test] = twoafct(scr,key,inst_test_rem,test,rsp_time,fc,stim,tar_textures,dist_textures);
            % save responses
            responses_mat(storage_start:storage_end_test,4) = rsp_test.RT;
            responses_mat(storage_start:storage_end_test,5) = rsp_test.correct;
            if stop
                ListenChar(0);
                sca;
                return
            end

        elseif Enc(trial) == 1 && Test(trial) == 2
            % condition 2: enc=single, test=guess
            responses_mat(storage_start:storage_end,1) = 2 * ones(enc.n,1);
            % run single task
            stop = enc_single(scr,key,inst_enc_single,enc,fc,stim,tar_textures);
            % store output, there is none, so leave 99
            % stop if escape is pressed
            if stop
                ListenChar(0);
                sca;
                return
            end
            % run 2-alternative-forced choice: guess condition with limited time to respond
            rsp_time = test.guess_time;
            [stop, rsp_test] = twoafct(scr,key,inst_test_guess,test,rsp_time,fc,stim,tar_textures,dist_textures);
            % abort if escape pressed
            if stop
                ListenChar(0);
                sca;
                return
            end
            % save responses
            responses_mat(storage_start:storage_end_test,4) = rsp_test.RT;
            responses_mat(storage_start:storage_end_test,5) = rsp_test.correct;
            
        elseif Enc(trial) == 2 && Test(trial) == 1
            % condition 3: enc=dual, test=remember
            responses_mat(storage_start:storage_end,1) = 3 * ones(enc.n,1);
            % run dual task
            [stop, rsp_dual] = enc_dual(scr,key,snd,inst_enc_dual,enc,fc,stim,audio,tar_textures);
            % store output
            responses_mat(storage_start:storage_end,2) = rsp_dual.RT;
            responses_mat(storage_start:storage_end,3) = rsp_dual.correct;
            % abort if escape pressed
            if stop
                ListenChar(0);
                sca;
                return
            end
            % run 2-alternative-forced-choice remember
            rsp_time = test.rem_time;
            [stop, rsp_test] = twoafct(scr,key,inst_test_rem,test,rsp_time,fc,stim,tar_textures,dist_textures);
            % save responses
            responses_mat(storage_start:storage_end_test,4) = rsp_test.RT;
            responses_mat(storage_start:storage_end_test,5) = rsp_test.correct;
            % abort if escape pressed
            if stop
                ListenChar(0);
                sca;
                return
            end

        else
            % condition 4: enc=dual, test=guess
            responses_mat(storage_start:storage_end,1) = 4 * ones(enc.n,1);
            % run dual task
            [stop, rsp_dual] = enc_dual(scr,key,snd,inst_enc_dual,enc,fc,stim,audio,tar_textures);
            % store output
            responses_mat(storage_start:storage_end,2) = rsp_dual.RT;
            responses_mat(storage_start:storage_end,3) = rsp_dual.correct;
            % abort if escape pressed
            if stop
                ListenChar(0);
                sca;
                return
            end
            % run 2-alternative-forced choice task: guess condition
            rsp_time = test.guess_time;
            [stop,rsp_test] = twoafct(scr,key,inst_test_guess,test,rsp_time,fc,stim,tar_textures,dist_textures);
            % store output
            responses_mat(storage_start:storage_end_test,4) = rsp_test.RT;
            responses_mat(storage_start:storage_end_test,5) = rsp_test.correct;
            % abort if escape pressed
            if stop
                ListenChar(0);
                sca;
                return
            end
            
        end
        % write data from matrix so far to end of file
        dlmwrite(dataFile,responses_mat(storage_start:storage_end,:),'-append');
        
    end
    
    %------------------------------------------------%
    %%%%%% Experiment End, Save Data, Clear Up %%%%%%%
    %------------------------------------------------%
    Screen('FillRect', scr.window, scr.black)
    % present instructions on screen
    DrawFormattedText(scr.window, inst_exp_end, 'center', scr.text_y, scr.white);
    Screen('Flip', scr.window);
    % proceed if any active key pressed
    KbStrokeWait();
    
    catch
    ListenChar(0);
    psychrethrow(psychlasterror);
    sca;
end
% Clear the screen and enable keyboard input and curser again
ListenChar(0);
PsychPortAudio('Close', snd.pahandle);
sca;
return
