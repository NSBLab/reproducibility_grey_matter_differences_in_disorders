%check shifting effect on binary correlation metric

clear all
addpath('/home/trangc/kg98/trangc/VBM/code/utils')
nVertice = 10000;
nOne = 1000;
nOffset = 1000;
%genrate random binary arrays
map = [[ones(nOne,1);zeros(nVertice-nOne,1)] [zeros(nOffset,1); ones(nOne,1);zeros(nVertice-nOne-nOffset,1)]];
% map = randi(2,nVertice,2)-1;
maplogi = logical(map);
nonzeroIn = find(any(maplogi,2)==1);

bincorr = bin_corr_mat(map);
overlapall = sum(xor(maplogi(:,1),maplogi(:,2))==0)/nVertice;
overlapNonZero = sum(xor(maplogi(nonzeroIn,1),maplogi(nonzeroIn,2))==0)/length(nonzeroIn);

