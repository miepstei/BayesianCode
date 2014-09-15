function Plot1By2Demo(t,s1,s2,varargin)

% function Plot1By2Demo(t,s1,s2,varargin)
%
% Shell function for plotting a figure with two sets of axes side
% by side.
%
% INPUT
% optional: filename - name and location to export .eps file of
%           figure. Should not include the extension.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Settings

% Fonts
FontName = 'Times';
FSsm = 7; % small font size
FSmed = 10; % medium font size
FSlg = 11; % large font size

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
figure1 = figure;

PP = [0,0,14,10]; % Here I set the paper position in centimeters
PS = PP(end-1:end); % paper size in centimeters

set(figure1,'paperpositionmode','manual','paperposition', ...
        PP,'papersize',PS, 'paperunits','centimeters');

if length(varargin)>0
  % So the figure is the same size on the screen as when it is printed:
  pu = get(gcf,'PaperUnits');
  pp = get(gcf,'PaperPosition');
  set(gcf,'Units',pu,'Position',pp)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Axis position

left = 0.12; % space on LHS of figure
right = 0.02; % space on RHS of figure
top = 0.05; % space above figure
bottom = 0.1;% space below figure
hspace = 0.07;

height = (1-top-bottom); % height of axis
width = (1-left-right-hspace)/2; % width of axis

across = [hspace+width,0,0,0];
pos1 = [left,1-top-height,width,height]; % position of axis
pos2 = pos1+across;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting

% First axis
ax1 = axes('position',pos1); % produce axis
hold on
ylabel('y','fontname',FontName,'FontSize',FSmed) % add axis labels
xlabel('omega = 2 pi c/lambda','fontname',FontName,'FontSize',FSmed)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Place your plots for the first axis here

plot(t,s1,'-','linewidth',LWthin)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		       
% Second axis
ax2 = axes('position',pos2); % produce second axis
hold on
%ylabel('ylabel','fontname',FontName,'FontSize',FSmed) % add axis labels
xlabel('omega = 2 pi c/lambda','fontname',FontName,'FontSize',FSmed)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Place your plots for the second axis here

plot(t,s2,'-','linewidth',LWthin)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tweaking axis to make them look nice

% First axis
set(ax1,'TickDir','out'); % alter the direction of the tick marks
set(ax1,'FontName',FontName,'FontSize',FSsm) % set the font name and size
set(ax1,'box','off') % turns the figure bounding box off
set(ax1,'layer','top') % stops problems with lines being plotted on
                       % top of the axis lines

		       
% Same for second axis		   
set(ax2,'TickDir','out'); 
set(ax2,'FontName',FontName,'FontSize',FSsm)                                    
set(ax2,'box','off') 
set(ax2,'layer','top')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exporting

if length(varargin)>0 % if the user supplies a file name...
  filename=[varargin{1},'.eps'];
  % choose the painters renderer, without cropping 
  print(figure1,'-depsc','-painters',filename,'-loose');
  
  % open the eps in ghostview
  %str = ['! gv ',filename,'&'];
  %eval(str)
end