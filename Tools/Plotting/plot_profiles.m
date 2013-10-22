function fig=plot_profiles(results_dir,colours,experiment,title_str,plot_row,plot_col,parameter_no,param_keys)
% results_dir,colours,experiment(string)
% title_str(string),plot_row,plot_col,number of
% parameters,parameter_strings

fig=figure();

for j=1:length(results_dir)
    for i=1:parameter_no
        load([results_dir{j} '/parameter_key_' num2str(param_keys(i)) '.mat'])
        hold on;
        subplot(plot_row,plot_col,i)
        plot(profiles(1,:),profile_likelihoods/-min(profile_likelihoods),colours{j})      
        ylim([-1 -0.997])
        title(title_str{i},'interpreter','latex')
    end
end
legend(experiment)
end