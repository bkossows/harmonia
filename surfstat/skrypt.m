%po³ówka - lh
%Przygotowanie
clear all; close all;
addpath ~/Documents/MATLAB/surfstat
subjects_dir='/Volumes/LaCie/Harmonia/freesurfer_braille-kopia';

%Za³aduj wszystkie grubo¶ci/wielko¶ci kory, wszystkich osób ze wszystkich
%timepointów - 28x5x163842
%mri_concat Hrb_*_T?/surf/lh.thickness.fwhm10.fsaverage.mgh --o fs_matlab/lh.thickness.fwhm10.fsaverage.mgh
%inne miary: lh.volume.fwhm10.fsaverage.mgh || lh.area.pial.fwhm10.fsaverage.mgh
%[Y,mri] = fs_read_Y('lh.thickness.fwhm10.fsaverage.mgh');

% 
 lh=cell_rdir('../*/surf/lh.thickness.fwhm10.fsaverage.mgh');
 rh=cell_rdir('../*/surf/rh.thickness.fwhm10.fsaverage.mgh');

%lh=cell_rdir('../*/surf/lh.pial_lgi.fwhm15.fsaverage.mgh');
%rh=cell_rdir('../*/surf/rh.pial_lgi.fwhm15.fsaverage.mgh');

Y=SurfStatReadData([lh,rh],'.',256);
%Y=SurfStatReadData(lh,'.',256);

%Za³aduj template fsaverage (czy warto zrobiæ swój?)
%lhsphere = fs_read_surf(fullfile(subjects_dir,'fsaverage/surf/lh.sphere'));
%lhcortex =
%fs_read_label(fullfile(subjects_dir,'fsaverage/label/lh.cortex.label'));
filesboth={fullfile(subjects_dir,'fsaverage/surf/lh.white'),fullfile(subjects_dir,'fsaverage/surf/rh.white')};

%sprobujmy po kolei
% lh=cell_rdir('../Hrb_1_T1/surf/lh.pial.obj');
% rh=cell_rdir('../Hrb_1_T1/surf/rh.pial.obj');
% 
% filesboth = [ lh, rh ];
% avsurf = SurfStatAvSurf( filesboth );
% NIE DZIA£A

s=SurfStatReadSurf(filesboth);
%s = SurfStatInflate( s , 0.75);

mask = SurfStatMaskCut( s );
%figure; SurfStatView(mask,s);

%Za³aduj qdec. Tabela powinna mec kolejno¶æ tak± jak lista plików w MGH ->
%sortowanie
Qdec = fReadQdec('qdec.table.full.dat.csv');
[~,i]=sort(Qdec(2:end,1));
sQdec = Qdec(i+1,:);
%teraz powinno byæ posortowane tak jak pliki - sprawd¼!
Qdec=[Qdec(1,:);sQdec];
nQdec=Qdec2num(Qdec);

%wyci±gn±æ subj id
subj=char(Qdec(2:end,2));
subj=str2num(subj(:,5:end));
initial_age=nQdec(:,4);
timepoint=nQdec(:,3);

%%%%MODEL
Subj=term(var2fac(subj(:)));
Age=term(initial_age);
Timepoint=term(timepoint);
%Hand=term(var2fac(hand));
M=1+Timepoint+Subj;
%M=1+Timepoint+Hand+Timepoint*Hand+random(Subj)+I; % 1+Age+Timepoint+random(Subj)+I lub pro¶ciej M=1+Timepoint+Subj;
figure; image(M)

slm = SurfStatLinMod( Y, M ,s)
%figure; SurfStatView( slm.r.*mask, s, 'Correlation within subject');
slm = SurfStatT( slm, -timepoint)
%contrast=((timepoint==2)-(timepoint==4));
%slm = SurfStatT( slm, contrast )

figure; SurfStatView( slm.t, s, 'T stat for timepoint' );

p_unc=0.01;
%uncorrected threshold z SurfStatP
thresh=stat_threshold(0,1,0,slm.df,p_unc,[],[],[],slm.k,[],[],0);
figure; SurfStatView( slm.t.*(abs(slm.t)>thresh), s, ['T val for uncorr p < ',num2str(p_unc)]);

[ pval, peak, clus ] = SurfStatP( slm,mask,p_unc);
pval.thresh=0.02;
figure; SurfStatView( pval, s, ' val corrected for timepoint' );

% qval = SurfStatQ( slm);
% figure; SurfStatView( qval, s, 'Q val for timepoint' );

%%% ROI PLOT
%1. Przygotuj pliki z obszarami np. mri_annotation2label --subject fsaverage --hemi lh --outdir out_labels/
%dodano --aparc2005s
%label_file=spm_select();
%label_file='/Volumes/LaCie/Harmonia/freesurfer_braille-kopia/fsaverage/out_labels/lh.fusiform.label';
label_file='/Volumes/LaCie/Harmonia/freesurfer_braille-kopia/fsaverage/aparc2005_labels/lh.G_occipit-temp_lat-Or_fusiform.label';
[~,label_name]=fileparts(label_file);
label_name=strrep(label_name,'_',' ');
[vtxs,nvtxs] = fs_read_label(label_file);
mask=zeros(1,size(Y,2));
mask(vtxs)=1;
mask=logical(mask);
%figure; SurfStatView( mask, s, label_name );
%figure; SurfStatView( mean(Y), s, 'mean signal from whole dataset' );

%%%normalizacja do T0
Ynorm=Y;

%%tymczasowo
% Ynorm(subj==25,:)=[];
% timepoint(subj==25)=[];

% for tp=min(timepoint):max(timepoint)
%    Ynorm(timepoint==tp,:)=Y(timepoint==tp,:)./Y(timepoint==1,:);
% end

figure; SurfStatPlot( timepoint, mean(Ynorm(:,mask),2), [], [], 'LineWidth',2, 'MarkerSize',12 );
figure; boxplot(mean(Ynorm(:,mask),2),timepoint); title(label_name);
figure; plot(reshape(mean(Ynorm(:,mask),2),5,[])); title(label_name);


%%%FLIP?
%fsaverage=SurfStatReadData(cell_rdir('../fsaverage/surf/lh.thickness'),'.',256);
%figure; SurfStatView( fsaverage, s, 'fsaverage thickness');