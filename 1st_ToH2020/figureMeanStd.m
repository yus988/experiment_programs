%%実験結果をimportして図示する。平均と標準偏差が入ったcsvファイルがあるフォルダ中で実行
% 必要データを回数ごとに1,2,3...のようにフォルダを作り、データを格納。1,2,3フォルダの1階層上で実施
% rootにtxtファイルが必要

clear
close all
RMS_Cell = cell(1,1);% RMSをx,y,z,sumでインポートするためのセル
Mean_Cell = cell(1,1);% RMS_cell から平均取得
Std_Cell = cell(1,1);% RMS_cell から標準誤差取得
cd_times = 1; % ディレクトリを動いた回数
actType =  dir('*.txt'); % vp2.txt or hapbeat.txt

max_loops = 3; % 何回ループさせるか。
max_loops = 5; % 何回ループさせるか。

isHapbeat = isempty(actType) || ~strcmp(actType.name,'vp.txt'); %Hapeatの場合

%% 生データを集計
for whole_times = 1:max_loops
    if whole_times == 1
        cd '1';
    elseif whole_times == 2
        cd '2';
    elseif whole_times == 3
        cd '3';
    elseif whole_times == 4
        cd '4';
    elseif whole_times == 5
        cd '5';
    end
%     Sort_by_Input2080140_0512
    
    if isHapbeat %Hapbeatの場合
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
            RMS_Cell{cd_times, whole_times} = RMS_column; %RMS値を格納
            cd .. 
        end
    else %Vp2の場合
        for cd_times = 1:3
            %各試行ごとに、改正先のフォルダへ移動
            if cd_times == 1 
                cd '20Hz_2W';
            elseif cd_times == 2
                cd '80Hz_2W';
            elseif cd_times == 3
                cd '140Hz_2W';
            end
            HumanPointsAccImport % 取り込み処理
            RMS_Cell{cd_times, whole_times} = RMS_column; %RMS値を格納
            cd .. 
        end
    end
    cd ..
end


%% RMSから平均（Mean）を算出

for i = 1:size(RMS_Cell,1) % 周波数ごとのイテレート。Mxのcell参照
    for j=1:size(RMS_Cell{1,1},2) % 軸ごとのイテレート。x,y,z,sum
        for k =1: size(RMS_Cell{1,1},1) % 測定箇所ごとのイテレート。
            % matlabの関数を使うため、tmp行列に格納
            tmp(1,1) = RMS_Cell{i,1}(k,j);
            tmp(2,1) = RMS_Cell{i,2}(k,j);
            tmp(3,1) = RMS_Cell{i,3}(k,j);
            Mean_Cell{i,1}(k,j) = mean(tmp);
        end
    end
end

%% RMSから標準偏差（Std）を算出
for i = 1:size(RMS_Cell,1) % 周波数ごとのイテレート。Mxのcell参照
    for j=1:size(RMS_Cell{1,1},2) % 軸ごとのイテレート。x,y,z,sum
        for k =1: size(RMS_Cell{1,1},1) % 測定箇所ごとのイテレート。
            % matlabの関数を使うため、tmp行列に格納
            tmp(1,1) = RMS_Cell{i,1}(k,j);
            tmp(2,1) = RMS_Cell{i,2}(k,j);
            tmp(3,1) = RMS_Cell{i,3}(k,j);
            Std_Cell{i,1}(k,j) = std(tmp);
        end
    end
end

% 平均値出すだけならここまで


%% マーカー（緑）の位置を配置
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
    
    
save; %save .mat file


%% 分類するフォルダの作成
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

%% グラフ描画（matがある場合はここからでOK）

% セットアップ
pointsNum = size(list,1); %測定点の数。listから読み込み
% if strcmp(dir('*.txt').name , 'front.txt')
%     txtPosX = 20;
%     txtPosY = 30;%
%     posOffset = 15;%改行量
% elseif strcmp(dir('*.txt').name , 'side.txt')
%     txtPosX = 20;
%     txtPosY = 30;%
%     posOffset = 15;%改行量
% elseif strcmp(dir('*.txt').name , 'back.txt')
%     txtPosX = 20;
%     txtPosY = 30;%
%     posOffset = 15;%改行量
% end

txtPosX = 20;
txtPosY = 30;%
posOffset = 15;%改行量

