function [ mixOut ] = myMix( multitrack, gain, panAngle )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%same individual gain and panning for all tracks for now:

panAngle_rad = panAngle * pi/180;
PL = cos(panAngle_rad);
PR = sin(panAngle_rad);

temp_mix = gain*multitrack;

mixOut = zeros(length(multitrack),2);
temp_track_stereo = zeros(length(multitrack),2);

for c = 1:size(temp_mix,2)
    
    temp_track_stereo(:,1) = PL * temp_mix(:,c);
    temp_track_stereo(:,2) = PR * temp_mix(:,c);

    mixOut = mixOut + temp_track_stereo - mixOut.*temp_track_stereo;
   
end

end

