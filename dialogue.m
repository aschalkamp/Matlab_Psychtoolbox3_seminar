function [sub_id,hand] = dialogue()
%dialogue.m erfragt die SubjectID und Händigkeit

    % dialog to change some parameters
    inst_subid = ['Generate your subject identification by combining'...
        ' the first letter of your surname, the first letter of the city'...
        ' you were born in and the day you were born.'...
        ' Example: Smith, London, 01.01.1990; SL01'];
    inst_hand = ['Inidcate which one your dominant hand is by writing'...
        ' r for right and l for left hand.'];
    prompt = {inst_subid, inst_hand};
    defaults = {'XXX','r'};

    % show dialog
    answer = inputdlg(prompt, 'Setup Information', 1, defaults);

    % takes the inputs that has been made in the dialog box and returns them 
    [sub_id, hand] = deal(answer{:});
end

