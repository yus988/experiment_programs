%% csvデータのインポートおよびラベル用データ生成

% used by MasterTensionInput.m

% 定量実験処理用スクリプト
% 入出力波形の類似度を検証する。
% 出力はresultCell, 各周波数事のTHD, 入力信号に対するdelay, 

% clear
close all

Fs = 1e4;%サンプル周波数
% Fs = 10e3;%サンプル周波数
t = 0:1/Fs:1;

%加速度センサの感度
V2N = 0.01178; %力センサ5916, Hapbeatの時はプラス
% V2N = - 0.01178; %力センサ5916, DCモーターの時はマイナス

nharm = 6;%thdの高調波数
list = dir('*.csv');
%10列2行のセルを作成。1列目にy軸加速度の行列、2列目に力センサ
%（できれば1-の連番にして一々ファイル名を変更しないでも良いようにしたい

numFiles = length(list);
Mx = cell(numFiles,2);% インポート用のセル
RMS_column = zeros(1,4);% RMS値格納用
resultCell = cell(4,1); % 周波数、RMS、THD、位相差

difsample =  dir('*.txt'); % vp2.txt or hapbeat.txt
isfs1e3= strcmp(difsample.name,'1e3.txt'); %Hapeatの場合

% csvデータのインポートおよびラベル用データ生成
for i = 1:numFiles
    
    % サンプリングレートが1e3の信号がある場合
    if isfs1e3
        if i <= 12
                Fs = 1e3;
        else
                Fs = 1e4;
        end
    end
    
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
            resultCell{i,2} = Mx{i,7+3*k};
            resultCell{i,3} = thd_db;
        end
    end
    %入力電圧の周波数を取得し記録（harmfreqで高調波が分かる、その始めの値を利用)
    [thd_db, harmpow, harmfreq] = thd(Mx{i,1}(:,2), Fs, nharm);
    Mx{i,4} = harmfreq(1,1);
    resultCell{i,1} = round(harmfreq(1,1),1);

    % FGから入力電圧のVppを求める。2倍は負の値を考慮
    Vin = 2*sqrt(2)*rms((Mx{i,1}(:,2)));
    Mx{i,5} = Vin;
end
% 行末に説明を追加
Mx{i+1,1} = '生データ';
Mx{i+1,2} = 'オフセット除去後';
Mx{i+1,3} = 'タイムテーブル';
Mx{i+1,4} = '周波数';
Mx{i+1,5} = '測定電圧（計算後）';
% resultCell{i+1,1} ='周波数';
% resultCell{i+1,2} = 'RMS';
% resultCell{i+1,3} = 'THD';
% resultCell{i+1,4} = 'Phase';

for k=0:1
    Mx{i+1,6+3*k} = strcat('ch', num2str(k+1), 'Hz');
    Mx{i+1,7+3*k} = strcat('ch', num2str(k+1), 'RMS');
    Mx{i+1,8+3*k} = strcat('ch', num2str(k+1), 'THD');
end


%% 
%% 信号の周波数成分の比較
Fs = 1e4;%サンプル周波数

for i = 1:numFiles
    
        % サンプリングレートが1e3の信号がある場合
    if isfs1e3
        if i <= 12
                Fs = 1e3;
        else
                Fs = 1e4;
        end
    end
    
    sig1 = Mx{i,2}(:,2); % 入力電圧（反転させる）
    sig2 = Mx{i,2}(:,1); % 張力
%     sig2 = -1 * Mx{i,2}(:,1); % 張力
    
    isMaster = exist('actType');
    if isMaster
        if strcmp(actType,'DCmotor')
            sig2 = -1 * Mx{i,2}(:,1); % 張力
        end
    end
        

    [P1,f1] = periodogram(sig1,[],[],Fs,'power');
    [P2,f2] = periodogram(sig2,[],[],Fs,'power');

%     figure
%     t = (0:numel(sig1)-1)/Fs;
%     subplot(2,2,1)
%     plot(t,sig1,'k')
%     ylabel('s1')
%     grid on
%     title('Time Series')
%     subplot(2,2,3)
%     plot(t,sig2)
%     ylabel('s2')
%     grid on
%     xlabel('Time (secs)')
%     subplot(2,2,2)
%     plot(f1,P1,'k')
%     ylabel('P1')
%     grid on
%     axis tight
%     title('Power Spectrum')
%     subplot(2,2,4)
%     plot(f2,P2)
%     ylabel('P2')
%     grid on
%     axis tight
%     xlabel('Frequency (Hz)')

    % コヒーレンス
    [Cxy,f] = mscohere(sig1,sig2,[],[],[],Fs);
    Pxy     = cpsd(sig1,sig2,[],[],[],Fs);
    phase   = -angle(Pxy)/pi*180;
