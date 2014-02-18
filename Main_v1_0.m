clear all;
close all;
clc;

% [filenames, pathname, filterindex] = uigetfile('*.mp3','MP3-files (*.mp3)', 'Pick a file', 'MultiSelect', 'on');

%Read audio files from directory
dirName = '/Users/rajaramanin/Documents/MATLAB/Reverse Engineering Mix/QMUL Multitrack database/multitrack_audio_1/alex_q_glamorama/';
files = dir(fullfile(dirName,'*.mp3'));
files = {files.name}';

%get target audiofile
del_idx = find(strcmp(files,'mix.mp3'));
[trgtMix, fs_t] = audioread(char(files(del_idx)));
trgtMix_info    = audioinfo(char(files(del_idx)));
files(del_idx) = []; %remove target mix file from list

X_ca = cell(1,length(files));
fs_X = cell(1,length(files));
X_info = cell(length(files),1);

for i = 1:length(files)
    % Number of channels not same for all tracks - Hence, use of cell arrays
    X_info{i,1} = audioinfo(char(files(i)));   
    [X_ca{1,i}, fs_X{1,i}] = audioread(char(files(i)));    
end
%%
[dimM, dimN] = cellfun(@size, X_ca);

if sum(dimN) > i+1
    disp(['Extra channels detected! :' sum(dimN)-i]);
elseif sum(dimN) == i+1
    disp('Possible drum track for extra channel');
elseif sum(dimN) == i
    disp('No drum track in mix');
end

if range(dimM) == 0 && max(dimM) == length(trgtMix)
    X = cell2mat(X_ca);     %Matrix of 'k' tracks/channels by 'n' samples
else
    error('filelength:argChk', 'Channels/tracks not of same length');
end

%%
%gain coeffs for each track determined seperately for all channels of target mix
gain_coeffs = leastSqGain(trgtMix, trgtMix_info.NumChannels, X);