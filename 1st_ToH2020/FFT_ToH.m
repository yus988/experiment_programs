% 各試行の波形に対してwavelet変換を行う
% csvファイルが入っているフォルダで実行



%% 以下各測定結果ファイルごとの処理
clear
Mx = cell(1,1);
cellResult = cell(zeros(1));

Fs = 1e3;%サンプル周波数
t = 0:1/Fs:1;
%加速度センサの感度
V2G6 = 0.206 / 9.80665; %MMA7361L 6Gモード = v/g v / (g*9.80665)
% V2G6 = 0.660 /9.80665; % EH2016用 KXR94-2050
nharm = 6;%thdの高調波数
list1e4 = dir('*.csv');%サンプリングレート10kHzのデータ
numFiles1e4 = length(list1e4);

list = dir('*.csv');
numFiles = length(list);

% サンプリングレート1kHzのデータを記録
if isfolder('1e3')
    cd '1e3'
    list1e3 = dir('*.csv');%サンプリングレート1kHzのデータ    
    numFiles1e3 = length(list1e3);
    Input_Hz = 0;
    Input_Vol = 0;
    filename = 'test';
    isAscending = true;%昇順か否か
    
    %入力電圧の周波数を取得し記録（harmfreqで高調波が分かる、その始めの値を利用)
    %1~8.2Hzはサンプリングレートが1000なので、そのファイルだけ修正
    %計測順が昇順(1Hz~)に対応
    
    % データのインポートおよびラベル用データ生成
    for i = 1:numFiles1e3
        Mx{i,1}= csvread(list1e3(i).name,21,1,[21,1,10020,4]);
        % オフセット除去（すべての要素から平均値を引く）
        Mx{i,2}(:,1) = ( Mx{i,1}(:,1) - mean(Mx{i,1}(:,1)) ) / V2G6; %下に引っ張った時を正に（標準では負）
        Mx{i,2}(:,2) = ( Mx{i,1}(:,2) - mean(Mx{i,1}(:,2)) ) / V2G6;
        Mx{i,2}(:,3) = ( Mx{i,1}(:,3) - mean(Mx{i,1}(:,3)) ) / V2G6;
        Mx{i,2}(:,4) = ( Mx{i,1}(:,4) - mean(Mx{i,1}(:,4)) );
        [thd_db, harmpow, harmfreq] = thd(Mx{i,1}(:,4), Fs, nharm);
        
        Mx{i,3} = harmfreq(1,1);
        Input_Hz = harmfreq(1,1);
        Mx{i,4} =  rms((Mx{i,2}(:,1))) + rms((Mx{i,2}(:,2)))+rms((Mx{i,2}(:,3)));%3軸RMS値
        Mx{i,5} = list1e3(i).name;
        
        Mx{i,6} = timetable(Mx{i,2}(:,1), Mx{i,2}(:,2), Mx{i,2}(:,3),'SampleRate',Fs);
        Mx{i,6}.Properties.VariableNames{'Var1'}='x' ;
        Mx{i,6}.Properties.VariableNames{'Var2'}='y' ;
        Mx{i,6}.Properties.VariableNames{'Var3'}='z' ;
    end
    cd ..
else
    numFiles1e3 = 0;
end
Fs = 1e4;%サンプル周波数
% サンプリングレート10kHzのデータを記録
for i = 1:numFiles1e4
    k = i + numFiles1e3;
    Mx{k,1}= csvread(list1e4(i).name,21,1,[21,1,10020,4]);
