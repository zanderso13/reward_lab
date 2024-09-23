% to run this code, you'll need to install an additional GitHub repository.
% https://github.com/canlab/CanlabCore

% initial set up and definition of all available data
basedir = '/projects/p30954/reward_lab/fmriprep';
cd(basedir)

pbo_rest_fnames = filenames(fullfile('sub*/ses-placebo/func/sub*Smooth*nii'));
thc_rest_fnames = filenames(fullfile('sub*/ses-thc/func/sub*Smooth*nii'));

% apply motion criteria and check for single sessions (no within sub)
fd_cutoff = 0.3;
[final_fnames_thc,final_fnames_pbo,motion] = check_motion(thc_rest_fnames,pbo_rest_fnames, fd_cutoff,basedir);

% save the files with subject list. For some reason, I was hitting some
% matlab errors trying to run these commands. I downloaded the cell arrays
% to my laptop and saved them from there. 
% writecell(final_fnames_thc,'/projects/p30954/reward_lab/thc_gift.txt');
% 
% writecell(final_fnames_pbo,'/projects/p30954/reward_lab/pbo_gift.txt');

% These are the command line calls to run group ICA with default settings
% and the component estimation tool. I am running these commands in the two
% separate shell scripts 'gica_pbo.sh' 'gica_thc.sh'. I didn't find a
% within subjects option. I'm imagining running more traditional
% multivariate testing with the resulting images.

% gica_cmd --data /projects/p30954/reward_lab/pbo_gift.txt --o /projects/p30954/reward_lab/gift_out/pbo
% gica_cmd --data /projects/p30954/reward_lab/thc_gift.txt --o /projects/p30954/reward_lab/gift_out/thc


%% functions
function [final_fnames_thc,final_fnames_pbo,motion] = check_motion(fnames_thc,fnames_pbo,fd_cutoff,basedir)
    % match thc list
    for thc = 1:length(fnames_thc)
        if sum(contains(fnames_pbo,fnames_thc{thc}(1:11))) < 1
            only_one_session_thc(thc,1) = 1;
        else
            only_one_session_thc(thc,1) = 0;
        end
    end
    
    
    fnames_thc(logical(only_one_session_thc))=[];

    final_fnames_thc = fnames_thc';
    % check final list for motion problems
    
    for sub = 1:length(final_fnames_thc)
        pid = final_fnames_thc{sub}(1:11);
        thc_motion = filenames(fullfile(pid,strcat('/ses-thc/func/',pid,'*rest*confounds_timeseries.txt')));
        pbo_motion = filenames(fullfile(pid,strcat('/ses-placebo/func/',pid,'*rest*confounds_timeseries.txt')));
        
        full_confounds_pbo = readtable(pbo_motion{1});
        full_confounds_thc = readtable(thc_motion{1});

        fd_pbo = full_confounds_pbo.framewise_displacement;
        fd_thc = full_confounds_thc.framewise_displacement;

        if nanmean(fd_pbo)>fd_cutoff
            motion_idx(sub) = 1;
        elseif nanmean(fd_thc)>fd_cutoff
            motion_idx(sub) = 1;
        else
            motion_idx(sub)=0;
        end

        motion(sub,:) = [nanmean(fd_pbo),nanmean(fd_thc)];
    end
    % final fnames for the thc session
    % at 0.3: sub-RiDE039 and sub-RiDE122 are excluded
    final_fnames_thc(logical(motion_idx))=[];
    
    % final fnames for the placebo session. I'm also going to make sure
    % that fullpaths are used for both sets of final fnames. This is a
    % little backward, but it's what gift needs to work
    for sub = 1:length(final_fnames_thc)
        pid = final_fnames_thc{sub}(1:11);
        final_fnames_pbo(1,sub) = fnames_pbo(contains(fnames_pbo,pid));
    end

    % make absolute paths and not relative paths
    for sub = 1:length(final_fnames_thc)
        final_fnames_thc(sub) = strcat(basedir,'/',final_fnames_thc(sub));
        final_fnames_pbo(sub) = strcat(basedir,'/',final_fnames_pbo(sub));
    end
end

