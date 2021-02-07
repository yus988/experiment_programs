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
    Mx{i,2}(:,1) = -1 * ( Mx{i,1}(:,1) - mean(Mx{i,1}(:,1)) ) / V2N; %���Ɉ������������𐳂Ɂi�W���ł͕��j
    Mx{i,2}(:,2) = -1 * ( Mx{i,1}(:,2) - mean(Mx{i,1}(:,2)) ) / V2G6;
    Mx{i,2}(:,3) = ( Mx{i,1}(:,3) - mean(Mx{i,1}(:,3)) ) / V2G6;
    Mx{i,2}(:,4) = -1 *  ( Mx{i,1}(:,4) - mean(Mx{i,1}(:,4)) );
  
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
    Mx{i,3} = timetable(Mx{i,2}(:,1), Mx{i,2}(:,2), Mx{i,2}(:,3), Mx{i,2}(:,4),'SampleRate',Fs);
    Mx{i,3}.Properties.VariableNames{'Var1'}='T' ;
    Mx{i,3}.Properties.VariableNames{'Var2'}='y' ;
    Mx{i,3}.Properties.VariableNames{'Var3'}='z' ;
    Mx{i,3}.Properties.VariableNames{'Var4'}='Input' ;
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
%% step ��͗p
TT1 = Mx{1,3};
TT2 = Mx{2,3};
TT3 = Mx{3,3};
TT4 = Mx{4,3};
TT5 = Mx{5,3};
TT6 = Mx{6,3};
TT7 = Mx{7,3};
TT8 = Mx{8,3};
TT9 = Mx{9,3};
TT10 = Mx{10,3};
time = transpose([0:0.0001:0.9999]); 
S = stepinfo(TT1.T,time);
%%
clf
% ���́A���͂�0-1�ɐ��K��
% N_In = normalize(TT1.Input, 'range');
% N_T = normalize(TT1.T ,'range');
% N_In = normalize(TT2.Input, 'range');
% N_T = normalize(TT2.T ,'range');
% N_In = normalize(TT3.Input, 'range');
% N_T = normalize(TT3.T ,'range');
% N_In = normalize(TT4.Input, 'range');
% N_T = normalize(TT4.T ,'range');
% N_In = normalize(TT5.Input, 'range');
% N_T = normalize(TT5.T ,'range');
N_In = normalize(TT6.Input, 'range'); %�_���Ŏg�p
N_T = normalize(TT6.T ,'range'); 
% N_In = normalize(TT7.Input, 'range');
% N_T = normalize(TT7.T ,'range');
% N_In = normalize(TT8.Input, 'range');
% N_T = normalize(TT8.T ,'range');
% N_In = normalize(TT9.Input, 'range');
% N_T = normalize(TT9.T ,'range');
% N_In = normalize(TT10.Input, 'range');
% N_T = normalize(TT10.T ,'range');

N_T_fixed = N_T;
% N_T(N_T == 1) % ���ꂾ�ƁAN_T��1�����݂��邩�ۂ��𕷂��Ă���
% T�̍ő�l��index�𓱏o
idx_Tmax =  find(N_T > 0.9999);

% risetime��1���ő�Ƃ��邽�߁AT��1�������index�ȍ~�̒l��1��
for idx = 1:10000
    if idx > idx_Tmax
        N_T_fixed(idx, 1) = 1;
    end
end

N_T_final = normalize(N_T_fixed ,'range');

% 1%(0.01)�𒴂����_�𒊏o
idx_over1p_T = find(N_T_final >0.01);
idx_over1p_In = find(N_In >0.01);
idx_1p_T = idx_over1p_T(1,1);
idx_1p_In = idx_over1p_In(1,1);
Time_1p_T = (idx_1p_T-1)/10000;
Time_1p_In = (idx_1p_In-1)/10000;

% 10%(0.1)�𒴂����_�𒊏o
idx_over10p_T = find(N_T_final >0.1);
idx_over10p_In = find(N_In >0.1);
idx_10p_T = idx_over10p_T(1,1);
idx_10p_In = idx_over10p_In(1,1);
Time_10p_T = (idx_10p_T-1)/10000;
Time_10p_In = (idx_10p_In-1)/10000;

% 90%(0.9)�𒴂����_�𒊏o
idx_over90p_T = find(N_T_final >0.9);
idx_over90p_In = find(N_In >0.9);
% ��L�͕����̒l��������̂ŁA���̂����n�߂̒l���擾
idx_90p_T = idx_over90p_T(1,1);
idx_90p_In = idx_over90p_In(1,1);
Time_90p_T = (idx_90p_T-1)/10000;
Time_90p_In = (idx_90p_In-1)/10000;
Time_100p_T = (idx_Tmax-1)/10000;

