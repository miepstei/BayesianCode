function Plot1By1(fig,standardise,varargin)

% function Plot1By1(varargin)
%
% Shell function for plotting a figure with one set of axes.
% Consider altering the lines marked: ***
%
% INPUT
% optional: filename - name and location to export .eps file of
%           figure. Should not include the extension (e.g. no .eps
%           extension)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Settings

% Fonts
FontName = 'TimesNewRoman';
FSsm = 7;
FSmed = 20;
FSlg = 14;

% Line widths
LWthick = 2;
LWthin = 1;

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

PP = [0,0,8,6]; %*** paper position in centimeters
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

height = (1-top-bottom); % height of axis
width = 1-left-right; % width of axis

pos1 = [left,1-top-height,width,height]; % position of axis

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting

AX=get(gcf,'children');
if standardise
    for i=1:length(AX) %plotyy
    
        set(AX(i),'position',pos1);
        hold on
        set(AX(i),'TickDir','out'); % alter the direction of the tick marks
    	set(AX(i),'FontName',FontName,'FontSize',FSsm) % set the font name
                                                 % and size

        set(get(AX(i),'xlabel'),'FontSize',FSmed)
        set(get(AX(i),'ylabel'),'FontSize',FSmed)
    end
else
    %keep the inset as is
    set(AX(2),'position',pos1);
    hold on
    set(AX(2),'TickDir','out'); % alter the direction of the tick marks
    set(AX(2),'FontName',FontName,'FontSize',FSsm) % set the font name
                                                 % and size

    set(get(AX(2),'xlabel'),'FontSize',FSmed)
    set(get(AX(2),'ylabel'),'FontSize',FSmed)    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
box off % turns the figure bounding box off
set(gca,'layer','top') % tops problems with lines being plotted on
                       % top of the axis lines
		       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exporting

if length(varargin)>0 % if the user supplies a file name
  filename=[varargin{1},'.eps'];
  
  % choose the painters renderer, without cropping 
  print(figure1,'-depsc','-painters',filename,'-loose');
  
  % open the eps in ghostview
  str = ['! gv ',filename,'&'];
  eval(str)
end