%% wavelet analyze
% subplot(3,1,1);
% stackedplot(TT1(:,1));
% subplot(3,1,2);
% stackedplot(TT1(:,2));
% subplot(3,1,3);
% stackedplot(TT1(:,3));
% 
% % 連続ウェーブレット変換
% cwt(TT1(:,1))
% cwt(TT1(:,2))
% cwt(TT1(:,3))

%% サブプロット https://jp.mathworks.com/help/wavelet/ref/cwt.html
% 0117 1,2,3,4,=neck_walk_x, leg_walk_x, arm_gun_x. neck_gun_x
close all;

% clear;
% v2_ImportFromTektronix
% 
% % Fs = 2500;
% % vibname = 'Hapbeat';
% % vibname = 'Haptuator';
% vibname='';
% positon = 'neck-'; action = 'walk-';
% wlplot = waveletPlot(Mx{1,1}(:,1),Fs, strcat(positon, action,'x', vibname));
% wlplot = waveletPlot(Mx{1,1}(:,2),Fs, strcat(positon, action,'y', vibname));
% wlplot = waveletPlot(Mx{1,1}(:,3),Fs, strcat(positon, action,'z', vibname));
% positon = 'leg-'; action = 'walk-';
% wlplot = waveletPlot(Mx{2,1}(:,1),Fs, strcat(positon, action,'x', vibname));
% wlplot = waveletPlot(Mx{2,1}(:,2),Fs, strcat(positon, action,'y', vibname));
% wlplot = waveletPlot(Mx{2,1}(:,3),Fs, strcat(positon, action,'z', vibname));
% positon = 'arm-'; action = 'gun-';
% wlplot = waveletPlot(Mx{3,1}(:,1),Fs, strcat(positon, action,'x', vibname));
% wlplot = waveletPlot(Mx{3,1}(:,2),Fs, strcat(positon, action,'y', vibname));
% wlplot = waveletPlot(Mx{3,1}(:,3),Fs, strcat(positon, action,'z', vibname));
% positon = 'neck-'; action = 'gun-';
% wlplot = waveletPlot(Mx{4,1}(:,1),Fs, strcat(positon, action,'x', vibname));
% wlplot = waveletPlot(Mx{4,1}(:,2),Fs, strcat(positon, action,'y', vibname));
% wlplot = waveletPlot(Mx{4,1}(:,3),Fs, strcat(positon, action,'z', vibname));


%%
% mpc3008_import
% Fsはmcp3008_importで定義

t = size(Mx{1,3});
len = t(1,1);
% action = 'gun-';
action = 'walk-';

% gun-neck import
positon = 'neck-'; 
y = Mx{1,3}(1000:len-1000,1); axis = 'x';
wlplot = waveletPlot(y,Fs,strcat(positon,action,axis));
y = Mx{2,3}(1000:len-1000,1); axis = 'y';
wlplot = waveletPlot(y,Fs,strcat(positon,action,axis));
z = Mx{3,3}(1000:len-1000,1); axis = 'z';
wlplot = waveletPlot(y,Fs,strcat(positon,action,axis));

positon = 'leg-';
% positon = 'arm-';
y = Mx{4,3}(1000:len-1000,1); axis = 'x';
wlplot = waveletPlot(y,Fs,strcat(positon,action,axis));
y = Mx{5,3}(1000:len-1000,1); axis = 'y';
wlplot = waveletPlot(y,Fs,strcat(positon,action,axis));
y = Mx{6,3}(1000:len-1000,1); axis = 'z';
wlplot = waveletPlot(y,Fs,strcat(positon,action,axis));

%%
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
