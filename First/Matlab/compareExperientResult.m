%%出力軸、周波数軸で比較するための図を出力。各計測フォルダのルートで実施（例：7.2前面2）

clear
close all

Fs = 1e4;%サンプル周波数
t = 0:1/Fs:1;
%加速度センサの感度
V2G = 0.206; %MMA7361L 6Gモード
% V2G = 0.800; %MMA7361L 1.5Gモード
V2N = 0.01178; %力センサ5916
nharm = 6;%thdの高調波数

Analysis = cell(15);
xyz = 0;

img_list = dir('./img/*.png');
Underlayer_img = imread('./img/Underlayer.png');
% ラベル描画関連
num_pointArray =  length(img_list)-1 ; %緑マーカの列の数。imgフォルダの画像数から算出
num_points = 12;

Annotation = zeros(num_points, 3); %c_AnnotationのFloat行列
centerOfAnnotation = zeros(num_points, 2);%c_Annotationから中心座標のみ取り出し
radiulOfCircles = zeros(num_points, 1);
labels = zeros(num_points,1);
labels_x = zeros(num_points,1);
labels_y = zeros(num_points,1);
labels_z = zeros(num_points,1);
labels_sum = zeros(num_points,1);
c_Annotation = cell(num_pointArray,1); %描画用マーカー座標を入れるセル

% 前面
radius_coef = 20;%描画のため加速度(g)に掛け合わせる係数

% 側背面
% radius_coef = 10;%描画のため加速度(g)に掛け合わせる係数

lineWidth = 2;

        % 前面
        base_x = 100;
        base_y = 100;
        pos_offset = 100;
        ecolor = 'black';

% %       右側面
%         base_x = 1150;
%         base_y = 300;
%         pos_offset = 250;
%         ecolor = 'white';
      
% %       左側面
%         base_x = 280;
%         base_y = 13;
%         pos_offset = 50;
%         ecolor = 'white';
% %        
%         % 背面
%         base_x = 120;
%         base_y = 150;
%         pos_offset = 50;
%         ecolor = 'black';
% 
figure;
imshow(imread('wb.png'),'Border','tight');
viscircles([base_x  base_y], 1 * radius_coef, 'Color',ecolor,'EnhanceVisibility',false,'LineWidth',lineWidth);
viscircles([base_x  base_y + pos_offset * 0.75], 2 * radius_coef, 'Color',ecolor,'EnhanceVisibility',false,'LineWidth',lineWidth);
viscircles([base_x  base_y + pos_offset * 2], 3 * radius_coef, 'Color',ecolor,'EnhanceVisibility',false,'LineWidth',lineWidth);


%描画させる加速度。Xg: 7, Yg: 10,  Zg: 13, Sum: 15
target_row = 15;  %Sum
% target_row = 7; %Xg
% target_row = 10; %Yg
% target_row = 13; %Zg

circleLineColor = '#0072BD';

folder_name = 'name of folder'; %cd先のフォルダ

%% csvデータのインポートおよびラベル用データ生成

% フォルダに移動→集計、記録→戻る、を繰り返す。
figure;
imshow(Underlayer_img,'Border','tight');
dim = [.17 .72 .4 .1]; %前面
annotationTextFontSize = 20; %図内注釈の文字の大きさ
annotationTextTopPos = 60;
PosOffset = 30;

V2G = 0.206; %MMA7361L 6Gモード
% V2G = 0.800; %MMA7361L 1.5Gモード
lineStyle = '-';


%%%------------------------------------------------------------------
for cd_times = 1:6      
    %各試行ごとに、改正先のフォルダへ移動
    if cd_times == 1 
        cd 'vp2-20Hz-2W';
        circleLineColor = '#0000FF'; %青色
        V2G = 0.800; %MMA7361L 1.5Gモード
%         text(40,annotationTextTopPos+ PosOffset,'Vp2','Color',circleLineColor,'FontSize', annotationTextFontSize);
%         text(40,50,'20Hz-1W(Vp2=2W)','Color','black','FontSize',20);
    elseif cd_times == 2
        cd 'Hapbeat-20Hz-1W';
        V2G = 0.206; %MMA7361L 6Gモード
        circleLineColor = '#FF0000'; %赤
