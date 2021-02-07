%%人体の各点の加速度測定時のファイル分け用スクリプト
%%入力電圧と周波数から40/160Hz_0.5/1/2Wに分類

clear
Fs = 1e4;%サンプル周波数
t = 0:1/Fs:1;
%加速度センサの感度
V2G6 = 0.206; %MMA7361L 6Gモード
V2G15 = 0.800; %MMA7361L 1.5Gモード
V2N = 0.01178; %力センサ5916
nharm = 6;%thdの高調波数
%10列2行のセルを作成。1列目にy軸加速度の行列、2列目に力センサ
%（できれば1-の連番にして一々ファイル名を変更しないでも良いようにしたい
list = dir('*.csv');
png = dir('*.png');
numFiles = length(list);
Mx = cell(numFiles,2);
Input_Hz = 0;
Input_Vol = 0;
%% 分類するフォルダの作成
if ~isfolder('40Hz_05W')
    mkdir 40Hz_05W
end

if ~isfolder('40Hz_1W')
    mkdir 40Hz_1W
end

if ~isfolder('40Hz_2W')
    mkdir 40Hz_2W
end

if ~isfolder('160Hz_05W')
    mkdir 160Hz_05W
end

 if ~isfolder('160Hz_1W')
    mkdir 160Hz_1W
end
    
if ~isfolder('160Hz_2W')
    mkdir 160Hz_2W
end
    
%%
% データのインポートおよびラベル用データ生成
for i = 1:numFiles
    Mx{i,1}= csvread(list(i).name,21,1,[21,1,10020,4]);
    % オフセット除去（すべての要素から平均値を引く）
    Mx{i,2}(:,1) = ( Mx{i,1}(:,1) - mean(Mx{i,1}(:,1)) ) / V2G15; %下に引っ張った時を正に（標準では負）
    Mx{i,2}(:,2) = ( Mx{i,1}(:,2) - mean(Mx{i,1}(:,2)) ) / V2G15;
    Mx{i,2}(:,3) = ( Mx{i,1}(:,3) - mean(Mx{i,1}(:,3)) ) / V2G15;
    Mx{i,2}(:,4) = ( Mx{i,1}(:,4) - mean(Mx{i,1}(:,4)) );

    %入力電圧の周波数を取得し記録（harmfreqで高調波が分かる、その始めの値を利用)
    [thd_db, harmpow, harmfreq] = thd(Mx{i,1}(:,4), Fs, nharm);
    Mx{i,3} = harmfreq(1,1);
    Input_Hz = harmfreq(1,1);
    Mx{i,4} = rms((Mx{i,2}(:,4)));
    Input_Vol =  rms((Mx{i,2}(:,4)));
    Mx{i,5} = list(i).name;
   
    % 入力電圧と周波数でファイルを仕訳
    if Input_Hz > 39 && Input_Hz <41
        if Input_Vol <  0.06 &&  Input_Vol > 0.05 && isfolder('40Hz_05W')
             copyfile(list(i).name, '40Hz_05W')
             copyfile(png(i).name, '40Hz_05W')
             elseif Input_Vol <   0.09 &&  Input_Vol > 0.08 && isfolder('40Hz_1W')            
             copyfile(list(i).name, '40Hz_1W')
             copyfile(png(i).name, '40Hz_1W')
        elseif Input_Vol <   0.14 &&  Input_Vol > 0.12 && isfolder('40Hz_2W')        
             copyfile(list(i).name, '40Hz_2W')
             copyfile(png(i).name, '40Hz_2W')
        end
    elseif Input_Hz > 159 && Input_Hz <161
       if Input_Vol <  0.06 &&  Input_Vol > 0.05 && isfolder('160Hz_05W')
            copyfile(list(i).name, '160Hz_05W')
            copyfile(png(i).name, '160Hz_05W')
       elseif Input_Vol <   0.09 &&  Input_Vol > 0.08 && isfolder('160Hz_1W')            
           copyfile(list(i).name, '160Hz_1W')
           copyfile(png(i).name, '160Hz_1W')
       elseif Input_Vol <   0.14 &&  Input_Vol > 0.12 && isfolder('160Hz_2W')        
          copyfile(list(i).name, '160Hz_2W')
          copyfile(png(i).name, '160Hz_2W')
        end
    end

    % FGから入力電圧のVppを求める。2倍は負の値を考慮
end

