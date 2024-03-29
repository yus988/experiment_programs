%% importTensionInput.m のmaster

tNegaPosi = 1;
cellGather = cell(1,1);% save each result Cells
recTimes = 1; % index of gatherCell

for ampLoop = 1:2 
    if ampLoop == 1
        ampType = 'HapbeatAmp';
    elseif ampLoop == 2
        ampType = 'Lepy';
    end
    cd (ampType)
    
    for actLoop = 1:2 % loop with actuator type
        if actLoop == 1
            actType = 'Hapbeat';
            tNegaPosi = 1;
        elseif actLoop == 2
            actType = 'DCmotor';
            tNegaPosi = -1;
        end
            cd (actType)    
            
        for exeLoop = 1:3 % loop execute times
            cd(num2str(exeLoop))
            importTensionInput
            cellGather{recTimes,exeLoop} = cell2mat(resultCell);
            
            cd ..
        end % end of exeLoop
        recTimes = recTimes + 1;
        cd ..

    end % end of actLoop
   
    cd ..
end % end of ampLoop


%% Figure out Mean and Std
% Hamp Hapbeat, DCmotor, Lepy Hapbeat, DCmotorの順

cellPlot = cell(1,1); % inner array:  Hz, RMS mean, std, THD mean, std, phase mean, std
tmpRMS = zeros(1,1);
tmpTHD = zeros(1,1);
tmpDEG= zeros(1,1);

v01rms = 0.1 /(2*sqrt(2));
v02rms = 0.2 /(2*sqrt(2));

for posLoop = 1:4
    if posLoop == 1 || posLoop == 3
%         vol = v02rms;
           vol = 1;
    elseif posLoop == 2 || posLoop ==4
%         vol = v01rms;
            vol = 2;
    end
        
    for i = 1 : size(cellGather{1,1},1) % row loop inside of the cell
        for exeLoop = 1:3
            tmpRMS(exeLoop,1) =  cellGather{posLoop,exeLoop}(i,2) * vol;
            tmpTHD(exeLoop,1) =  cellGather{posLoop,exeLoop}(i,3);
            tmpDEG(exeLoop,1) =  cellGather{posLoop,exeLoop}(i,4);
        end
        cellPlot{posLoop,1}(i,1) = cellGather{posLoop,1}(i,1);
        cellPlot{posLoop,1}(i,2) = mean(tmpRMS);
        cellPlot{posLoop,1}(i,3) = std(tmpRMS);
        cellPlot{posLoop,1}(i,4) = mean(tmpTHD);
        cellPlot{posLoop,1}(i,5) = std(tmpTHD);
        phaseDelay = mean(tmpDEG);
        if mean(tmpDEG) > 0
            phaseDelay = mean(tmpDEG) - 360;
        end
        cellPlot{posLoop,1}(i,6) = phaseDelay;
        cellPlot{posLoop,1}(i,7) = std(tmpDEG);    
    end
end

%% 
%% Hap/Lep mean/thd グラフの描画
close all

% inner array:  Hz, RMS mean, std, THD mean, std, phase mean, std
arrHampHap = cellPlot{1,1};
arrHampDCm = cellPlot{2,1};
arrLepyHap = cellPlot{3,1};
arrLepyDCm = cellPlot{4,1};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% yyaxis left; % activate left y axis
% configure left axis

%%% common settings for figures

lineStyle = '-';
marker = 'o';
figFontSize = 15;
figure
arrLegend = {'Hapbeat HAmp','DC motor HAmp','Hapbeat Lepy','DC motor Lepy'};
x0=0;
y0=0;
width=1080;
height=360;
%%%

hold on;
% arrHampHap
plotArr = arrHampHap;
lineColor = 'red';
errorbar(plotArr(:,1), plotArr(:,2),plotArr(:,3),'Marker',marker, 'LineStyle', lineStyle, ...
    'MarkerFaceColor', lineColor,'color',lineColor);

% arrHampDCm
plotArr = arrHampDCm;
lineColor = 'blue';
errorbar(plotArr(:,1), plotArr(:,2),plotArr(:,3),'Marker',marker, 'LineStyle', lineStyle, ...
    'MarkerFaceColor', lineColor,'color',lineColor);
