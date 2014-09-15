function [ ESS,essvals,essvalsnorm,essvalestime ] = CalculateESS( Samples,SamplerParams, MaxLag )

    % Samples is a NumOfSamples x NumOfParameters matrix

    [NumOfSamples, NumOfParameters] = size(Samples.params(SamplerParams.Burnin+1:end,:));

    Means = mean(Samples.params(SamplerParams.Burnin+1:end,:));

    % Calculate empirical autocovariance
    for i = 1:NumOfParameters
        ACs(:,i) = autocorr(Samples.params(SamplerParams.Burnin+1:end,i),MaxLag);
    end


    % Preallocate memory
    Gamma    = zeros(floor(size(ACs,1)/2), NumOfParameters);
    MinGamma = zeros(floor(size(ACs,1)/2), NumOfParameters);

    % Calculate Gammas from the autocorrelations
    for i = 1:NumOfParameters

        % Add other Gammas
        for j = 1:((size(ACs,1)/2))
            Gamma(j,i) = ACs(2*j-1,i) + ACs(2*j,i);
        end
    end

    % Calculate the initial monotone convergence estimator
    % -> Gamma(j,i) is min of preceding values
    for i = 1:NumOfParameters
        % Set initial min Gamma
        MinGamma(1,i) = Gamma(1,i);

        for j = 2:((size(ACs,1)/2))
            MinGamma(j,i) = min(Gamma(j,i), MinGamma(j-1,i));
            Gamma(j,i) = MinGamma(j,i);
        end
    end


    for i = 1:NumOfParameters
        % Get indices of all Gammas greater than 0
        PosGammas = find(Gamma(:,i)>0);
        % Sum over all positive Gammas
        MonoEst(i) = -ACs(1,i) + 2*sum(Gamma(1:length(PosGammas),i));

        % MonoEst cannot be less than 1 - fix for when lag 2 corrs < 0
        if MonoEst(i) < 1
            MonoEst(i) = 1;
        end
    end
    
    ESS = NumOfSamples./MonoEst;
    essvals = sprintf('%.4f ',ESS);
    essvalsnorm = ESS/NumOfSamples;
    essvalestime = (ESS/Samples.sampleTime)*60;
    
    fprintf('ESS: %s\n', essvals)
    fprintf('ESS per sample: %s\n', sprintf('%.4f ',ESS/NumOfSamples))
    fprintf('ESS per min: %s\n', sprintf('%.4f ',(ESS/Samples.sampleTime)*60))
end
