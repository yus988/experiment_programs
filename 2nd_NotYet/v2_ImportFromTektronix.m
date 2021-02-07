% 2�e��Tektronix

clear
% Fs = 1e4;%�T���v�����g��
Fs = 2.5e3;%�T���v�����g��
t = 0:1/Fs:1;
%�����x�Z���T�̊��x
V2G6 = 0.206; %MMA7361L 6G���[�h
V2G15 = 0.800; %MMA7361L 1.5G���[�h
V2N = 0.01178; %�̓Z���T5916
nharm = 6;%thd�̍����g��
%10��2�s�̃Z�����쐬�B1��ڂ�y�������x�̍s��A2��ڂɗ̓Z���T
%�i�ł����1-�̘A�Ԃɂ��Ĉ�X�t�@�C������ύX���Ȃ��ł��ǂ��悤�ɂ�����
list = dir('*.csv');
IsNXYZ = contains(pwd, "NXYZ"); %NXYZ�̑���̏ꍇTrue
numFiles = length(list);
Mx = cell(numFiles,2);
% RMS_Graph40Hz = zeros(numFiles/2,5);
% RMS_Graph160Hz = zeros(numFiles/2,5);
% AVG40Hz = zeros(numFiles/2,5);
% AVG160Hz = zeros(numFiles/2,5);
xyz = 0;
%%
% �f�[�^�̃C���|�[�g����у��x���p�f�[�^����
for i = 1:numFiles
    Mx{i,1}= csvread(list(i).name,21,1,[21,1,10020,4]);
    % �I�t�Z�b�g�����i���ׂĂ̗v�f���畽�ϒl�������j
    Mx{i,2}(:,1) = -1 * ( Mx{i,1}(:,1) - mean(Mx{i,1}(:,1)) ) / V2G15; %���Ɉ������������𐳂Ɂi�W���ł͕��j
    Mx{i,2}(:,2) = ( Mx{i,1}(:,2) - mean(Mx{i,1}(:,2)) ) / V2G15;
    Mx{i,2}(:,3) = ( Mx{i,1}(:,3) - mean(Mx{i,1}(:,3)) ) /V2G15;
    Mx{i,2}(:,4) = ( Mx{i,1}(:,4) - mean(Mx{i,1}(:,4)) );
    
    %  �ech�L�^���ʂ�thd�����harmfreq���L�^����
        for k = 0:2
            [thd_db, harmpow, harmfreq] = thd(Mx{i,2}(:,1+k), Fs, nharm);
            %thd(Mx{8,2}(:,1), Fs, nharm); % �ʂ�THD���������Ƃ�
            Mx{i,6+3*k} = harmfreq(1,1);
            Mx{i,7+3*k} = rms((Mx{i,2}(:,1+k)));
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
    
    % timetable ���e�񂲂Ƃɒǉ�
%     Mx{i,3} = timetable(Mx{i,2}(:,1), Mx{i,2}(:,2), Mx{i,2}(:,3), Mx{i,2}(:,4),'SampleRate',Fs);
    Mx{i,3} = timetable(Mx{i,1}(:,1), Mx{i,1}(:,2), Mx{i,1}(:,3), Mx{i,1}(:,4),'SampleRate',Fs);
    Mx{i,3}.Properties.VariableNames{'Var1'}='x' ;
    Mx{i,3}.Properties.VariableNames{'Var2'}='y' ;
    Mx{i,3}.Properties.VariableNames{'Var3'}='z' ;
    Mx{i,3}.Properties.VariableNames{'Var4'}='Input' ;
    %   �e���2��ϕ����ĕψʂ�
    %         temp = 1/fs * cumtrapz(xyz);
    %         temp = temp - mean(temp);
    %         XYZ = 1/fs * cumtrapz(temp) * 9.80665 * 1e6;
    %         F(:,i) = XYZ;
end

%% �s���ɐ�����ǉ�
Mx{i+1,1} = '���f�[�^';
Mx{i+1,2} = '�I�t�Z�b�g������';
Mx{i+1,3} = '�^�C���e�[�u��';
Mx{i+1,4} = '���g��';
Mx{i+1,5} = '����d���i�v�Z��j';
Mx{i+1,6+3*k} = strcat('ch', num2str(k+1), 'Hz');
Mx{i+1,7+3*k} = strcat('ch', num2str(k+1), 'RMS');
Mx{i+1,8+3*k} = strcat('ch', num2str(k+1), 'THD');

TT1 = Mx{1,3};
TT2 = Mx{2,3};
TT3 = Mx{3,3};
TT4 = Mx{4,3};
TT5 = Mx{5,3};

