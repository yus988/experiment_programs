%% csvデータのインポートおよびラベル用データ生成

% 起動電圧の平均、標準偏差を求める
% 出力はresultCell, 各周波数事のTHD, 入力信号に対するdelay, 

clear
close all

Fs = 1e4;%サンプル周波数
% Fs = 10e3;%サンプル周波数
t = 0:1/Fs:1;

%加速度センサの感度
V2N = 0.01178; %力センサ5916, Hapbeatの時はプラス
% V2N = - 0.01178; %力センサ5916, DCモーターの時はマイナス
% actType =  dir('*.txt'); % vp2.txt or hapbeat.txt
% isHapbeat = strcmp(actType.name,'hapbeat.txt'); %Hapeatの場合

% {→ 1,2,3回目, ↓20,80,140Hz}, (回数, rms)
cellHapUpRMS = cell(1,1);  % Hap Up
cellDCmUpRMS = cell(1,1);  % DCm Up
cellHapDwRMS = cell(1,1);  % Hap Dw 
cellDCmDwRMS = cell(1,1);  % Dcm Dw

for actType = 1:4
    if actType == 1 % HapUp
        actDir = 'HapUp';
        isHapbeat = 1;
    elseif actType == 2  % HapDw
        actDir = 'HapDw';
        isHapbeat = 1;
    elseif actType == 3  % DCmUp
        actDir = 'DcmUp';
        isHapbeat = 0;
    elseif actType == 4  % DCmDw
        actDir = 'DcmDw';
        isHapbeat = 0;
    end
    cd (actDir);
    
    for freqLoop = 1:3 %測定周波数ごとのループ
        if freqLoop == 1
            dirName = '20Hz';
        elseif freqLoop ==2
            dirName = '80Hz';
        elseif freqLoop == 3
            dirName = '140Hz';
        end

        cd (dirName);

        for exeLoop = 1:3
            cd (num2str(exeLoop));

            nharm = 6;%thdの高調波数
            list = dir('*.csv');
            %10列2行のセルを作成。1列目にy軸加速度の行列、2列目に力センサ
            %（できれば1-の連番にして一々ファイル名を変更しないでも良いようにしたい
            inputVol = 0.5; %入力電圧Vpp

            numFiles = length(list);
            Mx = cell(numFiles,2);% インポート用のセル
            RMS_column = zeros(1,4);% RMS値格納用
            resultCell = cell(4,1);

            % csvデータのインポートおよびラベル用データ生成
            for i = 1:numFiles
                Mx{i,1}= csvread(list(i).name,21,1,[21,1,10020,2]);
                % オフセット除去（すべての要素から平均値を引く）
                Mx{i,2}(:,1) = ( Mx{i,1}(:,1) - mean(Mx{i,1}(:,1)) ) / V2N; %下に引っ張った時を正に（標準では負）
                Mx{i,2}(:,2) = ( Mx{i,1}(:,2) - mean(Mx{i,1}(:,2)) );

                % timetable を各列ごとに追加
                Mx{i,3} = timetable(Mx{i,2}(:,1), Mx{i,2}(:,2),'SampleRate',Fs);
                Mx{i,3}.Properties.VariableNames{'Var1'}='T'  ;
                Mx{i,3}.Properties.VariableNames{'Var2'}='In' ;

                for k = 0:1 % ch1~3各Hz,RMS,THDの記録
                    [thd_db, ~, harmfreq] = thd(Mx{i,2}(:,1+k), Fs, nharm);
                    %             thd(Mx{8,2}(:,1), Fs, nharm); % 個別のTHDを見たいとき
                    Mx{i,6+3*k} = harmfreq(1,1);
                    %         Mx{i,7+3*k} = rms((Mx{i,2}(:,1+k))) - 0.01 ;
                    Mx{i,7+3*k} = rms((Mx{i,2}(:,1+k))) ;
                    RMS_column(i,k+1) = Mx{i,7+3*k}; %  RMS値格納用行列
                    Mx{i,8+3*k} = thd_db;
                    if k==0
                        resultCell{i,2} = thd_db;
                    end
                end
                %入力電圧の周波数を取得し記録（harmfreqで高調波が分かる、その始めの値を利用)
                [thd_db, harmpow, harmfreq] = thd(Mx{i,1}(:,2), Fs, nharm);
                Mx{i,4} = harmfreq(1,1);
                resultCell{i,1} = round(harmfreq(1,1));

                % FGから入力電圧のVppを求める。2倍は負の値を考慮
                Vin = 2*sqrt(2)*rms((Mx{i,1}(:,2)));
                Mx{i,5} = Vin;

                if actType == 1 % HapUp
                    cellHapUpRMS{freqLoop,exeLoop}(i,1) = Mx{i,7}; % 張力RMS
                    cellHapUpRMS{freqLoop,exeLoop}(i,2) = Mx{i,10}; % モーター両端RMS
                elseif actType == 2  % HapDw
                    cellHapDwRMS{freqLoop,exeLoop}(i,1) = Mx{i,7}; % 張力RMS
                    cellHapDwRMS{freqLoop,exeLoop}(i,2) = Mx{i,10}; % 張力RMS
                elseif actType == 3  % DCmUp
                    cellDCmUpRMS{freqLoop,exeLoop}(i,1) = Mx{i,7}; % 張力RMS
                    cellDCmUpRMS{freqLoop,exeLoop}(i,2) = Mx{i,10}; % 張力RMS
                elseif actType == 4  % DCmDw
                    cellDCmDwRMS{freqLoop,exeLoop}(i,1) = Mx{i,7}; % 張力RMS
                    cellDCmDwRMS{freqLoop,exeLoop}(i,2) = Mx{i,10}; % 張力RMS
                end
                
            end
            % 行末に説明を追加
            Mx{i+1,1} = '生データ';
            Mx{i+1,2} = 'オフセット除去後';
            Mx{i+1,3} = 'タイムテーブル';
            Mx{i+1,4} = '周波数';
            Mx{i+1,5} = '測定電圧（計算後）';
            resultCell{i+1,1} ='周波数';
            resultCell{i+1,2} = 'THD';

            for k=0:1
                Mx{i+1,6+3*k} = strcat('ch', num2str(k+1), 'Hz');
                Mx{i+1,7+3*k} = strcat('ch', num2str(k+1), 'RMS');
                Mx{i+1,8+3*k} = strcat('ch', num2str(k+1), 'THD');
            end

    %         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %         % 最低張力検証用
    %         % arr20Hz = zeros(size(Mx,1),2);
    %         arr20Hz = zeros(1,2);
    %         arr80Hz = zeros(1,2);
    %         arr140Hz = zeros(1,2);
    %         arrRMS = zeros(1,2);
    % 
    %         for i = 1:size(Mx,1)-1
    %             tmpTensionVol = Mx{i,7} * V2N; % 張力RMS (電圧表示）
    %             arrRMS(i,1)=Mx{i,10}; % 入力電圧RMS
    %             arrRMS(i,2)=tmpTensionVol; % 張力RMS
    %         end
    % 
    %         figure
    %         subplot(2,1,1)
    %         plot(arrRMS(:,1),arrRMS(:,2),'Marker','o', ...
    %             'MarkerFaceColor', 'blue','color','blue');
    %         subplot(2,1,2)
    %         plot(arrRMS(:,2),'Marker','o', ...
    %             'MarkerFaceColor', 'blue','color','blue');
    %         saveas(gcf,'result.png');
    %         save;

            cd ..
        end % ここまで、1,2,3 dir内の処理
        cd .. % ここまで、20Hz, 80Hz, 140Hz dir内の処理
    end
    
    cd ..

end

%% HapAmp 平均、標準偏差の算出
tmpHapUpRMS = zeros(1,1);
tmpHapDwRMS = zeros(1,1);
tmpDcmUpRMS = zeros(1,1);
tmpDcmDwRMS = zeros(1,1);

% 中の行列：空、T mean, T std, V mean, V std
cellPlot = cell(1,1); % →1:HapUp,2:HapDw,3:DCmUp,4:DCmDw

cellHapUpMean = cell(1,1);
cellHapDwMean = cell(1,1);
cellDCmUpMean = cell(1,1);
cellDCmDwMean = cell(1,1);

for freqLoop = 1:size(cellHapUpRMS,1) % 周波数別, 縦方向
    % matlabの関数を使うため、tmp行列に格納
    for i = 1: size(cellHapUpRMS{1,1},1)
        for exeLoop = 1 : size(cellHapUpRMS,2)
            tmpHapUpRMS(exeLoop,1) = cellHapUpRMS{freqLoop,exeLoop}(i,1);
            tmpHapDwRMS(exeLoop,1) = cellHapDwRMS{freqLoop,exeLoop}(i,1);
            tmpDcmUpRMS(exeLoop,1) = cellDCmUpRMS{freqLoop,exeLoop}(i,1);
            tmpDcmDwRMS(exeLoop,1) = cellDCmDwRMS{freqLoop,exeLoop}(i,1);
        end
        cellPlot{freqLoop,1}(i,2) = mean(tmpHapUpRMS);
        cellPlot{freqLoop,1}(i,3) = std(tmpHapUpRMS);
        
        cellPlot{freqLoop,2}(i,2) = mean(tmpHapDwRMS);
        cellPlot{freqLoop,2}(i,3) = std(tmpHapDwRMS);
        
        cellPlot{freqLoop,3}(i,2) = mean(tmpDcmUpRMS);
        cellPlot{freqLoop,3}(i,3) = std(tmpDcmUpRMS);
        
        cellPlot{freqLoop,4}(i,2) = mean(tmpDcmDwRMS);
        cellPlot{freqLoop,4}(i,3) = std(tmpDcmDwRMS);
    end
end


for freqLoop = 1:size(cellHapUpRMS,1) % 周波数別, 縦方向
    % matlabの関数を使うため、tmp行列に格納
    for i = 1: size(cellHapUpRMS{1,1},1)
        for exeLoop = 1 : size(cellHapUpRMS,2)
            tmpHapUpRMS(exeLoop,1) = cellHapUpRMS{freqLoop,exeLoop}(i,2);
            tmpHapDwRMS(exeLoop,1) = cellHapDwRMS{freqLoop,exeLoop}(i,2);
            tmpDcmUpRMS(exeLoop,1) = cellDCmUpRMS{freqLoop,exeLoop}(i,2);
            tmpDcmDwRMS(exeLoop,1) = cellDCmDwRMS{freqLoop,exeLoop}(i,2);
        end
        cellPlot{freqLoop,1}(i,4) = mean(tmpHapUpRMS);
        cellPlot{freqLoop,1}(i,5) = std(tmpHapUpRMS);
        
        cellPlot{freqLoop,2}(i,4) = mean(tmpHapDwRMS);
        cellPlot{freqLoop,2}(i,5) = std(tmpHapDwRMS);
        
        cellPlot{freqLoop,3}(i,4) = mean(tmpDcmUpRMS);
        cellPlot{freqLoop,3}(i,5) = std(tmpDcmUpRMS);
        
        cellPlot{freqLoop,4}(i,4) = mean(tmpDcmDwRMS);
        cellPlot{freqLoop,4}(i,5) = std(tmpDcmDwRMS);
    end
end

% for i = 1:21
%         % Hap up
%         cellPlot{1,1}(i,1) = 0.60 + (i-1) * 0.01; % 20Hz 
%         cellPlot{2,1}(i,1) = 0.70 + (i-1) * 0.01; % 80Hz 
%         cellPlot{3,1}(i,1) = 0.80 + (i-1) * 0.01; % 140Hz 
% 
%         % DCm up
%         cellPlot{1,3}(i,1) = 0.20 + (i-1) * 0.01; % 20Hz 
%         cellPlot{2,3}(i,1) = 0.30 + (i-1) * 0.01; % 80Hz 
%         cellPlot{3,3}(i,1) = 0.30 + (i-1) * 0.01; % 140Hz 
% 
% end
% % Hap dw
% cellPlot{1,2}(:,1) = flip(cellPlot{1,1}(:,1));
% cellPlot{2,2}(:,1) = flip(cellPlot{2,1}(:,1));
% cellPlot{3,2}(:,1) = flip(cellPlot{3,1}(:,1));
% % DCm dw
% cellPlot{1,4}(:,1) = flip(cellPlot{1,3}(:,1));
% cellPlot{2,4}(:,1) = flip(cellPlot{2,3}(:,1));
% cellPlot{3,4}(:,1) = flip(cellPlot{3,3}(:,1));
% close all


%%

close all;
lineStyle = '-';
marker = 'o';
for typeLoop = 1:4
    if typeLoop == 1 
        typeTxt = 'Hapbeat Increment';
        act = 'Hapbeat';
    elseif typeLoop == 2
        typeTxt = 'Hapbeat Decrement';
        act = 'Hapbeat';
    elseif typeLoop == 3
        typeTxt = 'DC motor Increment';
        act = 'DC motor';
    elseif typeLoop == 4
        typeTxt = 'DC motor Decrement';
        act = 'DC motor';
    end
    figure 
    hold on
    for freqLoop = 1:3
        if freqLoop == 1
            lineColor =  '#FFA500'; %オレンジ
            freqText = '20Hz';
        elseif freqLoop ==2
            lineColor = '#0000FF'; %青色
            freqText = '80Hz';
        elseif freqLoop == 3
            lineColor = '#FF00FF'; %マゼンタ
            freqText = '140Hz';
        end
        markerFaceColor = 'black';
        arr = cellPlot{freqLoop,typeLoop};
        arr(:,2) = arr(:,2) * 1000;
        arr(:,3) = arr(:,3) * 1000;
        arr(:,4) = arr(:,4) * 1000 / 1.3; % 電流 (mA) に変換 i = v / r
        arr(:,5) = arr(:,5) * 1000/ 1.3; % 
        errorbar(arr(:,4),arr(:,2), arr(:,3),arr(:,3),arr(:,5),arr(:,5),...
            'Marker',marker,'LineStyle', lineStyle,'MarkerFaceColor', markerFaceColor, ...
            'MarkerSize',4,'color',lineColor);
    end
   
        ax = gca;
        ax.YLim = [0 100];
        xlabel('RMS value of motor current  (mA)');
        ylabel('RMS value of tension (mN)');
        title(typeTxt);
        legend(strcat(act,' 20 Hz'), strcat(act,' 80 Hz'),strcat(act,' 140 Hz'));
        set(gca,'FontSize',14);
        saveas(gcf,strcat(typeTxt,'.png'));
    hold off
end


%             %%
%             
%             
%             
% freq = 1;
% errorbar(cellPlot{freq,1}(:,1), cellHapUpMean{freq,1}(:,1), cellHapUpMean{freq,1}(:,2)...
%     ,'Marker',marker,'LineStyle', lineStyle,'MarkerFaceColor', lineColor, ...
%     'MarkerSize',4,'color',lineColor);
% % HapbeatUp 80Hz
% freq = 2;
% errorbar(cellPlot{freq,1}(:,1), cellHapUpMean{freq,1}(:,1), cellHapUpMean{freq,1}(:,2)...
%     ,'Marker',marker,'LineStyle', lineStyle,'MarkerFaceColor', lineColor, ...
%     'MarkerSize',4,'color',lineColor);
% % HapbeatUp 140Hz
% freq = 3;
% errorbar(cellPlot{freq,1}(:,1), cellHapUpMean{freq,1}(:,1), cellHapUpMean{freq,1}(:,2)...
%     ,'Marker',marker,'LineStyle', lineStyle,'MarkerFaceColor', lineColor, ...
%     'MarkerSize',4,'color',lineColor);
% 
% ax = gca;
% ax.YLim = [0 0.1];
% xlabel('Input Voltage from function generator (V)');
% ylabel('RMS value of tension (N)');
% title('Hapbeat increment');
% legend('Hapbeat 20Hz', 'Hapbeat 80Hz','Hapbeat 140Hz');
% set(gca,'FontSize',14)
% 
% hold off
% 
% %%
% figure
% % ax2 = subplot(2,2,2);
% hold on
% % DCmotorUp 20Hz
% lineColor =  '#FFA500'; %オレンジ
% freq = 1;
% errorbar(arrDCmInput{freq,1}(:,1), cellDCmUpMean{freq,1}(:,1), cellDCmUpMean{freq,1}(:,2)...
%     ,'Marker',marker,'LineStyle', lineStyle,...
%     'MarkerFaceColor', lineColor,'color',lineColor);
% % DCmotorUp 80Hz
% lineColor = '#0000FF'; %青色
% freq = 2;
% errorbar(arrDCmInput{freq,1}(:,1), cellDCmUpMean{freq,1}(:,1), cellDCmUpMean{freq,1}(:,2)...
%     ,'Marker',marker,'LineStyle', lineStyle,...
%     'MarkerFaceColor', lineColor,'color',lineColor);
% % DCmotorUp 140Hz
% lineColor = '#FF00FF'; %マゼンタ
% freq = 3;
% errorbar(arrDCmInput{freq,1}(:,1), cellDCmUpMean{freq,1}(:,1), cellDCmUpMean{freq,1}(:,2)...
%     ,'Marker',marker,'LineStyle', lineStyle,...
%     'MarkerFaceColor', lineColor,'color',lineColor);
% 
% ax = gca;
% ax.YLim = [0 0.1];
% 
% hold off
% 
% 
% figure
% % subplot(2,-2,3)
% hold on
% % HapbeatDw 20Hz
% lineColor =  '#FFA500'; %オレンジ
% freq = 1;
% errorbar(flip(cellPlot{freq,1}(:,1)), cellHapDwMean{freq,1}(:,1), cellHapDwMean{freq,1}(:,2)...
%     ,'Marker',marker,'LineStyle', lineStyle,...
%     'MarkerFaceColor', lineColor,'color',lineColor);
% % HapbeatDw 80Hz
% lineColor = '#0000FF'; %青色
% freq = 2;
% errorbar(flip(cellPlot{freq,1}(:,1)), cellHapDwMean{freq,1}(:,1), cellHapDwMean{freq,1}(:,2)...
%     ,'Marker',marker,'LineStyle', lineStyle,...
%     'MarkerFaceColor', lineColor,'color',lineColor);
% % HapbeatDw 140Hz
% lineColor = '#FF00FF'; %マゼンタ
% freq = 3;
% errorbar(flip(cellPlot{freq,1}(:,1)), cellHapDwMean{freq,1}(:,1), cellHapDwMean{freq,1}(:,2)...
%     ,'Marker',marker,'LineStyle', lineStyle,...
%     'MarkerFaceColor', lineColor,'color',lineColor,'MarkerSize',12);
% 
% ax = gca;
% ax.YLim = [0 0.1];
% xlabel('Input Voltage from function generator (V)');
% ylabel('RMS value of tension (N)');
% 
% hold off
% 
% figure
% % subplot(2,2,4)
% hold on
% % DCmotorDw 20Hz
% lineColor =  '#FFA500'; %オレンジ
% freq = 1;
% errorbar(flip(arrDCmInput{freq,1}(:,1)), cellDCmDwMean{freq,1}(:,1), cellDCmDwMean{freq,1}(:,2)...
%     ,'Marker',marker,'LineStyle', lineStyle,...
%     'MarkerFaceColor', lineColor,'color',lineColor);
% % DCmotorDw 80Hz
% lineColor = '#0000FF'; %青色
% freq = 2;
% errorbar(flip(arrDCmInput{freq,1}(:,1)), cellDCmDwMean{freq,1}(:,1), cellDCmDwMean{freq,1}(:,2)...
%     ,'Marker',marker,'LineStyle', lineStyle,...
%     'MarkerFaceColor', lineColor,'color',lineColor);
% % DCmotorDw 140Hz
% lineColor = '#FF00FF'; %マゼンタ
% freq = 3;
% errorbar(flip(arrDCmInput{freq,1}(:,1)), cellDCmDwMean{freq,1}(:,1), cellDCmDwMean{freq,1}(:,2)...
%     ,'Marker',marker,'LineStyle', lineStyle,...
%     'MarkerFaceColor', lineColor,'color',lineColor);
% 
% ax = gca;
% ax.YLim = [0 0.1];
% 
% hold off
