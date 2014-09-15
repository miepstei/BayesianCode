function nudgeLegend(hleg,lineDX,linePos,textPos)

% function nudgeLegend(hleg,lineDX,linePos,textPos)
%
% Dumb function used to correct legend location and appearance
%
% INPUTS
% hleg = handle of legend that you want to nudge
% lineDX = amount to increase line length (negative values decrease)
% linePos = moves lines in x and y directions size(linePos) = [1,2]
% linePos = moves text in x and y directions size(textPos) = [1,2]
%

hch=get(hleg,'children');

numChil = length(hch);

% shrink legend lines in the x direction
for k=1:numChil
  if isprop(hch(k),'XData')
    XData = get(hch(k),'XData');
    YData = get(hch(k),'YData');
     if length(XData)==2
      set(hch(k),'XData',[XData(1)+linePos(1),XData(2)+lineDX+linePos(1)]);
      set(hch(k),'YData',[YData(1)+linePos(2),YData(2)+linePos(2)]);
     end
  end
end

% move text
for k=1:numChil
  if isprop(hch(k),'position')
    posCur = get(hch(k),'position');
    set(hch(k),'position',posCur+[textPos,0]);
  end
end