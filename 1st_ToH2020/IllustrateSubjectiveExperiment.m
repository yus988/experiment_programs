%% 主観実験結果を図示するためのプログラム

clear;
list = dir('*.csv');
imgCell = cell(3,1); % imagelist格納用セル
Mx = cell(15,1);
labels = zeros(39,1);
centerOfAnnotation = zeros(1, 2);%c_Annotationから中心座標のみ取り出し
radiulOfCircles = zeros(1, 1);
radius_coef = 30;%描画のため加速度(g)に掛け合わせる係数

% ラベル描画関連
imgCell{1,1} = dir('./frontImg/*.png');
imgCell{2,1} = dir('./backImg/*.png');
imgCell{3,1} = dir('./sideImg/*.png');

%     fileName = 'mean.csv';
%     saveDir = 'meanResult';
%     fileName = 'count1.csv';
%     saveDir = 'count1Result';
   fileName = 'count2.csv';    
   saveDir = 'count2Result';

for i=1:15
    if i == 1
        range = '1:39'; %rangeFront20hz0w
    elseif i == 2
        range = '40:51'; %rangeBack20hz0w
    elseif i == 3
        range = '52:64'; %rangeSide20hz0w
    elseif i == 4
        range = '65:103'; %rangeFront20hz1w
    elseif i == 5
        range = '104:115'; %rangeBack20hz1w
    elseif i == 6
        range = '116:128'; %rangeSide20hz1w
    elseif i == 7
        range = '129:167'; %rangeFront20hz2w
    elseif i == 8
        range = '168:179'; %rangeBack20hz2w
    elseif i == 9
        range = '180:192'; %rangeSide20hz2w
    elseif i == 10
        range = '193:231'; %rangeFront80hz1w
    elseif i == 11
        range = '232:243'; %rangeBack80hz1w
    elseif i == 12
        range = '244:256'; %rangeSide80hz1w
    elseif i == 13
        range = '257:295'; %rangeFront140hz1w
    elseif i == 14
        range = '296:307'; %rangeBack140hz1w
    elseif i == 15
        range = '308:320'; %rangeSide140hz1w
    end
    Mx{i,1} =readmatrix(fileName,'range',range);
end


%% マーカー（緑）の位置に実験結果を図示
for loop = 1:15
    % 領域の設定
    if rem(loop,3) == 1
        imgPath = strcat('./frontImg/');
        targetImgCell = 1;
        areaName = 'front';
    elseif rem(loop,3) == 2
        imgPath = strcat('./backImg/');
        targetImgCell = 2;
        areaName = 'back';
    elseif rem(loop,3) == 0
        imgPath = strcat('./sideImg/');
        targetImgCell = 3;
        areaName = 'side';
    end
    % 出力の設定
    if and(loop >= 1, loop <= 3)
        power = '0.5W';
    elseif or(loop >= 10, and(loop >= 4, loop <= 6))
        power = '1W';
    elseif and(loop >= 7, loop <= 9)
        power = '2W';
    end
    % 周波数の設定
    if and(loop >= 1, loop <= 9)
        freq = '20Hz';
    elseif and(loop >= 10, loop <= 12)
        freq = '80Hz';
    elseif and(loop >= 13, loop <= 15)
        freq = '140Hz';
    end
    
    Underlayer_img = imread(strcat(imgPath,'Underlayer.png'));
    num_pointArray =  length(imgCell{targetImgCell,1}) - 1 ; %緑マーカの列の数。imgフォルダの画像数から算出
    c_Annotation = cell(num_pointArray,1); %描画用マーカー座標を入れるセル
    
    for i=1:num_pointArray
        img = imread(strcat(imgPath, num2str(i), '.png'));
        % 閾値からマーカーを二値化、重心を求める
        % greenDetect.mとnoiseReduction.mが必要
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
    
    %% 各軸ごとの加速度の大きさと数値を図示
    
    Annotation = zeros(1, 3); %c_AnnotationのFloat行列, [マーカーのx座標, y座用, 加速度の大きさr]
    %viscirclesを使うため、重心と円半径をそれぞれ別の行列に代入
    i = 0; %　c_Annotationの数だけ参照行をシフトさせるため
    for m = 1:size(c_Annotation,1)
        for k = 1: size(c_Annotation{m,1},1)
            Annotation(k+i, 1) = c_Annotation{m,1}(k, 1);
            Annotation(k+i, 2) = c_Annotation{m,1}(k, 2);
            % loop化
            Annotation(k+i, 3) = Mx{loop,1}(k+i,1) * radius_coef; % 半径となる値を代入
        end
        i = i + size(c_Annotation{m,1},1);
    end
    
    % Annotationの大きさなどを決定
    annoColor = 'blue';
    dispFrame = insertObjectAnnotation(Underlayer_img, 'circle', Annotation, Annotation(:,3)/radius_coef, ...
        'FontSize', 10, 'LineWidth', 2,'TextBoxOpacity',0, 'color', 'magenta','TextColor', annoColor);
    
    imshow(dispFrame,'Border','tight') % border tight を入れることで余白なしに
    
    x_base = 0;
    y_base = 20;
    title = strcat(areaName,'-',freq,'-',power);
    text(x_base,y_base,title,'Color','white','FontSize',12);
    
    %       画像保存
    cd (saveDir)
    saveas(gcf,strcat(title,'.png'));
    cd ..
    
end




%% 出力方向の比較（論文掲載用）
% 平均の分を計算した.matが必要
% マーカー（緑）の位置に実験結果を図示

