function replication = replication_mat(data)
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

replication = zeros(nSite, nSite); % preallocation space
for iLoop1 = 1:nSite
    if sum(data(:,iLoop1))==0
        replication(iLoop1,:) = 0;
    else
        for iLoop2 = 1:nSite
            if sum(data(:,iLoop2))==0
                replication(iLoop1,iLoop2) = 0;
            else

                replication(iLoop1,iLoop2) = sum(and(data(:,iLoop1),data(:,iLoop2))==1)/sum(data(:,iLoop2)==1);
            end

        end
    end
end