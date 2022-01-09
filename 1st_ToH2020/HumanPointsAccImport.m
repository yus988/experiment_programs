%%実験結果をimportして図示する。
%始めに入力信号に応じて場合分け
% 呼び出される側にclearは入れない

close all

Fs = 1e4;%サンプル周波数
t = 0:1/Fs:1;
%加速度センサの感度

% V2G6 = 0.206; %MMA7361L 6Gモード = v/g v / (g*9.80665)
% radius_coef = 15;
V2G6 = 0.206 / 9.80665; %MMA7361L 6Gモード = v/g v / (g*9.80665)
radius_coef = 15 / 9.80665 ;%描画のため加速度(g)に掛け合わせる係数

% V2G = 0.800; %MMA7361L 1.5Gモード
V2N = 0.01178; %力センサ5916

nharm = 6;%thdの高調波数
%10列2行のセルを作成。1列目にy軸加速度の行列、2列目に力センサ
%（できれば1-の連番にして一々ファイル名を変更しないでも良いようにしたい
list = dir('*.csv');
numFiles = length(list);
Mx = cell(numFiles,2);% インポート用のセル
Analysis = cell(15);
xyz = 0;
num_points = numFiles; % 測定点数なのでは？
labels = zeros(num_points,1);
labels_x = zeros(num_points,1);
labels_y = zeros(num_points,1);
labels_z = zeros(num_points,1);
labels_sum = zeros(num_points,1);

% 種類によって変更
area = 0 ; %前面：0
% area = 1 %側面：1
% area = 2 %背面：2

RMS_column = zeros(1,4);% RMS値格納用

%描画させる加速度。Xg: 7, Yg: 10,  Zg: 13, Sum: 15
target_row = 15;  %Sum
% target_row = 7; %Xg
% target_row = 10; %Yg
% target_row = 13; %Zg

% % 0.5,1,1.5G の大きさ
% figure;
% base_x = 300;
% base_y = 100;
% pos_offset = 150;
% ecolor = 'black';
% lineWidth = 2;
% imshow(imread('../wb2.png'),'Border','tight');
% viscircles([base_x  base_y], 0.5 * radius_coef, 'Color',ecolor,'EnhanceVisibility',false,'LineWidth',lineWidth);
% viscircles([base_x  base_y + pos_offset * 0.75], 1 * radius_coef, 'Color',ecolor,'EnhanceVisibility',false,'LineWidth',lineWidth);
% viscircles([base_x  base_y + pos_offset * 2], 1.5 * ra

%% csvデータのインポートおよびラベル用データ生成
for i = 1:numFiles
    Mx{i,1}= csvread(list(i).name,21,1,[21,1,10020,4]);
    % オフセット除去（すべての要素から平均値を引く）
    Mx{i,2}(:,1) = ( Mx{i,1}(:,1) - mean(Mx{i,1}(:,1)) ) / V2G6; %下に引っ張った時を正に（標準では負）
    Mx{i,2}(:,2) = ( Mx{i,1}(:,2) - mean(Mx{i,1}(:,2)) ) / V2G6;
    Mx{i,2}(:,3) = ( Mx{i,1}(:,3) - mean(Mx{i,1}(:,3)) ) / V2G6;
    Mx{i,2}(:,4) = ( Mx{i,1}(:,4) - mean(Mx{i,1}(:,4)) );
    
    for k = 0:2 % ch1~3各Hz,RMS,THDの記録
        [thd_db, ~, harmfreq] = thd(Mx{i,2}(:,1+k), Fs, nharm);
        %             thd(Mx{8,2}(:,1), Fs, nharm); % 個別のTHDを見たいとき
        Mx{i,6+3*k} = harmfreq(1,1);
        %         Mx{i,7+3*k} = rms((Mx{i,2}(:,1+k))) - 0.01 ;
        Mx{i,7+3*k} = rms((Mx{i,2}(:,1+k))) ;
        RMS_column(i,k+1) = Mx{i,7+3*k}; %  RMS値格納用行列
        Mx{i,8+3*k} = thd_db;
        
    end
    %入力電圧の周波数を取得し記録（harmfreqで高調波が分かる、その始めの値を利用)
    [thd_db, harmpow, harmfreq] = thd(Mx{i,1}(:,4), Fs, nharm);
    Mx{i,4} = harmfreq(1,1);
    % FGから入力電圧のVppを求める。2倍は負の値を考慮
    Vin = 2*sqrt(2)*rms((Mx{i,1}(:,4)));
    Mx{i,5} = Vin;
    Mx{i,9+3*k} = xyz;
    xyz = 0;
    % 3軸のRMS値
    Mx{i,9+3*k} =Mx{i,7+3*0} + Mx{i,7+3*1} + Mx{i,7+3*2};
    RMS_column(i,4) = Mx{i,9+3*k};
    
