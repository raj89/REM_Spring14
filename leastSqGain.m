function [ output ] = leastSqGain( target_mix, target_channels, multitrack_subspace)
% LEAST SQUARE GAIN FITTING v1.01 ~ Raja Raman - 02/16/2014
%To fit the Target Mix into Multitrack subspace for optimal gain fitting. Find a set of optimal coefficients a (gain vector) that minimize the
%Euclidean distance between target and estimated mix.

% Error prone and computationally heavy...
% Making the Multitrack a square matrix: X'*X
temp_multi_sqaure = (multitrack_subspace.') * multitrack_subspace;

% Taking inverse: (inv(square matrix) * X')
%temp_multi_inv = inv(temp_multi_sqaure);
n = size(temp_multi_sqaure);
temp_multitrack_subspace = (temp_multi_sqaure + (eye(n)*1e-10))\ (multitrack_subspace.'); % same as inv(X'X)*X'

% Multiplying by transpose:
%temp_multi = temp_multi_inv * multitrack_subspace.'; % less accurate - more INFs and NANs + slower

% Calculate the target fitness for optimal gain across each channel/track in Multitrack
% subspace in respect to each target channel.
for c = 1:target_channels
    gain_coeffs(c,:) = temp_multitrack_subspace * target_mix(:,c);
end

output = gain_coeffs;

end

