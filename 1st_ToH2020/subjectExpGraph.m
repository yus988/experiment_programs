%% 被験者実験の実験結果をimportして棒グラフ化する。
% ★実験データ\■3被験者実験\★MeanStd\Tシャツ\1T_Front で実行
% 必要データを回数ごとに1,2,3...のようにフォルダを作り、データを格納。1,2,3フォルダの1階層上で実施
% rootにtxtファイルが必要

clear
close all
RMS_Cell = cell(1,1);% RMSをx,y,z,sumでインポートするためのセル
Mean_Cell = cell(1,1);% RMS_cell から平均取得
Std_Cell = cell(1,1);% RMS_cell から標準誤差取得
cd_times = 1; % ディレクトリを動いた回数
actType =  dir('*.txt'); % vp2.txt or hapbeat.txt
arrMeanStd = zeros(1,2); % spreadsheetに張り付ける用の、mean,stdをまとめた行列。

% 測定回数
% maxLoops = 3; % 1人の場合
maxLoops = 6; % 被験者実験の場合

% folder1 = '1';
% folder2 = '2';
% folder3 = '3';
% folder4 = '4';
% folder5 = '5';
% folder6 = '6';

% 体脂肪率順
folder1 = 'sub3';
folder2 = 'sub4';
folder3 = 'sub2';
folder4 = 'sub5';
folder5 = 'sub1';
folder6 = 'sub6';

% 身長順
% folder1 = 'sub4';
% folder2 = 'sub2';
% folder3 = 'sub5';
% folder4 = 'sub6';
% folder5 = 'sub1';
% folder6 = 'sub3';

%% 生データを集計
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
        for cd_times = 1:5
            %各試行ごとに、改正先のフォルダへ移動
            if cd_times == 1 
                cd '20Hz_0W';
            elseif cd_times == 2
                cd '20Hz_1W';
            elseif cd_times == 3
                cd '20Hz_2W';
            elseif cd_times == 4
                cd '80Hz_1W';
             elseif cd_times == 5
                cd '140Hz_1W';
            end
            HumanPointsAccImport % 取り込み処理
            % 行＝信号の種類、列＝試行回数/別の被験者
            RMS_Cell{cd_times, whole_times} = RMS_column; %RMS値を格納
            cd .. 
        end
    cd ..
end
save;

%% 参加者全員分のデータを測定点ごとにまとめる

% ylimMax=60; 
ylimMax=70; % 80, 140Hz

% clothType = 'T-shirt';
clothType = "Dress-shirt";

GraphCell = cell(1,1); % {行：列}＝測定点#：信号の種類, (行：列)=測定点：人
close all
locate =  dir('*.txt');

locationNum = size(RMS_Cell{1,1},1); %測定点の数、17=前面、
for sigType = 1:5
    for pointNum = 1:locationNum % 測定点の数
        for subNum = 1: maxLoops
            GraphCell{sigType,1}(pointNum,subNum) = RMS_Cell{sigType,subNum}(pointNum,4);
        end
    end
end

skinGraphCell=GraphCell;
for i=1:5
    skinGraphCell{i,1}(5,:)=[];
    skinGraphCell{i,1}(5,:)=[];
end

save;


%% matをロードしてグラフの描画はここから

for sigType = 1:5
    
    figure
    ax = gca; % current axes
    
%     % 完全版
%     bar(GraphCell{sigType,1})
%     ax.XTick = 0:1:size(RMS_Cell{1,1},1);
%     %         前面
% %         width = 1440;
%     %         側面・背面
%     width = 960;
%     height =540;
    
    % 皮膚上のみ
        bar(skinGraphCell{sigType,1})%
        ax.XTick = 0:1:size(RMS_Cell{1,1},1);
       xticklabels({'1','2','3','4','7'})
        width = 540;
        height =540;

    if(strcmp(locate.name,'front.txt'))
        locateText = 'Front'; 
    elseif(strcmp(locate.name,'side.txt'))
        locateText = 'Side';
    elseif(strcmp(locate.name,'back.txt'))
        locateText = 'Back';
    end
    
    if sigType == 1
        signalText = '20Hz-0.5W';
    elseif sigType == 2
        signalText = '20Hz-1W';
    elseif sigType == 3
        signalText = '20Hz-2W';
    elseif sigType == 4
        signalText = '80Hz-1W';
    elseif sigType == 5
        signalText = '140Hz-1W';
    end
    
    % この時点ではcell型
    titleText = strcat(clothType,'-',locateText,'-',signalText);
    ax.FontSize=24;

    legend('sub1','sub2','sub3','sub4','sub5','sub6');
    title(titleText)
%  title('Dress-shirt-Back-20Hz-0.5W')
 
    xlabel('Number of measuring point')
    ylabel('RMS value of acceleration (m/s^{2})')
 
    ax.YLim = [0 ylimMax];
%     hline = refline([0 10]);
    set(gcf,'position',[0,0,width,height])
    saveas(gca,strcat(titleText,".fig"))
    saveas(gca,strcat(titleText,".png"))
end

