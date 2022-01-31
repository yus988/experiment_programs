%% GM1356から収集したデータからLAeqとピークをグラフ化するプログラム

freq = [1; 1.2; 1.5; 1.8; 2.2; 2.7;3.3;3.9;4.7;5.6;6.8;8.2;
    10; 12;15;18;22;27;33;39;47;56;68;82;
    100; 120;150;180;220;270;330;390;470;560;680;820;1000]; %周波数配列
lpfFreq=[100; 120;150;180;220;270;330;390;470;560;680;820;1000];
graphArr = zeros(numFiles,3);
Mx = cell(numFiles,2);% インポート用のセル

for k = 0:1
    if k == 1
        cd LPF
    end
    list = dir('*.csv');
    numFiles = length(list);
    
    for i = 1:numFiles
        tmp = readmatrix(list(i).name);
        %データサイズを導出、最後から20秒分のデータのみ残す
        sz = size(tmp,1);
        del = sz-20; %消す範囲
        tmp(1:del,:) = []; %初めの方のデータを削除
        Mx{i,4*k+1} = tmp;
        Mx{i,4*k+2} = freq(i,1);
        if k == 0
            graphArr(i,3*k+1) =  freq(i,1);
        else
            graphArr(i,3*k+1) =  lpfFreq(i,1);
        end
        
        Mx{i,4*k+3} = mean(tmp(:,2));
        graphArr(i,3*k+2) =  mean(tmp(:,2));
        Mx{i,4*k+4} = max(tmp(:,2));
        graphArr(i,3*k+3) =   max(tmp(:,2));
    end
    
    if k == 1
        cd ..
    end
end


%% グラフ描画

close all
width =1280;
height = 720;
figure('Position',[10 10 width height]);
hold on

% LPF無しプロット
lineColor = 'black';
y1 = graphArr(:,2);
y2 = graphArr(:,3);
plot(graphArr(:,1), y1, 'Color',lineColor, ...
    'Marker', 'o','MarkerSize',4,'MarkerFaceColor',lineColor);

% LPF有りプロット
y3 = graphArr(:,2);
lineColor = 'blue';
plot(graphArr(:,4), y1, 'Color',lineColor, ...
    'Marker', 'o','MarkerSize',4,'MarkerFaceColor',lineColor);
% plot(graphArr(:,1), y2, 'Color',lineColor, ...
%     'Marker', 'o','MarkerSize',4,'MarkerFaceColor',lineColor);
% 軸の調整
set(gca,'XScale','log')
set(gca,'YScale','log')

labelFont = 24;
xticklabels('manual');
xticklabels({[1 10  100 1000]});
ax = gca; % current axes
ax.FontSize = labelFont;
ax.XAxis.TickDirection  = 'out';
ax.XAxis.TickLength = [0.02 0.0];
xlim([0 1000])

xlabel('Frequency (Hz)','FontSize',labelFont)
ylabel('Sound Pressure level (dB)','FontSize',labelFont)