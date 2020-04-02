function [stop] = wait_for_key(key)
%wait_for_key.m wait until key (SPACE; cont) is pressed
% abort if ESCAPE; stop is pressed and return True, False such that higher order
% programs can be aborted as well
% arguments: key = structure with active keys

    resptobemade = true;
    stop = false;
    while resptobemade
        [~,~, keyCode] = KbCheck();
        if keyCode(key.stop)
            stop = true;
            ListenChar(0);
            sca;
            return
        elseif keyCode(key.cont)
            resptobemade = false;
        else
            resptobemade = true;
        end
    end
end

