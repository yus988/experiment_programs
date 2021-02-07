%%実験結果をimportして図示する。平均と標準偏差が入ったcsvファイルがあるフォルダ中で実行

clear
close all

if strcmp(dir('*.txt').name , 'front.txt')
    pointsNum = 50; %測定点の数。前面側面背面で場合分け
    txtPosX = 60;
    txtPosY = 750;%
    PosOffset = 30;%改行量
elseif strcmp(dir('*.txt').name , 'side.txt')
    pointsNum = 9;
    txtPosX = 60;
    txtPosY = 750;%
    PosOffset = 30;%改行量
elseif strcmp(dir('*.txt').name , 'back.txt')
    pointsNum = 15;
    txtPosX = 200;
    txtPosY = 1100;%
    PosOffset = 30;%改行量
end
    
labels = zeros(pointsNum,1);
radius_coef = 30;%描画のため加速度(g)に掛け合わせる係数


%% csvデータのインポートおよびラベル用データ生成

rms = readmatrix(dir('*.csv').name);
radiusOfMeans = rms(:,1) * radius_coef; %平均値を円の大きさに変換
radiusOfSTDEV = rms(:,2) * radius_coef; %標準偏差円の大きさに変換
radiusOfCV = rms(:,3)* radius_coef; %変動係数の大きさに変換
%% マーカー（緑）の位置に実験結果を図示

% ラベル描画関連
img_list = dir('./img/*.png');
Underlayer_img = imread('./img/Underlayer.png');
num_pointArray =  length(img_list)-1 ; %緑マーカの列の数。imgフォルダの画像数から算出

Annotation = zeros(pointsNum, 3); %c_AnnotationのFloat行列, [マーカーのx座標, y座用, 加速度の大きさr]
centerOfAnnotation = zeros(pointsNum, 2);%c_Annotationから中心座標のみ取り出し

c_Annotation = cell(num_pointArray,1); %描画用マーカー座標を入れるセル

for i=1:num_pointArray
    img = imread(strcat('./img/', num2str(i), '.png'));
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


%% グラフ描画
annotationTextFontSize = 20; %図内注釈の文字の大きさ

%---------------------------------------------------------------------------------------------------------------------------------------------------
figure
imshow(Underlayer_img); %一回のみ。ループの中に入れると都度初期化される。
text(txtPosX,txtPosY - PosOffset,'Mean','Color','black','FontSize', annotationTextFontSize);

%提示信号によって切り分け

% 出力方向の比較（平均）
comparisonType = 'Amplitude Comparison';
for i = 0:2
    if i == 0 
        circleLineColor =  '#FFFF00'; %黄色     
        text(txtPosX,txtPosY,'20Hz-05W','Color',circleLineColor,'FontSize', annotationTextFontSize);
    elseif i == 1
        circleLineColor = '#FFA500'; %オレンジ
        text(txtPosX,txtPosY +PosOffset,'20Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);

    elseif i == 2
        circleLineColor = '#FF0000'; %赤 
        text(txtPosX,txtPosY +2*PosOffset,'20Hz-2W','Color',circleLineColor,'FontSize', annotationTextFontSize);

    end   
    tmpMeans = radiusOfMeans(pointsNum*i + 1:pointsNum * (i+1) ,:); %測定点の数だけ抽出_ex)前面1~50,51~100...
    viscircles(centerOfAnnotation, tmpMeans,'Color',circleLineColor,'LineStyle','-','LineWidth',2);   
%     tmpSTDEV = radiusOfSTDEV(pointsNum*i + 1:pointsNum * (i+1) ,:); %測定点の数だけ抽出_ex)前面1~50,51~100...
%     viscircles(centerOfAnnotation, tmpSTDEV,'Color',circleLineColor,'LineStyle','-','LineWidth',2);    
end

%---------------------------------------------------------------------------------------------------------------------------------------------------

figure
imshow(Underlayer_img); %一回のみ。ループの中に入れると都度初期化される。
text(txtPosX,txtPosY - PosOffset,'STDEV','Color','black','FontSize', annotationTextFontSize);

%提示信号によって切り分け

% 出力方向の比較（標準偏差）
comparisonType = 'Amplitude Comparison';
for i = 0:2
    if i == 0 
        circleLineColor =  '#FFFF00'; %黄色     
        text(txtPosX,txtPosY,'20Hz-05W','Color',circleLineColor,'FontSize', annotationTextFontSize);
    elseif i == 1
        circleLineColor = '#FFA500'; %オレンジ
        text(txtPosX,txtPosY +PosOffset,'20Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);

    elseif i == 2
        circleLineColor = '#FF0000'; %赤 
        text(txtPosX,txtPosY +2*PosOffset,'20Hz-2W','Color',circleLineColor,'FontSize', annotationTextFontSize);

    end   
%     tmpMeans = radiusOfMeans(pointsNum*i + 1:pointsNum * (i+1) ,:); %測定点の数だけ抽出_ex)前面1~50,51~100...
%     viscircles(centerOfAnnotation, tmpMeans,'Color',circleLineColor,'LineStyle','-','LineWidth',2);   
    tmpSTDEV = radiusOfSTDEV(pointsNum*i + 1:pointsNum * (i+1) ,:); %測定点の数だけ抽出_ex)前面1~50,51~100...
    viscircles(centerOfAnnotation, tmpSTDEV,'Color',circleLineColor,'LineStyle','-','LineWidth',2);    
end


%---------------------------------------------------------------------------------------------------------------------------------------------------

