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

cellHapRMS = cell(1,1); % {→ 1,2,3回目, ↓20,80,140Hz}, (回数, rms)
cellDCmRMS = cell(1,1);

for actType = 1:2
    if actType == 1
        actDir = 'HapbeatWakeUp';
        isHapbeat = 1;
    else
        actDir = 'DCmotorWakeUp';
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
                
                if isHapbeat
                    cellHapRMS{freqLoop,exeLoop}(i,1) = Mx{i,7}; % 張力RMS
                else
                    cellDCmRMS{freqLoop,exeLoop}(i,1) = Mx{i,7}; % 張力RMS
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
tmpHapRMS = zeros(1,1);
tmpDcmRMS = zeros(1,1);
cellHapMean = cell(1,1);
cellDCmMean = cell(1,1);

for freqLoop = 1:size(cellHapRMS,1) % 周波数別, 縦方向
    % matlabの関数を使うため、tmp行列に格納
    for i = 1: size(cellHapRMS{1,1},1)
        for exeLoop = 1 : size(cellHapRMS,2)
            tmpHapRMS(exeLoop,1) = cellHapRMS{freqLoop,exeLoop}(i,1);
            tmpDcmRMS(exeLoop,1) = cellDCmRMS{freqLoop,exeLoop}(i,1);
        end
        cellHapMean{freqLoop,1}(i,1) = mean(tmpHapRMS);
        cellHapMean{freqLoop,1}(i,2) = std(tmpHapRMS);
        cellDCmMean{freqLoop,1}(i,1) = mean(tmpDcmRMS);
        cellDCmMean{freqLoop,1}(i,2) = std(tmpDcmRMS);
    end
end

arrHapInput = cell(1,1); % グラフx軸用のFG入力電圧の格納
arrDCmInput = cell(1,1);

for i = 1:21
        arrHapInput{1,1}(i,1) = 0.60 + (i-1) * 0.01; % 20Hz 
        arrHapInput{2,1}(i,1) = 0.70 + (i-1) * 0.01; % 80Hz 
        arrHapInput{3,1}(i,1) = 0.80 + (i-1) * 0.01; % 140Hz 
        arrDCmInput{1,1}(i,1) = 0.20 + (i-1) * 0.01; % 20Hz 
        arrDCmInput{2,1}(i,1) = 0.30 + (i-1) * 0.01; % 80Hz 
        arrDCmInput{3,1}(i,1) = 0.30 + (i-1) * 0.01; % 140Hz 
end

close all

lineStyle = '-';
marker = 'o';
lineColor = 'red';

hold on
% Hapbeat 20Hz
freq = 1;
errorbar(arrHapInput{freq,1}(:,1), cellHapMean{freq,1}(:,1), cellHapMean{freq,1}(:,2)...
    ,'Marker',marker,'LineStyle', lineStyle,...
    'MarkerFaceColor', lineColor,'color',lineColor);
% Hapbeat 80Hz
freq = 2;
errorbar(arrHapInput{freq,1}(:,1), cellHapMean{freq,1}(:,1), cellHapMean{freq,1}(:,2)...
    ,'Marker',marker,'LineStyle', lineStyle,...
    'MarkerFaceColor', lineColor,'color',lineColor);
% Hapbeat 140Hz
freq = 3;
errorbar(arrHapInput{freq,1}(:,1), cellHapMean{freq,1}(:,1), cellHapMean{freq,1}(:,2)...
    ,'Marker',marker,'LineStyle', lineStyle,...
    'MarkerFaceColor', lineColor,'color',lineColor);


lineColor = 'blue';
% DCmotor 20Hz
freq = 1;
errorbar(arrDCmInput{freq,1}(:,1), cellDCmMean{freq,1}(:,1), cellDCmMean{freq,1}(:,2)...
    ,'Marker',marker,'LineStyle', lineStyle,...
    'MarkerFaceColor', lineColor,'color',lineColor);
% DCmotor 80Hz
freq = 2;
errorbar(arrDCmInput{freq,1}(:,1), cellDCmMean{freq,1}(:,1), cellDCmMean{freq,1}(:,2)...
    ,'Marker',marker,'LineStyle', lineStyle,...
    'MarkerFaceColor', lineColor,'color',lineColor);
% DCmotor 140Hz
freq = 3;
errorbar(arrDCmInput{freq,1}(:,1), cellDCmMean{freq,1}(:,1), cellDCmMean{freq,1}(:,2)...
    ,'Marker',marker,'LineStyle', lineStyle,...
    'MarkerFaceColor', lineColor,'color',lineColor);



% resultCellを書き出し
% if ~isfolder('result')
%     mkdir result
%     cd result
%     writecell(resultCell,'result.csv')
%     cd ..

