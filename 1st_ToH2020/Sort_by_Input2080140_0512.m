%%�l��5�̊e�_�̉����x���莞�̃t�@�C�������p�X�N���v�g
%%���͓d���Ǝ��g������40/160Hz_0.5/1/2W�ɕ���

% clear
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
type =  dir('*.txt'); % vp2.txt or hapbeat.txt
numFiles = length(list);
Mx = cell(numFiles,2);
Input_Hz = 0;
Input_Vol = 0;
filename = 'test';

%% ���ނ���t�H���_�̍쐬


if(isempty(type)) %Hapeat�̏ꍇ

    if ~isfolder('20Hz_0W')
        mkdir 20Hz_0W
        cd '20Hz_0W';
        fopen('20Hz-05W.txt','w');
        cd ..
    end

    if ~isfolder('20Hz_1W')
        mkdir 20Hz_1W

        cd '20Hz_1W';
        fopen('20Hz-1W.txt','w');
        cd ..
    end

    if ~isfolder('20Hz_2W')
        mkdir 20Hz_2W
        cd '20Hz_2W';
        fopen('20Hz-2W.txt','w');
        cd ..
    end

    if ~isfolder('80Hz_1W')
        mkdir 80Hz_1W
        cd '80Hz_1W';
        fopen('80Hz-1W.txt','w');
        cd ..
    end

    if ~isfolder('140Hz_1W')
        mkdir 140Hz_1W
        cd '140Hz_1W';
        fopen('140Hz-1W.txt','w');
        cd ..
    end

else % Vp2�̏ꍇ
    
        if ~isfolder('20Hz_2W')
            mkdir 20Hz_2W
            cd '20Hz_2W';
            fopen('20Hz-2W.txt','w');
            cd ..
        end
    
            if ~isfolder('80Hz_2W')
        mkdir 80Hz_2W
        cd '80Hz_2W';
        fopen('80Hz-2W.txt','w');
        cd ..
            end
    
        if ~isfolder('140Hz_2W')
            mkdir 140Hz_2W
            cd '140Hz_2W';
            fopen('140Hz-2W.txt','w');
            cd ..
        end
    
    
end

%%
% �f�[�^�̃C���|�[�g����у��x���p�f�[�^����
for i = 1:numFiles
    Mx{i,1}= csvread(list(i).name,21,1,[21,1,10020,4]);
    % �I�t�Z�b�g�����i���ׂĂ̗v�f���畽�ϒl�������j
    Mx{i,2}(:,1) = ( Mx{i,1}(:,1) - mean(Mx{i,1}(:,1)) ) / V2G6; %���Ɉ������������𐳂Ɂi�W���ł͕��j
    Mx{i,2}(:,2) = ( Mx{i,1}(:,2) - mean(Mx{i,1}(:,2)) ) / V2G6;
    Mx{i,2}(:,3) = ( Mx{i,1}(:,3) - mean(Mx{i,1}(:,3)) ) / V2G6;
    Mx{i,2}(:,4) = ( Mx{i,1}(:,4) - mean(Mx{i,1}(:,4)) );
    
    %���͓d���̎��g�����擾���L�^�iharmfreq�ō����g��������A���̎n�߂̒l�𗘗p)
    [thd_db, harmpow, harmfreq] = thd(Mx{i,1}(:,4), Fs, nharm);
    Mx{i,3} = harmfreq(1,1);
    Input_Hz = harmfreq(1,1);
    Mx{i,4} = rms((Mx{i,2}(:,4)));
    Input_Vol =  rms((Mx{i,2}(:,4)));
    Mx{i,5} = list(i).name;
    
    % ���͓d���Ǝ��g���Ńt�@�C�����d��
    %Vp2�d�����p
%     if strcmp(type.name,'vp2.txt')
    if isempty(type)     % Hapbeat    
        if Input_Hz > 19 && Input_Hz <21
            if Input_Vol > 0.050 && Input_Vol <  0.065 && isfolder('20Hz_0W')
                copyfile(list(i).name, '20Hz_0W')
                %              copyfile(png(i).name, '20Hz_05W')
            elseif    Input_Vol > 0.07 && Input_Vol < 0.09 && isfolder('20Hz_1W')
                copyfile(list(i).name, '20Hz_1W')
                %              copyfile(png(i).name, '20Hz_1W')
            elseif    Input_Vol > 0.11 && Input_Vol < 0.13 && isfolder('20Hz_2W')
                copyfile(list(i).name, '20Hz_2W')
                %              copyfile(png(i).name, '20Hz_2W')
            end
        elseif Input_Hz > 79 && Input_Hz <81
            if Input_Vol > 0.08 && Input_Vol < 0.1 && isfolder('80Hz_1W')
                copyfile(list(i).name, '80Hz_1W')
                %              copyfile(png(i).name, '80Hz_1W')
            end
        elseif Input_Hz > 139 && Input_Hz <141
            if Input_Vol > 0.08 && Input_Vol < 0.1 && isfolder('140Hz_1W')
                copyfile(list(i).name, '140Hz_1W')
                %              copyfile(png(i).name, '140Hz_1W')
            end
        end
  
    else  % Vp2   
        if Input_Hz > 19 && Input_Hz <21
            if Input_Vol > 0.4 && Input_Vol <  0.45 && isfolder('20Hz_2W')
                copyfile(list(i).name, '20Hz_2W')
            end
        elseif Input_Hz > 79 && Input_Hz <81
            if Input_Vol > 0.16 && Input_Vol < 0.18 && isfolder('80Hz_2W')
                copyfile(list(i).name, '80Hz_2W')
                %              copyfile(png(i).name, '80Hz_1W')
            end
        elseif Input_Hz > 139 && Input_Hz <141
            if Input_Vol > 0.14 && Input_Vol < 0.16 && isfolder('140Hz_2W')
                copyfile(list(i).name, '140Hz_2W')
                %              copyfile(png(i).name, '140Hz_1W')
            end
        end
        
    end

end

