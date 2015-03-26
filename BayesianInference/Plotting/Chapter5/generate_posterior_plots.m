function generate_posterior_plots(mcmc_experiment,experimentType,paramNames)
    mcmc_experiment=load(mcmc_experiment);
    kA=mcmc_experiment.model.kA;
    kF = size(mcmc_experiment.model.generateQ(mcmc_experiment.startParams,mcmc_experiment.data.concs(1)),1) - kA;
    k = mcmc_experiment.model.k;
    
    f = k ./(1:ceil(sqrt(k)));
    f = f(f==fix(f)).' ;
    f = unique([f;k./f]);
    
    if mod(f,2)
        k1 = median(f);
        k2 = median(f);
    else
        k1 = f(length(f)/2);
        k2 = f((length(f)+1)/2);
    end
    
    %options for calculating dcprogs variables
    if isfield(mcmc_experiment,'dcpoptions')
        dcpoptions = mcmc_mcmc_experiment.dcpoptions;
    else
        dcpoptions{1}=2;
        dcpoptions{2}=1e-12;
        dcpoptions{3}=1e-12;
        dcpoptions{4}=100;
        dcpoptions{5}=-1e6;
        dcpoptions{6}=0; 
    end


    %% Posterior Param Plot
    posterior_density_plot = generate_param_plot(mcmc_experiment.model.k,k1,k2,mcmc_experiment.samples.params(mcmc_experiment.SamplerParams.Burnin+1:end,:),paramNames);

    %% Sample from the posterior distribution generated
    SAMPLES=1;
    posterior_samples = datasample(mcmc_experiment.samples.params(mcmc_experiment.SamplerParams.Burnin+1:end,:),SAMPLES);

    %% Generate unconditional univariate distributions

    open_unconditional_plot = generate_unconditional_plot(mcmc_experiment,mcmc_experiment.data.resolved_data,experimentType,posterior_samples,1,2,2,kA,kF,dcpoptions);
    closed_unconditional_plot = generate_unconditional_plot(mcmc_experiment,mcmc_experiment.data.resolved_data,experimentType,posterior_samples,0,2,2,kA,kF,dcpoptions);

    %% Generate conditional distributions < 0.1 msec
    conditional_open_density = generate_conditional_plot(mcmc_experiment,mcmc_experiment.data.resolved_data,experimentType,posterior_samples,1,2,2,kA,kF,[2.5e-5,0.1/1000],dcpoptions);

    %% Generate conditional mean distributions
    tint = [0.025 0.05;0.05 0.1; 0.1 0.2; 0.2 2; 2 20; 20 200; 200 2000;]/1000;
    conditional_open_mean_density = generate_conditional_mean_plot(mcmc_experiment,mcmc_experiment.data.resolved_data,experimentType,posterior_samples,1,2,2,kA,kF,tint,dcpoptions);

    %%Generate bivariate plot
    bivariate_plot = generate_bivariate_plot(mcmc_experiment,mcmc_experiment.data.resolved_data,'experimental',2,2);

    PlotNByM(posterior_density_plot,k1,k2,1,[getenv('P_HOME') '/BayesianInference/Plotting/Debug/generated_posterior_parameters'])
    PlotNByM(open_unconditional_plot,2,2,1,[getenv('P_HOME') '/BayesianInference/Plotting/Debug/generated_posterior_open_times'])
    PlotNByM(closed_unconditional_plot,2,2,1,[getenv('P_HOME') '/BayesianInference/Plotting/Debug/generated_posterior_closed_times'])
    PlotNByM(conditional_open_density,2,2,1,[getenv('P_HOME') '/BayesianInference/Plotting/Debug/generated_posterior_conditional_open_times'])
    PlotNByM(conditional_open_mean_density,2,2,1,[getenv('P_HOME') '/BayesianInference/Plotting/Debug/generated_posterior_conditional_mean'])
    PlotNByM(bivariate_plot,2,2,1,[getenv('P_HOME') '/BayesianInference/Plotting/Debug/generated_bivariate_plot'])
    %PlotNByM(posterior_bivariate_plot,2,2,1,[getenv('P_HOME') '/BayesianInference/Plotting/Debug/generated_bivariate_plot'])

    close(posterior_density_plot)
    close(open_unconditional_plot)
    close(closed_unconditional_plot)
    close(conditional_open_density)
    close(conditional_open_mean_density)
    close(bivariate_plot)
    %close(posterior_bivariate_plot)




end