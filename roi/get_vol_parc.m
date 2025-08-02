function volParc = get_vol_parc(map, parc)
% input: map: map in spm volume format (use map=spm_vol(niftifile))
%        parc: parcelation mask (can be read from nifti file)
%
% output: volParc: vector of volume per ml in each parcel

%number of parcels
N = max(parc,[],'all');

volParc = zeros(N,1);
for n = 1:N
    vsz = abs(det(map.mat));
    img = spm_read_vols(map);

    volParc(n) = sum(img(parc==n)) * vsz / 1000; % vsz in mm^3 (= 0.001 ml)
end