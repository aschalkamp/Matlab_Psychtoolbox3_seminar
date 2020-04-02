function [stimwidth,stimheight] = deg2pix(angle, coeffwidth, coeffheight)
%deg2pix.m given a visual angle and the degree to pixel coefficients
% returns the stimulus width and height in pixels
% arguments: angle       = subtended visual angle by stimulus
%            coeffwidth  = calculated conversion constant from degree to pixel
%            coeffheight = calculated conversion constant from degree to pixel
    stimwidth = round(angle*coeffwidth);
    stimheight = round(angle*coeffheight);
end

