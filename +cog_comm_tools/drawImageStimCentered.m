% Draws image data in 'imageStim' to window centered,  BUT DOES NOT FLIP SCREEN.
%
% Remember: TOP LEFT CORNER OF SCREEN is x=0, y=0.
%
% Author: Brian Armstrong
%
function drawImageStimCentered(window, imageStim)
    cog_comm_tools.drawImageDataAtDestRect(window, imageStim.imageData, []);