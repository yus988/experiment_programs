% 下着の有無の比較のためのスクリプト
% n回分の平均を取るスクリプト。csv入ったフォルダで実行

close all

% まずsortする
Sort_by_Input2080140_0512

Fs = 1e4;%サンプル周波数
t = 0:1/Fs:1;
%加速度センサの感度
V2G = 0.206; %MMA7361L 6Gモード
% V2G = 0.800; %MMA7361L 1.5Gモード
V2N = 0.01178; %力センサ5916
nharm = 6;%thdの高調波数
%10列2行のセルを作成。1列目にy軸加速度の行列、2列目に力センサ
%（できれば1-の連番にして一々ファイル名を変更しないでも良いようにしたい

Mx = cell(numFiles,2);% インポート用のセル
Analysis = cell(15);
xyz = 0;
num_points = numFiles; % 測定点数なのでは？
RMS_column = zeros(1,4);% RMS値格納用
resultArray = zeros(10,4);


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


    list = dir('*.csv');
numFiles = length(list);

%% csvデータのインポートおよびラベル用データ生成
for i = 1:numFiles
    Mx{i,1}= csvread(list(i).name,21,1,[21,1,10020,4]);
    % オフセット除去（すべての要素から平均値を引く）
    Mx{i,2}(:,1) = ( Mx{i,1}(:,1) - mean(Mx{i,1}(:,1)) ) / V2G; %下に引っ張った時を正に（標準では負）
    Mx{i,2}(:,2) = ( Mx{i,1}(:,2) - mean(Mx{i,1}(:,2)) ) / V2G;
    Mx{i,2}(:,3) = ( Mx{i,1}(:,3) - mean(Mx{i,1}(:,3)) ) / V2G;
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
end
    
%% RMSから平均（Mean）を算出
for j = 1:4
     row = 2 * cd_times - 1;
     resultArray(row,j) = mean(RMS_column(:,j));
     resultArray(row + 1,j) = std(RMS_column(:,j));
end
    cd .. 
end
