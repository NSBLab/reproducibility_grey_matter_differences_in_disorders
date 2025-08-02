function [overlapall, overlapNonZero] = overlap_mat(data)
% Calculate the overlapping matrix as in Marek 2022
%
%% Input:
% data      - the matrix whose columns are calculated.
%
%% Output:
% overlapall     - overlapping matrix showing the overlapping between pair of maps.
% overlapoOnZero     - overlapping matrix showing the overlapping between pair of maps that have non zero components.

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

[nVertice nSite] = size(data); % number of columns/sites

r_phi = zeros(nSite, nSite); % preallocation space
for iLoop1 = 1:nSite
    for iLoop2 = 1:nSite
        maplogi = logical(squeeze(sigmapSurrsVerAll(:,isDiagSite)));
        nonzeroIn = find(or(data(:,iLoop1),data(:,iLoop2))==1);

        overlapall(iLoop1,iLoop2) = sum(xor(data(:,iLoop1),data(:,iLoop2))==0)/nVertice;
        overlapNonZero(iLoop1,iLoop2) = sum(xor(data(nonzeroIn,iLoop1),data(nonzeroIn,iLoop2))==0)/length(nonzeroIn);




    end
end