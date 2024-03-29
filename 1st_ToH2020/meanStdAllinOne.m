%% 被験者実験の実験結果をimportして円形を描くスクリプト（1枚絵）
% ★実験データ\■3被験者実験\★MeanStd\Tシャツ で実行
% 必要データを回数ごとに1,2,3...のようにフォルダを作り、データを格納。1,2,3フォルダの1階層上で実施
% rootにtxtファイルが必要

clear
close all
tmpRMS_Cell = cell(1,1);% tmp 各エリアごとのRMSをx,y,z,sumでインポートするためのセル
Mean_Cell = cell(1,1);% tmpRMS_Cell から各エリアごとの平均取得
Std_Cell = cell(1,1);% tmpRMS_Cell から各エリアごとの標準誤差取得

cd_times = 1; % ディレクトリを動いた回数
arrMeanStd = zeros(1,2); % spreadsheetに張り付ける用の、mean,stdをまとめた行列。
subjectNum = 6; % 被験者数。何回ループさせるか。
areaNum = 3; % FRONT SIDE BACK

%% それぞれの area mean std を求める
for areaItr = 1:areaNum
    if areaItr == 1
        cd '1_Front';
    elseif areaItr == 2
        cd '2_Side';
    elseif areaItr == 3
        cd '3_Back';
    end
    
    %% 生データを集計
    for subItr = 1:subjectNum
        if subItr == 1
            cd 'sub1';
        elseif subItr == 2
            cd 'sub2';
        elseif subItr == 3
            cd 'sub3';
        elseif subItr == 4
            cd 'sub4';
        elseif subItr == 5
            cd 'sub5';
        elseif subItr == 6
            cd 'sub6';
        end
        %     Sort_by_Input2080140_0512
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
            tmpRMS_Cell{cd_times, subItr} = RMS_column; %RMS値を格納
            cd ..
        end
        cd ..
    end
    
    %% RMSから平均（Mean）を算出
    tmp = zeros(1,1);
    for i = 1:size(tmpRMS_Cell,1) % 周波数ごとのイテレート。Mxのcell参照
        for j=1:size(tmpRMS_Cell{1,1},2) % 軸ごとのイテレート。x,y,z,sum
            for k =1: size(tmpRMS_Cell{1,1},1) % 測定箇所ごとのイテレート。
                % matlabの関数を使うため、tmp行列に格納
                for loop = 1 : subjectNum
                    tmp(loop,1) = tmpRMS_Cell{i,loop}(k,j);
                end
                Mean_Cell{i,areaItr}(k,j) = mean(tmp);
            end
        end
    end
    
    %% RMSから標準偏差（Std）を算出
    for i = 1:size(tmpRMS_Cell,1) % 周波数ごとのイテレート。Mxのcell参照
        for j=1:size(tmpRMS_Cell{1,1},2) % 軸ごとのイテレート。x,y,z,sum
            for k =1: size(tmpRMS_Cell{1,1},1) % 測定箇所ごとのイテレート。
                % matlabの関数を使うため、tmp行列に格納
                for loop = 1 : subjectNum
                    tmp(loop,1) = tmpRMS_Cell{i,loop}(k,j);
                end
                Std_Cell{i,areaItr}(k,j) = std(tmp);
            end
        end
    end
    
    %% spreadsheet貼り付け用にまとめる。ひとまずsumだけ
    row = 1;
    for i = 1:size(tmpRMS_Cell,1) % 周波数ごとのイテレート。Mxのcell参照
        for k =1: size(tmpRMS_Cell{1,1},1) % 測定箇所ごとのイテレート。
            % matlabの関数を使うため、tmp行列に格納
            arrMeanStd(row,2*areaItr-1) =  Mean_Cell{i,areaItr}(k,4);
            arrMeanStd(row,2*areaItr) =  Std_Cell{i,areaItr}(k,4);
            row = row + 1;
        end
    end

    cd ..
        save; %save .mat file
end
% ここまでで、全エリアのRMSの平均とSTDが格納される

%% マーカー（緑）の位置を配置
% 画像を差し替えた時はここから

    % ラベル描画関連
    img_list = dir('./img/*.png');
    Underlayer_img = imread('./img/Underlayer.png');
    num_pointArray =  length(img_list)-1 ; %緑マーカの列の数。imgフォルダの画像数から算出
    centerOfAnnotation = zeros(1, 2);%c_Annotationから中心座標のみ取り出し
    c_Annotation = cell(num_pointArray,1); %描画用マーカー座標を入れるセル
    
    for i=1:num_pointArray
        img = imread(strcat('./img/', num2str(i), '.png'));
        % 閾値からマーカーを二値化、重心を求める greenDetect.mとnoiseReduction.mが必要
        [BW, masked] = m_greenDetect(img);
        BW_filtered = m_noiseReduction(BW);
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
        
        %     Ygを基準に並び替え
        tmp_colmun = sortrows(tmp_colmun, 2);
        c_Annotation{i,1} =tmp_colmun;
    end
    
    %c_AnnotationはCell形式なので、2列の行列にする
    i = 0; %centerOfAnnotationの行番号オフセット
    for m = 1:size(c_Annotation,1) %sizeは画像の列数
        for k = 1: size(c_Annotation{m,1},1)
            centerOfAnnotation(k+i, :) = [c_Annotation{m,1}(k, 1) c_Annotation{m,1}(k, 2)];
        end
        i = i + size(c_Annotation{m,1},1);
    end