%             Mx{k,1}= csvread(list1e4(i).name,21,1,[21,1,3020,3]); %t EH2016 WTV用temp
    % オフセット除去（すべての要素から平均値を引く）
    Mx{k,2}(:,1) = ( Mx{k,1}(:,1) - mean(Mx{k,1}(:,1)) ) / V2G6; %下に引っ張った時を正に（標準では負）
    Mx{k,2}(:,2) = ( Mx{k,1}(:,2) - mean(Mx{k,1}(:,2)) ) / V2G6;
    Mx{k,2}(:,3) = ( Mx{k,1}(:,3) - mean(Mx{k,1}(:,3)) ) / V2G6;
    
    if size(Mx{1,1},2) > 3
        Mx{k,2}(:,4) = ( Mx{k,1}(:,4) - mean(Mx{k,1}(:,4)) );
        [thd_db, harmpow, harmfreq] = thd(Mx{k,1}(:,4), Fs, nharm);
        Mx{k,3} = harmfreq(1,1);
        Mx{k,4} = thd_db(1,1);
        Mx{k,5} = harmpow(1,1);

        input_Hz = harmfreq(1,1);
    end
    Mx{k,6} =  rms((Mx{k,2}(:,1))) + rms((Mx{k,2}(:,2)))+rms((Mx{k,2}(:,3)));%3軸RMS値
    Mx{k,7} = list1e4(i).name;
    
    Mx{k,8} = timetable(Mx{k,2}(:,1), Mx{k,2}(:,2), Mx{k,2}(:,3),'SampleRate',Fs);
    Mx{k,8}.Properties.VariableNames{'Var1'}='x' ;
    Mx{k,8}.Properties.VariableNames{'Var2'}='y' ;
    Mx{k,8}.Properties.VariableNames{'Var3'}='z' ;
    
end
save;

%% FFT 一括表示＆保存
close all
type =  erase(dir('*.txt').name,'.txt');

enableCD = true;
% enableCD = false; % for debug

Fs = 1e3;
for axisInt = 1:3 % 軸の種類
    if axisInt == 1
        axisStr = 'x';
    elseif axisInt == 2
        axisStr = 'y';
    elseif axisInt == 3
        axisStr = 'z';
    end
    for i = 1:size(Mx,1) % 行列方向、周波数別のデータ
        freqNum = Mx{i,3};
        % 1 ~ 10 Hz の測定を行った時のみ
        if freqNum < 9
            Fs = 1e3;
            freqStr = num2str(round(Mx{i,3},1));
        else
            Fs = 1e4;
            %                         Fs = 1e3; % EH2016のデータ専用
            freqStr = num2str(round(Mx{i,3}));
        end
        if ~isfolder('FFT')
            mkdir('FFT')
        end
        
        % acc,vel,disを計算 
        acc = Mx{i,2}(:,axisInt); %加速度データ
        acc = acc - mean(acc);
        vel = cumtrapz(1/Fs,acc);
        vel = vel-mean(vel); 
        dis = cumtrapz(1/Fs,vel);

        for mode = 1:1 % 加速度、速度、変位のループ
            if mode == 1
                modeStr = 'acc';
                y = acc;
            elseif mode == 2
                modeStr = 'vel';
                y = vel;
            elseif mode == 3
                modeStr = 'dis';
                y = dis;
            end
            
                    % FFTフォルダの中でacc,vel,disを作る。
            if(enableCD == true)
                cd FFT
                if ~isfolder(modeStr)
                    mkdir(modeStr)
                end          
            end
            
            % 各モードフォルダの中でx,y,zを作る。
            if(enableCD == true)
                cd(modeStr)
                if ~isfolder(axisStr)
                mkdir(axisStr)
                end
                cd (axisStr)
            end
           
            Freq = Mx{i,3};
            locate = num2str(i);
            desc = strcat(freqStr,' Hz','-',axisStr,'-',modeStr,'-locate-',locate);
            %       関数
            plotFFT(y,Fs,Freq,desc);
            fileName = replace(desc,'.','r');% ファイル名に . が入るのを阻止

            % グラフを保存して元のフォルダに戻る。
            if(enableCD == true)
                savefig(fileName);
                saveas(gcf,strcat(fileName,'.png'));
                cd ../../..
            end
            close

        end
    end
end


%% 主成分分析