labels = zeros(pointsNum,1);

radius_coef = 15;%描画のため加速度(g)に掛け合わせる係数
annotationTextFontSize = 8; %図内注釈の文字の大きさ

%---------------------------------------------------------------------------------------------------------------------------------------------------
% 描画
% size(RMS_Cell,1)
for i = 1:5 % 信号の種類ごと
    
    if isHapbeat %Hapbeatの場合
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
    else %Vp2の場合
         if i == 1 
             type = '20Hz-2W';
         elseif i == 2
             type = '80Hz-2W';
         elseif i == 3
             type = '140Hz-2W';
         elseif i == 4
             break;
         end
    end

    for j = 1:4 % x,y,z,sum
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
        % J = imresize(Underlayer_img,2);
        imshow(Underlayer_img,'Border','tight') ;
        % truesize([1920 1080]);
%       circleLineColor =  	[1 1 0]; %黄色
        stdLineColor = circleLineColor; % 標準偏差の線の色
        text(txtPosX,txtPosY,title,'Color',circleLineColor,'FontSize', annotationTextFontSize);

        tmpMeans = Mean_Cell{i,1}(:,j) ; %全測定箇所の測定値を含んだ行列。イテレート
        circleMeans = tmpMeans * radius_coef;
        
        % RMSの値に沿った円を描画
        viscircles(centerOfAnnotation, circleMeans,'EnhanceVisibility',false,'Color',circleLineColor,'LineStyle','-','LineWidth',1);   

        % RMSの値を示すテキストを追加
        text(Annotation(:,1), Annotation(:,2)+posOffset, num2str(round(tmpMeans,3)),'Color','blue','FontSize', annotationTextFontSize);

        % 標準偏差の図示
        tmpStd = Std_Cell{i,1}(:,j) ;   %全測定箇所の測定値を含んだ行列。イテレート
        tmpMeanPlueStd = tmpMeans + tmpStd;
        viscircles(centerOfAnnotation, tmpMeanPlueStd * radius_coef ,'EnhanceVisibility',false,'Color',	stdLineColor,'LineStyle',':','LineWidth',1);   
        tmpMeanMinusStd = tmpMeans - tmpStd;
        errorIndex = find(tmpMeanMinusStd < 0); % 負の値があるとviscirclesがエラーになるので、負の値を0にする
        tmpMeanMinusStd(errorIndex, 1) = 0;
        viscircles(centerOfAnnotation, tmpMeanMinusStd * radius_coef ,'EnhanceVisibility',false,'Color',stdLineColor,'LineStyle',':','LineWidth',1);   

        % 標準偏差の値を示すテキストを追加
        text(Annotation(:,1) -10, Annotation(:,2) + posOffset*1.8 ,strcat('±',num2str(round(tmpStd,3))),'Color','blue','FontSize',annotationTextFontSize);
        
        % 画像保存
        cd (axis)
        saveas(gcf,strcat(title,'.png'));
        cd ..
    end
end
close

% % dispframe
% Annotation(:, 3) = circleMeans;
% dispFrame = insertObjectAnnotation(Underlayer_img, 'circle', Annotation, tmpMeans, ...
% 'FontSize', 10, 'LineWidth', 1,'TextBoxOpacity',0, 'color', 'magenta','TextColor', 'white');
% imshow(dispFrame,'Border','tight') % border tight を入れることで余白なしに
% 
% hold
% tmpMeans = Mean_Cell{2,1}(:,4) ; %全測定箇所の測定値を含んだ行列
% circleMeans = tmpMeans * radius_coef;
% Annotation(:, 3) = circleMeans;
% dispFrame2 = insertObjectAnnotation(Underlayer_img, 'circle', Annotation, tmpMeans, ...
% 'FontSize', 10, 'LineWidth', 1,'TextBoxOpacity',0, 'color', 'red','TextColor', 'white');
% imshow(dispFrame2,'Border','tight') % border tight を入れることで余白なしに

%% 出力方向の比較（論文掲載用）
% 平均の分を計算した.matが必要

% Meanの描画
figure
imshow(Underlayer_img,'Border','tight') ;
text(txtPosX,txtPosY - posOffset,'Mean','Color','black','FontSize', annotationTextFontSize);

