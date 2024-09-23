
% load in behavioral data

load('/Users/zacharyanderson/Documents/UIC/REWARD/participant_data_thc.mat');
load('/Users/zacharyanderson/Documents/UIC/REWARD/participant_data_pbo.mat');

load('/Users/zacharyanderson/Documents/UIC/REWARD/demographics.mat');

% ids and the order they were submitted to GIFT. 
sub_ids = {'RiDE017', 'RiDE024', 'RiDE028', 'RiDE033', 'RiDE034', 'RiDE041', 'RiDE051', 'RiDE055', 'RiDE057',...
    'RiDE059', 'RiDE061', 'RiDE066', 'RiDE069', 'RiDE070', 'RiDE074', 'RiDE077', 'RiDE078', 'RiDE086',...
    'RiDE087', 'RiDE092', 'RiDE094', 'RiDE095', 'RiDE102', 'RiDE105', 'RiDE106', 'RiDE107',...
    'RiDE109', 'RiDE110', 'RiDE119', 'RiDE120', 'RiDE121', 'RiDE123'};

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
thc_fnames = filenames(fullfile('RiDE*ica*-1.mat'),1);
pbo_fnames = filenames(fullfile('RiDE*ica*-2.mat'),1);

components_i_want = 1:5; 
% { 'SC', (1:5);'AU', (6:7);'SM', (8:16);'VI', (17:25);'CC', (26:42);      
% 'DM', (43:49);'CB', (50:53)};

for sub = 1:length(thc_fnames)
    thctemp = load(thc_fnames{sub});
    pbotemp = load(pbo_fnames{sub});
    thcbrainfinal(:,sub,:) = thctemp.tc(:,components_i_want);
    pbobrainfinal(:,sub,:) = pbotemp.tc(:,components_i_want);
end

thcbrainfinal = mean(thcbrainfinal,3);
pbobrainfinal = mean(pbobrainfinal,3);

% similarity matrix construction

sim_mat = corr(thcbrainfinal',pbobrainfinal');

% bootstrapped prediction
brain_diff = thcbrainfinal-pbobrainfinal;
feel_diff = thcfeel - pbofeel;
high_diff = thchigh - pbohigh;
like_diff = thclike - pbolike;
rew_diff = thcrewfeel - pborewfeel;


for boots = 1:100
    fprintf(strcat('Test set: ',num2str(boots),'\n'))
    MdlStd_test{boots} = fitrsvm(brain_diff',rew_diff,'Standardize',true,'KFold',5);
end

% control dist
for boots = 1:100
    fprintf(strcat('Control: ',num2str(boots),'\n'))
    idx = randperm(length(rew_diff)); rew_diff_temp = rew_diff(idx);
    MdlStd_control{boots} = fitrsvm(brain_diff',rew_diff_temp,'Standardize',true,'KFold',5);
end

% visualize out of sample mean squared error of both models

for boots = 1:100
    test_error = kfoldLoss(MdlStd_test{boots});