close all
i=4; % 側面中央
acc=Mx{i,2}; 
acc(:,4)=[]; % 入力電圧の列を削除
% 主成分分析
[coeff,score,latent,tsquared,explained,mu] = pca(acc);

pcaAxis = acc*coeff(:,1);

plotFFT(pcaAxis,1e4,10,'Measured Prncipal-Axis Acceleration Signal from 20 Hz Sine Wave Input');
savefig('resultForPaper');

CT = timetable(pcaAxis,'SampleRate',Fs);

%% 論文画像生成用 (20Hz Side)
close all
i=4; % 側面中央
acc = Mx{i,2}(:,1); %加速度データ x
acc = acc - mean(acc);
plotFFT(acc,1e4,10,'Measured X-axis Acceleration Signal from 10 Hz Sine Wave Input');
savefig('resultForPaper');

%% 論文画像生成用 (20Hz Back)
close all
i=3; % 背面中央
acc = Mx{i,2}(:,3); %加速度データ z
acc = acc - mean(acc);
plotFFT(acc,1e4,10,'Measured z-axis Acceleration Signal from 10 Hz Sine Wave Input');
savefig('resultForPaper');

%% FFTした結果をプロットする関数

% minPeakDistance = (1/freq) /2 *Fs;
% [pks(:,2) pks(:,1)] = findpeaks(y,'MinPeakHeight',rms(y),'MinPeakDistance',minPeakDistance);

function pfReturn = plotFFT(y,Fs,freq,desc) % データ、サンプリングレート,グラフタイトル
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

figure('Name',desc,'NumberTitle','off','Position',[10 10 960 540]);
subplot(2,1,1)
plot(t,yExtr)
% plot(t,y)
xlabel('Time (s)')
ylabel('Accelaration (m/s^{2})')
title(desc)
set(gca,'box','off') 
ax = gca; % current axes
ax.FontSize = labelFont;


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
title('Single-Sided Amplitude Spectrum of Acceleration Signal')
xlabel('Frequency (Hz)')
ylabel('Amplitude Spectrum')% 単位は(m/s)
set(gca,'xscale','log')
% ax.XAxis.TickLength = [0.04 0.0];
set(gca,'box','off') 
ax = gca;
ax.XAxisLocation = 'bottom';
ax.XAxis.TickDirection  = 'out';
ax.XAxis.TickLength = [0.02 0.0];
ax.FontSize = labelFont;
xlim([1 300])
grid on 


end

%% 加速度、速さ、変位の波形とパワースペクトラム表示試し用
% Fs = 1e3;
% % x = 0:1/Fs:9.9999;
% % acc = Mx{6,2}(:,1);
% Fs = 1e4;
% x = 0:1/Fs:0.9999;
% acc = Mx{19,2}(:,1);
% % acc = Mx{30,2}(:,1);
% 
% filtFreq = 33/2;

% 試し用
% disp = cumtrapz(1/Fs,cumtrapz(1/Fs,y));
% acc = y;
% vel = cumtrapz(1/Fs,y);
% vel = vel - mean(vel);
% disp = cumtrapz(1/Fs,vel);
% plot(disp);
% TT = timetable(acc,vel,disp,'SampleRate',Fs);



%% 加速度、速さ、変位の波形とパワースペクトラム表示する関数
function dispPS = dispPowerSpectrum(acc,Fs,freq,desc) % データ、サンプリングレート,グラフタイトル
% filtFreq = freq - freq / 10;
filtFreq = freq / 2;
if Fs == 1e4 
    x = 0:1/Fs:0.9999;
elseif Fs == 1e3
    x = 0:1/Fs:9.9999;
end

% x = 0:1/Fs:2.999; % EH2016用
% filtFreq = 15;  % EH2016用

if freq <10
    xMin=0; xMax = 300;

elseif freq < 50
    xMin=1; xMax = 300;
else
    xMin =10; xMax = 1000;
end

dispVelosity = true;

