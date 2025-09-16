function [out, parcellatedData, zeroResult] = parcellateData(data, rois, varargin)
%% Examples
%   parcellateData((1:100).', (mod(1:100, 6)).'+1)
%   parcellateData((1:100).', (mod(1:100, 6)).')   % rois indexed 0 are excluded 
%   parcellateData((1:100).'+[0,10], (mod(1:100, 6)).'+1)
%   parcellateData((1:100).'+[0,10], (mod(1:100, 6)).'+1, @(x) mean(x, 1)) % same as above 
%   parcellateData((1:100).'+[0,10], (mod(1:100, 6)).'+1, @(x) mean(x, 'all')) % different 
%   
%   parcellateData((1:100).', (mod(1:100, 6)).'+1)
%   parcellateData((1:100).', (mod(1:100, 6)).'+2) % rois with no data return NaN values
%   parcellateData((1:100).', (mod(1:100, 6)).'*2)
%   parcellateData((1:100).', (mod(1:100, 6)).', @(x) sum(x, 1)) % change the function
%   parcellateData((1:100).'+[0,10], (mod(1:100, 6)).', @(x) sum(x, 1)) % change the function
%   parcellateData((1:100).', (mod(1:100, 6)).', @numel) % count the number of points in each ROI
%   parcellateData((1:100).', (mod(1:100, 6)).', @(x) [min(x) max(x)], 'nargout', 2) % return multiple outputs
%   parcellateData((1:100).'+[0,10], (mod(1:100, 6)).', @(x) [min(x) max(x)], 'nargout', 2) % return multiple outputs for multiple columns
%   parcellateData((1:100).', (mod(1:100, 6)).', @(x) sum(x, 1))./parcellateData((1:100).', (mod(1:100, 6)).', @numel), parcellateData((1:100).', (mod(1:100, 6)).') 
%   
%   parcellateData(magic(5), [1;1;1;3;3]) 
%   parcellateData(magic(5), [1;1;1;3;3], @sum) 
%   %parcellateData(magic(5), [0;1;1;3;3], @sum) % this will fail as some groups are only one row (and so the behaviour of `sum` changes) 
%   parcellateData(magic(5), [1;1;1;3;3], @(x) sum(x, 'all')) 
%   parcellateData(magic(5), [0;1;1;3;3], @(x) sum(x, 1))
%   parcellateData(magic(5), [2;1;1;3;3], @(x) sum(x, 1))
%   
%   roiCentroids = parcellateData(rh_verts_midthickness, Scha17_parcs.rh_scha1000, @(x) mean(x, 1)); whos roiCentroids, nnz(isnan(roiCentroids)) 
%
%
%% Input Arguments
%  data - data to be parcellated (V x 1 vector or V x D matrix)
%  
%  rois - ROI allocation of each row in `data` (V x 1 vector)
%
%  func - function to aggregate data in each parcel (function handle)
%
%
%% Output Arguments
%  out - data after parcellation (R x D x M matrix) 
%  Where R is the maximum ROI ID (or `nrois`, if input), and M is the number of
%  outputs from `func`
%  
%  parcellatedData - raw output from splitapply (R' x M matrix)
%  Where R' is the number of unique ROIs
%  
%% ENDPUBLISH 


%% Prelims
ip = inputParser;
addRequired(ip, 'data');
addRequired(ip, 'rois');
addOptional(ip, 'func', @(x) mean(x, 1), @(x) isa(x, 'function_handle') );

addParameter(ip, 'nrois', max(rois)); % force number of rois in out, if desired
addParameter(ip, 'nargout', 1); % size of third dimension

ip.parse(data, rois, varargin{:});


%% Computations
% Use findgroups and splitapply to do parcellation
[groups, groupAllocations] = findgroups(ip.Results.rois);
parcellatedData = splitapply(ip.Results.func, ip.Results.data, groups);

% Reshape data based on number of columns and number of outputs
parcellatedData = reshape(parcellatedData, ...
    size(parcellatedData, 1), [], ip.Results.nargout);
zeroResult = parcellatedData(~groupAllocations,:,:);

% Reshape into final shape for outputting
out = nan([ip.Results.nrois, size(parcellatedData, 2:3)]);
out(nonzeros(groupAllocations),:,:) = parcellatedData(~~groupAllocations,:,:);


end
