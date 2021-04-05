%%人体5の各点の加速度測定時のファイル分け用スクリプト
%%入力電圧と周波数から40/160Hz_0.5/1/2Wに分類

% clear
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
type =  dir('*.txt'); % vp2.txt or hapbeat.txt
numFiles = length(list);
Mx = cell(numFiles,2);
Input_Hz = 0;
Input_Vol = 0;
filename = 'test';

%% 分類するフォルダの作成


if(isempty(type)) %Hapeatの場合

    if ~isfolder('20Hz_0W')
        mkdir 20Hz_0W
        cd '20Hz_0W';
        fopen('20Hz-05W.txt','w');
        cd ..
    end

    if ~isfolder('20Hz_1W')
        mkdir 20Hz_1W

        cd '20Hz_1W';
        fopen('20Hz-1W.txt','w');
        cd ..
    end

    if ~isfolder('20Hz_2W')
        mkdir 20Hz_2W
        cd '20Hz_2W';
        fopen('20Hz-2W.txt','w');
        cd ..
    end

    if ~isfolder('80Hz_1W')
        mkdir 80Hz_1W
        cd '80Hz_1W';
        fopen('80Hz-1W.txt','w');
        cd ..
    end

    if ~isfolder('140Hz_1W')
        mkdir 140Hz_1W
        cd '140Hz_1W';
        fopen('140Hz-1W.txt','w');
        cd ..
    end

else % Vp2の場合
    
        if ~isfolder('20Hz_2W')
            mkdir 20Hz_2W
            cd '20Hz_2W';
            fopen('20Hz-2W.txt','w');
            cd ..
        end
    
            if ~isfolder('80Hz_2W')
        mkdir 80Hz_2W
        cd '80Hz_2W';
        fopen('80Hz-2W.txt','w');
        cd ..
            end
    
        if ~isfolder('140Hz_2W')
            mkdir 140Hz_2W
            cd '140Hz_2W';
            fopen('140Hz-2W.txt','w');
            cd ..
        end
    
    
end

%%
% データのインポートおよびラベル用データ生成
for i = 1:numFiles
    Mx{i,1}= csvread(list(i).name,21,1,[21,1,10020,4]);
    % オフセット除去（すべての要素から平均値を引く）
    Mx{i,2}(:,1) = ( Mx{i,1}(:,1) - mean(Mx{i,1}(:,1)) ) / V2G6; %下に引っ張った時を正に（標準では負）
    Mx{i,2}(:,2) = ( Mx{i,1}(:,2) - mean(Mx{i,1}(:,2)) ) / V2G6;
    Mx{i,2}(:,3) = ( Mx{i,1}(:,3) - mean(Mx{i,1}(:,3)) ) / V2G6;
    Mx{i,2}(:,4) = ( Mx{i,1}(:,4) - mean(Mx{i,1}(:,4)) );
    
    %入力電圧の周波数を取得し記録（harmfreqで高調波が分かる、その始めの値を利用)
    [thd_db, harmpow, harmfreq] = thd(Mx{i,1}(:,4), Fs, nharm);
    Mx{i,3} = harmfreq(1,1);
    Input_Hz = harmfreq(1,1);
    Mx{i,4} = rms((Mx{i,2}(:,4)));
    Input_Vol =  rms((Mx{i,2}(:,4)));
    Mx{i,5} = list(i).name;
    
    % 入力電圧と周波数でファイルを仕訳
    %Vp2仕分け用
%     if strcmp(type.name,'vp2.txt')
    if isempty(type)     % Hapbeat    
        if Input_Hz > 19 && Input_Hz <21
            if Input_Vol > 0.050 && Input_Vol <  0.065 && isfolder('20Hz_0W')
                copyfile(list(i).name, '20Hz_0W')
                %              copyfile(png(i).name, '20Hz_05W')
            elseif    Input_Vol > 0.07 && Input_Vol < 0.09 && isfolder('20Hz_1W')
                copyfile(list(i).name, '20Hz_1W')
                %              copyfile(png(i).name, '20Hz_1W')
            elseif    Input_Vol > 0.11 && Input_Vol < 0.13 && isfolder('20Hz_2W')
                copyfile(list(i).name, '20Hz_2W')
                %              copyfile(png(i).name, '20Hz_2W')
            end
        elseif Input_Hz > 79 && Input_Hz <81
            if Input_Vol > 0.08 && Input_Vol < 0.1 && isfolder('80Hz_1W')
                copyfile(list(i).name, '80Hz_1W')
                %              copyfile(png(i).name, '80Hz_1W')
            end
        elseif Input_Hz > 139 && Input_Hz <141
            if Input_Vol > 0.08 && Input_Vol < 0.1 && isfolder('140Hz_1W')
                copyfile(list(i).name, '140Hz_1W')
                %              copyfile(png(i).name, '140Hz_1W')
            end
        end
  
    else  % Vp2   
        if Input_Hz > 19 && Input_Hz <21
            if Input_Vol > 0.4 && Input_Vol <  0.45 && isfolder('20Hz_2W')
                copyfile(list(i).name, '20Hz_2W')
            end
        elseif Input_Hz > 79 && Input_Hz <81
            if Input_Vol > 0.16 && Input_Vol < 0.18 && isfolder('80Hz_2W')
                copyfile(list(i).name, '80Hz_2W')
                %              copyfile(png(i).name, '80Hz_1W')
            end
        elseif Input_Hz > 139 && Input_Hz <141
            if Input_Vol > 0.14 && Input_Vol < 0.16 && isfolder('140Hz_2W')
                copyfile(list(i).name, '140Hz_2W')
                %              copyfile(png(i).name, '140Hz_1W')
            end
        end
        
    end

end