% ����ꂽ���ʁi1%, 10%, 90%��delay�j��msec�ŕ\��
Record = cell(4,2);
Record{1,1} = "Time_1p_In";
Record{1,2} = Time_1p_In;
Record{2,1} = "Time_1p_T";
Record{2,2} = Time_1p_T;
Record{3,1} = "Time_10p_In";
Record{3,2} = Time_10p_In;
Record{4,1} = "Time_10p_T";
Record{4,2} = Time_10p_T;
Record{5,1} = "Time_90p_In";
Record{5,2} = Time_90p_In;
Record{6,1} = "Time_90p_T";
Record{6,2} = Time_90p_T;
Record{7,1} = "1p_T-In";
Record{7,2} =abs(Time_1p_T-Time_1p_In);
Record{8,1} = "10p_T-In";
Record{8,2} =abs(Time_10p_T-Time_10p_In);
Record{9,1} = "90p_T-In";
Record{9,2} =abs(Time_90p_T-Time_90p_In);
Record{10,1} = "In_1p-10p";
Record{10,2} =abs(Time_1p_In-Time_10p_In);
Record{11,1} = "In_10p-90p";
Record{11,2} =abs(Time_10p_In-Time_90p_In);
Record{12,1} = "T_1p-10p";
Record{12,2} =abs(Time_1p_T-Time_10p_T);
Record{13,1} = "T_10p-90p";
Record{13,2} =abs(Time_10p_T-Time_90p_T);
Record{14,1} = "T_90p-100p";
Record{14,2} =abs(Time_90p_T-Time_100p_T);

% �f�o�b�O�Ƃ��ĕ`��p
    % plot(N_T_final)
    % risetime(N_T_fixed,Fs);
    % risetime(N_In,Fs);

% risetime��p�����ꍇ�i���悻10, 90%�̒l�j
    % [R_In,  LTime_In,  UTime_In] = risetime(N_In, Fs);
    % % [R_T,  LTime_T,  UTime_T] = risetime(N_T_fixed ,Fs);
    % [R_T,  LTime_T,  UTime_T] = risetime(N_T_final ,Fs);
    % % risetime�œ���ꂽx�l�iindex�̒��Ԃ����蓾��j���A�Y����index�����i�s��F1~, �b���F0~�Ȃ̂�+1����j
    % idx_LTime_In = round(LTime_In*10000)+1;
    % idx_UTime_In =  round(UTime_In*10000)+1;
    % idx_LTime_T = round(LTime_T*10000)+1;
    % idx_UTime_T = round(UTime_T*10000)+1;
    
    % L_dif_T_IN = abs(LTime_In - LTime_T) * 1000;
    % U_dif_T_IN = abs(UTime_In - UTime_T) * 1000;
    % In_dif_U_L = abs(UTime_In - LTime_In) * 1000;
    % T_dif_U_L = abs(UTime_T - LTime_T) * 1000;
    
    % Record{1,1} = "L_dif_T_IN";
    % Record{1,2} = L_dif_T_IN;
    % Record{2,1} = "U_dif_T_IN";
    % Record{2,2} = U_dif_T_IN;
    % Record{3,1} = "In_dif_U_L";
    % Record{3,2} = In_dif_U_L;
    % Record{4,1} = "T_dif_U_L";
    % Record{4,2} = T_dif_U_L;

hold on
% �O���t�̕`��
plot(time,N_In);
plot(time,N_T_final);
% 1%�N���_
plot(time,N_In,'p','MarkerIndices', [idx_10p_In idx_90p_In],...
    'MarkerFaceColor','red',...
    'MarkerSize',10)
plot(time,N_T_final,'p','MarkerIndices', [idx_10p_T idx_90p_T],...
    'MarkerFaceColor','red',...
    'MarkerSize',10)
% plot(time,N_In,'p','MarkerIndices', [idx_1p_In idx_10p_In idx_90p_In],...
%     'MarkerFaceColor','red',...
%     'MarkerSize',10)
% plot(time,N_T_final,'p','MarkerIndices', [idx_1p_T idx_10p_T idx_90p_T],...
%     'MarkerFaceColor','red',...
%     'MarkerSize',10)


%% �`�撲��
hold on
labelFont = 18;

ax = gca; % current axes
ax.FontSize = labelFont;
ax.XLim = [0.4515 0.456];
ax.YLim = [0 1];
ax.XTickMode = 'auto';
% ax.XTickMode = 'manual';
ax.XTickLabelMode = 'manual';
ax.XTickLabel = [0 0.5 1 1.5 2 2.5 3 3.5 4 4.5];

% ax.XAxis.TickValues = [0:8]
xlabel('Time(ms)','FontSize',labelFont);
ylabel('Normalized Power Ratio','FontSize',labelFont);

legend('Input (V)' ,'Output (N)','FontSize',labelFont)
grid on



% % risetime��p��������10%�A90%�̓���
% plot(time,N_In,'o','MarkerIndices', [idx_LTime_In idx_UTime_In] ,...
%     'MarkerFaceColor','red',...
%     'MarkerSize',10)
% 
% plot(time,N_T_final,'o','MarkerIndices', [idx_LTime_T idx_UTime_T],...
%     'MarkerFaceColor','red',...
%     'MarkerSize',10)


% �ω������傫���_�̒��o����ѕ`��
    % TF_In = ischange(N_In);
    % idx_TF_In = find(TF_In);
    % TF_N_T = ischange(N_T_final);
    % idx_TF_T = find(TF_N_T);
    % plot(time,N_In,'p','MarkerIndices', idx_TF_In ,...
    %     'MarkerFaceColor','red',...
    %     'MarkerSize',10)
    % plot(time,N_T_final,'p','MarkerIndices', idx_TF_T,...
    %     'MarkerFaceColor','red',...
    %     'MarkerSize',10)

% plot(time,N_T_fixed);
% plot(time,N_T_fixed,'o','MarkerIndices', [idx_LTime_T idx_UTime_T],...
%     'MarkerFaceColor','red',...
%     'MarkerSize',10)
