
% load in behavioral data

load('/Users/zacharyanderson/Documents/UIC/REWARD/participant_data_thc.mat');
load('/Users/zacharyanderson/Documents/UIC/REWARD/participant_data_pbo.mat');

load('/Users/zacharyanderson/Documents/UIC/REWARD/demographics.mat');

% ids and the order they were submitted to GIFT. 
sub_ids = {'RiDE017', 'RiDE024', 'RiDE028', 'RiDE033', 'RiDE034', 'RiDE041', 'RiDE051', 'RiDE055', 'RiDE057',...
    'RiDE059', 'RiDE061', 'RiDE066', 'RiDE069', 'RiDE070', 'RiDE074', 'RiDE077', 'RiDE078', 'RiDE086',...
    'RiDE087', 'RiDE092', 'RiDE094', 'RiDE095', 'RiDE102', 'RiDE105', 'RiDE106', 'RiDE107',...
    'RiDE109', 'RiDE110', 'RiDE119', 'RiDE120', 'RiDE121', 'RiDE123', 'RiDE133'};

% create data tables with variables of interest

for sub = 1:length(sub_ids)
    thchigh(sub,1) = datthc.THC_deq_high_120_180_0(contains(datthc.record_id,sub_ids(sub)),1);
    thcfeel(sub,1) = datthc.THC_deq_feel_120_180_0(contains(datthc.record_id,sub_ids(sub)),1);
    thclike(sub,1) = datthc.THC_deq_like_120_180_0(contains(datthc.record_id,sub_ids(sub)),1);
    thcrewfeel(sub,1) = datthc.THC_arci_morphine_120_180_0(contains(datthc.record_id,sub_ids(sub)),1);
    
    pbohigh(sub,1) = datpbo.PBO_deq_high_120_180_0(contains(datpbo.record_id,sub_ids(sub)),1);
    pbofeel(sub,1) = datpbo.PBO_deq_feel_120_180_0(contains(datpbo.record_id,sub_ids(sub)),1);
    pbolike(sub,1) = datpbo.PBO_deq_like_120_180_0(contains(datpbo.record_id,sub_ids(sub)),1);
    pborewfeel(sub,1) = datpbo.PBO_arci_morphine_120_180_0(contains(datpbo.record_id,sub_ids(sub)),1);

    covsex(sub,1) = dem.demo_sex(contains(dem.record_id,sub_ids(sub)),1);
    covage(sub,1) = dem.demo_age(contains(dem.record_id,sub_ids(sub)),1);
    covrace(sub,1) = dem.demo_race(contains(dem.record_id,sub_ids(sub)),1);
    coveth(sub,1) = dem.demo_ethnicity(contains(dem.record_id,sub_ids(sub)),1);
    covalclife(sub,1) = dem.scid_alc_lifetime(contains(dem.record_id,sub_ids(sub)),1);
    covalccurrent(sub,1) = dem.scid_alc_current(contains(dem.record_id,sub_ids(sub)),1);
    covthclife(sub,1) = dem.scid_thc_lifetime(contains(dem.record_id,sub_ids(sub)),1);
    covthccurrent(sub,1) = dem.scid_thc_current(contains(dem.record_id,sub_ids(sub)),1);
    
end
% create data object for brain data for specific components. Currently
% averaged across suggested networks

basedir = '/Users/zacharyanderson/Documents/UIC/REWARD/gift_out_spatial';

cd(basedir)
thc_fnames = filenames(fullfile('RiDE*sub*component*ica_s1_.nii'),1);
pbo_fnames = filenames(fullfile('RiDE*sub*component*ica_s2_.nii'),1);

thcbrain = fmri_data(thc_fnames);
pbobrain = fmri_data(pbo_fnames);

components_i_want = 5; 
% { 'SC', (1:5);'AU', (6:7);'SM', (8:16);'VI', (17:25);'CC', (26:42);      
% 'DM', (43:49);'CB', (50:53)};

for sub = 1:length(thc_fnames)
    if sub == 1
        thcbrainfinal(:,sub,:) = thcbrain.dat(:,components_i_want);
        pbobrainfinal(:,sub,:) = pbobrain.dat(:,components_i_want);
    else
        thcbrainfinal(:,sub,:) = thcbrain.dat(:,components_i_want+(53.*(sub-1)));
        pbobrainfinal(:,sub,:) = pbobrain.dat(:,components_i_want+(53.*(sub-1)));
    end
end

thcbrainfinal = mean(thcbrainfinal,3);
pbobrainfinal = mean(pbobrainfinal,3);

thcbrainreg = thcbrain; thcbrainreg.dat = [];
pbobrainreg = pbobrain; pbobrainreg.dat = [];

% find a difference score. First, I'm going to get an average image
thcbrainreg.dat = []; thcbrainreg.dat = thcbrainfinal;
pbobrainreg.dat = []; pbobrainreg.dat = pbobrainfinal;
diffbrain = thcbrain; diffbrain.dat = []; diffbrain.dat = thcbrainfinal - pbobrainfinal;

thcbrainreg.X = ones(length(thc_fnames),1);
pbobrainreg.X = ones(length(thc_fnames),1);
diffbrain.X = ones(length(thc_fnames),1);

thcstat1 = regress(thcbrainreg);
pbostat1 = regress(pbobrainreg);
diffstat1 = regress(diffbrain);

% at this liberal threshold, there is one cluster that appears in the
% superior frontal gyrus extending into the cingulate
diffthresh_mean = threshold(diffstat1.t,0.001,'unc','k',5);
table(diffthresh_mean)

% now I'll do the regressions that were suggested for feel

thcbrainreg.X = thcfeel;
pbobrainreg.X = pbofeel;
diffbrain.X = thcfeel-pbofeel;