figure('Name',desc,'NumberTitle','off','Position',[0 0 1440 540]);
row = 2; col = 2;
if dispVelosity
    row = 2; col = 3; % 速さを並べる場合
end
subplot(row,col,1)
% 加速度波形表示
acc = acc-mean(acc);
% acc = detrend(acc);
% acc = highpass(acc,filtFreq,Fs,'Steepness',0.85,'StopbandAttenuation',60);
plot(x,acc);
title(strcat('Acc Wave-',desc));
grid on

% 速さ波形表示
vel = cumtrapz(1/Fs,acc);
% vel = detrend(vel);
vel = vel-mean(vel);
% vel = highpass(vel,filtFreq,Fs,'Steepness',0.85,'StopbandAttenuation',60);

if dispVelosity
    subplot(row,col,2)
    plot(x,vel);
    title(strcat('Vel Wave-',desc));
    grid on
end

subplot(row,col,2)
if dispVelosity
    subplot(row,col,3)  % 速さを並べる場合
end
% 変位波形表示
dis = cumtrapz(1/Fs,vel);
% dis = detrend(dis);
% dis = dis-mean(dis);
% dis = highpass(dis,filtFreq,Fs,'Steepness',0.9999,'StopbandAttenuation',60);
plot(x,dis)
title(strcat('Disp Wave-',desc));
grid on

TT = timetable(acc,vel,dis,'SampleRate',Fs);

% 加速度パワースペクトラム表示
subplot(row,col,3)
if dispVelosity
    subplot(row,col,4)  % 速さを並べる場合
end
[pxx,f] = pspectrum(TT(:,1));
plot(f,pow2db(pxx));
xlabel('Frequency (Hz)')
ylabel('Power Spectrum (dB)')
set(gca,'xscale','log')
title(strcat('Acc PS-',desc));
xlim([xMin xMax])
grid on

% % 速度パワースペクトラム表示
if dispVelosity
    subplot(row,col,5)  % 速さを並べる場合
    [pxx,f] = pspectrum(TT(:,2));
    plot(f,pow2db(pxx));
    xlabel('Frequency (Hz)')
    ylabel('Power Spectrum (dB)')
    set(gca,'xscale','log')
    title(strcat('Vel Wave-',desc));
    xlim([xMin xMax])
    grid on
end

subplot(row,col,4) 
if dispVelosity
    subplot(row,col,6)  % 速さを並べる場合
end

% 変位パワースペクトラム表示
[pxx,f] = pspectrum(TT(:,3));
plot(f,pow2db(pxx));
xlabel('Frequency (Hz)')
ylabel('Power Spectrum (dB)')
set(gca,'xscale','log')
title(strcat('Disp PS-',desc));
xlim([xMin xMax])

grid on


dispPS = TT;

end

%% fftを行い、グラフを描画する関数。
function psPlot = powerSpectrumPlot(TT,Fs,jiku,desc) % データ、サンプリングレート,グラフタイトル
% tms = (0:numel(TT.Time)-1)/Fs;
% 解析元信号
subplot(2,1,1)

if jiku == 'x'
    plot(TT.Time,TT.x);
elseif jiku == 'y'
    plot(TT.Time,TT.y);
elseif jiku == 'z'
    plot(TT.Time,TT.z);
end 

axis tight
title(desc)
xlabel('Time (s)')
ylabel('Accelaration amplitude (m/s^{2})')

subplot(2,1,2)
[pxx,f] = pspectrum(TT);
plot(f,pow2db(pxx));
grid on
xlabel('Frequency (Hz)')
ylabel('Power Spectrum (dB)')
set(gca,'xscale','log')
title('Default Frequency Resolution')

fileName = replace(desc,'.','r');% ファイル名に . が入るのを阻止
savefig(fileName);
saveas(gcf,strcat(fileName,'.png'));
end

