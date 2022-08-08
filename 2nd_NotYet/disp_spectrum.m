%% import files

[a_inst, Fs] = audioread("1_Lisztomania_Inst_-14lufs.mp3",'native');
[a_vox, Fs] =  audioread("1_Lisztomania_Vox_-14lufs.mp3",'native');
[b_inst, Fs] = audioread("7_Countdown_Inst_-14lufs.mp3",'native');
[b_vox, Fs] =  audioread("7_Countdown_Vox_-14lufs.mp3",'native');

TT_a_vox = timetable(a_vox, 'SampleRate', Fs);
TT_a_inst = timetable(a_inst, 'SampleRate', Fs);
TT_b_vox = timetable(b_vox, 'SampleRate', Fs);
TT_b_inst = timetable(b_inst, 'SampleRate', Fs);

save;


%% グラフ描画
close all;
figure;
subplot(2,1,1);
% t = TT_a_vox.Time;
% y = TT_a_vox.a_vox(:,1);

t = TT_a_inst.Time;
x = TT_a_inst.a_inst(:,1);

plot(t, x);
% subplot(2,1,2);

% figure;
% % spectrogram(y,[],[],[],Fs,'yaxis');
% % set(gca,'yscale','log')
% % ax = gca;
% % ylim([1 1000])
%
% % plot(TT_b_vox.Time, TT_b_vox.b_vox(:,1));
% % t = TT_a_vox.Time;
% x = TT_a_vox.a_vox(:,1);
% [ X, f, t, S ] = spectrogram( x, 128, 120, 128, Fs );
% save;

%% calc spectrum

% 8192 sample 50%overlapping Hann windows
window = hann(8192); % default hamming window
noverlap = []; % 50%のオーバーラップが
nfft =[]; % max(256,2p)
% x = TT_a_vox.a_vox(:,1);
x = TT_a_inst.a_inst(:,1);
save;
[X, f, t, S] = spectrogram(x,window,noverlap,nfft,Fs);




length = 8192;
[ywinhat,fw2,t2,P2] = spectrogram(x,length,noverlap,nfft,Fs);
S2 = P2*Fs/length;

SdB2 = 10*log10(S2); % Convert spectral power to decibel scale
subplot(2,1,1)
image(t2,fw2,SdB2,'CDataMapping','scaled')  %CDataMapping=scaled
% uses the range of values of SdB2 to make the color scale.

axis xy % Puts low frequencies at the bottom
colorbar
% [s,f,t]


%% t
length = 8192;
stft(x,Fs,'Window',hanning(length,'periodic'),'OverlapLength',length/2,'FFTLength',length*2, 'FrequencyRange', 'onesided');


%% plot figure
close all
figure('Position',[0 -700 1080 720]);
for i=1:2
    subplot(4,1,2*i-1);
    % t = TT_a_vox.Time;
    % y = TT_a_vox.a_vox(:,1);

%     % track-A
%     if i ==1
%         t = TT_a_vox.Time;
%         x = TT_a_vox.a_vox(:,1);
%     else
%         t = TT_a_inst.Time;
%         x = TT_a_inst.a_inst(:,1);
%     end

%     track-B
    if i ==1
        t = TT_b_vox.Time;
        x = TT_b_vox.b_vox(:,1);
    else
        t = TT_b_inst.Time;
        x = TT_b_inst.b_inst(:,1);
    end

    plot(t, x);
    xlim([t(1,1) t(size(t,1),1)])
    xticks([minutes(0:4)])
    set(gca,'TickDir','out')

    % スペクトログラム描画
    subplot(4,1,2*i);
    noverlap = []; % 50%のオーバーラップが
    nfft =[]; % max(256,2p)
    length = 8192;
    spectrogram(x,length,noverlap,nfft,Fs,'yaxis');

    set(gca,'yscale','log');
    ylim([10/1000 1000/1000])
    caxis([-80 -20])
    colorbar('off')
end

%% カラーバーコピー
figure
spectrogram(x,length,noverlap,nfft,Fs,'yaxis');
% [X, F, T, S] = spectrogram(x,length,noverlap,nfft,Fs);

set(gca,'TickDir','out')
% caxis([-80 -20])
% caxis('auto')
set(gca,'yscale','log');
ylim([10/1000 1000/1000])
c = colorbar;
c.TickDirection = 'out';

subplot(4,1,2)
ylim([0.1 10])




% window = hann(8192); % default hamming window

% title('Evolutionary Power Spectrum')
% ylabel('Frequency (Hz)')
% xlabel('Time (s)')
% caxis([-5 2])
% c = colorbar;
% c.Label.String = 'Power (dB)';


% axis xy
% xlabel( 'time (s)' )
% ylabel( 'frequency (Hz)' )
% set(gca,'yscale','log')
% ax = gca;
% ylim([1 1000])
%
% imagesc( t, f, pow2db( S ) )


% % パラメーター
% timeLimits = seconds([0 242.0647]); % 秒
% frequencyLimits = [0 100]; % Hz
% overlapPercent = 50;
%
% %%
% % 対象の信号時間領域へのインデックス
% TT_a_vox_a_vox_1_ROI = TT_a_vox.a_vox(:,1);
% timeValues = TT_a_vox.Properties.RowTimes;
% TT_a_vox_a_vox_1_ROI = timetable(timeValues,TT_a_vox_a_vox_1_ROI,'VariableNames',{'Data'});
% TT_a_vox_a_vox_1_ROI = TT_a_vox_a_vox_1_ROI(timerange(timeLimits(1),timeLimits(2),'closed'),1);
%
% % スペクトル推定の計算
% % 以下の関数呼び出しを出力引数なしで実行して結果をプロットします
% [P,F,T] = pspectrum(TT_a_vox_a_vox_1_ROI, ...
%     'spectrogram', ...
%     'FrequencyLimits',frequencyLimits, ...
%     'OverlapPercent',overlapPercent);
