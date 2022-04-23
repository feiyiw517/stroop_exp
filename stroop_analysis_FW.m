%% Preparation

clear all;

%% experimental loop

for which_subject = 1:9 % change based on number of data files
   filename = ['TEST' num2str(which_subject) '_Stroop.mat'];
   load(filename);
   
  % set up indices
   correctness = 6;
   congruency = 1;
   RT = 3;
   
  %% 0. making histogram, should be skewed
  figure(which_subject);
  hist(emat(:, RT));
  
  %% 1. sort out data of interest (doi)
  
  % get overall accuracy
  correct_trials = emat (:, correctness) == 1;
  doi = emat(correct_trials, :);
  n_correct_overall = size(doi, 1);
  n_total = size(emat, 1);
  overall_accuracy = n_correct_overall/n_total * 100;
  
  % get congruent accuracy
  congruent_trials = emat (:, congruency) == 1;
  get_congruent = emat (congruent_trials, :);
  correct_congruent = get_congruent(:, correctness) == 1;
  get_doi_congruent = get_congruent(correct_congruent,:);
  n_correct_congruent = size(get_doi_congruent,1);
  n_total_congruent = size(get_congruent, 1);
  congruent_accuracy = n_correct_congruent/n_total_congruent * 100;
  
  % get incongruent accuracy
  incongruent_trials = emat (:, congruency) == 2;
  get_incongruent = emat (incongruent_trials, :);
  correct_incongruent = get_incongruent(:, correctness) == 1;
  get_doi_incongruent = get_incongruent(correct_incongruent,:);
  n_correct_incongruent = size(get_doi_incongruent,1);
  n_total_incongruent = size(get_incongruent, 1);
  incongruent_accuracy = n_correct_incongruent/n_total_incongruent * 100;
  
  % separate correct data in doi matrix base on congruency
  doi_congruent = doi(doi(:, congruency) == 1, :); % first column of doi = congruency
  doi_incongruent = doi(doi(:, congruency) == 2, :); 
  
  %% 2. remove RT outliers that are outside +/-3 std
  crit = 3; % can be 3 if conservative.
  
  mean_congruent = mean(doi_congruent(:, RT));
  std_congruent = std(doi_congruent(:, RT));
  include_congruent = doi_congruent(:, RT) < mean_congruent + std_congruent * crit & ...
      doi_congruent(:, RT) > mean_congruent - std_congruent * crit;
  final_congruent = doi_congruent (include_congruent, :);
  
  mean_incongruent = mean(doi_incongruent(:, RT));
  std_incongruent = mean(doi_incongruent(:, RT)); 
  include_incongruent = doi_incongruent(:, RT) < mean_incongruent + std_incongruent * crit & ...
      doi_incongruent(:, RT) > mean_incongruent - std_incongruent * crit;
  final_incongruent = doi_incongruent (include_incongruent, :);
  
 %% 3. get final mean RT for each condition
 mean_RT_congruent = mean(final_congruent(:, RT));
 mean_RT_incongruent = mean(final_incongruent(:, RT));
 
 %% 4. get final results matrix
 temp_results = [mean_RT_congruent congruent_accuracy mean_RT_incongruent incongruent_accuracy overall_accuracy];
 results(which_subject, :) = temp_results;
    
end


save('StroopResults.mat', 'results')