for i = 1:3
    if i == 1 
        circleLineColor =  '#FFFF00'; %黄色     
        text(txtPosX,txtPosY,'20Hz-05W','Color',circleLineColor,'FontSize', annotationTextFontSize);
    elseif i == 2
        circleLineColor = '#FFA500'; %オレンジ
        text(txtPosX,txtPosY + posOffset,'20Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);
    elseif i == 3
        circleLineColor = '#FF0000'; %赤 
        text(txtPosX,txtPosY +2*posOffset,'20Hz-2W','Color',circleLineColor,'FontSize', annotationTextFontSize);
    end   
    tmpMeans = Mean_Cell{i,1}(:,4); %全測定箇所の測定値を含んだ行列
    circleMeans = tmpMeans * radius_coef;
    viscircles(centerOfAnnotation, circleMeans,'EnhanceVisibility',false,'Color',circleLineColor,'LineStyle','-','LineWidth',1);   
end
saveas(gcf,strcat('1ampMeanDiff','.png'));
close

% %%
% 
% %---------------------------------------------------------------------------------------------------------------------------------------------------
% Stdの描画
figure
imshow(Underlayer_img,'Border','tight') ;
text(txtPosX,txtPosY - posOffset,'STDEV','Color','black','FontSize', annotationTextFontSize);
for i = 1:3
    if i == 1 
        circleLineColor =  '#FFFF00'; %黄色     
        text(txtPosX,txtPosY,'20Hz-05W','Color',circleLineColor,'FontSize', annotationTextFontSize);
    elseif i == 2
        circleLineColor = '#FFA500'; %オレンジ
        text(txtPosX,txtPosY +posOffset,'20Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);

    elseif i == 3
        circleLineColor = '#FF0000'; %赤 
        text(txtPosX,txtPosY +2*posOffset,'20Hz-2W','Color',circleLineColor,'FontSize', annotationTextFontSize);
    end   
%     tmpMeans = radiusOfMeans(pointsNum*i + 1:pointsNum * (i+1) ,:); %測定点の数だけ抽出_ex)前面1~50,51~100...
%     viscircles(centerOfAnnotation, tmpMeans,'Color',circleLineColor,'LineStyle','-','LineWidth',2);   
    tmpStd = Std_Cell{i,1}(:,4) * radius_coef;   %全測定箇所の測定値を含んだ行列。イテレート
    viscircles(centerOfAnnotation, tmpStd,'EnhanceVisibility',false,'Color',circleLineColor,'LineStyle',':','LineWidth',1);   
end
saveas(gcf,strcat('2ampStdDiff','.png'));
close


% 
% %---------------------------------------------------------------------------------------------------------------------------------------------------
% CV(変動係数、標準偏差÷平均値）の描画
figure
imshow(Underlayer_img,'Border','tight') ;
text(txtPosX,txtPosY - posOffset,'CV','Color','black','FontSize', annotationTextFontSize);

%提示信号によって切り分け

% 出力方向の比較（標準偏差）
comparisonType = 'Amplitude Comparison';
for i = 1:3
    if i == 1 
        circleLineColor =  '#FFFF00'; %黄色     
        text(txtPosX,txtPosY,'20Hz-05W','Color',circleLineColor,'FontSize', annotationTextFontSize);
    elseif i == 2
        circleLineColor = '#FFA500'; %オレンジ
        text(txtPosX,txtPosY +posOffset,'20Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);

    elseif i == 3
        circleLineColor = '#FF0000'; %赤 
        text(txtPosX,txtPosY +2*posOffset,'20Hz-2W','Color',circleLineColor,'FontSize', annotationTextFontSize);
    end     
    for j=1: size(Mean_Cell{1,1},1)
        tmpCVval(j,1) = Std_Cell{i,1}(j,4) / Mean_Cell{i,1}(j,4) ; %全測定箇所の測定値を含んだ行列        
    end
    tmpCV = tmpCVval * radius_coef;
    viscircles(centerOfAnnotation, tmpCV,'EnhanceVisibility',false,'Color',circleLineColor,'LineStyle',':','LineWidth',1);   
end
saveas(gcf,strcat('3ampCvDiff','.png'));
close

% 周波数ごとの比較（平均）（比較対象が連番で無いので注意）
% 平均の分を計算した.matが必要

% Meanの描画
figure
imshow(Underlayer_img,'Border','tight') ;
text(txtPosX,txtPosY - posOffset,'Mean','Color','black','FontSize', annotationTextFontSize);

for i = 1:3
    if i == 1 %20Hz
        circleLineColor = '#FFA500'; %オレンジ
        text(txtPosX,txtPosY,'20Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);
        f = 2;
    elseif i == 2 %80Hz
        circleLineColor = '#0000FF'; %青色
        text(txtPosX,txtPosY +posOffset,'80Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);
        f = 4;
    elseif i == 3 %140Hz
        circleLineColor = '#FF00FF'; %マゼンタ 
        text(txtPosX,txtPosY +2*posOffset,'140Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);        
        f = 5;
    end   
    tmpMeans = Mean_Cell{f,1}(:,4); %全測定箇所の測定値を含んだ行列
    circleMeans = tmpMeans * radius_coef;
    viscircles(centerOfAnnotation, circleMeans,'EnhanceVisibility',false,'Color',circleLineColor,'LineStyle','-','LineWidth',1);   
end
saveas(gcf,strcat('4freqMeanDiff','.png'));
close

% %%
% 
% %---------------------------------------------------------------------------------------------------------------------------------------------------
% Stdの描画
figure
imshow(Underlayer_img,'Border','tight') ;
text(txtPosX,txtPosY - posOffset,'STDEV','Color','black','FontSize', annotationTextFontSize);
for i = 1:3
    if i == 1 %20Hz
        circleLineColor = '#FFA500'; %オレンジ
        text(txtPosX,txtPosY,'20Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);
        f = 2;
    elseif i == 2 %80Hz
        circleLineColor = '#0000FF'; %青色
        text(txtPosX,txtPosY +posOffset,'80Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);
        f = 4;
    elseif i == 3 %140Hz
        circleLineColor = '#FF00FF'; %マゼンタ 
        text(txtPosX,txtPosY +2*posOffset,'140Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);        
        f = 5;
    end   
%     tmpMeans = radiusOfMeans(pointsNum*i + 1:pointsNum * (i+1) ,:); %測定点の数だけ抽出_ex)前面1~50,51~100...
%     viscircles(centerOfAnnotation, tmpMeans,'Color',circleLineColor,'LineStyle','-','LineWidth',2);   
    tmpStd = Std_Cell{f,1}(:,4) * radius_coef;   %全測定箇所の測定値を含んだ行列。イテレート
    viscircles(centerOfAnnotation, tmpStd,'EnhanceVisibility',false,'Color',circleLineColor,'LineStyle',':','LineWidth',1);   
end
saveas(gcf,strcat('5freqStdDiff','.png'));
close


% 
% %---------------------------------------------------------------------------------------------------------------------------------------------------
% CV(変動係数、標準偏差÷平均値）の描画
figure
imshow(Underlayer_img,'Border','tight') ;
text(txtPosX,txtPosY - posOffset,'CV','Color','black','FontSize', annotationTextFontSize);

%提示信号によって切り分け
% 出力方向の比較（標準偏差）
comparisonType = 'Amplitude Comparison';
for i = 1:3
    if i == 1 %20Hz
        circleLineColor = '#FFA500'; %オレンジ
        text(txtPosX,txtPosY,'20Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);
        f = 2;
    elseif i == 2 %80Hz
        circleLineColor = '#0000FF'; %青色
        text(txtPosX,txtPosY+posOffset,'80Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);
        f = 4;
    elseif i == 3 %140Hz
        circleLineColor = '#FF00FF'; %マゼンタ 
        text(txtPosX,txtPosY+2*posOffset,'140Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);        
        f = 5;
    end   
    
    % 行列同士で割ると行列の形が崩れるので、各要素ごとに割る必要がある。
    for j=1: size(Mean_Cell{1,1},1)
        tmpCVval(j,1) = Std_Cell{f,1}(j,4) / Mean_Cell{f,1}(j,4) ; %全測定箇所の測定値を含んだ行列        
    end
    tmpCV = tmpCVval * radius_coef;
    viscircles(centerOfAnnotation, tmpCV,'EnhanceVisibility',false,'Color',circleLineColor,'LineStyle',':','LineWidth',1);   
end
saveas(gcf,strcat('6freqCvDiff','.png'));
close

