% ルートフォルダで実行■1定量実験\0422Hapbeat重さ実験\Back

clear
Mx = cell(1,1);
cellResult = cell(zeros(1));

for cd_times = 1:7
    %% フォルダの移動
    if cd_times == 1
        folderName = '0g';
    elseif cd_times == 2
        folderName =  '20g';
    elseif cd_times == 3
        folderName =  '40g';
    elseif cd_times == 4
        folderName =  '60g';
    elseif cd_times == 5
        folderName =  '80g';
    elseif cd_times == 6
        folderName =  '100g';
    elseif cd_times == 7
        folderName =  '120g';
    end
    cd (folderName);
    
    %% 以下各測定結果ファイルごとの処理
    Fs = 1e3;%サンプル周波数
    t = 0:1/Fs:1;
    %加速度センサの感度
    V2G6 = 0.206 /9.80665; %MMA7361L 6Gモード = v/g v / (g*9.80665)
    nharm = 6;%thdの高調波数
    list1e4 = dir('*.csv');%サンプリングレート10kHzのデータ
    numFiles1e4 = length(list1e4);

    list = dir('*.csv');
    numFiles = length(list);

    Fs = 1e4;%サンプル周波数
    %% サンプリングレート10kHzのデータを記録
    for k = 1:numFiles1e4
        Mx{k,1}= csvread(list1e4(k).name,21,1,[21,1,10020,4]);
        % オフセット除去（すべての要素から平均値を引く）
        Mx{k,2}(:,1) = ( Mx{k,1}(:,1) - mean(Mx{k,1}(:,1)) ) / V2G6; %下に引っ張った時を正に（標準では負）
        Mx{k,2}(:,2) = ( Mx{k,1}(:,2) - mean(Mx{k,1}(:,2)) ) / V2G6;
        Mx{k,2}(:,3) = ( Mx{k,1}(:,3) - mean(Mx{k,1}(:,3)) ) / V2G6;
        Mx{k,2}(:,4) = ( Mx{k,1}(:,4) - mean(Mx{k,1}(:,4)) );
        [thd_db, harmpow, harmfreq] = thd(Mx{k,1}(:,4), Fs, nharm);
        
        Mx{k,3} = harmfreq(1,1);
        input_Hz = harmfreq(1,1);
        Mx{k,4} =  rms((Mx{k,2}(:,1))) + rms((Mx{k,2}(:,2)))+rms((Mx{k,2}(:,3)));%3軸RMS値
        Vin = 2*sqrt(2)*rms((Mx{k,1}(:,4)));
        Mx{k,5} = Vin;
        cellResult{cd_times,1}(k,1) = Mx{k,3};
        cellResult{cd_times,1}(k,2) = Mx{k,4};
        cellResult{cd_times,1}(k,3) = Mx{k,5};
    end
    cd ..
end % for cd_times = 1:6 の終わり

save;

%%
tmpArr = zeros(1,1); % 1:20Hz-0W, 2:20Hz-1W, 3:20Hz-2W 4:80Hz-1W, 5:80Hz-1W
arrPlot = zeros(1,1);
for typeLoop = 1:7 % 重さの種類分回す
    arrTar = cellResult{typeLoop,1};
    for i = 1 : size(cellResult{1,1},1)
        if arrTar(i,1) > 19 && arrTar(i,1) < 21
            if arrTar(i,3) > 0.16 && arrTar(i,3) < 0.18
                tmpArr(i,1) = arrTar(i,2); 
            elseif arrTar(i,3) > 0.23 && arrTar(i,3) < 0.25
                tmpArr(i,2) = arrTar(i,2);
            elseif arrTar(i,3) > 0.34 && arrTar(i,3) < 0.36
                tmpArr(i,3) = arrTar(i,2);
            end
        elseif arrTar(i,1) > 79 && arrTar(i,1) < 81
                tmpArr(i,4) = arrTar(i,2);
        elseif arrTar(i,1) > 139 && arrTar(i,1) < 141
                tmpArr(i,5) = arrTar(i,2);
        end            
    end
    tmpArr = sort(tmpArr,'descend');
    for k = 1:5
%       meat, std の順で並べる
        arrPlot(typeLoop, 2*k-1) = mean(tmpArr((1:3),k)); 
        arrPlot(typeLoop,2*k) = std(tmpArr((1:3),k));
    end
    tmpArr = zeros(1,1); % 1:20Hz-0W, 2:20Hz-1W, 3:20Hz-2W 4:80Hz-1W, 5:80Hz-1W
end

%%
close all

figure
% mass = [0 20 40 60 80 100 120];
mass = [58.5 78.5 98.5 118.5 138.5 158.5 178.5];

hold on
for k = 1:5
    if k == 1
        lineColor = '#ffd700'; %黄色
    elseif k == 2
        lineColor = '#FFA500'; %オレンジ
    elseif k == 3
        lineColor = '#FF0000'; %赤
    elseif k == 4
        lineColor = '#0000FF'; %青色
    elseif k == 5 
        lineColor = '#FF00FF'; %マゼンタ 
    end
        
    errorbar(mass, arrPlot(:,2 * k -1),arrPlot(:,2*k), ...
       'Color',lineColor,'LineWidth',1, ... 
       'Marker','o', 'MarkerSize',4,'MarkerFaceColor',lineColor);