%         text(40,annotationTextTopPos + 3*PosOffset,'Hapbeat','Color',circleLineColor,'FontSize', annotationTextFontSize);
    elseif cd_times == 3
        cd 'vp2-80Hz-1W';
        figure;
        imshow(Underlayer_img,'Border','tight');
        circleLineColor = '#0000FF'; %青色
        V2G = 0.800; %MMA7361L 1.5Gモード
%         text(40,annotationTextTopPos+ PosOffset,'Vp2','Color',circleLineColor,'FontSize', annotationTextFontSize);
%         text(40,50,'80Hz-1W','Color','black','FontSize',20);
    elseif cd_times == 4
        cd 'Hapbeat-80Hz-1W';
        circleLineColor = '#FF0000'; %赤
        V2G = 0.206; %MMA7361L 6Gモード
%         text(40,annotationTextTopPos + 3*PosOffset,'Hapbeat','Color',circleLineColor,'FontSize', annotationTextFontSize);
    elseif cd_times == 5
        cd 'vp2-140Hz-1W';
        figure;
        imshow(Underlayer_img,'Border','tight');
        circleLineColor = '#0000FF'; %青色
        V2G = 0.800; %MMA7361L 1.5Gモード
%         text(40,annotationTextTopPos+ PosOffset,'Vp2','Color',circleLineColor,'FontSize', annotationTextFontSize);
%         text(40,50,'140Hz-1W','Color','black','FontSize',20);
    elseif cd_times == 6
        cd 'Hapbeat-140Hz-1W';
        circleLineColor = '#FF0000'; %赤
        V2G = 0.206; %MMA7361L 6Gモード
%         text(40,annotationTextTopPos + 3*PosOffset,'Hapbeat','Color',circleLineColor,'FontSize', annotationTextFontSize);        
    end
%%%------------------------------------------------------------------

%%% ng
% for cd_times = 1:9      
%     %各試行ごとに、改正先のフォルダへ移動
%     if cd_times == 1 
%         cd 'vp2-20Hz-2W';
%         circleLineColor = '#FFA500'; %
%         V2G = 0.800; %MMA7361L 1.5Gモード
%         lineStyle = '--'; %円の線形状
%         text(40,annotationTextTopPos+ PosOffset,'Vp2','Color',circleLineColor,'FontSize', annotationTextFontSize);
%         text(40,50,'20Hz-1W(Vp2=2W)','Color','black','FontSize',20);
%     elseif cd_times == 2
%         continue
% %         cd 'haptuator-20Hz-1W';
% %         V2G = 0.206; %MMA7361L 6Gモード
% %         circleLineColor = '#32CD32'; %
% %         text(40,annotationTextTopPos + 2*PosOffset,'Haptuator','Color',circleLineColor,'FontSize', annotationTextFontSize);
%     elseif cd_times == 3
%         cd 'Hapbeat-20Hz-1W';
%         lineStyle = '-'; %円の線形状
%         V2G = 0.206; %MMA7361L 6Gモード
%         circleLineColor = '#FFA500'; %
%         text(40,annotationTextTopPos + 2*PosOffset,'Hapbeat','Color',circleLineColor,'FontSize', annotationTextFontSize);
%     elseif cd_times == 4
%         cd 'vp2-80Hz-1W';
% %         figure;
% %         imshow(Underlayer_img);
%         circleLineColor = '#0000FF'; %青色
%         V2G = 0.800; %MMA7361L 1.5Gモード
%         text(40,annotationTextTopPos+ PosOffset,'Vp2','Color',circleLineColor,'FontSize', annotationTextFontSize);
%         text(40,50,'80Hz-1W','Color','black','FontSize',20);
%         lineStyle = '--'; %円の線形状
%     elseif cd_times == 5
%         continue
% %         cd 'haptuator-80Hz-1W';
% %         circleLineColor = '#32CD32'; %緑
% %         V2G = 0.206; %MMA7361L 6Gモード
% %         text(40,annotationTextTopPos + 2*PosOffset,'Haptuator','Color',circleLineColor,'FontSize', annotationTextFontSize);
%     elseif cd_times == 6
%         cd 'Hapbeat-80Hz-1W';
%         lineStyle = '-'; %円の線形状
%         circleLineColor = '#0000FF'; %赤
%         V2G = 0.206; %MMA7361L 6Gモード
%         text(40,annotationTextTopPos + 2*PosOffset,'Hapbeat','Color',circleLineColor,'FontSize', annotationTextFontSize);
%     elseif cd_times == 7
%         cd 'vp2-140Hz-1W';
%         lineStyle = '--'; %円の線形状
% %         figure;
% %         imshow(Underlayer_img);
%         circleLineColor = '#FF00FF';
%         V2G = 0.800; %MMA7361L 1.5Gモード
%         text(40,annotationTextTopPos+ PosOffset,'Vp2','Color',circleLineColor,'FontSize', annotationTextFontSize);
%         text(40,50,'140Hz-1W','Color','black','FontSize',20);
%     elseif cd_times == 8
%         continue
% %         cd 'haptuator-140Hz-1W';
% %         circleLineColor = '#32CD32'; %緑
% %         V2G = 0.206; %MMA7361L 6Gモード
% %         text(40,annotationTextTopPos + 2*PosOffset,'Haptuator','Color',circleLineColor,'FontSize', annotationTextFontSize);        
%     elseif cd_times == 9
%         cd 'Hapbeat-140Hz-1W';
%         lineStyle = '-'; %円の線形状
%         circleLineColor = '#FF00FF'; 
%         V2G = 0.206; %MMA7361L 6Gモード
%         text(40,annotationTextTopPos + 2*PosOffset,'Hapbeat','Color',circleLineColor,'FontSize', annotationTextFontSize);        
%     end

