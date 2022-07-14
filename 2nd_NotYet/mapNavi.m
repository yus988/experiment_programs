%ナビ実験の処理用スクリプト
clear, clc, close all
list = dir('*.csv');
numFiles = length(list);
Mx = cell(numFiles/4,2);% インポート用のセル
% MusicTime	PlayerRotY (deg)	Target (deg)	Accuracy (deg) 	SpentTime	MusicVol	VibVol
% Extract 0=start, 1=beacon, -1=error

for i = 1:numFiles
    %ファイル名から被験者番号を特定
   % 1--9の場合
    if strcmp(cell2mat(extract(list(i).name,6)), '-')  
         subj = str2double(extract(list(i).name,5));
    else
    % 10--の場合
         subj = str2double(extractBetween(list(i).name,5,6));
    end
    tmpTable = readtable(list(i).name,'PreserveVariableNames',true);

    condName = tmpTable{1,14}{1}; % 実験条件を抽出
    % 実験条件に応じて、記録する列の開始列を決める。
    if strcmp(condName,'nt')
        MxColOffset = 0;
    elseif strcmp(condName,'ntHap')
        MxColOffset = 5;
    elseif strcmp(condName,'HapDir')
        MxColOffset = 10;
    elseif strcmp(condName,'HapDirDist')
        MxColOffset = 15;
    end

    Mx{subj,1+MxColOffset} = readtable(list(i).name,'PreserveVariableNames',true);
    Mx{subj,2+MxColOffset} = rmmissing(tmpTable); % 回答行だけ抽出（文字列が入った行を無視）

    % 移動した総距離を計算
    dist = 0;
    endIndex = size(Mx{subj,1+MxColOffset},1);
    % 各試行開始時のポジション ビーコンごとに
    %     offsetX = Mx{subj,1}{iniIndex,3};
    %     offsetZ = Mx{subj,1}{iniIndex,4};
    tIndex = 1; % trajectory 用行列のインデックス
    for k = 1 : endIndex-1
        x = Mx{subj, 1+MxColOffset}{k,3};
        x_1 = Mx{subj, 1+MxColOffset}{k+1,3};
        z = Mx{subj, 1+MxColOffset}{k,4};
        z_1 = Mx{subj, 1+MxColOffset}{k+1,4};
        tmpDist = sqrt((x_1-x)^2+(z_1-z)^2);
        dist = dist + tmpDist;
        % 軌跡を記録
        Mx{subj,3+MxColOffset}(tIndex,1) = x;
        Mx{subj,3+MxColOffset}(tIndex,2) = z;
        tIndex = tIndex + 1;
    end

    Mx{subj,4+MxColOffset} = Mx{subj,2+MxColOffset}{4, 2}; % time = ansの最終行
    Mx{subj,5+MxColOffset} = dist;
    % ミスのカウント、多分消す
    %     Mx{subj,6+MxColOffset} = size(find(condName & Mx{1,1}{:,16}==-1),1);

end

arr = ["nt" "ans" "traj" "time" "dist" ...
    "ntHap" "ans" "traj" "time" "dist" ...
    "HapDir" "ans" "traj" "time" "dist" ...
    "HapDirDist" "ans" "traj" "time" "dist"
    ];

% arr = ["生データ" "回答抽出" ...
%     "nt:traj" "nt:time" "nt:dist" "nt:miss" ...
%     "ntHap:traj" "ntHap:time" "ntHap:dist"  "ntHap:miss" ...
%     "HapDir:traj" "HapDir:time" "HapDir:dist" "HapDir:miss" ...
%     "HapDist:traj" "HapDist:time" "HapDist:dist" "HapDist:miss"
%     ];
length = arr.length;
% 行末に説明を追加
for k = 1: length
    Mx{(numFiles/4)+1,k} =arr(1,k);
end

save;

%% 表にまとめ
resultArr = zeros(4,2);

for cond = 1:4
    resultArr(cond,1) = mean([Mx{1:subj, 4+5*(cond-1)}]);
    resultArr(cond,2) = mean([Mx{1:subj, 5+5*(cond-1)}]);
end

% arr = cell2mat(Mx{1:2, 4})
% M = Mx{2, 4}
% 
% mean([Mx{1:2, 4}])

% https://jp.mathworks.com/help/matlab/matlab_prog/access-data-in-a-cell-array.html
% Mx{1,4:5}
% mean(Mx{1,16}{646:649,1})

%% 軌跡描画

% traj = Mx{1,3}; % nt
% traj = Mx{1,7}; % ntHap
% traj = Mx{1,11}; % hapDir
% traj = Mx{1,15}; % hapDirDist
% plot(traj(:,1),traj(:,2));

%
% traj = Mx{1,7};
% plot(traj(:,1),traj(:,2));
