scriptdir = '~/repo/reward_lab';

repodir = '~/repo';

% next is where the preprocessed data is
directories = '/projects/p30954/reward_lab/fmriprep';

% What run of your task are you looking at?
run = 1;
% What session appears in your raw filenames when in BIDS format?
ses = 'placebo';
% Do you want to overwrite previously estimated first levels or just add to
% what you have? 1 overwrites, 0 adds
overwrite = 0;
% Last thing is janky but bear with me. How long are your participant ID's?
% i.e. 10234 would correspond with a 5 for this variable
ID_length = 7;


file_list = filenames(fullfile(directories,strcat('*/ses-',ses,'/func/sub*rest*preproc_bold.nii')));
for i = 1:length(file_list)
    sublist{i} = file_list{i}(42:48);
end

if overwrite == 0
    smooth_list = filenames(fullfile(directories,strcat('*/ses-',ses,'/func/sub*Smooth*nii')));
    counter = 1;
    for sub = 1:length(sublist)
        curr_sub = sublist(sub);
        if sum(contains(smooth_list,curr_sub)) == 0 
            new_list(counter) = sublist(sub);
            counter = counter + 1;
        else
            continue
        end
    end
end

% Run/submit first level script
keyboard
cd(scriptdir)
for sub = 1:length(new_list)
    PID = new_list{sub};

     ica_single_smooth_rewlab(PID,ses,1,1)

     %    s = ['#!/bin/bash\n\n'...
     % '#SBATCH -A p30954\n'...
     % '#SBATCH -p short\n'...
     % '#SBATCH -t 00:20:00\n'...  
     % '#SBATCH --mem=30G\n\n'...
     % 'matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath(''' repodir ''')); ica_single_smooth_rewlab(''' PID ''',''' ses ''',' num2str(run) ',' num2str(overwrite) '); quit"\n\n'];
     % 
     % scriptfile = fullfile(scriptdir, 'smoothing_script.sh');
     % fout = fopen(scriptfile, 'w');
     % fprintf(fout, s);
     % 
     % 
     % !chmod 777 smoothing_script.sh
     % !sbatch smoothing_script.sh
     
end
