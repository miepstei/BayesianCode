function PlotNByM(fig,N,M,hastitle,axisFontSize,varargin)

% function PlotNByM(varargin)
%
% Shell function for plotting a subplot figure with N rows and M columns
% by side. 
% Consider altering the lines marked: ***
%
% INPUT
% optional: filename - name and location to export .eps file of
%           figure. Should not include the extension.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Settings

% Fonts
FontName = 'TimesNewRoman';
FSsm = axisFontSize; % small font size for axis labels
%FSmed = 9; % medium font size
%FSlg = 11; % large font size

% Line widths
LWthick = 2; % thick lines
LWthin = 1; % thin lines

% Colors
col1 = [0,0,0];
col2 = [1,0,0];
col3 = [0,0,1];
col4 = [1,3/4,0];
col5 = [0,1,3/4];
col6 = [3/4,0,1];
col7 = [3/4,1,0];
col8 = [0,3/4,1];
col9 = [1,0,3/4];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set figure size
figure1 = fig;

if length(varargin)>1
  % desperate times - set the paper size to change matlabs shoddy exponential scaling:
    PP = [0,0,varargin{2},varargin{3}];   
else
    PP = [0,0,14,10]; % *** paper position in centimeters
      
end

PS = PP(end-1:end); % paper size in centimeters
set(figure1, 'paperunits','centimeters')
set(figure1,'paperpositionmode','manual','paperposition', ...
        PP,'papersize',PS);

if length(varargin)>0
  % So the figure is the same size on the screen as when it is printed:
  pu = get(figure1,'PaperUnits');
  pp = get(figure1,'PaperPosition');
  set(figure1,'Units',pu,'Position',pp)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Axis position

left = 0.1; % space on LHS of figure
right = 0.02; % space on RHS of figure
top = 0.0; % space above figure
bottom = 0.1;% space below figure
hspace = 0.15/min(M,N);

if hastitle
    vspace = 0.25/min(N,M);
else
    vspace = 0.15/min(N,M);
end

height = ((1-top-bottom)/N)-vspace; % height of axis
width = ((1-left-right)/M)-hspace; % width of axis

%basically need some code here which calulates N*M positions
pos=zeros(N,M,4);

for i=1:N
    for j=1:M
        pos(i,j,:) =  [left+((width+hspace)*(j-1)),1-top-((height+vspace)*(i)),width,height];
        fprintf('%8.2f,',pos(i,j,:));fprintf('\n');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting

% First axis
%ax1 = axes('position',pos1); % produce axis
AX=get(figure1,'children');

if length(AX) < N*M
    %pad out axis vector to keep shape
    AX(length(AX)+1:N*M) = NaN;
end

%may need to look at this commentout
AX=reshape(flip(AX),N,M);

for i=1:N
    for j=1:M
        if isa(fig.Children(1),'matlab.graphics.axis.Axes')  %ignore "dummy" axes
            set(AX(i,j),'position',reshape(pos(i,j,:),1,4));
            set(AX(i,j),'TickDir','out'); % alter the direction of the tick marks
            set(AX(i,j),'FontName',FontName,'FontSize',FSsm) % set the font name and size
            set(AX(i,j),'box','off') % turns the figure bounding box off
            set(AX(i,j),'layer','top') % stops problems with lines being plotted on
                           % top of the axis lines
        end
    end
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exporting

if length(varargin)>0 % if the user supplies a file name...
  filename=[varargin{1},'.eps'];
  % choose the painters renderer, without cropping 
  print(figure1,'-depsc','-painters',filename,'-loose');
  
  % open the eps in ghostview
  str = ['! gv ',filename,'&'];
  eval(str)
end