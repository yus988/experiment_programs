%% csv�f�[�^�̃C���|�[�g����у��x���p�f�[�^����

% used by MasterTensionInput.m

% ��ʎ��������p�X�N���v�g
% ���o�͔g�`�̗ގ��x�����؂���B
% �o�͂�resultCell, �e���g������THD, ���͐M���ɑ΂���delay, 

% clear
close all

Fs = 1e4;%�T���v�����g��
% Fs = 10e3;%�T���v�����g��
t = 0:1/Fs:1;

%�����x�Z���T�̊��x
V2N = 0.01178; %�̓Z���T5916, Hapbeat�̎��̓v���X
% V2N = - 0.01178; %�̓Z���T5916, DC���[�^�[�̎��̓}�C�i�X

nharm = 6;%thd�̍����g��
list = dir('*.csv');
%10��2�s�̃Z�����쐬�B1��ڂ�y�������x�̍s��A2��ڂɗ̓Z���T
%�i�ł����1-�̘A�Ԃɂ��Ĉ�X�t�@�C������ύX���Ȃ��ł��ǂ��悤�ɂ�����

numFiles = length(list);
Mx = cell(numFiles,2);% �C���|�[�g�p�̃Z��
RMS_column = zeros(1,4);% RMS�l�i�[�p
resultCell = cell(4,1); % ���g���ARMS�ATHD�A�ʑ���

difsample =  dir('*.txt'); % vp2.txt or hapbeat.txt
isfs1e3= strcmp(difsample.name,'1e3.txt'); %Hapeat�̏ꍇ

% csv�f�[�^�̃C���|�[�g����у��x���p�f�[�^����
for i = 1:numFiles
    
    % �T���v�����O���[�g��1e3�̐M��������ꍇ
    if isfs1e3
        if i <= 12
                Fs = 1e3;
        else
                Fs = 1e4;
        end
    end
    
    Mx{i,1}= csvread(list(i).name,21,1,[21,1,10020,2]);
    % �I�t�Z�b�g�����i���ׂĂ̗v�f���畽�ϒl�������j
    Mx{i,2}(:,1) = ( Mx{i,1}(:,1) - mean(Mx{i,1}(:,1)) ) / V2N; %���Ɉ������������𐳂Ɂi�W���ł͕��j
    Mx{i,2}(:,2) = ( Mx{i,1}(:,2) - mean(Mx{i,1}(:,2)) );
    
    % timetable ���e�񂲂Ƃɒǉ�
    Mx{i,3} = timetable(Mx{i,2}(:,1), Mx{i,2}(:,2),'SampleRate',Fs);
    Mx{i,3}.Properties.VariableNames{'Var1'}='T'  ;
    Mx{i,3}.Properties.VariableNames{'Var2'}='In' ;

    for k = 0:1 % ch1~3�eHz,RMS,THD�̋L�^
        [thd_db, ~, harmfreq] = thd(Mx{i,2}(:,1+k), Fs, nharm);
        %             thd(Mx{8,2}(:,1), Fs, nharm); % �ʂ�THD���������Ƃ�
        Mx{i,6+3*k} = harmfreq(1,1);
        %         Mx{i,7+3*k} = rms((Mx{i,2}(:,1+k))) - 0.01 ;
        Mx{i,7+3*k} = rms((Mx{i,2}(:,1+k))) ;
        RMS_column(i,k+1) = Mx{i,7+3*k}; %  RMS�l�i�[�p�s��
        Mx{i,8+3*k} = thd_db;
        if k==0
            resultCell{i,2} = Mx{i,7+3*k};
            resultCell{i,3} = thd_db;
        end
    end
    %���͓d���̎��g�����擾���L�^�iharmfreq�ō����g��������A���̎n�߂̒l�𗘗p)
    [thd_db, harmpow, harmfreq] = thd(Mx{i,1}(:,2), Fs, nharm);
    Mx{i,4} = harmfreq(1,1);
    resultCell{i,1} = round(harmfreq(1,1),1);

    % FG������͓d����Vpp�����߂�B2�{�͕��̒l���l��
    Vin = 2*sqrt(2)*rms((Mx{i,1}(:,2)));
    Mx{i,5} = Vin;
end
% �s���ɐ�����ǉ�
Mx{i+1,1} = '���f�[�^';
Mx{i+1,2} = '�I�t�Z�b�g������';
Mx{i+1,3} = '�^�C���e�[�u��';
Mx{i+1,4} = '���g��';
Mx{i+1,5} = '����d���i�v�Z��j';
% resultCell{i+1,1} ='���g��';
% resultCell{i+1,2} = 'RMS';
% resultCell{i+1,3} = 'THD';
% resultCell{i+1,4} = 'Phase';

for k=0:1
    Mx{i+1,6+3*k} = strcat('ch', num2str(k+1), 'Hz');
    Mx{i+1,7+3*k} = strcat('ch', num2str(k+1), 'RMS');
    Mx{i+1,8+3*k} = strcat('ch', num2str(k+1), 'THD');
end


%% 
%% �M���̎��g�������̔�r
Fs = 1e4;%�T���v�����g��

for i = 1:numFiles
    
        % �T���v�����O���[�g��1e3�̐M��������ꍇ
    if isfs1e3
        if i <= 12
                Fs = 1e3;
        else
                Fs = 1e4;
        end
    end
    
    sig1 = Mx{i,2}(:,2); % ���͓d���i���]������j
    sig2 = Mx{i,2}(:,1); % ����
%     sig2 = -1 * Mx{i,2}(:,1); % ����
    
    isMaster = exist('actType');
    if isMaster
        if strcmp(actType,'DCmotor')
            sig2 = -1 * Mx{i,2}(:,1); % ����
        end
    end
        

    [P1,f1] = periodogram(sig1,[],[],Fs,'power');
    [P2,f2] = periodogram(sig2,[],[],Fs,'power');

%     figure
%     t = (0:numel(sig1)-1)/Fs;
%     subplot(2,2,1)
%     plot(t,sig1,'k')
%     ylabel('s1')
%     grid on
%     title('Time Series')
%     subplot(2,2,3)
%     plot(t,sig2)
%     ylabel('s2')
%     grid on
%     xlabel('Time (secs)')
%     subplot(2,2,2)
%     plot(f1,P1,'k')
%     ylabel('P1')
%     grid on
%     axis tight
%     title('Power Spectrum')
%     subplot(2,2,4)
%     plot(f2,P2)
%     ylabel('P2')
%     grid on
%     axis tight
%     xlabel('Frequency (Hz)')

    % �R�q�[�����X
    [Cxy,f] = mscohere(sig1,sig2,[],[],[],Fs);
    Pxy     = cpsd(sig1,sig2,[],[],[],Fs);
    phase   = -angle(Pxy)/pi*180;
%     [pks,locs] = findpeaks(Cxy,'MinPeakHeight',0.75);
% 
%     figure
% %   �U�����R�q�[�����X
%     subplot(2,1,1)
%     plot(f,Cxy)
%     title('Coherence Estimate')
%     grid on
%     hgca = gca;
%     hgca.XTick = round(f(locs),1);
%     % hgca.YTick = 0.75;
% %     axis([0 200 0 1]);
%     
% %   �ʑ��x��
%     subplot(2,1,2)
%     plot(f,phase)
%     title('Cross-spectrum Phase (deg)')
%     grid on
%     hgca = gca;
%     hgca.XTick = round(f(locs,1),1); 
%     yticks = sort(round(phase(locs)));
%     % hgca.YTick = round(phase(locs));
%     xlabel('Frequency (Hz)')
% %     axis([0 200 -180 180])

    Input_Hz = Mx{i,6};
    % knnsearch(f,Input_Hz): ���͎��g���ƍł��߂����g����Index��Ԃ�
    phaseDelay = phase(knnsearch(f,Input_Hz), 1);
    resultCell{i,4} = phaseDelay;
    imgTitle = strcat(num2str(round(Input_Hz)),'Hz');
%     saveas(gcf,strcat(imgTitle,'_','mscohere '));
%     saveas(gcf,strcat(imgTitle,'_','mscohere ','.png'));
end


% resultCell�������o��
if ~isfolder('result')
    mkdir result
    cd result
    writecell(resultCell,'result.csv')
    cd ..
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% �M���̒x���x
% 
% close all
% Fs = 1e4;%�T���v�����g��
% for i = 1:numFiles
%     % s1 = Mx{1,2}(:,2); % ���͓d��
%     s1 = Mx{i,2}(:,2); % ���͓d��
%     s2 = -1 * Mx{i,2}(:,1); % ���́i���]������j
%     % graph �`��
%     figure
%     ax(1) = subplot(2,1,1);
% %     plot(s1)
% %     [resultCell{i,4}(:,1),resultCell{i,4}(:,2)] = findpeaks(s1,Fs,'MinPeakDistance',0.01,'MinPeakHeight',0.05);
%     findpeaks(s1,Fs,'MinPeakDistance',0.01,'MinPeakHeight',0.05);
%     grid on
%     ax(2) = subplot(2,1,2);
%     plot(s2)
% %     [resultCell{i,5}(:,1),resultCell{i,5}(:,2)] = findpeaks(s2,Fs,'MinPeakDistance',0.01,'MinPeakHeight',0.5);
%     findpeaks(s2,Fs,'MinPeakDistance',0.01,'MinPeakHeight',0.02);   
%     t21 = finddelay(s1,s2) ;% ���̏ꍇ�As2��s1���x�T���v���x��Ă���
%     delaySec = t21 / Fs;
%     resultCell{i,3} = delaySec;
% end
% 
% resultCell{i+1,3} = 'delaySec';
% 





 %% �Œᒣ�͌��ؗp
% % arr20Hz = zeros(size(Mx,1),2);
% arr20Hz = zeros(1,2);
% arr80Hz = zeros(1,2);
% arr140Hz = zeros(1,2);
% arrRMS = zeros(1,2);
% 
% for i = 1:size(Mx,1)-1
%     tmpTensionVol = Mx{i,7} * V2N; % ����RMS (�d���\���j
%     arrRMS(i,1)=Mx{i,10}; % ���͓d��RMS
%     arrRMS(i,2)=tmpTensionVol; % ����RMS
% end
% 
% figure
% subplot(2,1,1)
% plot(arrRMS(:,1),arrRMS(:,2),'Marker','o', ...
%     'MarkerFaceColor', 'blue','color','blue');
% subplot(2,1,2)
% plot(arrRMS(:,2),'Marker','o', ...
%     'MarkerFaceColor', 'blue','color','blue');
% saveas(gcf,'result.png');
% 
% save;
