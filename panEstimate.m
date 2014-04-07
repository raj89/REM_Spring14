function [ g, PL, PR, Lpan_deg, Rpan_deg ] = panEstimate( gain_coeffs )
%Estimate individual track gains, Left and Right panning gains & panning
%angles in radians
%   g  = individual tracks gain vector, 
%   PL = left pan gain vector, 
%   PR = right pan gain vector,
%   Lpan_deg = Left panning angle (in degrees)
%   Rpan_deg = Right panning angle (in degrees)

% Assuming a 2 channel stereo mix:

g = sqrt(gain_coeffs(1,:).^2 + gain_coeffs(2,:).^2);                        %Individual gains on tracks
PL = gain_coeffs(1,:) ./ g;                                                 %Left channel panning
PR = gain_coeffs(2,:) ./ g;                                                 %Right channel panning

Lpan_deg = acos(PL) * 180/pi;                                               %Left pan angle in radians
Rpan_deg = asin(PR) * 180/pi;                                               %Right pan angle in radians

end

