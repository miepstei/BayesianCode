function Plot1By2(fig,varargin)

% function Plot1By2(varargin)
%
% Shell function for plotting a figure with two sets of axes side
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
FSsm = 20; % small font size for axes labels
FSmed = 20; % medium font size
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
figure1 = fig;

PP = [0,0,14,10]; % *** paper position in centimeters
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

left = 0.1; % space on LHS of figure
right = 0.02; % space on RHS of figure
top = 0.05; % space above figure
bottom = 0.1;% space below figure
hspace = 0.07;

height = (1-top-bottom); % height of axis
width = ((1-left-right)/2)-hspace; % width of axis

across = [hspace+width,0,0,0];

pos1 = [left,1-top-height,width,height]; % position of axis
pos2 = pos1+across;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting

% First axis
%ax1 = axes('position',pos1); % produce axis
AX=get(gcf,'children');
set(AX(1),'position',pos1);
hold on
set(get(AX(1),'xlabel'),'FontSize',FSmed)
set(get(AX(1),'ylabel'),'FontSize',FSmed)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *** Place your plots for the first axis here




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		       
% Second axis
%ax2 = axes('position',pos2); % produce second axis
set(AX(2),'position',pos2);
hold on
set(get(AX(2),'xlabel'),'FontSize',FSmed)
set(get(AX(2),'ylabel'),'FontSize',FSmed)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *** Place your plots for the second axis here




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tweaking axis to make them look nice

% First axis
set(AX(1),'TickDir','out'); % alter the direction of the tick marks
set(AX(1),'FontName',FontName,'FontSize',FSsm) % set the font name and size
set(AX(1),'box','off') % turns the figure bounding box off
set(AX(1),'layer','top') % stops problems with lines being plotted on
                       % top of the axis lines

		       
% Same for second axis		   
set(AX(2),'TickDir','out'); 
set(AX(2),'FontName',FontName,'FontSize',FSsm)                                    
set(AX(2),'box','off') 
set(AX(2),'layer','top')

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