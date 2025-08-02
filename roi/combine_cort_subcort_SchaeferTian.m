function combine_cort_subcort_SchaeferTian(CORTICALPARC,SUBCORTICALPARC,OUTNAME)

[hdr,dataA] = read_nifti(CORTICALPARC);

n_cort = max(max(max(dataA)));

[~,data_sub] = read_nifti(SUBCORTICALPARC);

if isa(dataA, 'int32')
dataB = int32(data_sub);
elseif isa(dataA, 'single')
dataB = single(data_sub);
end

n_subcort = max(max(max(dataB)));

ind1 = find(ismember(dataB,1:(n_subcort/2)));

dataB(ind1) = dataB(ind1) + n_cort;

ind2 = find(ismember(dataB,(n_subcort/2 + 1):n_subcort));

dataB(ind2) = dataB(ind2) + n_cort;

change=0;
changeslog=[];

        dim1=size(dataB,1);
        dim2=size(dataB,2);
        dim3=size(dataB,3);
        data=zeros(dim1,dim2,dim3);
        for x=1:dim1
            for y=1:dim2
                for z=1:dim3
                    valB=dataB(x,y,z);
                    valA=dataA(x,y,z);
                    if valB==0 && valA==0
                        data(x,y,z)=0;
                        change=change+0;
                    elseif valB~=0 && valA==0
                        data(x,y,z)=valB;
                        change=change+0;
                    elseif valB==0 && valA~=0
                        data(x,y,z)=valA;
                        change=change+0;
                    elseif valB~=0 && valA~=0
                        data(x,y,z)=0;
                        change=change+1;
                        changeslog(change,1)=x;
                        changeslog(change,2)=y;
                        changeslog(change,3)=z;
                        changeslog(change,4)=valA;
                        changeslog(change,5)=valB;
                    end
                end
            end
        end
        changes=size(changeslog,1);
        if changes==1
            fprintf(2,'%d voxel had two segmentation values and\nwas assigned an intensity value equal to zero.\n',changes);
        elseif changes>1
            fprintf(2,'%d voxels had two segmentation values and\nwere assigned an intensity value equal to zero.\n',changes);
        end

clear change changes changeslog

write_nifti(hdr,data,OUTNAME)
