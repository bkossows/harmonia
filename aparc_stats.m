subj=lhaparca2009sthickness;
split=regexp(subj,'_','split');
split=cat(1,split{:});
subj=str2double(split(:,2));
timepoint=char(split(:,3));
timepoint=str2num(timepoint(:,2));

labels={'lh_G_precentral_thickness',
        'lh_G_postcentral_thickness',
        'lh_S_central_thickness'};
labels={'lh_G_precentral_volume',
        'lh_G_postcentral_volume',
        'lh_S_central_volume'};
    
for i=1:size(labels,1)
    label=labels{i};
    Y=eval(label);
    label=strrep(label,'_',' ');

    Ynorm=Y;
    for tp=min(timepoint):max(timepoint)
       Ynorm(timepoint==tp,:)=Y(timepoint==tp,:)./Y(timepoint==1,:);
    end

    figure; boxplot(Ynorm,timepoint); title(label);
    if ~sum(sum(diff(reshape(subj,5,[]))))
    figure; plot(reshape(Y,5,[])); title(label);
    end

end