% arrLepyHap
plotArr = arrLepyHap;
lineColor = '#ff8c00';
errorbar(plotArr(:,1), plotArr(:,2),plotArr(:,3),'Marker',marker, 'LineStyle', lineStyle, ...
    'MarkerFaceColor', lineColor,'color',lineColor);

% arrLepyDCm
plotArr = arrLepyDCm;
lineColor = '#4b0082';
errorbar(plotArr(:,1), plotArr(:,2),plotArr(:,3),'Marker',marker, 'LineStyle', lineStyle, ...
    'MarkerFaceColor', lineColor,'color',lineColor);

ylabel({'RMS Value of Tension (N)';'from 0.2 V_{pp} input'});

set(gca,'XScale','log')
set(gca,'FontSize',figFontSize)
legend(arrLegend);
xlabel('Frequency (Hz)');

grid on
set(gcf,'position',[x0,y0,width,height])
hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% yyaxis right; % activate left y axis
figure
lineStyle = '-';
marker = '*';

% hap thd
plotArr = arrHampHap;
hold on;
lim = (15:32);
lineColor = 'red';
errorbar(plotArr(:,1), plotArr(:,4),plotArr(:,5),'Marker',marker, 'LineStyle', lineStyle, ...
    'MarkerFaceColor', lineColor,'color',lineColor);

% lep thd
plotArr = arrHampDCm;
lineColor = 'blue';
errorbar(plotArr(:,1), plotArr(:,4),plotArr(:,5),'Marker',marker, 'LineStyle', lineStyle, ...
    'MarkerFaceColor', lineColor,'color',lineColor);
% arrLepyHap
plotArr = arrLepyHap;
lineColor = '#ff8c00';
errorbar(plotArr(lim,1), plotArr(lim,4),plotArr(lim,5),'Marker',marker, 'LineStyle', lineStyle, ...
    'MarkerFaceColor', lineColor,'color',lineColor);

% arrLepyDCm
plotArr = arrLepyDCm;
lineColor = '#4b0082';
errorbar(plotArr(lim,1), plotArr(lim,4),plotArr(lim,5),'Marker',marker, 'LineStyle', lineStyle, ...
    'MarkerFaceColor', lineColor,'color',lineColor);

% configure left axis
ylabel('THD (dB)');

set(gca,'XScale','log')
set(gca,'FontSize',figFontSize)

legend(arrLegend);
xlabel('Frequency (Hz)');
grid on
set(gcf,'position',[x0,y0,width,height])

hold off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% saveas(gcf,strcat('gainValue','.png'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% phase dealy
figure
hold on;
lim = (1:32);
% arrHampHap
plotArr = arrHampHap;
lineColor = 'red';
errorbar(plotArr(lim,1), plotArr(lim,6),plotArr(lim,7),'Marker',marker, 'LineStyle', lineStyle, ...
    'MarkerFaceColor', lineColor,'color',lineColor);

% arrHampDCm
plotArr = arrHampDCm;
lineColor = 'blue';
errorbar(plotArr(lim,1), plotArr(lim,6),plotArr(lim,7),'Marker',marker, 'LineStyle', lineStyle, ...
    'MarkerFaceColor', lineColor,'color',lineColor);
%%%%%%
lim = (15:32);
% arrLepyHap
plotArr = arrLepyHap;
lineColor = '#ff8c00';
errorbar(plotArr(lim,1), plotArr(lim,6),plotArr(lim,7),'Marker',marker, 'LineStyle', lineStyle, ...
    'MarkerFaceColor', lineColor,'color',lineColor);
% arrLepyDCm
plotArr = arrLepyDCm;
lineColor = '#4b0082';
errorbar(plotArr(lim,1), plotArr(lim,6),plotArr(lim,7),'Marker',marker, 'LineStyle', lineStyle, ...
    'MarkerFaceColor', lineColor,'color',lineColor);

ylabel('Phase delay (deg)');
ylim([-360 0]);
set(gca,'XScale','log')
set(gca,'FontSize',figFontSize)
legend(arrLegend);
xlabel('Frequency (Hz)');
grid on
set(gcf,'position',[x0,y0,width,height])

hold off


