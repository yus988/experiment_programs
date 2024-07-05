% �����̗L���̔�r�̂��߂̃X�N���v�g
% n�񕪂̕��ς����X�N���v�g�Bcsv�������t�H���_�Ŏ��s

close all

% �܂�sort����
Sort_by_Input2080140_0512

Fs = 1e4;%�T���v�����g��
t = 0:1/Fs:1;
%�����x�Z���T�̊��x
V2G = 0.206; %MMA7361L 6G���[�h
% V2G = 0.800; %MMA7361L 1.5G���[�h
V2N = 0.01178; %�̓Z���T5916
nharm = 6;%thd�̍����g��
%10��2�s�̃Z�����쐬�B1��ڂ�y�������x�̍s��A2��ڂɗ̓Z���T
%�i�ł����1-�̘A�Ԃɂ��Ĉ�X�t�@�C������ύX���Ȃ��ł��ǂ��悤�ɂ�����

Mx = cell(numFiles,2);% �C���|�[�g�p�̃Z��
Analysis = cell(15);
xyz = 0;
num_points = numFiles; % ����_���Ȃ̂ł́H
RMS_column = zeros(1,4);% RMS�l�i�[�p
resultArray = zeros(10,4);


for cd_times = 1:5
    %�e���s���ƂɁA������̃t�H���_�ֈړ�
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

%% csv�f�[�^�̃C���|�[�g����у��x���p�f�[�^����
for i = 1:numFiles
    Mx{i,1}= csvread(list(i).name,21,1,[21,1,10020,4]);
    % �I�t�Z�b�g�����i���ׂĂ̗v�f���畽�ϒl�������j
    Mx{i,2}(:,1) = ( Mx{i,1}(:,1) - mean(Mx{i,1}(:,1)) ) / V2G; %���Ɉ������������𐳂Ɂi�W���ł͕��j
    Mx{i,2}(:,2) = ( Mx{i,1}(:,2) - mean(Mx{i,1}(:,2)) ) / V2G;
    Mx{i,2}(:,3) = ( Mx{i,1}(:,3) - mean(Mx{i,1}(:,3)) ) / V2G;
    Mx{i,2}(:,4) = ( Mx{i,1}(:,4) - mean(Mx{i,1}(:,4)) );
    
    for k = 0:2 % ch1~3�eHz,RMS,THD�̋L�^
        [thd_db, ~, harmfreq] = thd(Mx{i,2}(:,1+k), Fs, nharm);
        %             thd(Mx{8,2}(:,1), Fs, nharm); % �ʂ�THD���������Ƃ�
        Mx{i,6+3*k} = harmfreq(1,1);
        %         Mx{i,7+3*k} = rms((Mx{i,2}(:,1+k))) - 0.01 ;
        Mx{i,7+3*k} = rms((Mx{i,2}(:,1+k))) ;
        RMS_column(i,k+1) = Mx{i,7+3*k}; %  RMS�l�i�[�p�s��
        Mx{i,8+3*k} = thd_db;
        
    end
    %���͓d���̎��g�����擾���L�^�iharmfreq�ō����g��������A���̎n�߂̒l�𗘗p)
    [thd_db, harmpow, harmfreq] = thd(Mx{i,1}(:,4), Fs, nharm);
    Mx{i,4} = harmfreq(1,1);
    % FG������͓d����Vpp�����߂�B2�{�͕��̒l���l��
    Vin = 2*sqrt(2)*rms((Mx{i,1}(:,4)));
    Mx{i,5} = Vin;
    Mx{i,9+3*k} = xyz;
    xyz = 0;
    % 3����RMS�l
    Mx{i,9+3*k} =Mx{i,7+3*0} + Mx{i,7+3*1} + Mx{i,7+3*2};
    RMS_column(i,4) = Mx{i,9+3*k};
end
    
%% RMS���畽�ρiMean�j���Z�o
for j = 1:4
     row = 2 * cd_times - 1;
     resultArray(row,j) = mean(RMS_column(:,j));
     resultArray(row + 1,j) = std(RMS_column(:,j));
end
    cd .. 
end
