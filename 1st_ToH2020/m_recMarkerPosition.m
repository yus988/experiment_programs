%% マーカー（緑）の位置を配置
% 画像から緑マーカーの位置を読み取ってcenterOfAnnotationに格納する。
num_pointArray =  length(img_list)-1 ; %緑マーカの列の数。imgフォルダの画像数から算出
centerOfAnnotation = zeros(1, 2);%c_Annotationから中心座標のみ取り出し
c_Annotation = cell(num_pointArray,1); %描画用マーカー座標を入れるセル

for i=1:num_pointArray
    img = imread(strcat('./img/', num2str(i), '.png'));
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

%c_AnnotationはCell形式なので、2列の行列にする
i = 0; %centerOfAnnotationの行番号オフセット
for m = 1:size(c_Annotation,1) %sizeは画像の列数
        for k = 1: size(c_Annotation{m,1},1)
            centerOfAnnotation(k+i, :) = [c_Annotation{m,1}(k, 1) c_Annotation{m,1}(k, 2)];
        end
        i = i + size(c_Annotation{m,1},1);
end