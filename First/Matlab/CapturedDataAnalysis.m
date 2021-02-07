% hsv_rec から出力された.csvファイルを、マーカーのインデックスごとに並べ替えて格納する
% 1列目：記録Index（≒時間）、２列目：マーカーのインデックス、３列目：重心のx座標、４列目：重心のy座標、5,6,7列目：マーカーのh,s,v平均値、８列目：面積

clear;
list = dir('*.csv');
numFiles = length(list);
Import = cell(numFiles,2);    
GraphCell = cell(numFiles, 2);

 for i = 1 : numFiles
      Import{i,2} = csvread(list(i).name, 0, 0);%csvファイルの読み込み 
 end

 num_marker =  max(Import{1,2}(:, 2));
 
 for i = 1 :  num_marker%max = マーカーの個数, ここのIは代入先の行（Import）を示す
        pickIndex = find( Import{1,2}(:,2) == i ); %
        for k = 1 : length(pickIndex)
            pick = pickIndex(k,1); %元データから取り出したい行番号をpickに代入する(1回ごとに更新される）
            if  Import{1, 2}(pick,8) < 100 % マーカーの面積が一定以下だったら（誤検出）
                len = (num_marker - Import{1, 2}(pick,2)) - 1; % 誤検出をしたindex numberからindexの最大を引いた値。修正する回数
                    for m =  0  :  len  % num_markerが最大になるまで、検出した後のindexの値を1引く
                             Import{1,2}(pick+1 + (len - m) ,2)  =  Import{1,2}(pick + (len - m), 2);
                    end
                    Import{1, 2}(pick,:) = []; %ここで誤検出したインデックスを消している
            end
            Import{i, 1}(k,:) = Import{1,2}(pick,:);%元データのpick行目をまとめ用セル行列に代入
        end          
 end

 %% グラフ化
 num_marker =  max(Import{1,2}(:, 2)); %誤検出の行を消してあるので、これで正しいマーカーの個数が分かる
 Xg_movement = 0;
 Yg_movement = 0;
%  マーカー1つ1つに対して回す
 for i = 1 :  num_marker 
        [row_index, column_index] = size(Import{i,1}); % 各Index毎のデータサイズを取得
        GraphCell{i,1} = i;
        for k = 1 : row_index  - 1%各マーカーデータの行末まで。各計算処理はここに書く
            % フレーム間の位置の差分を積算する
            Xg_movement = Xg_movement +  abs( Import{i,1}(k+1,3) - Import{i,1}(k,3));
            Yg_movement = Yg_movement + abs (Import{i,1}(k+1,4) - Import{i,1}(k,4));
        end
        
%             GraphCell{i,2} = Xg_movement;
%             GraphCell{i,3} = Yg_movement;
        GraphCell{i,2} = (Xg_movement + Yg_movement) / row_index;
        Xg_movement = 0;
        Yg_movement = 0;
 end

GraphData = cell2mat(GraphCell) ;
%  stem(GraphData(:,1), GraphData(:,4))
  
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
