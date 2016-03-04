clear all
close all

START_TIME=now;

% Specify the baseDirectory
BaseDir = fullfile('/Volumes','Extras','RealTime','Data','Radials');
Ext = 'ruv';
debug = true;
% Number of latest files to keep, delete all the rest from the hot
% directory after copying into the proper yyyy_mm folder.
Num2Keep = 24*3;

sites={'BIGC','BML1','BMLR','BRKY','COMM','CRIS','DRAK','FORT','GCVE', ...
       'GCYN','MLML','MONT','NPGS','PAFS','PESC','PILR','PPIN','PREY', ...
       'PSLR','PSUR','RAGG','RTC1','SAUS','SCRZ','SLID','TRES'};

types = {'RDLi','RDLm'};

for i = 1:numel(sites)
    for j = 1:numel(types)
        fprintf('Processing: %s %s\n',sites{i},types{j})
        hotClean(BaseDir,sites{i},types{j},Num2Keep,Ext,debug);
    end
end

END_TIME = now;
fprintf('hotClean_driver.m complete ...\n');
fprintf('Start Time: %s,  End Time: %s\n', ...
    datestr(START_TIME,0),datestr(END_TIME,0));

disp('Exiting')
exit;
