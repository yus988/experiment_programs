% 3軸のデータを主成分分析し、主成分軸の波形を求めるスクリプト
% Tシャツ/2T_Side/ で実行
close all

% 体脂肪率順
folder1 = 'sub3';
folder2 = 'sub4';
folder3 = 'sub2';
folder4 = 'sub5';
folder5 = 'sub1';
folder6 = 'sub6';

for whole_times = 1:maxLoops
    if whole_times == 1
        cd (folder1);
    elseif whole_times == 2
        cd (folder2);
    elseif whole_times == 3
        cd (folder3);
    elseif whole_times == 4
        cd (folder4);
    elseif whole_times == 5
        cd (folder5);
    elseif whole_times == 6
        cd (folder6);
    end    
    
    cd '20Hz_1W';
    
    load matlab.mat

    %%
    i=4; % 側面中央
%     i=3; % 背面中央
    acc=Mx{i,2};
    acc(:,4)=[]; % 入力電圧の列を削除
    
    % sub6(yus)の時のみx,yを反転
%     acc(:,1)= -1*acc(:,1);
%     acc(:,2)= -1*acc(:,2);
        % 主成分分析
        [coeff,score,latent,tsquared,explained,mu] = pca(acc);
        pcaAxis = acc*coeff(:,1); % 3軸を1軸に変換
        desc = strcat('pca 20Hz-1W sub', num2str(whole_times));
        plotFFT(pcaAxis,1e4,10,desc);
    
%         [r,harmpow,harmfreq] = thd(pcaAxis);

%     %     x軸
%         desc = strcat('x-axis 20Hz-1W sub', num2str(whole_times));
%         plotFFT(acc(:,1),1e4,10,desc);
%     
%     % y軸
%         desc = strcat('y-axis 20Hz-1W sub', num2str(whole_times));
%         plotFFT(acc(:,2),1e4,10,desc);
%     
%     % z軸
%     desc = strcat('z-axis 20Hz-1W sub', num2str(whole_times));
%     plotFFT(acc(:,3),1e4,10,desc);
%     
    
    savefig('resultForPaper');

%     CT = timetable(pcaAxis,'SampleRate',Fs);
    %%
    cd ../..
end


%% FFTした結果をプロットする関数

function pfReturn = plotFFT(y,Fs,freq,desc) % データ、サンプリングレート,グラフタイトル

% グラフサイズ
width =480;
height = 540;


% 切り出し
% %検算用変数定義
% i = 4; axisInt=1;
% y = Mx{i,2}(:,axisInt);
% freq = Mx{i,3}(:,axisInt);
% Fs = 1e4;

% 周期の半分の時間をピークが被らない値とし、（各周期ごとの最大値）
% rms値以上の値をピークとして求める。
minPeakDistance = (1/freq) /2 *Fs;
[pks(:,2), pks(:,1)] = findpeaks(y,'MinPeakHeight',rms(y),'MinPeakDistance',minPeakDistance);

% ピーク一つずつに対して、最小となるピーク対を探す。
for i = 1: size(pks(:,1),1)
    omit = pks;
    omit(i,:) =zeros(1,size(pks(:,1),2)); % pksから比較元の値（i番目のピーク）を削除する。
    [pks(i,3), pks(i,4)] = knnsearch(omit(:,2),pks(i,2)); % i番目のピークと最も差が小さいピークを見つける
end
% pks 1列目：ピークの時の測定点、2列目：ピークの値、3列目：ピーク対の相手番地、4列目：ピーク差

[M, I] = min(pks(:,4)); % 格納したピーク差のうち最も小さいモノを探す
minTime = pks(I,1); % 抽出したピーク対のうち小さい方の時間
maxTime = pks(pks(I,3),1);
yExtr = y(minTime:maxTime,1);

%グラフに必要な変数
% L = 1e4;             % Length of signal
L = size(yExtr,1); %切り取った信号のデータ数
T = 1/Fs;             % Sampling period
t = (0:L-1)*T;        % Time vector
% tlim = t(1, minTime:maxTime);
labelFont = 18;

figure('Name',desc,'NumberTitle','off','Position',[10 10 width height]);
subplot(2,1,1)
plot(t,yExtr)
% plot(t,y)
xlabel('Time (s)')
ylabel('Accelaration (m/s^{2})')
title(desc)
set(gca,'box','off') 
ax = gca; % current axes
ax.FontSize = labelFont;
xlim([0 0.1])


% Plot Figure % figure
subplot(2,1,2)
% y=Mx{1,2}(:,1); % 生の波形
% Y=fft(y); % fft
Y=fft(yExtr); % fft

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
stem(f,P1,'filled','MarkerSize',4)
% title('Single-Sided Amplitude Spectrum of Acceleration Signal')
xlabel('Frequency (Hz)')
ylabel('Amplitude Spectrum')% 単位は(m/s)
set(gca,'xscale','log')
% ax.XAxis.TickLength = [0.04 0.0];
set(gca,'box','off') 
ax = gca;
ax.XAxisLocation = 'bottom';
ax.XAxis.TickDirection  = 'out';
ax.XAxis.TickLength = [0.05 0.0];
ax.FontSize = labelFont;
xlim([10 300])
grid on 

end