thcstat2 = regress(thcbrainreg);
pbostat2 = regress(pbobrainreg);
diffstat2 = regress(diffbrain);

% now I'll do the regressions that were suggested for high

thcbrainreg.X = thchigh;
pbobrainreg.X = pbohigh;
diffbrain.X = thchigh-pbohigh;

thcstat3 = regress(thcbrainreg);
pbostat3 = regress(pbobrainreg);
diffstat3 = regress(diffbrain);

% now I'll do the regressions that were suggested for like

thcbrainreg.X = thclike;
pbobrainreg.X = pbolike;
diffbrain.X = thclike-pbolike;

thcstat4 = regress(thcbrainreg);
pbostat4 = regress(pbobrainreg);
diffstat4 = regress(diffbrain);

% now the big demographic model

thcbrainreg.X = [covage,covsex,coveth,covrace];
pbobrainreg.X = [covage,covsex,coveth,covrace];
diffbrain.X = [covage,covsex,coveth,covrace];

thcstat5 = regress(thcbrainreg);
pbostat5 = regress(pbobrainreg);
diffstat5 = regress(diffbrain);

% individual dem: age

thcbrainreg.X = [covage];
pbobrainreg.X = [covage];
diffbrain.X = [covage];

thcstat5_1 = regress(thcbrainreg);
pbostat5_1 = regress(pbobrainreg);
diffstat5_1 = regress(diffbrain);

% individual dem: sex

thcbrainreg.X = [covsex];
pbobrainreg.X = [covsex];
diffbrain.X = [covsex];

thcstat5_2 = regress(thcbrainreg);
pbostat5_2 = regress(pbobrainreg);
diffstat5_2 = regress(diffbrain);

% individual dem: race

thcbrainreg.X = [covrace];
pbobrainreg.X = [covrace];
diffbrain.X = [covrace];

thcstat5_3 = regress(thcbrainreg);
pbostat5_3 = regress(pbobrainreg);
diffstat5_3 = regress(diffbrain);

% individual dem: ethnicity

thcbrainreg.X = [coveth];
pbobrainreg.X = [coveth];
diffbrain.X = [coveth];

thcstat5_4 = regress(thcbrainreg);
pbostat5_4 = regress(pbobrainreg);
diffstat5_4 = regress(diffbrain);

% now past alc while adjusting for big demographic model

thcbrainreg.X = [covalclife,covsex,covrace];
pbobrainreg.X = [covalclife,covsex,covrace];
diffbrain.X = [covalclife,covsex,covrace];

thcstat6 = regress(thcbrainreg);
pbostat6 = regress(pbobrainreg);
diffstat6 = regress(diffbrain);

% now past thc while adjusting for big demographic model

thcbrainreg.X = [covthclife,covsex,covrace];
pbobrainreg.X = [covthclife,covsex,covrace];
diffbrain.X = [covthclife,covsex,covrace];

thcstat7 = regress(thcbrainreg);
pbostat7 = regress(pbobrainreg);
diffstat7 = regress(diffbrain);

% now current alc while adjusting for big demographic model

thcbrainreg.X = [covalccurrent,covsex,covrace];
pbobrainreg.X = [covalccurrent,covsex,covrace];
diffbrain.X = [covalccurrent,covsex,covrace];

thcstat8 = regress(thcbrainreg);
pbostat8 = regress(pbobrainreg);
diffstat8 = regress(diffbrain);

% now current thc while adjusting for big demographic model

thcbrainreg.X = [covthccurrent,covsex,covrace];
pbobrainreg.X = [covthccurrent,covsex,covrace];
diffbrain.X = [covthccurrent,covsex,covrace];

thcstat9 = regress(thcbrainreg);
pbostat9 = regress(pbobrainreg);
diffstat9 = regress(diffbrain);

% now I'll do the regressions that were suggested for feel controlling for
% demographic regressors

thcbrainreg.X = [thcfeel,covsex,covrace];
pbobrainreg.X = [pbofeel,covsex,covrace];
diffbrain.X = [thcfeel-pbofeel,covsex,covrace];

thcstat10 = regress(thcbrainreg);
pbostat10 = regress(pbobrainreg);
diffstat10 = regress(diffbrain);

% now I'll do the regressions that were suggested for high controlling for
% demographic regressors

thcbrainreg.X = [thchigh,covsex,covrace];
pbobrainreg.X = [pbohigh,covsex,covrace];
diffbrain.X = [thchigh-pbohigh,covsex,covrace];

thcstat11 = regress(thcbrainreg);
pbostat11 = regress(pbobrainreg);
diffstat11 = regress(diffbrain);

% now I'll do the regressions that were suggested for like controlling for
% demographic regressors

thcbrainreg.X = [thclike,covsex,covrace];
pbobrainreg.X = [pbolike,covsex,covrace];
diffbrain.X = [thclike-pbolike,covsex,covrace];

thcstat12 = regress(thcbrainreg);
pbostat12 = regress(pbobrainreg);
diffstat12 = regress(diffbrain);

% now I'll do the regressions that were suggested for morphine/reward controlling for
% demographic regressors

thcbrainreg.X = [thcrewfeel,covsex,covrace];
pbobrainreg.X = [pborewfeel,covage,covsex,covrace];
diffbrain.X = [thcrewfeel-pborewfeel,covsex,covrace];

thcstat13 = regress(thcbrainreg);
pbostat13 = regress(pbobrainreg);
diffstat13 = regress(diffbrain);


% in general use this line to visualize each analysis
thresh_obj = threshold(diffstat13.t,0.001,'unc','k',5); orthviews(select_one_image(thresh_obj,1)); table(select_one_image(thresh_obj,1))


%% multivariate models

for boots = 1:100
    MdlStd = fitrsvm(X,Y,'Standardize',true)

end

