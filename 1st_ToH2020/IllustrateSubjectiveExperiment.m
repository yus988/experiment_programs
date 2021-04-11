%% 主観実験結果を図示するためのプログラム

clear;
list = dir('*.csv');
imgCell = cell(3,1); % imagelist格納用セル
Mx = cell(15,2);
labels = zeros(39,1);
centerOfAnnotation = zeros(1, 2);%c_Annotationから中心座標のみ取り出し
radiulOfCircles = zeros(1, 1);
radius_coef = 30;%描画のため加速度(g)に掛け合わせる係数

% ラベル描画関連
imgCell{1,1} = dir('./T-frontImg/*.png');
imgCell{2,1} = dir('./T-backImg/*.png');
imgCell{3,1} = dir('./T-sideImg/*.png');

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
    
    for j = 1:2
%         if j == 1 
%           fileName = 'y_mean.csv';
%         elseif j== 2
%           fileName = 't_mean.csv';
%         end
          saveDir = 'meanResult';
%         
%         if j == 1 
%           fileName = 'y_count1.csv';
%         elseif j== 2
%           fileName = 't_count1.csv';
%         end
%         saveDir = 'count1Result';

%         
        if j == 1 
          fileName = 'y_count2.csv';
        elseif j== 2
          fileName = 't_count2.csv';
        end
%         saveDir = 'count2Result';

        radius_coef = 10;%描画のため加速度(g)に掛け合わせる係数
          
        Mx{i,j} =readmatrix(fileName,'range',range);
    end
    
end


%% マーカー（緑）の位置に実験結果を図示    
for clothType = 1:2
    
    if clothType == 1
        cloth = 'Y-';
    elseif clothType == 2
        cloth = 'T-';
    end
    
    for loop = 1:15
        % 領域の設定
        if rem(loop,3) == 1 
            imgPath = strcat('./',cloth ,'frontImg/');
            targetImgCell = 1;
            areaName = 'front';
        elseif rem(loop,3) == 2
            imgPath = strcat('./',cloth ,'backImg/');
            targetImgCell = 2;
            areaName = 'back';
        elseif rem(loop,3) == 0
            imgPath = strcat('./',cloth ,'sideImg/');
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
                Annotation(k+i, 3) = Mx{loop,clothType}(k+i,1) * radius_coef; % 半径となる値を代入
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
        title = strcat(cloth,areaName,'-',freq,'-',power);
        text(x_base,y_base,title,'Color','white','FontSize',12);   
        
%       画像保存
        cd count1Result
        saveas(gcf,strcat(title,'.png'));
        cd ..
    end
end