for clothLoop = 1:3
    
    if clothLoop == 1
        imgPath = strcat('./frontImg/');
        targetImgCell = 1;
        areaName = 'front';
        areaOffset=0; % 領域ごとに参照するセル行の変更
    elseif clothLoop == 2
        imgPath = strcat('./backImg/');
        targetImgCell = 2;
        areaName = 'back';
        areaOffset=1; % 領域ごとに参照するセル行の変更
    elseif clothLoop == 3
        imgPath = strcat('./sideImg/');
        targetImgCell = 3;
        areaName = 'side';
        areaOffset=2; % 領域ごとに参照するセル行の変更
    end
    
    
    Underlayer_img = imread(strcat(imgPath,'Underlayer.png'));
    num_pointArray =  length(imgCell{targetImgCell,1}) - 1 ; %緑マーカの列の数。imgフォルダの画像数から算出
    c_Annotation = cell(num_pointArray,1); %描画用マーカー座標を入れるセル
    
    for i=1:num_pointArray
        img = imread(strcat(imgPath, num2str(i), '.png'));
        % 閾値からマーカーを二値化、重心を求める
        % greenDetect.mとnoiseReduction.mが必要
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
    
    Annotation = zeros(1, 2); %c_AnnotationのFloat行列, [マーカーのx座標, y座用, 加速度の大きさr]
    %viscirclesを使うため、重心と円半径をそれぞれ別の行列に代入
    i = 0; %　c_Annotationの数だけ参照行をシフトさせるため
    for m = 1:size(c_Annotation,1)
        for k = 1: size(c_Annotation{m,1},1)
            Annotation(k+i, 1) = c_Annotation{m,1}(k, 1);
            Annotation(k+i, 2) = c_Annotation{m,1}(k, 2);
        end
        i = i + size(c_Annotation{m,1},1);
    end
    
    centerOfAnnotation = Annotation;
    txtPosX = 20;
    txtPosY = 30;%
    posOffset = 15;%改行量
    annotationTextFontSize = 8; %図内注釈の文字の大きさ
    radius_coef = 8;
    lineWidth = 3;
    lineStyle = '-';
    
    % Meanの描画
    figure
    imshow(Underlayer_img,'Border','tight') ;
    text(txtPosX,txtPosY - posOffset,'Mean','Color','black','FontSize', annotationTextFontSize);
    
    for i = 1:3
        if i == 1
            circleLineColor =  '#FFFF00'; %黄色
            text(txtPosX,txtPosY,'20Hz-05W','Color',circleLineColor,'FontSize', annotationTextFontSize);
            %         circleOffset = 0; % 重なり防止のためのオフセット
            %         lineWidth = 2; % 重なり防止のために線の太さを変更
            lineStyle = '-';
            
        elseif i == 2
            circleLineColor = '#FFA500'; %オレンジ
            text(txtPosX,txtPosY + posOffset,'20Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);
            lineStyle = '-.';
            %         circleOffset = 1; % 重なり防止のためのオフセット
            %         lineWidth = 1.5; % 重なり防止のために線の太さを変更
        elseif i == 3
            circleLineColor = '#FF0000'; %赤
            text(txtPosX,txtPosY +2*posOffset,'20Hz-2W','Color',circleLineColor,'FontSize', annotationTextFontSize);
            %         circleOffset = 2; % 重なり防止のためのオフセット
            %         lineWidth = 1; % 重なり防止のために線の太さを変更
            lineStyle = '--';
        end
        tmpMeans = Mx{i * 3 - 2 + areaOffset,1}; %全測定箇所の測定値を含んだ行列
        circleMeans = tmpMeans * radius_coef ;
        viscircles(centerOfAnnotation, circleMeans,'EnhanceVisibility',false,'Color',circleLineColor,'LineStyle',lineStyle,'LineWidth',lineWidth);
    end
    cd (saveDir)
    
    saveas(gcf,strcat('1_',areaName,'AmpDiff','.png'));
    cd ..
    
    close
    
    % Freqの描画
    figure
    imshow(Underlayer_img,'Border','tight') ;
    text(txtPosX,txtPosY - posOffset,'Mean','Color','black','FontSize', annotationTextFontSize);
    
    for i = 1:3
        if i == 1
            circleLineColor = '#FFA500'; %オレンジ
            text(txtPosX,txtPosY,'20Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);
            %         circleOffset = 0; % 重なり防止のためのオフセット
            %         lineWidth = 2; % 重なり防止のために線の太さを変更
            f = 2;
            lineStyle = '-';
            
        elseif i == 2
            circleLineColor = '#0000FF'; %青色
            text(txtPosX,txtPosY +posOffset,'80Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);
            lineStyle = '-.';
            f = 4;
            %         circleOffset = 1; % 重なり防止のためのオフセット
            %         lineWidth = 1.5; % 重なり防止のために線の太さを変更
        elseif i == 3
            circleLineColor = '#FF00FF'; %マゼンタ
            text(txtPosX,txtPosY +2*posOffset,'140Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);
            %         circleOffset = 2; % 重なり防止のためのオフセット
            %         lineWidth = 1; % 重なり防止のために線の太さを変更
            lineStyle = '--';
            f = 5;
        end
        tmpMeans = Mx{f * 3 - 2 + areaOffset,1}; %全測定箇所の測定値を含んだ行列
        circleMeans = tmpMeans * radius_coef ;
        viscircles(centerOfAnnotation, circleMeans,'EnhanceVisibility',false,'Color',circleLineColor,'LineStyle',lineStyle,'LineWidth',lineWidth);
    end
    cd (saveDir)
    saveas(gcf,strcat('1_',areaName,'FreqDiff','.png'));
    
    cd ..
    close
end


