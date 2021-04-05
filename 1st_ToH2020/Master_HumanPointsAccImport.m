%%HumanPointsAccImportを各パラメータごとに実行。各計測フォルダのルートで実施（例：7.2前面2）
clear
% Sort_by_Input2080140_0512

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
    HumanPointsAccImport
    save;
    cd .. 
end

close