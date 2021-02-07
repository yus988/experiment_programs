% ���[�^���[�d������p�̃v���O�����B
clear

Fs = 1e4;%�T���v�����g��
t = 0:1/Fs:1;
nharm = 6;%thd�̍����g��
list = dir('*.csv');
numFiles = length(list);
Mx = cell(numFiles,2);
Rm = 1.1; %���[�^
%%
% �f�[�^�̃C���|�[�g����у��x���p�f�[�^����
for i = 1:numFiles
        Mx{i,1}= csvread(list(i).name,21,1,[21,1,10020,1]);
        Mx{i,2}(:,1) = ( Mx{i,1}(:,1) - mean(Mx{i,1}(:,1)) );
        %���͓d���̎��g�����擾���L�^�iharmfreq�ō����g��������A���̎n�߂̒l�𗘗p)
        [thd_db, harmpow, harmfreq] = thd(Mx{i,1}(:,1), Fs, nharm);
        % FG������͓d����Vpp�����߂�B2�{�͕��̒l���l��
        Vin = 2*sqrt(2)*rms((Mx{i,1}(:,1)));
        Mx{i,3} = timetable(Mx{i,2}(:,1),'SampleRate',Fs);
        Mx{i,4} = harmfreq(1,1);
        Mx{i,5} = Vin;
        Mx{i,6} = thd_db;
        Mx{i,7} = rms((Mx{i,1}(:,1)));
        Mx{i, 8} = Mx{i,7}^2 / Rm;
end

%% �s���ɐ�����ǉ�
Mx{i+1,1} = '���f�[�^';
Mx{i+1,2} = '�I�t�Z�b�g������';
Mx{i+1,3} = '�^�C���e�[�u��';
Mx{i+1,4} = '���g��';
Mx{i+1,5} = 'Vpp';
Mx{i+1,6} = 'THD';
Mx{i+1,7} = 'RMS';
%% ���`�͈�20~200mV
% TT_40hz20mV = Mx{1,3};
% TT_40hz30mV = Mx{2,3};
% TT_40hz40mV = Mx{3,3};
% TT_40hz50mV = Mx{4,3};
% TT_40hz60mV = Mx{5,3};
% TT_40hz70mV = Mx{6,3};
% TT_40hz80mV = Mx{7,3};
% TT_40hz90mV = Mx{8,3};
% TT_40hz100mV = Mx{9,3};
% TT_40hz110mV = Mx{10,3};
% TT_40hz120mV = Mx{11,3};
% TT_40hz130mV = Mx{12,3};
% TT_40hz140mV = Mx{13,3};
% TT_40hz150mV = Mx{14,3};
% TT_40hz160mV = Mx{15,3};
% TT_40hz170mV = Mx{16,3};
% TT_40hz180mV = Mx{17,3};
% TT_40hz190mV = Mx{18,3};
% TT_40hz200mV = Mx{19,3};
% TT_160hz20mV = Mx{20,3};
% TT_160hz30mV = Mx{21,3};
% TT_160hz40mV = Mx{22,3};
% TT_160hz50mV = Mx{23,3};
% TT_160hz60mV = Mx{24,3};
% TT_160hz70mV = Mx{25,3};
% TT_160hz80mV = Mx{26,3};
% TT_160hz90mV = Mx{27,3};
% TT_160hz100mV = Mx{28,3};
% TT_160hz110mV = Mx{29,3};
% TT_160hz120mV = Mx{30,3};
% TT_160hz130mV = Mx{31,3};
% TT_160hz140mV = Mx{32,3};
% TT_160hz150mV = Mx{33,3};
% TT_160hz160mV = Mx{34,3};
% TT_160hz170mV = Mx{35,3};
% TT_160hz180mV = Mx{36,3};
% TT_160hz190mV = Mx{37,3};
% TT_160hz200mV = Mx{38,3};