%     TT= timetable(Mx{i,2}(:,1), Mx{i,2}(:,2), Mx{i,2}(:,3),Mx{i,2}(:,4),'SampleRate',Fs);
    % timetable を各列ごとに追加
    Mx{i,3} = timetable(Mx{i,2}(:,1), Mx{i,2}(:,2), Mx{i,2}(:,3),Mx{i,2}(:,4),'SampleRate',Fs);
    Mx{i,3}.Properties.VariableNames{'Var1'}='x' ;
    Mx{i,3}.Properties.VariableNames{'Var2'}='y' ;
    Mx{i,3}.Properties.VariableNames{'Var3'}='z' ;
    labels_x(i,1) = round(Mx{i, 7}, 3,'significant');
    labels_y(i,1) = round(Mx{i, 10}, 3,'significant');
    labels_z(i,1) = round(Mx{i, 13}, 3,'significant');
    labels_sum(i,1) = round(Mx{i, 15}, 3,'significant');
end
% 行末に説明を追加
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
Mx{i+1,15} = '3軸RMS値';

save;

%%  %%%%%%%  以下、図示しないなら不要 %%%%%%%

%% マーカー（緑）の位置に実験結果を図示
% 
% % ラベル描画関連
% img_list = dir('../img/*.png');
% Underlayer_img = imread('../img/Underlayer.png');
% num_pointArray =  length(img_list)-1 ; %緑マーカの列の数。imgフォルダの画像数から算出
% 
% centerOfAnnotation = zeros(num_points, 2);%c_Annotationから中心座標のみ取り出し
% radiulOfCircles = zeros(num_points, 1);
% 
% c_Annotation = cell(num_pointArray,1); %描画用マーカー座標を入れるセル
% 
% for i=1:num_pointArray
%     img = imread(strcat('../img/', num2str(i), '.png'));
%     % 閾値からマーカーを二値化、重心を求める
%     % greenDetect.mとnoiseReduction.mが必要
%     [BW, masked] = m_greenDetect(img);
%     BW_filtered = m_noiseReduction(BW);
%     % stats = regionprops(BW1_filtered);
%     I = rgb2gray(masked);
%     stats = regionprops(BW_filtered, I ,{'Centroid'});
%     tmp_colmun =zeros(size(stats,1),2) ;
%     for k = 1: size(stats,1)
%         centroids = stats(k).Centroid;
%         tmp_colmun(k,1) = centroids(1,1);
%         tmp_colmun(k,2) = centroids(1,2);
%         % X座標を元にグループ分け、別々の行列に重心座標を代入する
%     end
%     %     Xgを基準に並び替え
%     %     tmp_colmun =  sortrows(tmp_colmun, 1);
%     
%     %     Ygを基準に並び替え
%     tmp_colmun = sortrows(tmp_colmun, 2);
%     c_Annotation{i,1} =tmp_colmun;
% end
% 
% 
% %% 各軸ごとの加速度の大きさと数値を図示
% % x,y,z,sumを一度の処理で描画する
% %描画のため加速度(g)に掛け合わせる係数
% 
% 
% % if area == 0
% %     radius_coef = 15;%前面
% % elseif area == 1
% %     radius_coef = 25;%側面
% % elseif area ==2
% %     radius_coef = 25;%側面
% % end
%    
% 
% % for axis = 0:3
% %     if axis == 2
% % %         figure('Name','x')
% %         target_row = 7;
% %         labels = labels_x;
% %     elseif axis == 1
% % %         figure('Name','y')
% %         target_row = 10;
% %         labels = labels_y;
% %     elseif axis == 0
% % %         figure('Name','z')
% %         target_row = 13;
% %         labels = labels_z;
% %     elseif axis == 3
%         figure('Name','sum')
%         target_row = 15 ;
%         labels = labels_sum;
% %     end
% %     
% 
%     Annotation = zeros(num_points, 3); %c_AnnotationのFloat行列, [マーカーのx座標, y座用, 加速度の大きさr]
%     %viscirclesを使うため、重心と円半径をそれぞれ別の行列に代入
%     i = 0; %　c_Annotationの数だけ参照行をシフトさせるため
%     for m = 1:size(c_Annotation,1)
%         for k = 1: size(c_Annotation{m,1},1)
%             Annotation(k+i, 1) = c_Annotation{m,1}(k, 1);
%             Annotation(k+i, 2) = c_Annotation{m,1}(k, 2);
%             Annotation(k+i, 3) = Mx{k+i, target_row}*radius_coef;
%         end
%         i = i + size(c_Annotation{m,1},1);
%     end
%     % Mxに格納されているデータを重心＋offsetの位置に描画
%     %     dispFrame = insertObjectAnnotation(Underlayer_img, 'circle', Annotation, labels, ...
%     %          'FontSize', 30, 'LineWidth', 3,'TextBoxOpacity',0.4, 'color', 'magenta','TextColor', 'white');
%     %     imshow(dispFrame)
%     %
%     %     % 前面用フォント 適宜調整
%     
%  % Annotationの大きさなどを決定
%  annoColor = 'blue';
% if area == 0 %前面
%     dispFrame = insertObjectAnnotation(Underlayer_img, 'circle', Annotation, labels, ...
%     'FontSize', 10, 'LineWidth', 2,'TextBoxOpacity',0, 'color', 'magenta','TextColor', annoColor);
% elseif area == 1 %側面
%     dispFrame = insertObjectAnnotation(Underlayer_img, 'circle', Annotation, labels, ...
%     'FontSize', 20, 'LineWidth', 3,'TextBoxOpacity',0.4, 'color', 'magenta','TextColor', annoColor);
% elseif area ==2 %背面
%     dispFrame = insertObjectAnnotation(Underlayer_img, 'circle', Annotation, labels, ...
%     'FontSize', 20, 'LineWidth', 3,'TextBoxOpacity',0.4, 'color', 'magenta','TextColor', annoColor);
% end
%    
%     
% %     dispFrame = insertObjectAnnotation(Underlayer_img, 'circle', Annotation, labels, ...
% %         'FontSize', 20, 'LineWidth', 3,'TextBoxOpacity',0.4, 'color', 'magenta','TextColor', 'white');
%     
% 
%     imshow(dispFrame,'Border','tight') % border tight を入れることで余白なしに
%     
%     % 前面用フォント
%     %     dispFrame = insertObjectAnnotation(Underlayer_img, 'circle', Annotation, labels, ...
%     %          'FontSize', 8, 'LineWidth', 3,'TextBoxOpacity',0,'TextColor', 'white');
%     %     imshow(dispFrame)
%     
%     
%     if target_row == 7
%         str = 'Xg';
%     elseif target_row == 10
%         str = 'Yg';
%     elseif target_row == 13
%         str = 'Zg';
%     elseif target_row == 15
%         str = 'Sum';
%     end
%     %     Sum, x, y, zの表示
%     %annotationテキストのy座用
%     
%     if or(area == 0,area==1) %前面 or 側面
%                 x_base = 220;
%                 y_base = 20;
%                 y_offset = 30;
%     elseif area == 1 %背面
%         %         x_base = 240;
%         %         y_base = 140;
%         %         y_offset = 30;
%     end
%         text(x_base,y_base,erase(dir('*.txt').name,'.txt'),'Color','white','FontSize',20);
%     %     text(x_base,y_base + y_offset,str,'Color','white','FontSize',20);
%     
% % end % for end
% 
% saveas(gcf,strcat('sum','.png'));
% 
% %% 描画重心と加速度の大きさを示す円を描画するのに使用する行列の準備
% 
% % マーカーの中心座標を注釈用float行列に変換（cell形式からfloat行列形式に変えたい）
% 
% %% x,y,zの加速度の値を一枚図に描画
% % radius_coef = 60;%描画のため加速度(g)に掛け合わせる係数
% 
% figure
% % imshow(Underlayer_img); %一回のみ。ループの中に入れると都度初期化される。
% imshow(Underlayer_img,'Border','tight');
% 
% % 円の大きさの注釈（重力加速度：円直径）
% 
% annotation_color = 'white';
% 
% if area == 0
%     % 前面 or 側面
%     %     viscircles([150  400],1 * radius_coef, 'Color',annotation_color);
%     %     text(130,400,'1G','Color',annotation_color,'FontSize',24);
%     %     viscircles([150  520],2 * radius_coef, 'Color',annotation_color);
%     %     text(130,520,'2G','Color',annotation_color,'FontSize',24);
%     %     viscircles([150  700],3 * radius_coef, 'Color',annotation_color);
%     %     text(130,700,'3G','Color',annotation_color,'FontSize',24);
%     
% elseif area == 1
%     % 背面
%     %     viscircles([100  250], 1 * radius_coef, 'Color',annotation_color);
%     %     text(80,250,'1G','Color',annotation_color,'FontSize',16);
%     %     viscircles([300 250], 2 * radius_coef, 'Color',annotation_color);
%     %     text(270,250,'2G','Color',annotation_color,'FontSize',24);
%     %     viscircles([500  250], 3 * radius_coef, 'Color',annotation_color);
%     %     text(470,250,'3G','Color',annotation_color,'FontSize',24);
% end
% 
% %annotationテキストのy座用
% % x_base = 250;
% % y_base = 20;
% %ディレクトリにある.txtのファイル名を注釈に利用
% text(x_base,y_base,erase(dir('*.txt').name,'.txt'),'Color','white','FontSize',20);
% % text(40,50,erase(dir('*.txt').name,'.txt'),'Color','white','FontSize',20);
% 
% for axis = 0:2
%     %加速度の大きさをlabels行列に代入
%     if axis == 2
%         target_row = 7; % x
%         circleLineColor = '#009C4E'; % x = 緑色
%         %         text(40,y_base + 1*y_offset,'x = green','Color',circleLineColor,'FontSize',20);
%     elseif axis == 1
%         target_row = 10; % y
%         circleLineColor = '#FFFF00'; % y = 黄色
%         %         text(40,y_base + 2*y_offset,'y = yellow','Color',circleLineColor,'FontSize',20);
%     elseif axis == 0
%         target_row = 13; % z
%         circleLineColor = '#FFA500'; % z = オレンジ
%         %         text(40,y_base + 3*y_offset,'z = orange','Color',circleLineColor,'FontSize',20);
%     end
%     
%     %viscirclesを使うため、重心と円半径をそれぞれ別の行列に代入
%     i = 0;
%     for m = 1:size(c_Annotation,1)
%         for k = 1: size(c_Annotation{m,1},1)
%             centerOfAnnotation(k+i, :) = [c_Annotation{m,1}(k, 1) c_Annotation{m,1}(k, 2)];
%             radiulOfCircles(k+i, :) = Mx{k+i, target_row}*radius_coef;
%         end
%         i = i + size(c_Annotation{m,1},1);
%     end
%     
%     viscircles(centerOfAnnotation, radiulOfCircles,'Color',circleLineColor,'EnhanceVisibility',false,'LineStyle','-','LineWidth',1);
% end
% 
% % text(x_base,y_base,erase(dir('*.txt').name,'.txt'),'Color','white','FontSize',20);
% saveas(gcf,strcat('xyz','.png'));


