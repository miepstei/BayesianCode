
chi1 = chi2inv(0.95,1);
figure
for i=1:9
    subplot(3,3,i) 
    plot(exp(profiles(1,:,i)),profile_likelihoods(i,:))
    title(parameter_keys(i)) 
    line([exp(min(profiles(1,:,i))) exp(max(profiles(1,:,i)))],[min(profile_likelihoods(i,:))+(0.5*chi1) min(profile_likelihoods(i,:))+(0.5*chi1)])    
end

ranges = zeros(9,3);
for i=1:9
   range = profiles(1,profile_likelihoods(i,:) < min(profile_likelihoods(i,:))+(0.5*chi1),i);
   ranges(i,1) = exp(min(range));
   ranges(i,2) = exp(max(range));
   ranges(i,3) = true_values(i);
end