figure
imshow(Underlayer_img); %一回のみ。ループの中に入れると都度初期化される。
text(txtPosX,txtPosY - PosOffset,'CV','Color','black','FontSize', annotationTextFontSize);

%提示信号によって切り分け

% 出力方向の比較（標準偏差）
comparisonType = 'Amplitude Comparison';
for i = 0:2
    if i == 0 
        circleLineColor =  '#FFFF00'; %黄色     
        text(txtPosX,txtPosY,'20Hz-05W','Color',circleLineColor,'FontSize', annotationTextFontSize);
    elseif i == 1
        circleLineColor = '#FFA500'; %オレンジ
        text(txtPosX,txtPosY +PosOffset,'20Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);

    elseif i == 2
        circleLineColor = '#FF0000'; %赤 
        text(txtPosX,txtPosY +2*PosOffset,'20Hz-2W','Color',circleLineColor,'FontSize', annotationTextFontSize);

    end     
    tmpCV = radiusOfCV(pointsNum*i + 1:pointsNum * (i+1) ,:); %測定点の数だけ抽出_ex)前面1~50,51~100...
    viscircles(centerOfAnnotation, tmpCV,'Color',circleLineColor,'LineStyle','-','LineWidth',2);    
end


%---------------------------------------------------------------------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------------------------------------------------------------------


figure
imshow(Underlayer_img); %一回のみ。ループの中に入れると都度初期化される。
text(txtPosX,txtPosY - PosOffset,'Mean','Color','black','FontSize', annotationTextFontSize);

%周波数ごと（平均）（比較対象が連番で無いので注意）
for i = 0:2
    if i == 0 %20Hz
        circleLineColor = '#FFA500'; %オレンジ
        text(txtPosX,txtPosY,'20Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);
        f = 1;
    elseif i == 1 %80Hz
        circleLineColor = '#0000FF'; %青色
        text(txtPosX,txtPosY +PosOffset,'80Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);
        f = 3;
    elseif i == 2 %140Hz
        circleLineColor = '#FF00FF'; %マゼンタ 
        text(txtPosX,txtPosY +2*PosOffset,'140Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);        
        f = 4;
    end   
    tmpMeans = radiusOfMeans(pointsNum*f + 1:pointsNum * (f+1) ,:); %測定点の数だけ抽出_ex)前面1~50,51~100...
    viscircles(centerOfAnnotation, tmpMeans,'Color',circleLineColor,'LineStyle','-','LineWidth',2);   

%     tmpSTDEV = radiusOfSTDEV(pointsNum*i + 1:pointsNum * (i+1) ,:); %測定点の数だけ抽出_ex)前面1~50,51~100...
%     viscircles(centerOfAnnotation, tmpSTDEV,'Color',circleLineColor,'LineStyle','-','LineWidth',2);    

end


%---------------------------------------------------------------------------------------------------------------------------------------------------

figure
imshow(Underlayer_img); %一回のみ。ループの中に入れると都度初期化される。
text(txtPosX,txtPosY - PosOffset,'STDEV','Color','black','FontSize', annotationTextFontSize);

%周波数ごと（平均）（比較対象が連番で無いので注意）
for i = 0:2
    if i == 0 %20Hz
        circleLineColor = '#FFA500'; %オレンジ
        text(txtPosX,txtPosY,'20Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);
        f = 1;
    elseif i == 1 %80Hz
        circleLineColor = '#0000FF'; %青色
        text(txtPosX,txtPosY +PosOffset,'80Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);
        f = 3;
    elseif i == 2 %140Hz
        circleLineColor = '#FF00FF'; %マゼンタ 
        text(txtPosX,txtPosY +2*PosOffset,'140Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);        
        f = 4;
    end   
%     viscircles(centerOfAnnotation, tmpMeans,'Color',circleLineColor,'LineStyle','-','LineWidth',2);   
%     tmpMeans = radiusOfMeans(pointsNum*f + 1:pointsNum * (f+1) ,:); %測定点の数だけ抽出_ex)前面1~50,51~100...

    tmpSTDEV = radiusOfSTDEV(pointsNum*i + 1:pointsNum * (i+1) ,:); %測定点の数だけ抽出_ex)前面1~50,51~100...
    viscircles(centerOfAnnotation, tmpSTDEV,'Color',circleLineColor,'LineStyle','-','LineWidth',2);    
end

%---------------------------------------------------------------------------------------------------------------------------------------------------

figure
imshow(Underlayer_img); %一回のみ。ループの中に入れると都度初期化される。
text(txtPosX,txtPosY - PosOffset,'CV','Color','black','FontSize', annotationTextFontSize);

%周波数ごと（平均）（比較対象が連番で無いので注意）
for i = 0:2
    if i == 0 %20Hz
        circleLineColor = '#FFA500'; %オレンジ
        text(txtPosX,txtPosY,'20Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);
        f = 1;
    elseif i == 1 %80Hz
        circleLineColor = '#0000FF'; %青色
        text(txtPosX,txtPosY +PosOffset,'80Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);
        f = 3;
    elseif i == 2 %140Hz
        circleLineColor = '#FF00FF'; %マゼンタ 
        text(txtPosX,txtPosY +2*PosOffset,'140Hz-1W','Color',circleLineColor,'FontSize', annotationTextFontSize);        
        f = 4;
    end
    
    tmpCV = radiusOfCV(pointsNum*i + 1:pointsNum * (i+1) ,:); %測定点の数だけ抽出_ex)前面1~50,51~100...
    viscircles(centerOfAnnotation, tmpCV,'Color',circleLineColor,'LineStyle','-','LineWidth',2);    
end


