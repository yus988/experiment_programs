%%人体の各点の加速度測定時のファイル分け用スクリプト
% % 実験1定量評価・周波数応答のグラフの作成に使用
%%入力電圧と周波数から40/160Hz_0.5/1/2Wに分類
% ルートフォルダで実行

clear
graphCell = cell(zeros(1));

for cd_times = 1:6
    %% フォルダの移動
    if cd_times == 1
            folderName = 'Hapbeat本体';
    elseif cd_times == 2
            folderName =  'Hapbeat前面';
    elseif cd_times == 3
            folderName =  'Hapbeat側面';
    elseif cd_times == 4
            folderName =  'Hapbeat背面';
    elseif cd_times == 5
            folderName =  'Vp2本体';
    elseif cd_times == 6
            folderName =  'Vp2-1cm';
    end
    legendArray{cd_times,1} = folderName;
    cd (folderName);
    %% 以下各測定結果ファイルごとの処理
        Fs = 1e3;%サンプル周波数
        t = 0:1/Fs:1;
        %加速度センサの感度
        V2G6 = 0.206; %MMA7361L 6Gモード
        nharm = 6;%thdの高調波数
        list1e4 = dir('*.csv');%サンプリングレート10kHzのデータ
        numFiles1e4 = length(list1e4);


        %% サンプリングレート1kHzのデータを記録
        cd '1e3'

        list1e3 = dir('*.csv');%サンプリングレート1kHzのデータ

        numFiles1e3 = length(list1e3);
        Mx = cell(numFiles1e3 + numFiles1e4,2);
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
        Fs = 1e4;%サンプル周波数   
        %% サンプリングレート10kHzのデータを記録
        for i = 1:numFiles1e4
            k = i + numFiles1e3;
            Mx{k,1}= csvread(list1e4(i).name,21,1,[21,1,10020,4]);
            % オフセット除去（すべての要素から平均値を引く）
            Mx{k,2}(:,1) = ( Mx{k,1}(:,1) - mean(Mx{k,1}(:,1)) ) / V2G6; %下に引っ張った時を正に（標準では負）
            Mx{k,2}(:,2) = ( Mx{k,1}(:,2) - mean(Mx{k,1}(:,2)) ) / V2G6;
            Mx{k,2}(:,3) = ( Mx{k,1}(:,3) - mean(Mx{k,1}(:,3)) ) / V2G6;
            Mx{k,2}(:,4) = ( Mx{k,1}(:,4) - mean(Mx{k,1}(:,4)) );
            [thd_db, harmpow, harmfreq] = thd(Mx{k,1}(:,4), Fs, nharm);

            Mx{k,3} = harmfreq(1,1);
            input_Hz = harmfreq(1,1);
            Mx{k,4} =  rms((Mx{k,2}(:,1))) + rms((Mx{k,2}(:,2)))+rms((Mx{k,2}(:,3)));%3軸RMS値
            Mx{k,5} = list1e4(i).name;
        end
        
        
        for i = 1:size(Mx,1)
            graphCell{cd_times,1}(i,1) = Mx{i,3};
            graphCell{cd_times,1}(i,2) = Mx{i,4};
        end
        % 各フォルダの内容を図示（確認用）
%             figure
%             tmp = sortrows(graphCell{cd_times,1});
%             semilogx(tmp(:,1),tmp(:,2));
%             title(folderName)
        cd ..
        
end %% for cd_times = 1:6 の終わり

%% グラフ描画用のfloat行列を作成
% 
% tmp = sortrows(graphCell{4,1});
% graphArray(:,1) = tmp(:,1);
% 
% for i = 1:6
%     tmp = sortrows(graphCell{i,1});
%     graphArray(:,i+1) = tmp(:,2);
% end


%% グラフ描画

close all

for i = 1:6
    tmp = sortrows(graphCell{i,1});
    if i == 1  %'Hapbeat enclosure';
       lineColor = 'red';
       lineStyle = '--';
    elseif i == 2  %'Hapbeat front';
       lineColor = '#ff8c00';
       lineStyle = '-';
    elseif i == 3  %'Hapbeat side';
       lineColor = '#ff0000';
       lineStyle = '-';
    elseif i == 4  %'Hapbeat back';
       lineColor = '#ff1493';
       lineStyle = '-';
    elseif i == 5  %'Vp2 enclosure';
       lineColor = 'blue';
       lineStyle = '--';
    elseif i == 6  %'Vp2 1cm apart';
       lineColor = 'blue'; 
       lineStyle = '-';
    end
    marker = 'o';
    semilogx(tmp(:,1),tmp(:,2),'Color',lineColor,'LineStyle',lineStyle, ...
        'Marker',marker,'MarkerSize',4,'MarkerFaceColor',lineColor);
    hold on
end
% 軸の調整
labelFont = 24;
xticklabels('manual');
xticklabels({[1 10  100 1000]});
ax = gca; % current axes
ax.FontSize = labelFont;
ax.XAxis.TickDirection  = 'out';
ax.XAxis.TickLength = [0.04 0.0];

ax.YLim = [0 11];
ax.YAxis.TickValues = [0:11];
% ax.XAxis.TickValues = [1 2 3 4 5 6 7 8 9 10 20 30 40 50 60 70 80 90 100 200 300 400 500 600 700 800 900 1000];

xlabel('Frequency (Hz)','FontSize',labelFont)
ylabel('Acceleration amplitude (G)','FontSize',labelFont)


grid on
TickDir = 'out';

% legend(legendArray)
legend('Hapbeat enclosure','Hapbeat front','Hapbeat side','Hapbeat back','Vp2 enclosure','Vp2 1cm apart')


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

