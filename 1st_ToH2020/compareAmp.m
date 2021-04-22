%% 定量実験処理用スクリプト
% アンプ測定の√で実行
% -Hapbeat -1 -2 -3 
% -Lepy -1 -2 -3


clear
Fs = 1e4;%サンプル周波数
% Fs = 10e3;%サンプル周波数
t = 0:1/Fs:1;
%加速度センサの感度
V2N = 0.01178; %力センサ5916
nharm = 6;%thdの高調波数
%10列2行のセルを作成。1列目にy軸加速度の行列、2列目に力センサ
%（できれば1-の連番にして一々ファイル名を変更しないでも良いようにしたい
inputVol = 0.5; %入力電圧Vpp

HapCell = cell(1,1); % 一時保管用。各ループで回す
LepCell = cell(1,1); % 一時保管用。各ループで回す
 % 3回分のRMSとTHDをまとめるCell Hz:RMS:THD 
cellHapResult = cell(1,1);
cellLepResult = cell(1,1);
thdArr = zeros(1,1);
% グラフ図示用行列
arrHapRmsMeanStd = zeros(1,1); % Hz, RMS mean, std
arrLepRmsMeanStd = zeros(1,1); % Hz, RMS, std
arrHapThdMeanStd = zeros(1,1); % Hz, Thd, mean, std
arrLepThdMeanStd = zeros(1,1); % Hz, THD, std

%% Hapbeat, Lepyフォルダから結果を取得
cd Hapbeat

