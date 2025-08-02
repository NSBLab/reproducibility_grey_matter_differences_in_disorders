function multipleAxes(mat1,label_1,label_2,var)
%This function  creates 2 axis in 1 colorbar
%Variables used-
%mat1 - Input matrix
%label_1& label_2 = Axis labels
%var - relation between axes, say var = 5, if axis 2 = 5* axis 1
%'wid': It changes the width of colorbar to fit the axis labels
%0.8 will be ideal for most of the situations
%To change the orientation of text, add it in 'ylabel' step
%Please give your feedback to prasob@gmail.com
%Change imagesc to mesh or other command according to your application
%This code is modified version of 
%https://in.mathworks.com/matlabcentral/answers/475762-colormap-utility-two-axes-in-colorbar
wid = 0.8;
figure,imagesc(mat1);
constant1 = 2; % Example, 2 axes are scaled by 2. Enter relation between axes here
hAx=gca;                     % save axes handle main axes
hCB=colorbar;                % add colorbar, save its handle
hNuCBAx=axes('Position',hCB.Position,'color','none');  % add mew axes at same posn
hNuCBAx.XAxis.Visible='off'; % hide the x axis of new
posn=hAx.Position;           % get main axes location
posn(3)=wid*posn(3);         % cut down width
hAx.Position=posn;           % resize mmain axes to make room for labels colorbar
hCB.Position=hNuCBAx.Position;  % put the colorbar back to overlay second axeix
min1 = min(mat1(:)); max1= max(mat1(:));
ymin = min1*var; ymax =max1*var;%connection equation between axes
hNuCBAx.YLim=[ymin ymax];       % alternate scale limits new axis
ylabel(hCB,label_1,'Rotation',90,'FontWeight','bold','VerticalAlignment','middle')
ylabel(hNuCBAx,label_2,'Rotation',90,'FontWeight','bold','VerticalAlignment','middle')
hCB.Position=hNuCBAx.Position;  % put the colorbar back to overlay second axeix
  end