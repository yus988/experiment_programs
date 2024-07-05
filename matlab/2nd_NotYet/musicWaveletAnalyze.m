%% 音楽ファイルを対象とした wavelet analyze 

% サブプロット https://jp.mathworks.com/help/wavelet/ref/cwt.html
close all;

list = dir('*.mp3');
[data, Fs] = audioread(list(1).name);

%% 
% fs = 44100; % wavのサンプル周波数
fr = 2000; % 変更するサンプリングレート
x = data(:,1);
[P,Q] = rat(fr/Fs);
abs(P/Q*Fs-fr);
xnew  = resample(x,P,Q);

subplot(2,1,1)
plot((0:length(x)-1)/Fs,x)
subplot(2,1,2)
plot((0:length(xnew )-1)/(P/Q*Fs),xnew )


spectrogram(x,256,250,256,fs,'yaxis')

TT = timetable(x,'SampleRate',fs);
%音を鳴らす
% sound(x,fs)
% sound(xnew,fs)
%  sound(xnew,fs)

% y=data([10000:11000],1);


%%
wlplot = waveletPlot(xnew,fr,'test');


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
    subplot(2,1,1)
    plot(tms,y)
    axis tight
    title(desc)
    xlabel('Time (s)')
    ylabel('Amplitude')
    
%  cwt結果のスカログラム
    subplot(2,1,2)
    surface(tms,frq,abs(cfs))
    axis tight
    shading flat
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
    set(gca,'yscale','log')
    
%   見やすくするため、y軸の範囲を限定（予め絞り込んでから）
%     ylim([10,100])
%     yticks([10 20 30 40 50 60 70 80 90 100])
    ax = gca;
    ax.TickDir = 'out';
    wlplot = 'null';
    savefig(desc);
    saveas(gcf,strcat(desc,'.png'));
end