%% %%%%%%%  以上、図示しないなら不要 %%%%%%%

%% タイムテーブルに代入
% t1 = Mx{1,3};
% t2 = Mx{2,3};
% t3 = Mx{3,3};
% t4 = Mx{4,3};
% t5 = Mx{5,3};
% t6 = Mx{6,3};
% t7 = Mx{7,3};
% t8 = Mx{8,3};
% t9 = Mx{9,3};
% t10 = Mx{10,3};
% t11 = Mx{11,3};
% t12 = Mx{12,3};
% t13 = Mx{13,3};
% t14 = Mx{14,3};
% t15 = Mx{15,3};
% %
%% 重心検知
% % 重ね元の画像のインポート
%
% img = imread(Underlayer_img);
% % 閾値からマーカーを二値化、重心を求める
% % greenDetect.mとnoiseReduction.mが必要
% [BW, masked] = greenDetect(img);
% BW_filtered = noiseReduction(BW);
% % stats = regionprops(BW1_filtered);
% I = rgb2gray(masked);
% stats = regionprops(BW_filtered, I ,{'Centroid','WeightedCentroid'});
% t1st_column =zeros(size(stats,1),2) ;
% t2nd_column= zeros(size(stats,1),2) ;
% t3rd_column = zeros(size(stats,1),2) ;
%
% Recorder = cell(size(stats,1));
% Annotation = zeros(size(stats,1),3);
% labels = zeros(size(stats,1),1);
%
% for k = 1: size(stats,1)
%     centroids = stats(k).Centroid;
%     Xg = centroids(1,1);
%     Yg = centroids(1,2);
% %     WeightedCentroid1 = stats(k).WeightedCentroid;
% % X座標を元にグループ分け、別々の行列に重心座標を代入する
%     if Xg > 50 && Xg < 150
%        t1st_column(k,1) = Xg;
%        t1st_column(k,2) = Yg;
%     elseif Xg > 300 && Xg < 400
%        t2nd_column(k,1) = Xg;
%        t2nd_column(k,2) = Yg;
%     elseif Xg > 500 && Xg < 700
%        t3rd_column(k,1) = Xg;
%        t3rd_column(k,2) = Yg;
%     end
%     labels(k,1) = round(Mx{k,target_row}, 3,'significant');
% end
%
% % 0の要素を削除
%% 数値描画
% % Ygを基準に並び替え
%     t1st_column = sortrows(t1st_column,2);
%     t2nd_column = sortrows(t2nd_column,2);
%     t3rd_column = sortrows(t3rd_column,2);
%
%  % 0の行を削除。必ず小さい順にソートし、0の行が上側にある状態で実行すること
%  for m = 1:size(t1st_column,1)
%      if t1st_column(1,1) == 0
%          t1st_column(1,:) = [];
%      end
%  end
%  for m = 1:size(t2nd_column,1)
%      if t2nd_column(1,1) == 0
%          t2nd_column(1,:) = [];
%      end
%  end
% for m = 1:size(t3rd_column,1)
%      if t3rd_column(1,1) == 0
%          t3rd_column(1,:) = [];
%      end
%  end
%
% % 画像に加速度の大きさに応じた円（第3引数）を描画
% for m = 1:size(t1st_column,1)
%     Annotation(m, :) =[t1st_column(m, 1) t1st_column(m, 2) Mx{m,target_row}*radius_coef];
% end
%
%  for m = 1:size(t2nd_column,1)
%     Annotation(m+row_num, :) =[t2nd_column(m, 1) t2nd_column(m, 2) Mx{m+row_num,target_row}*radius_coef];
%  end
%
% for m = 1:size(t3rd_column,1)
%     Annotation(m+row_num*2, :) =[t3rd_column(m, 1) t3rd_column(m, 2) Mx{m+row_num*2,target_row}*radius_coef];
% end
%
% % Mxに格納されているデータを重心＋offsetの位置に描画
% dispFrame = insertObjectAnnotation(img, 'circle', Annotation, labels, ...
%      'FontSize', 30, 'LineWidth', 3,'TextBoxOpacity',0.4);
% imshow(dispFrame)
%
% if target_row == 7
%     str = 'Xg';
% elseif target_row == 10
%     str = 'Yg';
% elseif target_row == 13
%     str = 'Zg';
% elseif target_row == 15
%     str = 'Sum';
% end
% % 軸の注釈
% dim = [.14 .6 .4 .1];
% % title(str);
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
%%
% t13 = Mx{13,3};
% t14 = Mx{14,3};
% t15 = Mx{15,3};
% t16 = Mx{16,3};
% t17 = Mx{17,3};
% t18 = Mx{18,3};
% t19 = Mx{19,3};
% t20 = Mx{20,3};
% t21 = Mx{21,3};
% t22 = Mx{22,3};
% t23 = Mx{23,3};
% t24 = Mx{24,3};
% t25 = Mx{25,3};
% t26 = Mx{26,3};
% t27 = Mx{27,3};
% t28 = Mx{28,3};
% t29 = Mx{29,3};
% t30 = Mx{30,3};
% t31 = Mx{31,3};
% t32 = Mx{32,3};
% t33 = Mx{33,3};
% t34 = Mx{34,3};
%% コメントアウト
%% 数値描画
% 重ね元の画像のインポート
%
% img = imread(Underlayer_img);
% % 閾値からマーカーを二値化、重心を求める
% % greenDetect.mとnoiseReduction.mが必要
% [BW, masked] = greenDetect(img);
% BW_filtered = noiseReduction(BW);
% % stats = regionprops(BW1_filtered);
% I = rgb2gray(masked);
% stats = regionprops(BW_filtered, I ,{'Centroid','WeightedCentroid'});
% t1st_column =zeros(size(stats,1),2) ;
% t2nd_column= zeros(size(stats,1),2) ;
% t3rd_column = zeros(size(stats,1),2) ;
%
% Recorder = cell(size(stats,1));
% Annotation = zeros(size(stats,1),3);
% labels = zeros(size(stats,1),1);
%
% for k = 1: size(stats,1)
%     centroids = stats(k).Centroid;
%     Xg = centroids(1,1);
%     Yg = centroids(1,2);
% %     WeightedCentroid1 = stats(k).WeightedCentroid;
% % X座標を元にグループ分け、別々の行列に重心座標を代入する
%     if Xg > 50 && Xg < 150
%        t1st_column(k,1) = Xg;
%        t1st_column(k,2) = Yg;
%     elseif Xg > 300 && Xg < 400
%        t2nd_column(k,1) = Xg;
%        t2nd_column(k,2) = Yg;
%     elseif Xg > 500 && Xg < 700
%        t3rd_column(k,1) = Xg;
%        t3rd_column(k,2) = Yg;
%     end
%     labels(k,1) = round(Mx{k,target_row}, 3,'significant');
% end
%%グラフ描画（AVG）
%
% RMS_Graph40Hz = zeros(numFiles/2,5); numFiledが偶数でないとエラーが出るので注意
% RMS_Graph160Hz = zeros(numFiles/2,5);
% AVG40Hz = zeros(numFiles/2,5);
% AVG160Hz = zeros(numFiles/2,5);

