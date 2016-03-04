function [ ] = bgprint(ofn,type,width,height,varargin)

if ~exist('type','var') || isempty(type)    
    type = '-depsc2';
end
if type(1) ~= '-'
    type = strcat('-',type);
end
if type(2) ~= 'd'
    type = ['-d',type(2:end)];
end

if ~exist('width','var') || isempty(width)
    width = 12;
end
if ~exist('height','var') || isempty(height)
    height = 12;
end

% Normally paperposition is [0.25,0.25,8.0,10.5] (tall) or
%                           [0.25,0.25,10.5,8.0] (wide)
% Set to width x height inches to make background, crontab image bigger than 
% default image in terminal environment (without a graphics env).
set(gcf,'PaperPosition',[0.25,0.25,width,height]);
% Now set the paper size - a little bigger than the paper position
set(gcf,'PaperSize',[0.25+width+0.25, 0.25+height+0.25]);
% % Set the renderer
% set(gcf,'Renderer','painters');

% Make the call to print - pass any extra arguments to print thru
% varargin.  Will work even if varargin is empty ({ })
feval('print',type,varargin{:},ofn)

