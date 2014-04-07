clear all;
close all;
clc;

% [filenames, pathname, filterindex] = uigetfile('*.mp3','MP3-files (*.mp3)', 'Pick a file', 'MultiSelect', 'on');

%Read audio files from directory
dirName = '/Users/rajaramanin/Documents/MATLAB/Reverse Engineering Mix/Eval Set/';
folder = dir(fullfile(dirName));
folder = {folder.name}';
folder = folder(4:end);

numMixes = length(folder);
n = 1;

tolerance = 5;

gain_predicted_true = 0;
gain_predicted_false = 0;
pan_predicted_true = 0;
pan_predicted_false = 0;

track_count = 0;

result_eval_tol5 = cell(numMixes,13);

for n = 1:numMixes
n
tic
subfolder = char(folder(n));
subfolder = [char(dirName) subfolder];

files = dir(fullfile(subfolder));
files = {files.name}';
files = files(4:end);
% del_idx = find(strcmp(files, '.'));
% files(del_idx) = [];
% del_idx = find(strcmp(files, '..'));
% files(del_idx) = [];
% del_idx = find(strcmp(files, '.DS_Store'));
% files(del_idx) = [];

X_ca = cell(1,length(files));
% fs_X = cell(1,length(files));
% X_info = cell(length(files),1);

for i = 1:length(files)
    % Number of channels not same for all tracks - Hence, use of cell arrays
%     X_info{i,1} = audioinfo(char(files(i))); 
    tempfile = [subfolder '/' char(files(i))];
    X_ca{1,i} = audioread(char(tempfile));    
end
%%
[dimM, dimN] = cellfun(@size, X_ca);

track_count = track_count + sum(dimN);

X = cell2mat(X_ca);     %Matrix of 'k' tracks/channels by 'n' samples

%% 
gain_ip = rand(1)+1;
pan_ip = randi(6)*10;

%My MIX evaluation
myMixTrgt = myMix(X,gain_ip,pan_ip);

%Evaluation from myMix - 
gain_coeffs_eval = leastSqGain(myMixTrgt,2, X);

% Get indivdual gain for tracks and panning
[gains, PL, PR, Lpan_deg, Rpan_deg] = panEstimate(gain_coeffs_eval);

%%
gain_difference = gains - gain_ip;
gain_difference_per = (abs(gain_difference)/gain_ip)*100;

LRpans_check_equal  = Lpan_deg./Rpan_deg;
LRpans_check_equal = LRpans_check_equal < 1+0.05 & LRpans_check_equal > 1-0.05;

pan_difference = Lpan_deg - pan_ip;
pan_difference_per = (abs(pan_difference)/pan_ip)*100;

gain_tol_check = gain_difference_per <= tolerance;
pan_tol_check = pan_difference_per <= tolerance;

        
%%
% prediction
gain_predicted_true = gain_predicted_true + sum(gain_tol_check);

pan_predicted_true = pan_predicted_true + sum(pan_tol_check);

%%
% Result cell matrix: numMixes X 12 result columns
sno = sprintf('Song%d',n);
result_eval_tol5{n,1} = sno;                                                %Song no.
result_eval_tol5{n,2} = gain_ip;                                            %gain applied (1 value)                                            
result_eval_tol5{n,3} = pan_ip;                                             %pan applied (1 value)
result_eval_tol5{n,4} = gains;                                              %gains extracted X no. of tracks
result_eval_tol5{n,5} = Lpan_deg;                                           %Left Panning extracted X no. of tracks
result_eval_tol5{n,6} = Rpan_deg;                                           %Right Panning extracted X no. of tracks
result_eval_tol5{n,7} = gain_difference;                                    %Gain difference X no. of tracks
result_eval_tol5{n,8} = gain_difference_per;                                %Gain differece % X no. of tracks
result_eval_tol5{n,9} = LRpans_check_equal;                                 %Check left pans = right pans for all tracks (bool value for song)
result_eval_tol5{n,10} = pan_difference;                                    %Pan difference X no. of tracks
result_eval_tol5{n,11} = pan_difference_per;                                %Pan difference % X no. of tracks
result_eval_tol5{n,12} = gain_tol_check;                                    %Gain ~= applied gain, tolerance = 1% (bool value) X no. of tracks
result_eval_tol5{n,13} = pan_tol_check;                                     %Pan ~= applied panning, tolerance = 1% (bool vale) X no. of tracks
toc
end
%%
gain_predicted_false = track_count - gain_predicted_true;
gain_precision = gain_predicted_true/track_count;
gain_recall = gain_predicted_true/(gain_predicted_true + gain_predicted_false);
gpr = [gain_precision, gain_recall];
save('gpr.mat', 'gpr');

pan_predicted_false = track_count - pan_predicted_true;
pan_precision = pan_predicted_true/track_count;
pan_recall = pan_predicted_true/(pan_predicted_true + pan_predicted_false);
ppr = [pan_precision, pan_recall];
save('ppr.mat','ppr');

colHeadings = {'songNo','gainApplied', 'panApplied', 'gainExtracted', 'LpanExtracted', 'RpanExtracted', 'gainDifference', 'gainDifferencePercent', 'panEqualCheck', 'panDifference', 'panDifferencePercent', 'GainCheck', 'PanCheck'};
songs = cell2struct(result_eval_tol5, colHeadings, 2);
save('results_struct.mat','songs');