end
legend('20Hz-0.5W', '20Hz-1W', '20Hz-2W', '80Hz-1W', '140Hz-1W');
hold off
xlabel('Housing mass (g)')
ylabel('RMS value of triaxial acceleration (m/s^{2})')
ax = gca;
ax.XLim = [58.5 178.5];

xticks([58.5 78.5 98.5 118.5 138.5 158.5 178.5])
ax.YLim = [0 70];

set( gca, 'FontName','Tahoma','FontSize',15 ); 

saveas(gca,'figure.fig');



% %% グラフ描画用のcell作成（平均、標準偏差）
% 
% cellPlot = cell(1,1); % freq mean std
% tmp = zeros(1,1);
% 
% for posLoop = 1:6
%     for i = 1 : size(cellResult{posLoop,1},1)
%         for exeLoop = 1:3
%             tmp(exeLoop,1) =  cellResult{posLoop,exeLoop}(i,2);
%         end
%         cellPlot{posLoop,1}(i,1) = cellResult{posLoop,1}(i,1);
%         cellPlot{posLoop,1}(i,2) = mean(tmp);
%         cellPlot{posLoop,1}(i,3) = std(tmp);
%     end
% end
% 
% 
% %% グラフ描画
% 
% close all
% 
% for i = 1:6
%     tmp = sortrows(cellPlot{i,1});
%     if i == 1  %'Hapbeat enclosure';
%         markerColor = 'red';
%         lineColor = 'red';
%         lineStyle = '-';
%     elseif i == 2  %'Hapbeat front';
%         lineColor = '#00ff00';
%         lineStyle = '-';
%     elseif i == 3  %'Hapbeat side';
%         lineColor = '#ff00ff';
%         lineStyle = '-';
%     elseif i == 4  %'Hapbeat back';
%         lineColor = '#8b4513';
%         lineStyle = '-';
%     elseif i == 5  %'Vp2 enclosure';
%         markerColor = 'blue';
%         lineColor = 'blue';
%         lineStyle = '-';
%     elseif i == 6  %'Vp2 1cm apart';
%         lineColor = '#00008b';
%         lineStyle = '-';
%     end
%     marker = 'o';
%     errorbar(tmp(:,1),tmp(:,2),tmp(:,3),'Color',lineColor,'LineStyle',lineStyle, ...
%         'Marker',marker,'MarkerSize',4,'MarkerFaceColor',lineColor);
%     hold on
% end
% % 軸の調整
% set(gca,'XScale','log')
% labelFont = 24;
% xticklabels('manual');
% xticklabels({[1 10  100 1000]});
% ax = gca; % current axes
% ax.FontSize = labelFont;
% ax.XAxis.TickDirection  = 'out';
% ax.XAxis.TickLength = [0.04 0.0];
% hline = refline([0 1]);
% 
% % ax.YLim = [0 11];
% % ax.YAxis.TickValues = [0:11];
% % ax.XAxis.TickValues = [1 2 3 4 5 6 7 8 9 10 20 30 40 50 60 70 80 90 100 200 300 400 500 600 700 800 900 1000];
% 
% xlabel('Frequency (Hz)','FontSize',labelFont)
% ylabel('Acceleration amplitude (G)','FontSize',labelFont)
% 
% 
% grid on
% TickDir = 'out';
% 
% % legend(legendArray)
% legend('Hapbeat housing','Hapbeat front','Hapbeat side','Hapbeat back','Vp2 enclosure','Vp2 1cm apart')


%     if cd_times == 1
%             folderName = 'Hapbeat本体';
%     elseif cd_times == 2
%             folderName =  'Hapbeat前面';
%     elseif cd_times == 3
%             folderName =  'Hapbeat側面';
%     elseif cd_times == 4
%             folderName =  'Hapbeat背面';
%     elseif cd_times == 5
%             folderName =  'Vp2本体';
%     elseif cd_times == 6
%             folderName =  'Vp2-1cm';


% semilogx(graphCell{1,1}(:,1),graphCell{1,1}(:,2), ...
%     graphCell{2,1}(:,1),graphCell{2,1}(:,2), ...
%     graphCell{3,1}(:,1),graphCell{3,1}(:,2), ...
%     graphCell{4,1}(:,1),graphCell{4,1}(:,2), ...
%     graphCell{5,1}(:,1),graphCell{5,1}(:,2), ...
%     graphCell{6,1}(:,1),graphCell{6,1}(:,2));
%
%
% figure
% tmp = sortrows(graphCell{4,1});
% semilogx(graphCell{4,1}(:,1),graphCell{4,1}(:,2));
% semilogx(sortrows{4,1}(:,1),graphCell{4,1}(:,2));
%
% semilogx(tmp(:,1),tmp(:,2));

