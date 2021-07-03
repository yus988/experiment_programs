% 各試行の波形に対してwavelet変換を行う
% csvファイルが入っているフォルダで実行


%% 以下各測定結果ファイルごとの処理
clear
Mx = cell(1,1);
cellResult = cell(zeros(1));

Fs = 1e3;%サンプル周波数
t = 0:1/Fs:1;
%加速度センサの感度
% V2G6 = 0.660 /9.80665; % EH2016用 KXR94-2050
V2G6 = 0.206 /9.80665; %MMA7361L 6Gモード = v/g v / (g*9.80665)
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
    %     Mx{k,1}= csvread(list1e4(i).name,21,1,[21,1,3020,3]); %t WTV用temp
    Mx{k,1}= csvread(list1e4(i).name,21,1,[21,1,10020,4]);
    % オフセット除去（すべての要素から平均値を引く）
    Mx{k,2}(:,1) = ( Mx{k,1}(:,1) - mean(Mx{k,1}(:,1)) ) / V2G6; %下に引っ張った時を正に（標準では負）
    Mx{k,2}(:,2) = ( Mx{k,1}(:,2) - mean(Mx{k,1}(:,2)) ) / V2G6;
    Mx{k,2}(:,3) = ( Mx{k,1}(:,3) - mean(Mx{k,1}(:,3)) ) / V2G6;
    
    if size(Mx{1,1},2) > 3
        Mx{k,2}(:,4) = ( Mx{k,1}(:,4) - mean(Mx{k,1}(:,4)) );
        [thd_db, harmpow, harmfreq] = thd(Mx{k,1}(:,4), Fs, nharm);
        Mx{k,3} = harmfreq(1,1);
        input_Hz = harmfreq(1,1);
    end
    Mx{k,4} =  rms((Mx{k,2}(:,1))) + rms((Mx{k,2}(:,2)))+rms((Mx{k,2}(:,3)));%3軸RMS値
    Mx{k,5} = list1e4(i).name;
    
    Mx{k,6} = timetable(Mx{k,2}(:,1), Mx{k,2}(:,2), Mx{k,2}(:,3),'SampleRate',Fs);
    Mx{k,6}.Properties.VariableNames{'Var1'}='x' ;
    Mx{k,6}.Properties.VariableNames{'Var2'}='y' ;
    Mx{k,6}.Properties.VariableNames{'Var3'}='z' ;
    
%   各列を2回積分して変位に
    temp = 1/Fs * cumtrapz(xyz);
    temp = temp - mean(temp);
    XYZ = 1/fs * cumtrapz(temp) * 9.80665 * 1e6;
    F(:,i) = XYZ;
end
%%
% Fs = 1e3;
% x = 0:1/Fs:9.9999;
% acc = Mx{6,2}(:,1);
Fs = 1e4;
x = 0:1/Fs:0.9999;
acc = Mx{19,2}(:,1);
% acc = Mx{30,2}(:,1);

filtFreq = 33/2;
close all 
figure

row = 2; col = 3;
subplot(row,col,1)
acc = acc-mean(acc);
% acc = highpass(acc,filtFreq,Fs,'Steepness',0.85,'StopbandAttenuation',60);
plot(x,acc);
title('acc');

subplot(row,col,2)
vel = cumtrapz(1/Fs,acc);
vel = vel-mean(vel);
% vel = highpass(vel,filtFreq,Fs,'Steepness',0.85,'StopbandAttenuation',60);
plot(x,vel);
title('vel');

subplot(row,col,3)
dis = cumtrapz(1/Fs,vel);
dis = dis-mean(dis);
dis = highpass(dis,filtFreq,Fs,'Steepness',0.9999,'StopbandAttenuation',60);
plot(x,dis)
title('dis');

TT = timetable(acc,vel,dis,'SampleRate',Fs);


subplot(row,col,4)
[pxx,f] = pspectrum(TT(:,1));
plot(f,pow2db(pxx));
xlabel('Frequency (Hz)')
ylabel('Power Spectrum (dB)')
set(gca,'xscale','log')
title('acc');
xlim([1 1000])

subplot(row,col,5)
[pxx,f] = pspectrum(TT(:,2));
plot(f,pow2db(pxx));
xlabel('Frequency (Hz)')
ylabel('Power Spectrum (dB)')
set(gca,'xscale','log')
title('vel');
xlim([1 1000])

subplot(row,col,6)
[pxx,f] = pspectrum(TT(:,3));
plot(f,pow2db(pxx));
xlabel('Frequency (Hz)')
ylabel('Power Spectrum (dB)')
set(gca,'xscale','log')
title('dis');
xlim([1 1000])

% TT.Properties.VariableNames{'Var1'}='acc' ;
% TT.Properties.VariableNames{'Var2'}='vel' ;
% TT.Properties.VariableNames{'Var3'}='dis' ;

%% パワースペクトラム
close all
type =  erase(dir('*.txt').name,'.txt');

Fs = 1e3;
for freq = 1:3
    if freq == 1
        axis = 'x';
    elseif freq == 2
        axis = 'y';
    elseif freq == 3
        axis = 'z';
    end
    for i = 1:size(Mx,1)
        % 1 ~ 10 Hz の測定を行った時のみ
        if Mx{i,3} < 9
            Fs = 1e3;
            Freq = num2str(round(Mx{i,3},1));
        else
            Fs = 1e4;
            %             Fs = 1e3; % EH2016のデータ専用
            Freq = num2str(round(Mx{i,3}));
        end
        y = Mx{i,2}(:,freq);
        if ~isfolder('powerSpectrum')
            mkdir('powerSpectrum')
        end
        cd powerSpectrum
        if ~isfolder(axis)
            mkdir(axis)
        end
        cd (axis)
        locate = num2str(i);
        TT = Mx{i,6}(:,freq);
        powerSpectrumPlot(TT,Fs,axis,strcat(Freq,' Hz','-', axis,'-',type,'-locate-',locate));
        close
        cd ../..
        
    end
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




%% wavelet analyze
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
