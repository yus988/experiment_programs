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
end

%% wavelet analyze
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
        if ~isfolder('wavelet')
            mkdir('wavelet')
        end
        cd wavelet
        if ~isfolder(axis)
            mkdir(axis)
        end
        cd (axis)
%         wlplot = waveletPlot(y,Fs,strcat(Freq,' Hz','-', axis,'-',type));
        locate = num2str(i);
        wlplot = waveletPlot(y,Fs,strcat(Freq,' Hz','-', axis,'-',type,'-locate-',locate));

        close
        cd ../..
        
    end
end

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
%% 全てのデータを一枚にプロット（アーカイブ）
% 最初は楽だが、その後データを動かしたりするときに不便。また重い。
% 
% % 0117 1,2,3,4,=neck_walk_x, leg_walk_x, arm_gun_x. neck_gun_x
% v2_ImportFromTektronix
% close all;
% Fs = 2500;
% figure('Name','test','NumberTitle','off','Position',[0 0 2560 1440]);
% % 全てを1枚に入れる
% % 1,2,3,4,5,6,7,8,9,10,11,12
% vibname='';
% positon = 'neck-'; action = 'walk-';
% % 1,2,3,7,8,9,13,14,15,19,20,21
% wlplot = waveletPlot(Mx{1,1}(:,1),Fs, strcat(positon, action,'x', vibname) ,1);
% wlplot = waveletPlot(Mx{1,1}(:,2),Fs, strcat(positon, action,'y', vibname) ,2);
% wlplot = waveletPlot(Mx{1,1}(:,3),Fs, strcat(positon, action,'z', vibname) ,3);
% positon = 'leg-'; action = 'walk-';
% wlplot = waveletPlot(Mx{2,1}(:,1),Fs, strcat(positon, action,'x', vibname) ,7);
% wlplot = waveletPlot(Mx{2,1}(:,2),Fs, strcat(positon, action,'y', vibname) ,8);
% wlplot = waveletPlot(Mx{2,1}(:,3),Fs, strcat(positon, action,'z', vibname) ,9);
% positon = 'arm-'; action = 'gun-';
% wlplot = waveletPlot(Mx{3,1}(:,1),Fs, strcat(positon, action,'x', vibname) ,13);
% wlplot = waveletPlot(Mx{3,1}(:,2),Fs, strcat(positon, action,'y', vibname) ,14);
% wlplot = waveletPlot(Mx{3,1}(:,3),Fs, strcat(positon, action,'z', vibname) ,15);
% positon = 'neck-'; action = 'gun-';
% wlplot = waveletPlot(Mx{4,1}(:,1),Fs, strcat(positon, action,'x', vibname) ,19);
% wlplot = waveletPlot(Mx{4,1}(:,2),Fs, strcat(positon, action,'y', vibname) ,20);
% wlplot = waveletPlot(Mx{4,1}(:,3),Fs, strcat(positon, action,'z', vibname) ,21);
% 
% 
% function wlplot = waveletPlot(y,Fs,desc, id) % データ、サンプリングレート,グラフタイトル
% %  cwt単体のグラフ生成
% %     figure('Name',strcat(desc,'-cwt'),'NumberTitle','off');
% %     cwt(y,Fs);
%     % 信号の連続ウェーブレット変換と CWT の周波数を求めます。
%     [cfs,frq] = cwt(y,Fs);
%     % 関数 cwt により、時間と周波数の座標軸がスカログラムで設定されます。サンプル時間を表すベクトルを作成します。
%     tms = (0:numel(y)-1)/Fs;
% %     savefig(strcat(desc,'-cwt'));
% %     saveas(gcf,strcat(desc,'-cwt','.png'));
%     
%     % 新しい Figure で、元の信号を上のサブプロットにプロットし、スカログラムを下のサブプロットにプロットします。対数スケールで周波数をプロットします。
% %     figure('Name',desc,'NumberTitle','off','Position',[0 0 960 540]);
% 
% %  解析元信号
% %  subplot のサイズ
%     rows = 3; 
%     cols = 8;
%     subplot(cols,rows,id)
% %     subplot(2,1,1)
% %     stackedplot(TT(:,1));
%     plot(tms,y)
%     axis tight
%     title(desc)
%     xlabel('Time (s)')
%     ylabel('Amplitude')
%     
% %  cwt結果のスカログラム
%  
%      subplot(cols,rows,id + 3)
% %     subplot(2,1,2)
%     surface(tms,frq,abs(cfs))
% %     axis tight
%     shading flat
%     xlabel('Time (s)')
%     ylabel('Frequency (Hz)')
%     set(gca,'yscale','log')
%     
% %   見やすくするため、y軸の範囲を限定（予め絞り込んでから）
% %     ylim([10,100])
%     ax = gca
%     ax.TickDir = 'out';
%     wlplot = 'null';
% end
% %  savefig(gcf);
%  saveas(gcf,strcat(desc,'.png'));
% 