%     
    Annotation = zeros(num_points, 3); %c_AnnotationのFloat行列, [マーカーのx座標, y座用, 加速度の大きさr]
    %viscirclesを使うため、重心と円半径をそれぞれ別の行列に代入
    i = 0; %　c_Annotationの数だけ参照行をシフトさせるため
    for m = 1:size(c_Annotation,1)
        for k = 1: size(c_Annotation{m,1},1)
            Annotation(k+i, 1) = c_Annotation{m,1}(k, 1);
            Annotation(k+i, 2) = c_Annotation{m,1}(k, 2);
        end
        i = i + size(c_Annotation{m,1},1);
    end
    
save; %save .mat file


% 分類するフォルダの作成
if ~isfolder('X')
    mkdir 'X';
end
if ~isfolder('Y')
    mkdir 'Y';
end
if ~isfolder('Z')
    mkdir 'Z';
end
if ~isfolder('Sum')
    mkdir 'Sum';
end

% グラフ描画（matがある場合はここからでOK）

% 格納された各エリアのRMS、STDを1つのarrayに入れる。

frontPoints = 14; sidePoints = 7; backPoints = 6;
pointsNum = frontPoints+sidePoints+backPoints; %測定点の数。

tmpMeans = zeros(pointsNum,1);
tmpStd = zeros(pointsNum,1);


txtPosX = 20; txtPosY = 30;  posOffset = 15;%改行量
labels = zeros(pointsNum,1);
radius_coef = 20  / 9.80665;%描画のため加速度(g)に掛け合わせる係数
annotationTextFontSize = 18; %図内注釈の文字の大きさ

% for i = 1:5 % 信号の種類ごと
for i = 2:2 % 20Hz-1W

    if i == 1 
        type = '20Hz-0W';
    elseif i == 2
        type = '20Hz-1W';
    elseif i == 3
        type = '20Hz-2W';
    elseif i == 4
        type = '80Hz-1W';
    elseif i == 5
        type = '140Hz-1W';
    end

    for j = 4:4 % x,y,z,sum
         %提示信号によって切り分け
         if j == 1 
             axis = 'X';
             circleLineColor= '#009C4E'; % x = 緑色
         elseif j == 2
             axis = 'Y';
             circleLineColor = '#FFFF00'; % y = 黄色
         elseif j == 3
             axis = 'Z';
             circleLineColor = '#FFA500'; % z = オレンジ
         elseif j == 4
             axis = 'Sum';
             circleLineColor = 'magenta'; % z = オレンジ
         end
        title = strcat(type,'-',axis);
        close
        figure
        
       
        imshow(Underlayer_img,'Border','tight') ;
        stdLineColor = circleLineColor; % 標準偏差の線の色
%         text(txtPosX,txtPosY,title,'Color',circleLineColor,'FontSize', annotationTextFontSize);

        % 描画用の行列に値を格納
        for k = 1:pointsNum
            if k <= frontPoints
                areaType = 1;
                dataIndex = k;
            elseif k>frontPoints && k <= (frontPoints + sidePoints)
                areaType = 2;
                dataIndex = k -frontPoints;
            elseif k > (frontPoints + sidePoints)
                areaType = 3;
                dataIndex = k-(frontPoints + sidePoints);
            end
            tmpMeans(k,1) = Mean_Cell{i,areaType}(dataIndex,j);
            tmpStd(k,1) = Std_Cell{i,areaType}(dataIndex,j);
       
%%%%%%%%%%%%%%%% %標準偏差の表示
            circleMeans = tmpMeans(k,1) * radius_coef;     
            lineWidth = 1.5 +  tmpStd(k,1) * 3; % 標準偏差の範囲になるように調整する
            circleLineColor = '[1 0 0 0.2]'; % 灰色
            % RMSの値に沿った円を描画
            viscircles(centerOfAnnotation(k,:), circleMeans,'EnhanceVisibility',false, ...
            'Color',circleLineColor,'LineStyle','-','LineWidth',lineWidth);   

            circleLineColor = '#ff0000'; % 赤    
            lineWidth = 1.5; 
            % RMSの値に沿った円を描画
            viscircles(centerOfAnnotation(k,:), circleMeans,'EnhanceVisibility',false, ...
            'Color',circleLineColor,'LineStyle','-','LineWidth',lineWidth);   
        end
   
        % RMSの値に沿った円を描画（中心の線）