%     [pks,locs] = findpeaks(Cxy,'MinPeakHeight',0.75);
% 
%     figure
% %   振幅二乗コヒーレンス
%     subplot(2,1,1)
%     plot(f,Cxy)
%     title('Coherence Estimate')
%     grid on
%     hgca = gca;
%     hgca.XTick = round(f(locs),1);
%     % hgca.YTick = 0.75;
% %     axis([0 200 0 1]);
%     
% %   位相遅れ
%     subplot(2,1,2)
%     plot(f,phase)
%     title('Cross-spectrum Phase (deg)')
%     grid on
%     hgca = gca;
%     hgca.XTick = round(f(locs,1),1); 
%     yticks = sort(round(phase(locs)));
%     % hgca.YTick = round(phase(locs));
%     xlabel('Frequency (Hz)')
% %     axis([0 200 -180 180])

    Input_Hz = Mx{i,6};
    % knnsearch(f,Input_Hz): 入力周波数と最も近い周波数のIndexを返す
    phaseDelay = phase(knnsearch(f,Input_Hz), 1);
    resultCell{i,4} = phaseDelay;
    imgTitle = strcat(num2str(round(Input_Hz)),'Hz');
%     saveas(gcf,strcat(imgTitle,'_','mscohere '));
%     saveas(gcf,strcat(imgTitle,'_','mscohere ','.png'));
end


% resultCellを書き出し
if ~isfolder('result')
    mkdir result
    cd result
    writecell(resultCell,'result.csv')
    cd ..
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% 信号の遅延度
% 
% close all
% Fs = 1e4;%サンプル周波数
% for i = 1:numFiles
%     % s1 = Mx{1,2}(:,2); % 入力電圧
%     s1 = Mx{i,2}(:,2); % 入力電圧
%     s2 = -1 * Mx{i,2}(:,1); % 張力（反転させる）
%     % graph 描画
%     figure
%     ax(1) = subplot(2,1,1);
% %     plot(s1)
% %     [resultCell{i,4}(:,1),resultCell{i,4}(:,2)] = findpeaks(s1,Fs,'MinPeakDistance',0.01,'MinPeakHeight',0.05);
%     findpeaks(s1,Fs,'MinPeakDistance',0.01,'MinPeakHeight',0.05);
%     grid on
%     ax(2) = subplot(2,1,2);
%     plot(s2)
% %     [resultCell{i,5}(:,1),resultCell{i,5}(:,2)] = findpeaks(s2,Fs,'MinPeakDistance',0.01,'MinPeakHeight',0.5);
%     findpeaks(s2,Fs,'MinPeakDistance',0.01,'MinPeakHeight',0.02);   
%     t21 = finddelay(s1,s2) ;% 正の場合、s2がs1よりxサンプル遅れている
%     delaySec = t21 / Fs;
%     resultCell{i,3} = delaySec;
% end
% 
% resultCell{i+1,3} = 'delaySec';
% 





 %% 最低張力検証用
% % arr20Hz = zeros(size(Mx,1),2);
% arr20Hz = zeros(1,2);
% arr80Hz = zeros(1,2);
% arr140Hz = zeros(1,2);
% arrRMS = zeros(1,2);
% 
% for i = 1:size(Mx,1)-1
%     tmpTensionVol = Mx{i,7} * V2N; % 張力RMS (電圧表示）
%     arrRMS(i,1)=Mx{i,10}; % 入力電圧RMS
%     arrRMS(i,2)=tmpTensionVol; % 張力RMS
% end
% 
% figure
% subplot(2,1,1)
% plot(arrRMS(:,1),arrRMS(:,2),'Marker','o', ...
%     'MarkerFaceColor', 'blue','color','blue');
% subplot(2,1,2)
% plot(arrRMS(:,2),'Marker','o', ...
%     'MarkerFaceColor', 'blue','color','blue');
% saveas(gcf,'result.png');
% 
% save;