%% wavelet analyze 使用する際は関数より上のセクションに移動
% close all
% type =  erase(dir('*.txt').name,'.txt');
%
% Fs = 1e3;
% for freq = 1:3
%     if freq == 1
%         axis = 'x';
%     elseif freq == 2
%         axis = 'y';
%     elseif freq == 3
%         axis = 'z';
%     end
%     for i = 1:size(Mx,1)
%         % 1 ~ 10 Hz の測定を行った時のみ
%         if Mx{i,3} < 9
%             Fs = 1e3;
%             Freq = num2str(round(Mx{i,3},1));
%         else
%             Fs = 1e4;
% %             Fs = 1e3; % EH2016のデータ専用
%             Freq = num2str(round(Mx{i,3}));
%         end
%         y = Mx{i,2}(:,freq);
%         if ~isfolder('wavelet')
%             mkdir('wavelet')
%         end
%         cd wavelet
%         if ~isfolder(axis)
%             mkdir(axis)
%         end
%         cd (axis)
% %         wlplot = waveletPlot(y,Fs,strcat(Freq,' Hz','-', axis,'-',type));
%         locate = num2str(i);
%         wlplot = waveletPlot(y,Fs,strcat(Freq,' Hz','-', axis,'-',type,'-locate-',locate));
%
%         close
%         cd ../..
%
%     end
% end

%% デバッグ用、1回のみ

% y = Mx{6,1}(:,1);
% Fs = 1e3;
% wlplot = waveletPlot(y,Fs,strcat('debug'));
%


%% wavelet変換を行い、グラフを描画する関数。
function wlplot = waveletPlot(y,Fs,desc) % データ、サンプリングレート,グラフタイトル
%  cwt単体のグラフ生成
%     figure('Name',strcat(desc,'-cwt'),'NumberTitle','off');
%     cwt(y,Fs);
% 信号の連続ウェーブレット変換と CWT の周波数を求めます。
[cfs,frq] = cwt(y,Fs);
% 関数 cwt により、時間と周波数の座標軸がスカログラムで設定されます。サンプル時間を表すベクトルを作成します。
tms = (0:numel(y)-1)/Fs;
%     savefig(strcat(desc,'-cwt'));
%     saveas(gcf,strcat(desc,'-cwt','.png'));

% 新しい Figure で、元の信号を上のサブプロットにプロットし、スカログラムを下のサブプロットにプロットします。対数スケールで周波数をプロットします。
figure('Name',desc,'NumberTitle','off','Position',[0 0 960 540]);

%  解析元信号
% subplot(2,1,1)
subplot(3,1,1)
plot(tms,y)
axis tight
title(desc)
xlabel('Time (s)')
ylabel('Accelaration amplitude (m/s^{2})')

%  cwt結果のスカログラム
%  subplot(2,1,2)
subplot(3,1,[2,3])
surface(tms,frq,abs(cfs))
colorbar('southoutside')
axis tight
shading flat
xlabel('Time (s)')
ylabel('Frequency (Hz)')
set(gca,'yscale','log')
c = colorbar('southoutside');
c.Label.String = 'Power';
ax = gca;
ax.TickDir = 'out';
%   見やすくするため、y軸の範囲を限定（予め絞り込んでから）
%     ylim([10,100])
%     yticks([10 20 30 40 50 60 70 80 90 100])
wlplot = 'null';
fileName = replace(desc,'.','r');% ファイル名に . が入るのを阻止
savefig(fileName);
saveas(gcf,strcat(fileName,'.png'));
end
%%
% T = 1/Fs;             % Sampling period
% L = 10000;             % Length of signal
% t = (0:L-1)*T;        % Time vector
% Y = fft(Mx{3,2}(:,1));
% P2 = abs(Y/L);
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% f = Fs*(0:(L/2))/L;
% plot(f,P1)
% title('Single-Sided Amplitude Spectrum of X(t)')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')
%
%
%
%
% [pxx, f] = periodogram(Mx{3,2}(:,1), Fs);
% periodogram(Mx{3,2}(:,1))