%         circleMeans = tmpMeans * radius_coef;
%         viscircles(centerOfAnnotation, circleMeans,'EnhanceVisibility',false,'Color',circleLineColor,'LineStyle','-','LineWidth',1);   
        
%%%%%%%%%%%%%%%%   標準偏差の円の大きさ確認用
%        % RMSの値を示すテキストを追加
%         text(Annotation(:,1), Annotation(:,2)+posOffset, num2str(round(tmpMeans,3)),'Color','blue','FontSize', annotationTextFontSize);
% 
%        % 標準偏差の図示
%         tmpMeanPlueStd = tmpMeans + tmpStd;
%         viscircles(centerOfAnnotation, tmpMeanPlueStd * radius_coef ,'EnhanceVisibility',false,'Color',	stdLineColor,'LineStyle',':','LineWidth',1);   
%         tmpMeanMinusStd = tmpMeans - tmpStd;
%         errorIndex = find(tmpMeanMinusStd < 0); % 負の値があるとviscirclesがエラーになるので、負の値を0にする
%         tmpMeanMinusStd(errorIndex, 1) = 0;
%         viscircles(centerOfAnnotation, tmpMeanMinusStd * radius_coef ,'EnhanceVisibility',false,'Color',stdLineColor,'LineStyle',':','LineWidth',1);   
% 
%      % 標準偏差の値を示すテキストを追加
%         text(Annotation(:,1) -10, Annotation(:,2) + posOffset*1.8 ,strcat('±',num2str(round(tmpStd,3))),'Color','blue','FontSize',annotationTextFontSize);
%%%%%%%%%%%%%%%%

        % 画像保存
        cd (axis)
        saveas(gcf,strcat(title,'.png'));
        cd ..
    end
end
% close


%% 出力方向の比較

% Meanの描画
figure
imshow(Underlayer_img,'Border','tight') ;

% radius_coef = 10  / 9.80665;%描画のため加速度(g)に掛け合わせる係数


%     text(txtPosX,txtPosY - posOffset,'Mean','Color','black','FontSize', annotationTextFontSize);

for i = 1:3
    if i == 1 
        circleLineColor =  '#FFFF00'; %黄色     
%             text(txtPosX,txtPosY,'20Hz-05W','Color',circleLineColor,'FontSize', annotationTextFontSize);
    elseif i == 2
        circleLineColor = '#FFA500'; %オレンジ
%             text(txtPosX,txtPosY + posOffset,'20Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);
    elseif i == 3
        circleLineColor = '#FF0000'; %赤 
%             text(txtPosX,txtPosY +2*posOffset,'20Hz-2W','Color',circleLineColor,'FontSize', annotationTextFontSize);
    end
    
        % 描画用の行列に値を格納
    for k = 1:pointsNum
        if k <= frontPoints
            areaType = 1;
            dataIndex = k;
        elseif k>frontPoints && k <= (frontPoints + sidePoints)
            areaType = 2;
            dataIndex = k -frontPoints;
        elseif k > (frontPoints + sidePoints)
            areaType = 3;
            dataIndex = k-(frontPoints + sidePoints);
        end
        tmpMeans(k,1) = Mean_Cell{i,areaType}(dataIndex,j);
        tmpStd(k,1) = Std_Cell{i,areaType}(dataIndex,j);
    end
    circleMeans = tmpMeans * radius_coef;
    viscircles(centerOfAnnotation, circleMeans,'EnhanceVisibility',false,'Color',circleLineColor,'LineStyle','-','LineWidth',1);   
end
saveas(gcf,strcat('1ampMeanDiff','.png'));
% close


%% 基準円の大きさ表示用
figure;
close all
base_x = 30;
base_y = 100;
pos_offset = 100;
ecolor = 'black';
lineWidth = 2;
imshow(Underlayer_img);
% 基準の m/s
v1 = 1;
v2 = 10;
v3 = 20;
viscircles([base_x  base_y], v1 * radius_coef, 'Color',ecolor,'EnhanceVisibility',false,'LineWidth',lineWidth);
viscircles([base_x + pos_offset * 0.75 base_y ], v2 * radius_coef, 'Color',ecolor,'EnhanceVisibility',false,'LineWidth',lineWidth);
viscircles([base_x + pos_offset * 2  base_y ], v3 * radius_coef, 'Color',ecolor,'EnhanceVisibility',false,'LineWidth',lineWidth);
saveas(gcf,strcat('baseCircle','.png'));














