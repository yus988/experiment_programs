% Eurohaptics16�̌��ʂ�ToH1�e�ڂ���ɉ���

close all; clear;

list = dir('*.csv');
numFiles = length(list);
Mx = cell(numFiles,1);% �C���|�[�g�p�̃Z��
rmsArr = zeros(9,16);
stdArr = zeros(9,16);

% csv�f�[�^�̃C���|�[�g
for i = 1:numFiles
    Mx{i,1}= readmatrix(list(i).name);
end

% ��̐���
% 1 = wtv_150hz_chest_front
% 2 = wtv_150hz_chest_back
% 3 = wtv_30hz_chest_back
% 4 = wtv_30hz_chest_front
% 5 = wtv_30hz_abdo_front
% 6 =wtv_30hz_abdo_back
% 7 = wtv_150hz_abdo_back
% 8 = wtv_150hz_abdo_front
%   9 = hapt_150hz_chest_front
% 10 = hapt_150hz_chest_back
% 11 = hapt_30hz_chest_back
% 12 = hapt_30hz_chest_front
% 13 = hapt_30hz_abdo_front
% 14 = hapt_30hz_abdo_back
% 15 = hapt_150hz_abdo_back
% 16 = hapt_150hz_abdo_front

% �e����_�̕��ςƕW���΍����v�Z
for row = 1:9
    for col = 1:16
        for k = 1:5
            tmp(k,1) = Mx{k,1}(row,col);
        end
        rmsArr(row,col) = mean(tmp);
        stdArr(row,col) = mean(tmp);
    end
end

save;

%% �}�[�J�[�i�΁j�̈ʒu�Ɏ������ʂ�}��

% ���x���`��֘A
img_list = dir('./img/*.png');
num_pointArray =  length(img_list) ; %�΃}�[�J�̗�̐��Bimg�t�H���_�̉摜������Z�o
c_Annotation = cell(num_pointArray,1); %�`��p�}�[�J�[���W������Z��

for i=1:num_pointArray
    img = imread(strcat('./img/', num2str(i), '.png'));
    % 臒l����}�[�J�[���l���A�d�S�����߂� greenDetect.m��noiseReduction.m���K�v
    [BW, masked] = m_greenDetect(img);
    BW_filtered = m_noiseReduction(BW);
    % stats = regionprops(BW1_filtered);
    I = rgb2gray(masked);
    stats = regionprops(BW_filtered, I ,{'Centroid'});
    tmp_colmun =zeros(size(stats,1),2) ;
    for k = 1: size(stats,1)
        centroids = stats(k).Centroid;
        tmp_colmun(k,1) = centroids(1,1);
        tmp_colmun(k,2) = centroids(1,2);
        % X���W�����ɃO���[�v�����A�ʁX�̍s��ɏd�S���W��������
    end
    %     Xg����ɕ��ёւ� tmp_colmun =  sortrows(tmp_colmun, 1);

    %     Yg����ɕ��ёւ�
    tmp_colmun = sortrows(tmp_colmun, 2);
    c_Annotation{i,1} =tmp_colmun;
end



%% �e�����Ƃ̉����x�̑傫���Ɛ��l��}��

% c_Annotation ��2��ɒ���
i=0;
for m = 1:size(c_Annotation,1)
    for k = 1: size(c_Annotation{m,1},1)
        Annotation(k+i, 1) = c_Annotation{m,1}(k, 1);
        Annotation(k+i, 2) = c_Annotation{m,1}(k, 2);
    end
    i = i + size(c_Annotation{m,1},1);
end

front = 1:18;
back = 19:36;


%% �O���t�̕`��

close all

circleLineColor = 'r';
radiusCoef =5;

% for freq = 1:2  % 1=30Hz, 2=150Hz
for freq = 1:1  % 1=30Hz, 2=150Hz

    if freq ==1
        ftxt = '30_Hz';
    else
        ftxt = '150_Hz';
    end
%     for i=1:4
    for i=1:1
        if i ==1
            nm = 'wtvFront';
            annorow = 1:18;
            width = 4.1;
            if freq == 1
                chest = 4; abdo = 5;
            else
                chest = 1; abdo = 8;
            end
        elseif i == 2
            nm = 'wtvBack';
            annorow = 19:36;
            width = 3.94;

            if freq == 1
                chest = 3; abdo = 6;
            else
                chest = 2; abdo = 7;
            end
        elseif i == 3
            nm = 'haptFront';
            annorow = 1:18;
            width = 4.1;
            if freq == 1
                chest = 12; abdo = 13;
            else
                chest = 9; abdo = 16;
            end
        elseif i == 4
            nm = 'haptBack';
            annorow = 19:36;
            width = 3.94;

            if freq == 1
                chest = 11; abdo = 14;
            else
                chest = 10; abdo = 15;
            end
        end
        Underlayer_img = imread(strcat('./underlayer/', nm, '.png'));

%         figure('Name',ftxt, 'Units', 'centimeters', 'Position', [0 -40 width 5.05]);
        figure('Name',ftxt, 'Units', 'centimeters', 'Position', [0 -40 width 5.05 ]);

        imshow(Underlayer_img,'Border','tight');

        % viscircle �p�̔z������B

        centerOfAnnotation = Annotation(annorow,:);
        tmpMean(:,1) =  [rmsArr(:,chest); rmsArr(:,abdo)];
        tmpStd(:,1) = [rmsStd(:,chest); rmsStd(:,abdo)];
        radiulOfCircles(:,1) = tmpMean * radiusCoef;
        viscircles(centerOfAnnotation, radiulOfCircles,'Color',circleLineColor, ...
            'EnhanceVisibility',false,'LineStyle','-','LineWidth',1);


%%%%%%%%%%%%%%%   �W���΍��̉~�̑傫���m�F�p
     % RMS�̒l�������e�L�X�g��ǉ�
        text(centerOfAnnotation(:,1), centerOfAnnotation(:,2)+posOffset, ...
            num2str(round(tmpMean,3)),'Color','blue','FontSize', '10');

      % �W���΍��̐}��
        tmpMeanPlueStd = tmpMean + tmpStd;
        viscircles(centerOfAnnotation, tmpMeanPlueStd * radius_coef ,'EnhanceVisibility',false,'Color',	stdLineColor,'LineStyle',':','LineWidth',1);   
        tmpMeanMinusStd = tmpMean - tmpStd;
        errorIndex = find(tmpMeanMinusStd < 0); % ���̒l�������viscircles���G���[�ɂȂ�̂ŁA���̒l��0�ɂ���
        tmpMeanMinusStd(errorIndex, 1) = 0;
        viscircles(centerOfAnnotation, tmpMeanMinusStd * radius_coef ,'EnhanceVisibility',false,'Color',stdLineColor,'LineStyle',':','LineWidth',1);   

     % �W���΍��̒l�������e�L�X�g��ǉ�
%         text(Annotation(:,1) -10, Annotation(:,2) + posOffset*1.8 ,strcat('�}',num2str(round(tmpStd,3))),'Color','blue','FontSize',annotationTextFontSize);
%%%%%%%%%%%%%%%


        print(strcat(ftxt,'_', nm),'-depsc');
    
%         saveas(gcf,strcat(ftxt,'_', nm,'.png'));
    end
end


% ��̐���
% 1 = wtv_150hz_chest_front
% 2 = wtv_150hz_chest_back
% 3 = wtv_30hz_chest_back
% 4 = wtv_30hz_chest_front
% 5 = wtv_30hz_abdo_front
% 6 =wtv_30hz_abdo_back
% 7 = wtv_150hz_abdo_back
% 8 = wtv_150hz_abdo_front
%   9 = hapt_150hz_chest_front
% 10 = hapt_150hz_chest_back
% 11 = hapt_30hz_chest_back
% 12 = hapt_30hz_chest_front
% 13 = hapt_30hz_abdo_front
% 14 = hapt_30hz_abdo_back
% 15 = hapt_150hz_abdo_back
% 16 = hapt_150hz_abdo_front

