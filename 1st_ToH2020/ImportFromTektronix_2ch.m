clear
Fs = 1e4;%�T���v�����g��
% Fs = 10e3;%�T���v�����g��
t = 0:1/Fs:1;
%�����x�Z���T�̊��x
V2G6 = 0.206; %MMA7361L 6G���[�h
V2G15 = 0.800; %MMA7361L 1.5G���[�h
V2N = 0.01178; %�̓Z���T5916
nharm = 6;%thd�̍����g��
%10��2�s�̃Z�����쐬�B1��ڂ�y�������x�̍s��A2��ڂɗ̓Z���T
%�i�ł����1-�̘A�Ԃɂ��Ĉ�X�t�@�C������ύX���Ȃ��ł��ǂ��悤�ɂ�����
list = dir('*.csv');
numFiles = length(list);
Mx = cell(numFiles,2);

%%
% �f�[�^�̃C���|�[�g����у��x���p�f�[�^����
for i = 1:numFiles
    Mx{i,1}= csvread(list(i).name,21,1,[21,1,10020,2]);
    % �I�t�Z�b�g�����i���ׂĂ̗v�f���畽�ϒl�������j
%     Mx{i,2}(:,1) = ( Mx{i,1}(:,1) - mean(Mx{i,1}(:,1)) ) / V2G6;
    Mx{i,2}(:,1) = ( Mx{i,1}(:,1) - mean(Mx{i,1}(:,1)) )  / V2N;
    Mx{i,2}(:,2) = ( Mx{i,1}(:,2) - mean(Mx{i,1}(:,2)) );

        for k = 0:1
            [thd_db, harmpow, harmfreq] = thd(Mx{i,2}(:,1+k), Fs, nharm);
            %thd(Mx{8,2}(:,1), Fs, nharm); % �ʂ�THD���������Ƃ�
            Mx{i,6+3*k} = harmfreq(1,1);
            Mx{i,7+3*k} = rms((Mx{i,2}(:,1+k))) ;
            Mx{i,8+3*k} = thd_db;
        end
        
% *2* sqrt(2);�@%Vpp�ɂ��邽�߂̏����irms�ɂ�����j
%     Mx{i,4} = peak2rms(Mx{i,2}(:,1));
%     Mx{i,5} = peak2rms(Mx{i,2}(:,2));

    % timetable ���e�񂲂Ƃɒǉ�
    Mx{i,3} = timetable(Mx{i,2}(:,1), Mx{i,2}(:,2),'SampleRate',Fs);
    Mx{i,3}.Properties.VariableNames{'Var1'}='Out' ;
    Mx{i,3}.Properties.VariableNames{'Var2'}='In' ;
end

%% �s���ɐ�����ǉ�
Mx{i+1,1} = '���f�[�^';
Mx{i+1,2} = '�I�t�Z�b�g������';
Mx{i+1,3} = '�^�C���e�[�u��';
Mx{i+1,4} = '���g��';
Mx{i+1,5} = '����d���i�v�Z��j';
for k=0:2
    Mx{i+1,6+3*k} = strcat('ch', num2str(k+1), 'Hz');
    Mx{i+1,7+3*k} = strcat('ch', num2str(k+1), 'RMS');
    Mx{i+1,8+3*k} = strcat('ch', num2str(k+1), 'THD');
end

%%
Plot_Array(:,1) = [1; 1.2; 1.5; 1.8; 2.2; 2.7; 3.3; 3.9; 4.7; 5.6; 6.8; 8.2; ...
    10; 12; 15; 18; 22; 27; 33; 39; 47; 56; 68; 82; ... 
    100; 120; 150; 180; 220; 270; 330; 390; 470; 560; 680; 820; 1000];
for i = 1:37
    Plot_Array(i,2) = Mx{i ,7};
    Plot_Array(i,3) = Mx{i,10};
    Plot_Array(i,4) = Mx{i ,7} /Mx{i,10};
    Plot_Array(i,5) = Mx{i ,7} /Mx{i,10};
end

clf
% semilogx(Plot_Array(:,1), Plot_Array(:,2) )
% semilogx(Plot_Array(:,1), Plot_Array(:,4),'-o', ...
%     'MarkerFaceColor', 'blue')

semilogx(Plot_Array(:,1), Plot_Array(:,2),'-o', ...
    'MarkerFaceColor', 'blue')

xlabel('Frequency (Hz)')
ylabel('RMS Tension (N)')

% semilogx(Plot_Array(:,1), Plot_Array(:,3) )



%% �A���v�����オ�莞�ԗp
% [OutMin, idx_OutMin]=min(Mx{1,3}.Out)
% [InMin,idx_InMin]=min(Mx{1,3}.In)

%% �A���v���g��
TT1 = Mx{1,3};
TT1_2 = Mx{2,3};
TT1_5 = Mx{3,3};
TT1_8 = Mx{4,3};
TT2_2 = Mx{5,3};
TT2_7 = Mx{6,3};
TT3_3 = Mx{7,3};
TT3_9 = Mx{8,3};
TT4_7 = Mx{9,3};
TT5_6 = Mx{10,3};
TT6_8 = Mx{11,3};
TT8_2 = Mx{12,3};
TT10 = Mx{13,3};
TT12 = Mx{14,3};
TT15 = Mx{15,3};
TT18 = Mx{16,3};
TT22 = Mx{17,3};
TT27 = Mx{18,3};
TT33 = Mx{19,3};
TT39 = Mx{20,3};
TT47 = Mx{21,3};
TT56 = Mx{22,3};
TT68 = Mx{23,3};
TT82 = Mx{24,3};
TT100 = Mx{25,3};
TT120 = Mx{26,3};
TT150 = Mx{27,3};
TT180 = Mx{28,3};
TT220 = Mx{29,3};
TT270 = Mx{30,3};
TT330 = Mx{31,3};
TT390 = Mx{32,3};
TT470 = Mx{33,3};
TT560 = Mx{34,3};
TT680 = Mx{35,3};
TT820 = Mx{36,3};
TT1000 = Mx{37,3};