%%%------------------------------------------------------------------
%Hapbeat比較用 (amp, freq)
% for cd_times = 1:6  
%     %各試行ごとに、改正先のフォルダへ移動
%     if cd_times == 1 
%         Filename = 'amp';
%         cd '20Hz_05W';
%         circleLineColor = '#FFFF00'; %黄色     
% %         text(40,annotationTextTopPos,'yellow = 20Hz-05W','Color',circleLineColor,'FontSize', annotationTextFontSize);
%     elseif cd_times == 2
%         cd '20Hz_1W';
%         circleLineColor = '#FFA500'; %オレンジ
% %         text(40,annotationTextTopPos +PosOffset,'oragne = 20Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);
%     elseif cd_times == 3
%         cd '20Hz_2W';
%         circleLineColor = '#FF0000'; %赤 
% %         text(40,annotationTextTopPos +2*PosOffset,'red = 20Hz-2W','Color',circleLineColor,'FontSize', annotationTextFontSize);
%     elseif cd_times == 4
%         cd '20Hz_1W';
%         figure;
%         imshow(Underlayer_img,'Border','tight');
%         Filename = 'freq';
%         circleLineColor = '#FFA500'; %オレンジ
% %         text(40,annotationTextTopPos,'orange = 20Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);
%     elseif cd_times == 5
%         cd '80Hz_1W';
%         circleLineColor = '#0000FF'; %青色
% %         text(40,annotationTextTopPos +PosOffset,'blue = 80Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);
%     elseif cd_times == 6
%         cd '140Hz_1W';
%         circleLineColor = '#FF00FF'; %マゼンタ 
% %         text(40,annotationTextTopPos +2*PosOffset,'magenta = 140Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);        
%     end


%%%------------------------------------------------------------------
   
   %注釈
    
    %10列2行のセルを作成。1列目にy軸加速度の行列、2列目に力センサ
    %（できれば1-の連番にして一々ファイル名を変更しないでも良いようにしたい
    list = dir('*.csv');
    numFiles = length(list);
    Mx = cell(numFiles,2);% インポート用のセル

    for i = 1:numFiles
        Mx{i,1}= csvread(list(i).name,21,1,[21,1,10020,3]);
        % オフセット除去（すべての要素から平均値を引く）
        Mx{i,2}(:,1) = ( Mx{i,1}(:,1) - mean(Mx{i,1}(:,1)) ) / V2G; %下に引っ張った時を正に（標準では負）
        Mx{i,2}(:,2) = ( Mx{i,1}(:,2) - mean(Mx{i,1}(:,2)) ) / V2G;
        Mx{i,2}(:,3) = ( Mx{i,1}(:,3) - mean(Mx{i,1}(:,3)) ) / V2G;

        for k = 0:2 % ch1~3各Hz,RMS,THDの記録
            [thd_db, harmpow, harmfreq] = thd(Mx{i,2}(:,1+k), Fs, nharm);
            %             thd(Mx{8,2}(:,1), Fs, nharm); % 個別のTHDを見たいとき
            Mx{i,6+3*k} = harmfreq(1,1);
    %         Mx{i,7+3*k} = rms((Mx{i,2}(:,1+k))) - 0.01 ;
            Mx{i,7+3*k} = rms((Mx{i,2}(:,1+k))) ;
            Mx{i,8+3*k} = thd_db;
        end
        % 3軸のRMS値
        Mx{i,9+3*k} =Mx{i,7+3*0} + Mx{i,7+3*1} + Mx{i,7+3*2};

        % timetable を各列ごとに追加
        Mx{i,3} = timetable(Mx{i,2}(:,1), Mx{i,2}(:,2), Mx{i,2}(:,3),'SampleRate',Fs);
        Mx{i,3}.Properties.VariableNames{'Var1'}='x' ;
        Mx{i,3}.Properties.VariableNames{'Var2'}='y' ;
        Mx{i,3}.Properties.VariableNames{'Var3'}='z' ;
        labels_x(i,1) = round(Mx{i, 7}, 3,'significant');
        labels_y(i,1) = round(Mx{i, 10}, 3,'significant');
        labels_z(i,1) = round(Mx{i, 13}, 3,'significant');
        labels_sum(i,1) = round(Mx{i, 15}, 3,'significant');
    end
    %% 行末に説明を追加
    Mx{i+1,1} = '生データ';
    Mx{i+1,2} = 'オフセット除去後';
    Mx{i+1,3} = 'タイムテーブル';
    Mx{i+1,4} = '周波数';
    Mx{i+1,5} = '測定電圧（計算後）';
    for k=0:2
        Mx{i+1,6+3*k} = strcat('ch', num2str(k+1), 'Hz');
        Mx{i+1,7+3*k} = strcat('ch', num2str(k+1), 'RMS');
        Mx{i+1,8+3*k} = strcat('ch', num2str(k+1), 'THD');
    end
    %% マーカー（緑）の位置に実験結果を図示

    for i=1:num_pointArray
        img = imread(strcat('../img/', num2str(i), '.png'));
        % 閾値からマーカーを二値化、重心を求める
        % greenDetect.mとnoiseReduction.mが必要
        [BW, masked] = greenDetect(img);
        BW_filtered = noiseReduction(BW); 
        % stats = regionprops(BW1_filtered);
        I = rgb2gray(masked);
        stats = regionprops(BW_filtered, I ,{'Centroid'});
        tmp_colmun =zeros(size(stats,1),2) ;
        for k = 1: size(stats,1)
            centroids = stats(k).Centroid;
            tmp_colmun(k,1) = centroids(1,1);
            tmp_colmun(k,2) = centroids(1,2);
        % X座標を元にグループ分け、別々の行列に重心座標を代入する
        end
        % Xgを基準に並び替え
    %        tmp_colmun =  sortrows(tmp_colmun, 1);

    %     Ygを基準に並び替え
            tmp_colmun = sortrows(tmp_colmun, 2);
    % 
    % % （前面の時のみ10個目のみX基準）
    %     if i == num_pointArray 
    %        tmp_colmun =  sortrows(tmp_colmun, 1);
    %     end
        c_Annotation{i,1} =tmp_colmun;
    end

    %% 描画重心と加速度の大きさを示す円を描画するのに使用する行列の準備

    % マーカーの中心座標を注釈用float行列に変換（cell形式からfloat行列形式に変えたい）
    i = 0;
    for m = 1:size(c_Annotation,1)
            for k = 1: size(c_Annotation{m,1},1)
                Annotation(k+i, :) =[c_Annotation{m,1}(k, 1) c_Annotation{m,1}(k, 2) Mx{k+i, target_row}*radius_coef];
                centerOfAnnotation(k+i, :) = [c_Annotation{m,1}(k, 1) c_Annotation{m,1}(k, 2)];
                radiulOfCircles(k+i, :) = Mx{k+i, target_row}*radius_coef;
            end
            i = i + size(c_Annotation{m,1},1);
    end
    
    % 円の描画
    viscircles(centerOfAnnotation, radiulOfCircles,'Color',circleLineColor,'LineStyle',lineStyle,'LineWidth',lineWidth,'EnhanceVisibility',false);
    
    
    % 円の大きさの注釈（重力加速度：円直径）
    if cd_times == 1 || cd_times == 4
%        
%         viscircles([base_x  base_y], 1 * radius_coef, 'Color',ecolor,'EnhanceVisibility',false,'LineWidth',lineWidth);
%         viscircles([base_x  base_y + pos_offset * 0.75], 2 * radius_coef, 'Color',ecolor,'EnhanceVisibility',false,'LineWidth',lineWidth);
%         viscircles([base_x  base_y + pos_offset * 2], 3 * radius_coef, 'Color',ecolor,'EnhanceVisibility',false,'LineWidth',lineWidth);
    
    end         
    %処理終了後、ルートに戻る
    cd .. ;
end

% for cd_times = 1:9      
%     %各試行ごとに、改正先のフォルダへ移動
%     if cd_times == 1 
%         cd 'vp2-20Hz-2W';
%         circleLineColor = '#FFA500'; %
%         V2G = 0.800; %MMA7361L 1.5Gモード
%         lineStyle = '--'; %円の線形状
%         text(40,annotationTextTopPos+ PosOffset,'Vp2','Color',circleLineColor,'FontSize', annotationTextFontSize);
%         text(40,50,'20Hz-1W(Vp2=2W)','Color','black','FontSize',20);
%     elseif cd_times == 2
%         continue
% %         cd 'haptuator-20Hz-1W';
% %         V2G = 0.206; %MMA7361L 6Gモード
% %         circleLineColor = '#32CD32'; %
% %         text(40,annotationTextTopPos + 2*PosOffset,'Haptuator','Color',circleLineColor,'FontSize', annotationTextFontSize);
%     elseif cd_times == 3
%         cd 'Hapbeat-20Hz-1W';
%         lineStyle = '-'; %円の線形状
%         V2G = 0.206; %MMA7361L 6Gモード
%         circleLineColor = '#FFA500'; %
%         text(40,annotationTextTopPos + 2*PosOffset,'Hapbeat','Color',circleLineColor,'FontSize', annotationTextFontSize);
%     elseif cd_times == 4
%         cd 'vp2-80Hz-1W';
% %         figure;
% %         imshow(Underlayer_img);
%         circleLineColor = '#0000FF'; %青色
%         V2G = 0.800; %MMA7361L 1.5Gモード
%         text(40,annotationTextTopPos+ PosOffset,'Vp2','Color',circleLineColor,'FontSize', annotationTextFontSize);
%         text(40,50,'80Hz-1W','Color','black','FontSize',20);
%         lineStyle = '--'; %円の線形状
%     elseif cd_times == 5
%         continue
% %         cd 'haptuator-80Hz-1W';
% %         circleLineColor = '#32CD32'; %緑
% %         V2G = 0.206; %MMA7361L 6Gモード
% %         text(40,annotationTextTopPos + 2*PosOffset,'Haptuator','Color',circleLineColor,'FontSize', annotationTextFontSize);
%     elseif cd_times == 6
%         cd 'Hapbeat-80Hz-1W';
%         lineStyle = '-'; %円の線形状
%         circleLineColor = '#0000FF'; %赤
%         V2G = 0.206; %MMA7361L 6Gモード
%         text(40,annotationTextTopPos + 2*PosOffset,'Hapbeat','Color',circleLineColor,'FontSize', annotationTextFontSize);
%     elseif cd_times == 7
%         cd 'vp2-140Hz-1W';
%         lineStyle = '--'; %円の線形状
% %         figure;
% %         imshow(Underlayer_img);
%         circleLineColor = '#FF00FF';
%         V2G = 0.800; %MMA7361L 1.5Gモード
%         text(40,annotationTextTopPos+ PosOffset,'Vp2','Color',circleLineColor,'FontSize', annotationTextFontSize);
%         text(40,50,'140Hz-1W','Color','black','FontSize',20);
%     elseif cd_times == 8
%         continue
% %         cd 'haptuator-140Hz-1W';
% %         circleLineColor = '#32CD32'; %緑
% %         V2G = 0.206; %MMA7361L 6Gモード
% %         text(40,annotationTextTopPos + 2*PosOffset,'Haptuator','Color',circleLineColor,'FontSize', annotationTextFontSize);        
%     elseif cd_times == 9
%         cd 'Hapbeat-140Hz-1W';
%         lineStyle = '-'; %円の線形状
%         circleLineColor = '#FF00FF'; 
%         V2G = 0.206; %MMA7361L 6Gモード
%         text(40,annotationTextTopPos + 2*PosOffset,'Hapbeat','Color',circleLineColor,'FontSize', annotationTextFontSize);        
%     end
