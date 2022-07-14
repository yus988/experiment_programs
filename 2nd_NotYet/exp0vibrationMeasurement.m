clear
Mx = cell(1,1);
cellResult = cell(zeros(1));

subjNum= 10;
V2G6 = 0.206 / 9.80665; %MMA7361L 6Gモード = v/g v / (g*9.80665)
subjNo = 1;

for subj = 1:subjNum
    %% フォルダの移動
    if subj == subjNo
        folderName = strcat('sub-',string(subjNo));
    end
    cd (folderName);
    list = dir('*.csv');
    numFiles = length(list);
    Fs = 1e4;%サンプル周波数
    for pos = 0:numFiles-1
        Mx{subj, 3*pos+1 }= csvread(list(pos+1).name,21,1,[21,1,10020,4]);
        Mx{subj,3*pos+2}(:,1) = ( Mx{subj,3*pos+1}(:,1) - mean(Mx{subj,3*pos+1}(:,1)) ) / V2G6; %下に引っ張った時を正に（標準では負）
        Mx{subj,3*pos+2}(:,2) = ( Mx{subj,3*pos+1}(:,2) - mean(Mx{subj,3*pos+1}(:,2)) ) / V2G6;
        Mx{subj,3*pos+2}(:,3) = ( Mx{subj,3*pos+1}(:,3) - mean(Mx{subj,3*pos+1}(:,3)) ) / V2G6;
        Mx{subj,3*pos+2}(:,4) = ( Mx{subj,3*pos+1}(:,4) - mean(Mx{subj,3*pos+1}(:,4)) );
        Mx{subj,3*pos+3} =sqrt(rms(Mx{subj,3*pos+2}(:,1))^2 + rms(Mx{subj,3*pos+2}(:,2))^2 + rms(Mx{subj,3*pos+2}(:,3))); % こうあるべき
    end
    cd ..
    subjNo = subjNo + 1;
end

save;