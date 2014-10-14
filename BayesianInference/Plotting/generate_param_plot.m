function fig=generate_param_plot(param_no,rows,cols,param_samples,param_names,varargin)
    plotComparisonParams = 0;
    if ~isempty(varargin)
        %do we want a comparitor set of params on the graph?
        paramComparison = varargin{1};
        plotComparisonParams = 1;
    end

    fig=figure('Visible','off');
    for i=1:param_no
        h=subplot(cols,rows,i);
        hist (param_samples(:,i),20)
        title(sprintf('$%s$',param_names{i}),'Interpreter','latex')
        
        limits = ylim;
        if plotComparisonParams
            line([paramComparison(i),paramComparison(i)],[limits(1),limits(2)],'LineStyle','--','Color','r')
        end
    end
end