for cdTimes = 1:3
    if cdTimes == 1
        cd '1';
    elseif cdTimes == 2
        cd '2';
    elseif cdTimes == 3
        cd '3';
    end
    list = dir('*.csv');
    numFiles = length(list);
    % データのインポートおよびラベル用データ生成
    for i = 1:numFiles
        if i <= 12
            Fs = 1e3;
        else
            Fs = 1e4;
        end
        % 1chの場合 (pngで確認）
        HapCell{i,1}= csvread(list(i).name,21,1,[21,1,10020,1]);
        % オフセット除去（すべての要素から平均値を引く）
        HapCell{i,2}(:,1) = ( HapCell{i,1}(:,1) - mean(HapCell{i,1}(:,1)) );
        % timetable を各列ごとに追加
        HapCell{i,3} = timetable(HapCell{i,2}(:,1),'SampleRate',Fs);
        HapCell{i,3}.Properties.VariableNames{'Var1'}='Out' ;
        [thd_db, harmpow, harmfreq] = thd(HapCell{i,2}(:,1), Fs, nharm);
        HapCell{i,4} = harmfreq(1,1);
        HapCell{i,5} = rms((HapCell{i,2}(:,1))) ;
        HapCell{i,6} = thd_db;
        thdArr(i,1) = thd_db;
        HapCell{i,7} = HapCell{i,5}*2* sqrt(2);%Vppにするための処理（rmsにかける）
        
        cellHapResult{cdTimes,1}(i,1) = harmfreq(1,1);
        cellHapResult{cdTimes,1}(i,2) = rms((HapCell{i,2}(:,1))) ;
        cellHapResult{cdTimes,1}(i,3) = thd_db ;   
    end
    
    % 全高調波歪
    HapThd(1,1) = mean(thdArr);
    HapThd(1,2) = mean(thdArr((1:12),1));
    HapThd(1,3) = mean(thdArr((13:37),1));

    % 行末に説明を追加
    HapCell{i+1,1} = '生データ';
    HapCell{i+1,2} = 'オフセット除去後';
    HapCell{i+1,3} = 'タイムテーブル';
    HapCell{i+1,4} = 'Hz';
    HapCell{i+1,5} = 'RMS';
    HapCell{i+1,6} = 'THD';
    HapCell{i+1,7} = 'Vpp';
    cd ..
end
cd ..
    

% Lepyの出力結果をインポート
cd Lepy
for cdTimes = 1:3
    if cdTimes == 1
        cd '1';
    elseif cdTimes == 2
        cd '2';
    elseif cdTimes == 3
        cd '3';
    end
    list = dir('*.csv');
    numFiles = length(list);
    for i = 1:numFiles
        if i <= 12
            Fs = 1e3;
        else
            Fs = 1e4;
        end
        % 1chの場合 (pngで確認）
        LepCell{i,1}= csvread(list(i).name,21,1,[21,1,10020,1]);
        
        % オフセット除去（すべての要素から平均値を引く）
        LepCell{i,2}(:,1) = ( LepCell{i,1}(:,1) - mean(LepCell{i,1}(:,1)) );
        % timetable を各列ごとに追加
        LepCell{i,3} = timetable(LepCell{i,2}(:,1),'SampleRate',Fs);
        LepCell{i,3}.Properties.VariableNames{'Var1'}='Out' ;
        
        [thd_db, harmpow, harmfreq] = thd(LepCell{i,2}(:,1), Fs, nharm);
        LepCell{i,4} = harmfreq(1,1);
        LepCell{i,5} = rms((LepCell{i,2}(:,1))) ;
        LepCell{i,6} = thd_db;
        thdArr(i,1) = thd_db;
        LepCell{i,7} = LepCell{i,5}*2* sqrt(2);%Vppにするための処理（rmsにかける）
        
        cellLepResult{cdTimes,1}(i,1) = harmfreq(1,1);
        cellLepResult{cdTimes,1}(i,2) = rms((LepCell{i,2}(:,1))) ;
        cellLepResult{cdTimes,1}(i,3) = thd_db ;   
    end
    
    LepThd = mean(thdArr);
    LepThd(1,2) = mean(thdArr((1:12),1));
    LepThd(1,3) = mean(thdArr((13:37),1));
    LepCell{i+1,1} = '生データ';
    LepCell{i+1,2} = 'オフセット除去後';
    LepCell{i+1,3} = 'タイムテーブル';
    LepCell{i+1,4} = 'Hz';
    LepCell{i+1,5} = 'RMS';
    LepCell{i+1,6} = 'THD';
    LepCell{i+1,7} = 'Vpp';
    cd ..
end 
cd ..

%% HapAmp 平均、標準偏差の算出
tmpFreq = zeros(1,1);
tmpRMS = zeros(1,1);
tmpTHD = zeros(1,1);
for i = 1:size(cellHapResult{1,1},1) % 周波数別
    % matlabの関数を使うため、tmp行列に格納
    for loop = 1 : size(cellHapResult,1) 
        tmpFreq(loop,1) = cellHapResult{loop,1}(i,1);
        % ゲインを出すためVpp に変換 & 入力電圧で割る
        tmpRMS(loop,1) = cellHapResult{loop,1}(i,2)  * 2 * sqrt(2) / inputVol;
        tmpTHD(loop,1) = cellHapResult{loop,1}(i,3);
    end
    arrHapRmsMeanStd(i,1) = mean(tmpFreq);
    arrHapRmsMeanStd(i,2) = mean(tmpRMS);
    arrHapRmsMeanStd(i,3) = std(tmpRMS);
    arrHapThdMeanStd(i,1) = mean(tmpFreq);
    arrHapThdMeanStd(i,2) = mean(tmpTHD);
    arrHapThdMeanStd(i,3) = std(tmpTHD);
end

%% LepAmp 平均、標準偏差の算出
tmpFreq = zeros(1,1);
tmpRMS = zeros(1,1);
tmpTHD = zeros(1,1);
for i = 1:size(cellLepResult{1,1},1) % 周波数別
    % matlabの関数を使うため、tmp行列に格納
    for loop = 1 : size(cellLepResult,1) 
        tmpFreq(loop,1) = cellLepResult{loop,1}(i,1);
        % ゲインを出すためVpp に変換 & 入力電圧で割る
        tmpRMS(loop,1) = cellLepResult{loop,1}(i,2) * 2 * sqrt(2) / inputVol;
        tmpTHD(loop,1) = cellLepResult{loop,1}(i,3);
    end
    arrLepRmsMeanStd(i,1) = mean(tmpFreq);
    arrLepRmsMeanStd(i,2) = mean(tmpRMS);
    arrLepRmsMeanStd(i,3) = std(tmpRMS);
    arrLepThdMeanStd(i,1) = mean(tmpFreq);
    arrLepThdMeanStd(i,2) = mean(tmpTHD);
    arrLepThdMeanStd(i,3) = std(tmpTHD);
end

%% Hap/Lep mean/thd グラフの描画
close all
figure
hold on

clf % clear window

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
yyaxis left; % activate left y axis
% configure left axis
lineStyle = '-';
marker = 'o';

% hap mean 
plotArr = arrHapRmsMeanStd;
semilogx(plotArr(:,1), plotArr(:,2),'Marker',marker, 'LineStyle', lineStyle, ...
    'MarkerFaceColor', 'red','color','red');

% lep mean
plotArr = arrLepRmsMeanStd;
hold on;
semilogx(plotArr(:,1), plotArr(:,2),'Marker',marker, 'LineStyle', lineStyle, ...
    'MarkerFaceColor', 'blue','color','blue');

ylabel('Gain');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
yyaxis right; % activate left y axis

lineStyle = '-';
marker = '*';

% hap thd
plotArr = arrHapThdMeanStd;
hold on;
lineColor = '#ffb6c1';
semilogx(plotArr(:,1), plotArr(:,2),'Marker',marker,'LineStyle', lineStyle,...
    'MarkerFaceColor', lineColor,'color',lineColor);

% lep thd
hold on;
plotArr = arrLepThdMeanStd;
lineColor = '#87cefa';
semilogx(plotArr(:,1), plotArr(:,2),'Marker',marker, 'LineStyle', lineStyle, ...
    'MarkerFaceColor', lineColor,'color',lineColor);

% configure left axis
ylabel('THD (dB)');
set(gca,'FontSize',20)

legend('Gain Hapbeat','Gain Lepy','THD Hapbeat','THD Lepy','FontSize',20);
xlabel('Frequency (Hz)');

% semilogx(plotArr(:,1), plotArr(:,3) )
saveas(gcf,strcat('gainValue','.png'));





% %% 周波数応答（ゲイン）の表示
% plotArr(:,1) = [1; 1.2; 1.5; 1.8; 2.2; 2.7; 3.3; 3.9; 4.7; 5.6; 6.8; 8.2; ...
%     10; 12; 15; 18; 22; 27; 33; 39; 47; 56; 68; 82; ... 
%     100; 120; 150; 180; 220; 270; 330; 390; 470; 560; 680; 820; 1000];
% for i = 1:37
%     plotArr(i,2) = HapCell{i,7}/inputVol; % Hapbeatアンプ Vpp
%     plotArr(i,3) = LepCell{i,7}/inputVol; % Lepy Vpp
%     plotArr(i,4) = HapCell{i,6};% Hapbeatアンプ THD
%     plotArr(i,5) = LepCell{i,6};% Lepy THD
% end
% 
% clf
% % semilogx(plotArr(:,1), plotArr(:,2) )
% % semilogx(plotArr(:,1), plotArr(:,4),'-o', ...
% %     'MarkerFaceColor', 'blue')
% semilogx(plotArr(:,1), plotArr(:,2),'Marker','o', ...
%     'MarkerFaceColor', 'red','color','red');
% 
% hold on;
% semilogx(plotArr(:,1), plotArr(:,3),'Marker','o', ...
%     'MarkerFaceColor', 'blue','color','blue');
% 
% hold on;
% lineColor = 'red';
% semilogx(plotArr(:,1), plotArr(:,4),'Marker','s', ...
%     'MarkerFaceColor', lineColor,'color',lineColor);
% 
% hold on;
% lineColor = 'blue';
% semilogx(plotArr(:,1), plotArr(:,5),'Marker','s', ...
%     'MarkerFaceColor', lineColor,'color',lineColor);
% 
% 
% ax = gca;
% ax.XAxis.FontSize = 20;
% ax.YAxis.FontSize = 20;
% 
% legend('Hapbeat','Lepy','FontSize',20);
% xlabel('Frequency (Hz)');
% ylabel('Gain');
% 
% % semilogx(plotArr(:,1), plotArr(:,3) )
% saveas(gcf,strcat('gainValue','.png'));
% 
% 
% %% アンプ立ち上がり時間用
% % [OutMin, idx_OutMin]=min(Mx{1,3}.Out)
% % [InMin,idx_InMin]=min(Mx{1,3}.In)
% 
% %% Hapbeatタイムテーブル
% HapTT1 = HapCell{1,3};
% HapTT1_2 = HapCell{2,3};
% HapTT1_5 = HapCell{3,3};
% HapTT1_8 = HapCell{4,3};
% HapTT2_2 = HapCell{5,3};
% HapTT2_7 = HapCell{6,3};
% HapTT3_3 = HapCell{7,3};
% HapTT3_9 = HapCell{8,3};
% HapTT4_7 = HapCell{9,3};
% HapTT5_6 = HapCell{10,3};
% HapTT6_8 = HapCell{11,3};
% HapTT8_2 = HapCell{12,3};
% HapTT10 = HapCell{13,3};
% HapTT12 = HapCell{14,3};
% HapTT15 = HapCell{15,3};
% HapTT18 = HapCell{16,3};
% HapTT22 = HapCell{17,3};
% HapTT27 = HapCell{18,3};
% HapTT33 = HapCell{19,3};
% HapTT39 = HapCell{20,3};
% HapTT47 = HapCell{21,3};
% HapTT56 = HapCell{22,3};
% HapTT68 = HapCell{23,3};
% HapTT82 = HapCell{24,3};
% HapTT100 = HapCell{25,3};
% HapTT120 = HapCell{26,3};
% HapTT150 = HapCell{27,3};
% HapTT180 = HapCell{28,3};
% HapTT220 = HapCell{29,3};
% HapTT270 = HapCell{30,3};
% HapTT330 = HapCell{31,3};
% HapTT390 = HapCell{32,3};
% HapTT470 = HapCell{33,3};
% HapTT560 = HapCell{34,3};
% HapTT680 = HapCell{35,3};
% HapTT820 = HapCell{36,3};
% HapTT1000 = HapCell{37,3};
% 
% %% Lepyタイムテーブル
% LepTT1 = LepCell{1,3};
% LepTT1_2 = LepCell{2,3};
% LepTT1_5 = LepCell{3,3};
% LepTT1_8 = LepCell{4,3};
% LepTT2_2 = LepCell{5,3};
% LepTT2_7 = LepCell{6,3};
% LepTT3_3 = LepCell{7,3};
% LepTT3_9 = LepCell{8,3};
% LepTT4_7 = LepCell{9,3};
% LepTT5_6 = LepCell{10,3};
% LepTT6_8 = LepCell{11,3};
% LepTT8_2 = LepCell{12,3};
% LepTT10 = LepCell{13,3};
% LepTT12 = LepCell{14,3};
% LepTT15 = LepCell{15,3};
% LepTT18 = LepCell{16,3};
% LepTT22 = LepCell{17,3};
% LepTT27 = LepCell{18,3};
% LepTT33 = LepCell{19,3};
% LepTT39 = LepCell{20,3};
% LepTT47 = LepCell{21,3};
% LepTT56 = LepCell{22,3};
% LepTT68 = LepCell{23,3};
% LepTT82 = LepCell{24,3};
% LepTT100 = LepCell{25,3};
% LepTT120 = LepCell{26,3};
% LepTT150 = LepCell{27,3};
% LepTT180 = LepCell{28,3};
% LepTT220 = LepCell{29,3};
% LepTT270 = LepCell{30,3};
% LepTT330 = LepCell{31,3};
% LepTT390 = LepCell{32,3};
% LepTT470 = LepCell{33,3};
% LepTT560 = LepCell{34,3};
% LepTT680 = LepCell{35,3};
% LepTT820 = LepCell{36,3};
% LepTT1000 = LepCell{37,3};
% save;