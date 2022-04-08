%ナビ実験の処理用スクリプト
clear, clc, close all

list = dir('*.csv');
numFiles = length(list);
Mx = cell(numFiles,2);% インポート用のセル
% MusicTime	PlayerRotY (deg)	Target (deg)	Accuracy (deg) 	SpentTime	MusicVol	VibVol
gbNum = 4; % 各ルート最後のビーコン
% Extract 0=start, 1=beacon, -1=error

for i = 1:numFiles
    % for i = 1:1
    %     Mx{i,1} = readmatrix(list(i).name);
    Mx{i,1} = readtable(list(i).name,'PreserveVariableNames',true);
    Mx{i,2} = rmmissing(Mx{i,1}); % 回答行だけ抽出（文字列が入った行を無視）
    
    for cond = 1:4
        if cond==1
            condName = 'nt';
        elseif cond == 2
            condName = 'ntHap';
        elseif cond == 3
            condName = 'hapDir';
        elseif cond == 4
            condName = 'hapDirDist';
        end
        % ゴール時の行列を求める
        modCond = strcmp(Mx{1,1}{:,10},condName); % 提示手法で検索
        iniNum = Mx{i, 1}{:,12} == 0;
        endNum = Mx{i,1}{:,7}==gbNum; % ビーコンの番号で抽出
        iniIndex = find(modCond&iniNum);
        endIndex = find(modCond&endNum);
        % 移動した総距離を計算
        dist = 0;
        % 各試行開始時のポジション
        offsetX = Mx{i,1}{iniIndex,3};
        offsetZ = Mx{i,1}{iniIndex,4};
        
        for k = iniIndex : (endIndex -1)
            x = Mx{i,1}{k,3};
            x_1 = Mx{i,1}{k+1,3};
            z = Mx{i,1}{k,4};
            z_1 = Mx{i,1}{k+1,4};
            tmpDist = sqrt((x_1-x)^2+(z_1-z)^2);
            dist = dist + tmpDist;
        end
                
        Mx{i,3+(cond-1)*3} = Mx{i,1}{endIndex, 2}; % time = 最後のspenttime
        Mx{i,4+(cond-1)*3} = dist;
        % ミスのカウント
        Mx{i,5+(cond-1)*3} = size(find(modCond & Mx{1,1}{:,12}==-1),1);
    end
end

arr = ["生データ" "回答抽出" ...
    "nt:time" "nt:dist" "nt:missCnt"...
    "ntHap:time" "ntHap:dist"  "ntHap:missCnt"...
    "hapDir:time" "hapDir:dist" "hapDir:missCnt"...
    "hapDirDist:time" "hapDirDist:dist" "hapDirDist:missCnt"
    ];
length = arr.length;
% 行末に説明を追加
for k = 1: length
    Mx{i+1,k} =arr(1,k);
end

%%