% %% グラフ描画（AVG）
% if isfile('awake.txt')
%     close all;
%     % RMS_Graph40Hz(:,1) = [7.176800356; 15.71619743; 27.86718577;45.15739219; 65.99584052; 88.54207624;
%     x40_axis = RMS_Graph40Hz(:,1);
%     x160_axis = RMS_Graph160Hz(:,1);
%     ylimN_max = 2.1;
%     xlim_min = 20;
%     % グラフの色
%     def_blue =[0 0.4470 0.7410];
%     def_orange = [0.8500 0.3250 0.0980];
%     % y_N40axis = 0 : 0.2 : max(RMS_Graph40Hz(:,2);
%     x_label ='Input Voltage (Top: Displayed on Fuction Generator (mV), Bot: Motor Voltage (mV) )';
%     y_Nlabel = 'Tension(N)';
%     y_XYZlabel = 'Acceleralation(G)';
%     %記録したデータが降順の場合、グラフ表示用に行列を並び替えて代入する
%     AVGflag = dir('*.txt');
%     if contains(pwd, "RVS") | contains(AVGflag.name, "AVG")
%         RMS_Graph40Hz = flip(AVG40Hz);
%         RMS_Graph160Hz = flip(AVG160Hz);
%     else
%         RMS_Graph40Hz = AVG40Hz;
%         RMS_Graph160Hz = AVG160Hz;
%     end
%     % 40Hzのグラフ
%     f1 = figure;
%     hold on
%     % 張力のy軸を左に、加速度のy軸を右に
%     yyaxis left
%     ylabel(y_Nlabel);
%     plot(x40_axis, RMS_Graph40Hz(:,2), '-o','MarkerFaceColor',def_blue,'MarkerSize',5)
%
%     ylim([0 ylimN_max])
%     %加速度のプロット（y軸右）
%     yyaxis right
%     plot(x40_axis, RMS_Graph40Hz(:,3),'-->','MarkerFaceColor',def_orange,'MarkerSize',5);
%     plot(x40_axis, RMS_Graph40Hz(:,4),'-^','MarkerFaceColor',def_orange,'MarkerSize',5);
%     plot( x40_axis, RMS_Graph40Hz(:,5),'-.d','MarkerFaceColor',def_orange,'MarkerSize',5);
%     ylim([0 0.45])
%     % x軸の範囲
%     xlim([xlim_min max(RMS_Graph40Hz(:,1))] )
%     xticks([20:10:200])
%
%     % xtl = '\begin{tabular}{c} 20 \\ 30\end{tabular}';
%     % set(gca,'XTick',[20:10:200],'XTickLabels',xtl,'TickLabelInterpreter','latex')
%     set(gca,'FontSize',9,'XTickLabel',{'20 (0.25)','30 (0.37)','40 (0.50)','50 (0.63)',...
%         '60 (0.76)','70 (0.88)','80 (1.01)','90 (1.14)','100 (1.27)',...
%         '110 (1.39)','120 (1.52)','130 (1.64)','140 (1.77)','150 (1.89)',...
%         '160 (2.01)','170 (2.13)','180 (2.25)','190 (2.37)','200 (2.49)'});
%     fix_xticklabels();
%     ylabel(y_XYZlabel);
%     % legend('Tension','G_x','G_y','G_z','G_{xyz}');
%     legend('Tension','G_x','G_y','G_z');
%     xlabel(x_label)
%     title('40Hz Result')
%     %表示させるスクリーンサイズを調整する。nw（横）とnh（高さ）を調整するだけでおｋ
%     scrsz = get(groot,'ScreenSize');
%     nw = 2;
%     nh =1.3;
%     maxW = scrsz(3);
%     maxH = scrsz(4);
%     p = get(gcf,'Position');
%     dw = p(3)-min(nw*p(3),maxW);
%     dh = p(4)-min(nh*p(4),maxH);
%     set(gcf,'Position',[p(1)+dw/2  p(2)+dh  min(nw*p(3),maxW)  min(nh*p(4),maxH)])
%     hold off
%     % 160Hzのグラフ
%     f2 = figure;
%     hold on
%     % 張力のy軸を左に、加速度のy軸を右に
%     yyaxis left
%     ylabel(y_Nlabel);
%     plot(x160_axis, RMS_Graph160Hz(:,2), '-o','MarkerFaceColor',def_blue,'MarkerSize',5)
%     ylim([0 ylimN_max])
%     %加速度のプロット（y軸右）
%     yyaxis right
%     % plot( x_axis, RMS_Graph160Hz(:,3), x_axis, RMS_Graph160Hz(:,4), x_axis, RMS_Graph160Hz(:,5), x_axis, RMS_Graph160Hz(:,6) )
%     plot(x160_axis, RMS_Graph160Hz(:,3),'-->','MarkerFaceColor',def_orange,'MarkerSize',5);
%     plot(x160_axis, RMS_Graph160Hz(:,4),'-^','MarkerFaceColor',def_orange,'MarkerSize',5);
%     plot( x160_axis, RMS_Graph160Hz(:,5),'-.d','MarkerFaceColor',def_orange,'MarkerSize',5);
%     ylim([0 0.45])
%     %160Hz 軸の範囲設定
%     xlim([xlim_min max(RMS_Graph160Hz(:,1))] )
%     xticks([20:10:200])
%     set(gca,'FontSize',9,'XTickLabel',{'20 (0.25)','30 (0.35)','40 (0.47)','50 (0.60)',...
%         '60 (0.72)','70 (0.83)','80 (0.95)','90 (1.06)','100 (1.18)',...
%         '110 (1.29)','120 (1.41)','130 (1.52)','140 (1.64)','150 (1.74)',...
%         '160 (1.85)','170 (1.96)','180 (2.07)','190 (2.19)','200 (2.29)'});
%     fix_xticklabels();
%     ylabel(y_XYZlabel);
%     % legend('Tension','G_x','G_y','G_z','G_{xyz}');
%     legend('Tension','G_x','G_y','G_z');
%     xlabel(x_label)
%     title('160Hz Result')
%     %表示させるスクリーンサイズを調整する。nw（横）とnh（高さ）を調整するだけでおｋ
%     scrsz = get(groot,'ScreenSize');
%     nw = 2;
%     nh =1.3;
%     maxW = scrsz(3);
%     maxH = scrsz(4);
%     p = get(gcf,'Position');
%     dw = p(3)-min(nw*p(3),maxW);
%     dh = p(4)-min(nh*p(4),maxH);
%     set(gcf,'Position',[p(1)+dw/2  p(2)+dh  min(nw*p(3),maxW)  min(nh*p(4),maxH)])
%
%     hold off
% end
%% グラフ描画（起動電圧）
% % if contains(AwakeFlag.name, "awake")
% if isfile('awake.txt')
%     close all;
%
%     RMS_Graph40Hz = flip(AVG40Hz);
%     RMS_Graph160Hz = flip(AVG160Hz);
%
%     x40_axis = RMS_Graph40Hz(:,1);
%     x160_axis = RMS_Graph160Hz(:,1);
%     ylimN_max = 2.1;
%     xlim40_min = min(RMS_Graph40Hz(:,1));
%     xlim40_max = max(RMS_Graph40Hz(:,1));
%     xlim160_min = min(RMS_Graph160Hz(:,1));
%     xlim160_max = max(RMS_Graph160Hz(:,1));
%     % y_N40axis = 0 : 0.2 : max(RMS_Graph40Hz(:,2);
%     x_label = 'Input Voltage (Top: Displayed on Fuction Generator (mV), Bot: Motor Voltage (mV) )'
%     y_Nlabel = 'Tension(N)';
%
%     % RMS_Graph40Hz = sortrows(RMS_Graph40Hz);
%     % RMS_Graph160Hz = sortrows(RMS_Graph160Hz);
%
%     %40Hzのグラフ
%     f1 = figure;
%     hold on
%     % 張力のy軸を左に、加速度のy軸を右に
%     ylabel(y_Nlabel);
%     plot(x40_axis, RMS_Graph40Hz(:,2),'-ro',x40_axis, RMS_Graph40Hz(:,3),'-r*', ...
%         x40_axis, RMS_Graph40Hz(:,4),'-go',x40_axis, RMS_Graph40Hz(:,5),'-g*',...
%         x40_axis, RMS_Graph40Hz(:,6),'-bo',x40_axis, RMS_Graph40Hz(:,7),'-b*');
%     % x軸の範囲
%     %     ylim([0 yN_max])
%     xlim([xlim40_min xlim40_max] )
%         set(gca,'FontSize',9,'XTickLabel',{'20 (253)','21 (265)','22 (278)','23 (289)',...
%         '24 (300)','25 (312)','26 (323)','27 (338)','28 (350)','29 (362)','30 (376)'});
%     fix_xticklabels();
%     % legend('Tension','G_x','G_y','G_z','G_{xyz}');
%     legend('1st','2nd','3rd','4th','5th','6th');
%     xlabel(x_label)
%     title('40Hz Result')
%
%         %表示させるスクリーンサイズを調整する。nw（横）とnh（高さ）を調整するだけでおｋ
%     scrsz = get(groot,'ScreenSize');
%     nw = 1;
%     nh =1.3;
%     maxW = scrsz(3);
%     maxH = scrsz(4);
%     p = get(gcf,'Position');
%     dw = p(3)-min(nw*p(3),maxW);
%     dh = p(4)-min(nh*p(4),maxH);
%     set(gcf,'Position',[p(1)+dw/2  p(2)+dh  min(nw*p(3),maxW)  min(nh*p(4),maxH)])
%
%
%     hold off
%
%     % 160Hzのグラフ
%     f2 = figure;
%     hold on
%     ylabel(y_Nlabel);
%     plot(x160_axis, RMS_Graph160Hz(:,2),'-ro',x160_axis, RMS_Graph160Hz(:,3),'-r*', ...
%         x160_axis, RMS_Graph160Hz(:,4),'-go',x160_axis, RMS_Graph160Hz(:,5),'-g*',...
%         x160_axis, RMS_Graph160Hz(:,6),'-bo',x160_axis, RMS_Graph160Hz(:,7),'-b*');        % 軸の範囲設定
% %     ylim([0 yN_max])
%     xlim([xlim160_min xlim160_max] )
%         set(gca,'FontSize',9,'XTickLabel',{'15 (200)','16 (212)','17 (222)','18 (234)',...
%         '19 (244)','20 (254)','21 (265)','22 (277)','23 (288)','24 (299)','25 (311)'});
%     fix_xticklabels();
%     % legend('Tension','G_x','G_y','G_z','G_{xyz}');
%     % legend('Tension','G_x','G_y','G_z','G_{xyz}');
%     legend('1st','2nd','3rd','4th','5th','6th');
%     xlabel(x_label)
%     title('160Hz Result')
%
%             %表示させるスクリーンサイズを調整する。nw（横）とnh（高さ）を調整するだけでおｋ
%     scrsz = get(groot,'ScreenSize');
%     nw = 1;
%     nh =1.3;
%     maxW = scrsz(3);
%     maxH = scrsz(4);
%     p = get(gcf,'Position');
%     dw = p(3)-min(nw*p(3),maxW);
%     dh = p(4)-min(nh*p(4),maxH);
%     set(gcf,'Position',[p(1)+dw/2  p(2)+dh  min(nw*p(3),maxW)  min(nh*p(4),maxH)])
%     hold off
% end
% %% 線形範囲20~200mV
% if IsNXYZ
%     L200mV = Mx{1,3};
%     L190mV = Mx{2,3};
%     L180mV = Mx{3,3};
%     L170mV = Mx{4,3};
%     L160mV = Mx{5,3};
%     L150mV = Mx{6,3};
%     L140mV = Mx{7,3};
%     L130mV = Mx{8,3};
%     L120mV = Mx{9,3};
%     L110mV = Mx{10,3};
%     L100mV = Mx{11,3};
%     L90mV = Mx{12,3};
%     L80mV = Mx{13,3};
%     L70mV = Mx{14,3};
%     L60mV = Mx{15,3};
%     L50mV = Mx{16,3};
%     L40mV = Mx{17,3};
%     L30mV = Mx{18,3};
%     L20mV = Mx{19,3};
%     H200mV = Mx{20,3};
%     H190mV = Mx{21,3};
%     H180mV = Mx{22,3};
%     H170mV = Mx{23,3};
%     H160mV = Mx{24,3};
%     H150mV = Mx{25,3};
%     H140mV = Mx{26,3};
%     H130mV = Mx{27,3};
%     H120mV = Mx{28,3};
%     H110mV = Mx{29,3};
%     H100mV = Mx{30,3};
%     H90mV = Mx{31,3};
%     H80mV = Mx{32,3};
%     H70mV = Mx{33,3};
%     H60mV = Mx{34,3};
%     H50mV = Mx{35,3};
%     H40mV = Mx{36,3};
%     H30mV = Mx{37,3};
%     H20mV = Mx{38,3};
% end
% %% 40,160Hz  起動点
% L30mV = Mx{1,3};
% L29mV = Mx{2,3};
% L28mV = Mx{3,3};
% L27mV = Mx{4,3};
% L26mV = Mx{5,3};
% L25mV = Mx{6,3};
% L24mV = Mx{7,3};
% L23mV = Mx{8,3};
% L22mV = Mx{9,3};
% L21mV = Mx{10,3};
% L20mV = Mx{11,3};
% H25mV = Mx{12,3};
% H24mV = Mx{13,3};
% H23mV = Mx{14,3};
% H22mV = Mx{15,3};
% H21mV = Mx{16,3};
% H20mV = Mx{17,3};
% H19mV = Mx{18,3};
% H18mV = Mx{19,3};
% H17mV = Mx{20,3};
% H16mV = Mx{21,3};
% H15mV = Mx{21,3};