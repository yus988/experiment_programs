%%�l�̂̊e�_�̉����x���莞�̃t�@�C�������p�X�N���v�g
%%���͓d���Ǝ��g������40/160Hz_0.5/1/2W�ɕ���

clear
Fs = 1e4;%�T���v�����g��
t = 0:1/Fs:1;
%�����x�Z���T�̊��x
V2G6 = 0.206; %MMA7361L 6G���[�h
V2G15 = 0.800; %MMA7361L 1.5G���[�h
V2N = 0.01178; %�̓Z���T5916
nharm = 6;%thd�̍����g��
%10��2�s�̃Z�����쐬�B1��ڂ�y�������x�̍s��A2��ڂɗ̓Z���T
%�i�ł����1-�̘A�Ԃɂ��Ĉ�X�t�@�C������ύX���Ȃ��ł��ǂ��悤�ɂ�����
list = dir('*.csv');
png = dir('*.png');
numFiles = length(list);
Mx = cell(numFiles,2);
Input_Hz = 0;
Input_Vol = 0;
%% ���ނ���t�H���_�̍쐬
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
% �f�[�^�̃C���|�[�g����у��x���p�f�[�^����
for i = 1:numFiles
    Mx{i,1}= csvread(list(i).name,21,1,[21,1,10020,4]);
    % �I�t�Z�b�g�����i���ׂĂ̗v�f���畽�ϒl�������j
    Mx{i,2}(:,1) = ( Mx{i,1}(:,1) - mean(Mx{i,1}(:,1)) ) / V2G15; %���Ɉ������������𐳂Ɂi�W���ł͕��j
    Mx{i,2}(:,2) = ( Mx{i,1}(:,2) - mean(Mx{i,1}(:,2)) ) / V2G15;
    Mx{i,2}(:,3) = ( Mx{i,1}(:,3) - mean(Mx{i,1}(:,3)) ) / V2G15;
    Mx{i,2}(:,4) = ( Mx{i,1}(:,4) - mean(Mx{i,1}(:,4)) );

    %���͓d���̎��g�����擾���L�^�iharmfreq�ō����g��������A���̎n�߂̒l�𗘗p)
    [thd_db, harmpow, harmfreq] = thd(Mx{i,1}(:,4), Fs, nharm);
    Mx{i,3} = harmfreq(1,1);
    Input_Hz = harmfreq(1,1);
    Mx{i,4} = rms((Mx{i,2}(:,4)));
    Input_Vol =  rms((Mx{i,2}(:,4)));
    Mx{i,5} = list(i).name;
   
    % ���͓d���Ǝ��g���Ńt�@�C�����d��
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

    % FG������͓d����Vpp�����߂�B2�{�͕��̒l���l��
end

