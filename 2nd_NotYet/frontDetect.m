%正面同定実験の処理用スクリプト
clear, clc, close all
list = dir('*.csv');
numFiles = length(list);
Mx = cell(numFiles,2);% インポート用のセル
% MusicTime	PlayerRotY (deg)	Target (deg)	Accuracy (deg) 	SpentTime	MusicVol	VibVol

for i = 1:numFiles
% for i = 1:1
    %     Mx{i,1} = readmatrix(list(i).name);
    Mx{i,1} = readtable(list(i).name,'PreserveVariableNames',true);
    Mx{i,2} = rmmissing(Mx{i,1}); % 回答行だけ抽出（文字列が入った行を無視）
    Mx{i,3} = mean(Mx{i,2}{:,4}); % dotMean
    Mx{i,4} = rad2deg(acos(Mx{i,3})); %dotから角度に変換
    Mx{i,5} = rad2deg( std(Mx{i,2}{:,4})); % radStd
    Mx{i,6} = mean(Mx{i,2}{:,5}); % timeMean
    Mx{i,7} = std(Mx{i,2}{:,5}); % timeStd
end

% 行末に説明を追加
Mx{i+1,1} = '生データ';
Mx{i+1,2} = '回答抽出';
Mx{i+1,3} = 'dotMean';
Mx{i+1,4} = 'degMean';
Mx{i+1,5} = 'radStd';
Mx{i+1,6} = 'timeMean';
Mx{i+1,7} = 'timeStd';

%% 時系列グラフ
% 回答率
time = table2array(Mx{1,2}(:,1));
ansRate = table2array(Mx{1,2}(:,4));
ansRate = rad2deg(acos(ansRate));
stem(time,ansRate,'Marker','o','MarkerSize',4,'MarkerFaceColor','blue');

%% 音声信号を載せたいとき実効

% % load an audio file
% [x, fs] = audioread('aTriviul_Mix.mp3');   % load an audio file
% x = x(:, 1);                  % get the first channel
% TT = timetable(x,'SampleRate',fs);

% subplot(2,1,1)
% plot((0:length(x)-1)/fs,x)
% subplot(2,1,2)
% stem(time,ansRate,'Marker','o','MarkerSize',4,'MarkerFaceColor','blue');