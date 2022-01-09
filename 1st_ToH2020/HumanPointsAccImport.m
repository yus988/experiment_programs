%%�������ʂ�import���Đ}������B
%�n�߂ɓ��͐M���ɉ����ďꍇ����
% �Ăяo����鑤��clear�͓���Ȃ�

close all

Fs = 1e4;%�T���v�����g��
t = 0:1/Fs:1;
%�����x�Z���T�̊��x

% V2G6 = 0.206; %MMA7361L 6G���[�h = v/g v / (g*9.80665)
% radius_coef = 15;
V2G6 = 0.206 / 9.80665; %MMA7361L 6G���[�h = v/g v / (g*9.80665)
radius_coef = 15 / 9.80665 ;%�`��̂��߉����x(g)�Ɋ|�����킹��W��

% V2G = 0.800; %MMA7361L 1.5G���[�h
V2N = 0.01178; %�̓Z���T5916

nharm = 6;%thd�̍����g��
%10��2�s�̃Z�����쐬�B1��ڂ�y�������x�̍s��A2��ڂɗ̓Z���T
%�i�ł����1-�̘A�Ԃɂ��Ĉ�X�t�@�C������ύX���Ȃ��ł��ǂ��悤�ɂ�����
list = dir('*.csv');
numFiles = length(list);
Mx = cell(numFiles,2);% �C���|�[�g�p�̃Z��
Analysis = cell(15);
xyz = 0;
num_points = numFiles; % ����_���Ȃ̂ł́H
labels = zeros(num_points,1);
labels_x = zeros(num_points,1);
labels_y = zeros(num_points,1);
labels_z = zeros(num_points,1);
labels_sum = zeros(num_points,1);

% ��ނɂ���ĕύX
area = 0 ; %�O�ʁF0
% area = 1 %���ʁF1
% area = 2 %�w�ʁF2

RMS_column = zeros(1,4);% RMS�l�i�[�p

%�`�悳��������x�BXg: 7, Yg: 10,  Zg: 13, Sum: 15
target_row = 15;  %Sum
% target_row = 7; %Xg
% target_row = 10; %Yg
% target_row = 13; %Zg

% % 0.5,1,1.5G �̑傫��
% figure;
% base_x = 300;
% base_y = 100;
% pos_offset = 150;
% ecolor = 'black';
% lineWidth = 2;
% imshow(imread('../wb2.png'),'Border','tight');
% viscircles([base_x  base_y], 0.5 * radius_coef, 'Color',ecolor,'EnhanceVisibility',false,'LineWidth',lineWidth);
% viscircles([base_x  base_y + pos_offset * 0.75], 1 * radius_coef, 'Color',ecolor,'EnhanceVisibility',false,'LineWidth',lineWidth);
% viscircles([base_x  base_y + pos_offset * 2], 1.5 * ra

%% csv�f�[�^�̃C���|�[�g����у��x���p�f�[�^����
for i = 1:numFiles
    Mx{i,1}= csvread(list(i).name,21,1,[21,1,10020,4]);
    % �I�t�Z�b�g�����i���ׂĂ̗v�f���畽�ϒl�������j
    Mx{i,2}(:,1) = ( Mx{i,1}(:,1) - mean(Mx{i,1}(:,1)) ) / V2G6; %���Ɉ������������𐳂Ɂi�W���ł͕��j
    Mx{i,2}(:,2) = ( Mx{i,1}(:,2) - mean(Mx{i,1}(:,2)) ) / V2G6;
    Mx{i,2}(:,3) = ( Mx{i,1}(:,3) - mean(Mx{i,1}(:,3)) ) / V2G6;
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
    
%     TT= timetable(Mx{i,2}(:,1), Mx{i,2}(:,2), Mx{i,2}(:,3),Mx{i,2}(:,4),'SampleRate',Fs);
    % timetable ���e�񂲂Ƃɒǉ�
    Mx{i,3} = timetable(Mx{i,2}(:,1), Mx{i,2}(:,2), Mx{i,2}(:,3),Mx{i,2}(:,4),'SampleRate',Fs);
    Mx{i,3}.Properties.VariableNames{'Var1'}='x' ;
    Mx{i,3}.Properties.VariableNames{'Var2'}='y' ;
    Mx{i,3}.Properties.VariableNames{'Var3'}='z' ;
    labels_x(i,1) = round(Mx{i, 7}, 3,'significant');
    labels_y(i,1) = round(Mx{i, 10}, 3,'significant');
    labels_z(i,1) = round(Mx{i, 13}, 3,'significant');
    labels_sum(i,1) = round(Mx{i, 15}, 3,'significant');
end
% �s���ɐ�����ǉ�
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
Mx{i+1,15} = '3��RMS�l';

save;

%%  %%%%%%%  �ȉ��A�}�����Ȃ��Ȃ�s�v %%%%%%%

%% �}�[�J�[�i�΁j�̈ʒu�Ɏ������ʂ�}��
% 
% % ���x���`��֘A
% img_list = dir('../img/*.png');
% Underlayer_img = imread('../img/Underlayer.png');
% num_pointArray =  length(img_list)-1 ; %�΃}�[�J�̗�̐��Bimg�t�H���_�̉摜������Z�o
% 
% centerOfAnnotation = zeros(num_points, 2);%c_Annotation���璆�S���W�̂ݎ��o��
% radiulOfCircles = zeros(num_points, 1);
% 
% c_Annotation = cell(num_pointArray,1); %�`��p�}�[�J�[���W������Z��
% 
% for i=1:num_pointArray
%     img = imread(strcat('../img/', num2str(i), '.png'));
%     % 臒l����}�[�J�[���l���A�d�S�����߂�
%     % greenDetect.m��noiseReduction.m���K�v
%     [BW, masked] = m_greenDetect(img);
%     BW_filtered = m_noiseReduction(BW);
%     % stats = regionprops(BW1_filtered);
%     I = rgb2gray(masked);
%     stats = regionprops(BW_filtered, I ,{'Centroid'});
%     tmp_colmun =zeros(size(stats,1),2) ;
%     for k = 1: size(stats,1)
%         centroids = stats(k).Centroid;
%         tmp_colmun(k,1) = centroids(1,1);
%         tmp_colmun(k,2) = centroids(1,2);
%         % X���W�����ɃO���[�v�����A�ʁX�̍s��ɏd�S���W��������
%     end
%     %     Xg����ɕ��ёւ�
%     %     tmp_colmun =  sortrows(tmp_colmun, 1);
%     
%     %     Yg����ɕ��ёւ�
%     tmp_colmun = sortrows(tmp_colmun, 2);
%     c_Annotation{i,1} =tmp_colmun;
% end
% 
% 
% %% �e�����Ƃ̉����x�̑傫���Ɛ��l��}��
% % x,y,z,sum����x�̏����ŕ`�悷��
% %�`��̂��߉����x(g)�Ɋ|�����킹��W��
% 
% 
% % if area == 0
% %     radius_coef = 15;%�O��
% % elseif area == 1
% %     radius_coef = 25;%����
% % elseif area ==2
% %     radius_coef = 25;%����
% % end
%    
% 
% % for axis = 0:3
% %     if axis == 2
% % %         figure('Name','x')
% %         target_row = 7;
% %         labels = labels_x;
% %     elseif axis == 1
% % %         figure('Name','y')
% %         target_row = 10;
% %         labels = labels_y;
% %     elseif axis == 0
% % %         figure('Name','z')
% %         target_row = 13;
% %         labels = labels_z;
% %     elseif axis == 3
%         figure('Name','sum')
%         target_row = 15 ;
%         labels = labels_sum;
% %     end
% %     
% 
%     Annotation = zeros(num_points, 3); %c_Annotation��Float�s��, [�}�[�J�[��x���W, y���p, �����x�̑傫��r]
%     %viscircles���g�����߁A�d�S�Ɖ~���a�����ꂼ��ʂ̍s��ɑ��
%     i = 0; %�@c_Annotation�̐������Q�ƍs���V�t�g�����邽��
%     for m = 1:size(c_Annotation,1)
%         for k = 1: size(c_Annotation{m,1},1)
%             Annotation(k+i, 1) = c_Annotation{m,1}(k, 1);
%             Annotation(k+i, 2) = c_Annotation{m,1}(k, 2);
%             Annotation(k+i, 3) = Mx{k+i, target_row}*radius_coef;
%         end
%         i = i + size(c_Annotation{m,1},1);
%     end
%     % Mx�Ɋi�[����Ă���f�[�^���d�S�{offset�̈ʒu�ɕ`��
%     %     dispFrame = insertObjectAnnotation(Underlayer_img, 'circle', Annotation, labels, ...
%     %          'FontSize', 30, 'LineWidth', 3,'TextBoxOpacity',0.4, 'color', 'magenta','TextColor', 'white');
%     %     imshow(dispFrame)
%     %
%     %     % �O�ʗp�t�H���g �K�X����
%     
%  % Annotation�̑傫���Ȃǂ�����
%  annoColor = 'blue';
% if area == 0 %�O��
%     dispFrame = insertObjectAnnotation(Underlayer_img, 'circle', Annotation, labels, ...
%     'FontSize', 10, 'LineWidth', 2,'TextBoxOpacity',0, 'color', 'magenta','TextColor', annoColor);
% elseif area == 1 %����
%     dispFrame = insertObjectAnnotation(Underlayer_img, 'circle', Annotation, labels, ...
%     'FontSize', 20, 'LineWidth', 3,'TextBoxOpacity',0.4, 'color', 'magenta','TextColor', annoColor);
% elseif area ==2 %�w��
%     dispFrame = insertObjectAnnotation(Underlayer_img, 'circle', Annotation, labels, ...
%     'FontSize', 20, 'LineWidth', 3,'TextBoxOpacity',0.4, 'color', 'magenta','TextColor', annoColor);
% end
%    
%     
% %     dispFrame = insertObjectAnnotation(Underlayer_img, 'circle', Annotation, labels, ...
% %         'FontSize', 20, 'LineWidth', 3,'TextBoxOpacity',0.4, 'color', 'magenta','TextColor', 'white');
%     
% 
%     imshow(dispFrame,'Border','tight') % border tight �����邱�Ƃŗ]���Ȃ���
%     
%     % �O�ʗp�t�H���g
%     %     dispFrame = insertObjectAnnotation(Underlayer_img, 'circle', Annotation, labels, ...
%     %          'FontSize', 8, 'LineWidth', 3,'TextBoxOpacity',0,'TextColor', 'white');
%     %     imshow(dispFrame)
%     
%     
%     if target_row == 7
%         str = 'Xg';
%     elseif target_row == 10
%         str = 'Yg';
%     elseif target_row == 13
%         str = 'Zg';
%     elseif target_row == 15
%         str = 'Sum';
%     end
%     %     Sum, x, y, z�̕\��
%     %annotation�e�L�X�g��y���p
%     
%     if or(area == 0,area==1) %�O�� or ����
%                 x_base = 220;
%                 y_base = 20;
%                 y_offset = 30;
%     elseif area == 1 %�w��
%         %         x_base = 240;
%         %         y_base = 140;
%         %         y_offset = 30;
%     end
%         text(x_base,y_base,erase(dir('*.txt').name,'.txt'),'Color','white','FontSize',20);
%     %     text(x_base,y_base + y_offset,str,'Color','white','FontSize',20);
%     
% % end % for end
% 
% saveas(gcf,strcat('sum','.png'));
% 
% %% �`��d�S�Ɖ����x�̑傫���������~��`�悷��̂Ɏg�p����s��̏���
% 
% % �}�[�J�[�̒��S���W�𒍎ߗpfloat�s��ɕϊ��icell�`������float�s��`���ɕς������j
% 
% %% x,y,z�̉����x�̒l���ꖇ�}�ɕ`��
% % radius_coef = 60;%�`��̂��߉����x(g)�Ɋ|�����킹��W��
% 
% figure
% % imshow(Underlayer_img); %���̂݁B���[�v�̒��ɓ����Ɠs�x�����������B
% imshow(Underlayer_img,'Border','tight');
% 
% % �~�̑傫���̒��߁i�d�͉����x�F�~���a�j
% 
% annotation_color = 'white';
% 
% if area == 0
%     % �O�� or ����
%     %     viscircles([150  400],1 * radius_coef, 'Color',annotation_color);
%     %     text(130,400,'1G','Color',annotation_color,'FontSize',24);
%     %     viscircles([150  520],2 * radius_coef, 'Color',annotation_color);
%     %     text(130,520,'2G','Color',annotation_color,'FontSize',24);
%     %     viscircles([150  700],3 * radius_coef, 'Color',annotation_color);
%     %     text(130,700,'3G','Color',annotation_color,'FontSize',24);
%     
% elseif area == 1
%     % �w��
%     %     viscircles([100  250], 1 * radius_coef, 'Color',annotation_color);
%     %     text(80,250,'1G','Color',annotation_color,'FontSize',16);
%     %     viscircles([300 250], 2 * radius_coef, 'Color',annotation_color);
%     %     text(270,250,'2G','Color',annotation_color,'FontSize',24);
%     %     viscircles([500  250], 3 * radius_coef, 'Color',annotation_color);
%     %     text(470,250,'3G','Color',annotation_color,'FontSize',24);
% end
% 
% %annotation�e�L�X�g��y���p
% % x_base = 250;
% % y_base = 20;
% %�f�B���N�g���ɂ���.txt�̃t�@�C�����𒍎߂ɗ��p
% text(x_base,y_base,erase(dir('*.txt').name,'.txt'),'Color','white','FontSize',20);
% % text(40,50,erase(dir('*.txt').name,'.txt'),'Color','white','FontSize',20);
% 
% for axis = 0:2
%     %�����x�̑傫����labels�s��ɑ��
%     if axis == 2
%         target_row = 7; % x
%         circleLineColor = '#009C4E'; % x = �ΐF
%         %         text(40,y_base + 1*y_offset,'x = green','Color',circleLineColor,'FontSize',20);
%     elseif axis == 1
%         target_row = 10; % y
%         circleLineColor = '#FFFF00'; % y = ���F
%         %         text(40,y_base + 2*y_offset,'y = yellow','Color',circleLineColor,'FontSize',20);
%     elseif axis == 0
%         target_row = 13; % z
%         circleLineColor = '#FFA500'; % z = �I�����W
%         %         text(40,y_base + 3*y_offset,'z = orange','Color',circleLineColor,'FontSize',20);
%     end
%     
%     %viscircles���g�����߁A�d�S�Ɖ~���a�����ꂼ��ʂ̍s��ɑ��
%     i = 0;
%     for m = 1:size(c_Annotation,1)
%         for k = 1: size(c_Annotation{m,1},1)
%             centerOfAnnotation(k+i, :) = [c_Annotation{m,1}(k, 1) c_Annotation{m,1}(k, 2)];
%             radiulOfCircles(k+i, :) = Mx{k+i, target_row}*radius_coef;
%         end
%         i = i + size(c_Annotation{m,1},1);
%     end
%     
%     viscircles(centerOfAnnotation, radiulOfCircles,'Color',circleLineColor,'EnhanceVisibility',false,'LineStyle','-','LineWidth',1);
% end
% 
% % text(x_base,y_base,erase(dir('*.txt').name,'.txt'),'Color','white','FontSize',20);
% saveas(gcf,strcat('xyz','.png'));


%% %%%%%%%  �ȏ�A�}�����Ȃ��Ȃ�s�v %%%%%%%

%% �^�C���e�[�u���ɑ��
% t1 = Mx{1,3};
% t2 = Mx{2,3};
% t3 = Mx{3,3};
% t4 = Mx{4,3};
% t5 = Mx{5,3};
% t6 = Mx{6,3};
% t7 = Mx{7,3};
% t8 = Mx{8,3};
% t9 = Mx{9,3};
% t10 = Mx{10,3};
% t11 = Mx{11,3};
% t12 = Mx{12,3};
% t13 = Mx{13,3};
% t14 = Mx{14,3};
% t15 = Mx{15,3};
% %
%% �d�S���m
% % �d�ˌ��̉摜�̃C���|�[�g
%
% img = imread(Underlayer_img);
% % 臒l����}�[�J�[���l���A�d�S�����߂�
% % greenDetect.m��noiseReduction.m���K�v
% [BW, masked] = greenDetect(img);
% BW_filtered = noiseReduction(BW);
% % stats = regionprops(BW1_filtered);
% I = rgb2gray(masked);
% stats = regionprops(BW_filtered, I ,{'Centroid','WeightedCentroid'});
% t1st_column =zeros(size(stats,1),2) ;
% t2nd_column= zeros(size(stats,1),2) ;
% t3rd_column = zeros(size(stats,1),2) ;
%
% Recorder = cell(size(stats,1));
% Annotation = zeros(size(stats,1),3);
% labels = zeros(size(stats,1),1);
%
% for k = 1: size(stats,1)
%     centroids = stats(k).Centroid;
%     Xg = centroids(1,1);
%     Yg = centroids(1,2);
% %     WeightedCentroid1 = stats(k).WeightedCentroid;
% % X���W�����ɃO���[�v�����A�ʁX�̍s��ɏd�S���W��������
%     if Xg > 50 && Xg < 150
%        t1st_column(k,1) = Xg;
%        t1st_column(k,2) = Yg;
%     elseif Xg > 300 && Xg < 400
%        t2nd_column(k,1) = Xg;
%        t2nd_column(k,2) = Yg;
%     elseif Xg > 500 && Xg < 700
%        t3rd_column(k,1) = Xg;
%        t3rd_column(k,2) = Yg;
%     end
%     labels(k,1) = round(Mx{k,target_row}, 3,'significant');
% end
%
% % 0�̗v�f���폜
%% ���l�`��
% % Yg����ɕ��ёւ�
%     t1st_column = sortrows(t1st_column,2);
%     t2nd_column = sortrows(t2nd_column,2);
%     t3rd_column = sortrows(t3rd_column,2);
%
%  % 0�̍s���폜�B�K�����������Ƀ\�[�g���A0�̍s���㑤�ɂ����ԂŎ��s���邱��
%  for m = 1:size(t1st_column,1)
%      if t1st_column(1,1) == 0
%          t1st_column(1,:) = [];
%      end
%  end
%  for m = 1:size(t2nd_column,1)
%      if t2nd_column(1,1) == 0
%          t2nd_column(1,:) = [];
%      end
%  end
% for m = 1:size(t3rd_column,1)
%      if t3rd_column(1,1) == 0
%          t3rd_column(1,:) = [];
%      end
%  end
%
% % �摜�ɉ����x�̑傫���ɉ������~�i��3�����j��`��
% for m = 1:size(t1st_column,1)
%     Annotation(m, :) =[t1st_column(m, 1) t1st_column(m, 2) Mx{m,target_row}*radius_coef];
% end
%
%  for m = 1:size(t2nd_column,1)
%     Annotation(m+row_num, :) =[t2nd_column(m, 1) t2nd_column(m, 2) Mx{m+row_num,target_row}*radius_coef];
%  end
%
% for m = 1:size(t3rd_column,1)
%     Annotation(m+row_num*2, :) =[t3rd_column(m, 1) t3rd_column(m, 2) Mx{m+row_num*2,target_row}*radius_coef];
% end
%
% % Mx�Ɋi�[����Ă���f�[�^���d�S�{offset�̈ʒu�ɕ`��
% dispFrame = insertObjectAnnotation(img, 'circle', Annotation, labels, ...
%      'FontSize', 30, 'LineWidth', 3,'TextBoxOpacity',0.4);
% imshow(dispFrame)
%
% if target_row == 7
%     str = 'Xg';
% elseif target_row == 10
%     str = 'Yg';
% elseif target_row == 13
%     str = 'Zg';
% elseif target_row == 15
%     str = 'Sum';
% end
% % ���̒���
% dim = [.14 .6 .4 .1];
% % title(str);
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
%%
% t13 = Mx{13,3};
% t14 = Mx{14,3};
% t15 = Mx{15,3};
% t16 = Mx{16,3};
% t17 = Mx{17,3};
% t18 = Mx{18,3};
% t19 = Mx{19,3};
% t20 = Mx{20,3};
% t21 = Mx{21,3};
% t22 = Mx{22,3};
% t23 = Mx{23,3};
% t24 = Mx{24,3};
% t25 = Mx{25,3};
% t26 = Mx{26,3};
% t27 = Mx{27,3};
% t28 = Mx{28,3};
% t29 = Mx{29,3};
% t30 = Mx{30,3};
% t31 = Mx{31,3};
% t32 = Mx{32,3};
% t33 = Mx{33,3};
% t34 = Mx{34,3};
%% �R�����g�A�E�g
%% ���l�`��
% �d�ˌ��̉摜�̃C���|�[�g
%
% img = imread(Underlayer_img);
% % 臒l����}�[�J�[���l���A�d�S�����߂�
% % greenDetect.m��noiseReduction.m���K�v
% [BW, masked] = greenDetect(img);
% BW_filtered = noiseReduction(BW);
% % stats = regionprops(BW1_filtered);
% I = rgb2gray(masked);
% stats = regionprops(BW_filtered, I ,{'Centroid','WeightedCentroid'});
% t1st_column =zeros(size(stats,1),2) ;
% t2nd_column= zeros(size(stats,1),2) ;
% t3rd_column = zeros(size(stats,1),2) ;
%
% Recorder = cell(size(stats,1));
% Annotation = zeros(size(stats,1),3);
% labels = zeros(size(stats,1),1);
%
% for k = 1: size(stats,1)
%     centroids = stats(k).Centroid;
%     Xg = centroids(1,1);
%     Yg = centroids(1,2);
% %     WeightedCentroid1 = stats(k).WeightedCentroid;
% % X���W�����ɃO���[�v�����A�ʁX�̍s��ɏd�S���W��������
%     if Xg > 50 && Xg < 150
%        t1st_column(k,1) = Xg;
%        t1st_column(k,2) = Yg;
%     elseif Xg > 300 && Xg < 400
%        t2nd_column(k,1) = Xg;
%        t2nd_column(k,2) = Yg;
%     elseif Xg > 500 && Xg < 700
%        t3rd_column(k,1) = Xg;
%        t3rd_column(k,2) = Yg;
%     end
%     labels(k,1) = round(Mx{k,target_row}, 3,'significant');
% end
%%�O���t�`��iAVG�j
%
% RMS_Graph40Hz = zeros(numFiles/2,5); numFiled�������łȂ��ƃG���[���o��̂Œ���
% RMS_Graph160Hz = zeros(numFiles/2,5);
% AVG40Hz = zeros(numFiles/2,5);
% AVG160Hz = zeros(numFiles/2,5);

% %% �O���t�`��iAVG�j
% if isfile('awake.txt')
%     close all;
%     % RMS_Graph40Hz(:,1) = [7.176800356; 15.71619743; 27.86718577;45.15739219; 65.99584052; 88.54207624;
%     x40_axis = RMS_Graph40Hz(:,1);
%     x160_axis = RMS_Graph160Hz(:,1);
%     ylimN_max = 2.1;
%     xlim_min = 20;
%     % �O���t�̐F
%     def_blue =[0 0.4470 0.7410];
%     def_orange = [0.8500 0.3250 0.0980];
%     % y_N40axis = 0 : 0.2 : max(RMS_Graph40Hz(:,2);
%     x_label ='Input Voltage (Top: Displayed on Fuction Generator (mV), Bot: Motor Voltage (mV) )';
%     y_Nlabel = 'Tension(N)';
%     y_XYZlabel = 'Acceleralation(G)';
%     %�L�^�����f�[�^���~���̏ꍇ�A�O���t�\���p�ɍs�����ёւ��đ������
%     AVGflag = dir('*.txt');
%     if contains(pwd, "RVS") | contains(AVGflag.name, "AVG")
%         RMS_Graph40Hz = flip(AVG40Hz);
%         RMS_Graph160Hz = flip(AVG160Hz);
%     else
%         RMS_Graph40Hz = AVG40Hz;
%         RMS_Graph160Hz = AVG160Hz;
%     end
%     % 40Hz�̃O���t
%     f1 = figure;
%     hold on
%     % ���͂�y�������ɁA�����x��y�����E��
%     yyaxis left
%     ylabel(y_Nlabel);
%     plot(x40_axis, RMS_Graph40Hz(:,2), '-o','MarkerFaceColor',def_blue,'MarkerSize',5)
%
%     ylim([0 ylimN_max])
%     %�����x�̃v���b�g�iy���E�j
%     yyaxis right
%     plot(x40_axis, RMS_Graph40Hz(:,3),'-->','MarkerFaceColor',def_orange,'MarkerSize',5);
%     plot(x40_axis, RMS_Graph40Hz(:,4),'-^','MarkerFaceColor',def_orange,'MarkerSize',5);
%     plot( x40_axis, RMS_Graph40Hz(:,5),'-.d','MarkerFaceColor',def_orange,'MarkerSize',5);
%     ylim([0 0.45])
%     % x���͈̔�
%     xlim([xlim_min max(RMS_Graph40Hz(:,1))] )
%     xticks([20:10:200])
%
%     % xtl = '\begin{tabular}{c} 20 \\ 30\end{tabular}';
%     % set(gca,'XTick',[20:10:200],'XTickLabels',xtl,'TickLabelInterpreter','latex')
%     set(gca,'FontSize',9,'XTickLabel',{'20 (0.25)','30 (0.37)','40 (0.50)','50 (0.63)',...
%         '60 (0.76)','70 (0.88)','80 (1.01)','90 (1.14)','100 (1.27)',...
%         '110 (1.39)','120 (1.52)','130 (1.64)','140 (1.77)','150 (1.89)',...
%         '160 (2.01)','170 (2.13)','180 (2.25)','190 (2.37)','200 (2.49)'});
%     fix_xticklabels();
%     ylabel(y_XYZlabel);
%     % legend('Tension','G_x','G_y','G_z','G_{xyz}');
%     legend('Tension','G_x','G_y','G_z');
%     xlabel(x_label)
%     title('40Hz Result')
%     %�\��������X�N���[���T�C�Y�𒲐�����Bnw�i���j��nh�i�����j�𒲐����邾���ł���
%     scrsz = get(groot,'ScreenSize');
%     nw = 2;
%     nh =1.3;
%     maxW = scrsz(3);
%     maxH = scrsz(4);
%     p = get(gcf,'Position');
%     dw = p(3)-min(nw*p(3),maxW);
%     dh = p(4)-min(nh*p(4),maxH);
%     set(gcf,'Position',[p(1)+dw/2  p(2)+dh  min(nw*p(3),maxW)  min(nh*p(4),maxH)])
%     hold off
%     % 160Hz�̃O���t
%     f2 = figure;
%     hold on
%     % ���͂�y�������ɁA�����x��y�����E��
%     yyaxis left
%     ylabel(y_Nlabel);
%     plot(x160_axis, RMS_Graph160Hz(:,2), '-o','MarkerFaceColor',def_blue,'MarkerSize',5)
%     ylim([0 ylimN_max])
%     %�����x�̃v���b�g�iy���E�j
%     yyaxis right
%     % plot( x_axis, RMS_Graph160Hz(:,3), x_axis, RMS_Graph160Hz(:,4), x_axis, RMS_Graph160Hz(:,5), x_axis, RMS_Graph160Hz(:,6) )
%     plot(x160_axis, RMS_Graph160Hz(:,3),'-->','MarkerFaceColor',def_orange,'MarkerSize',5);
%     plot(x160_axis, RMS_Graph160Hz(:,4),'-^','MarkerFaceColor',def_orange,'MarkerSize',5);
%     plot( x160_axis, RMS_Graph160Hz(:,5),'-.d','MarkerFaceColor',def_orange,'MarkerSize',5);
%     ylim([0 0.45])
%     %160Hz ���͈̔͐ݒ�
%     xlim([xlim_min max(RMS_Graph160Hz(:,1))] )
%     xticks([20:10:200])
%     set(gca,'FontSize',9,'XTickLabel',{'20 (0.25)','30 (0.35)','40 (0.47)','50 (0.60)',...
%         '60 (0.72)','70 (0.83)','80 (0.95)','90 (1.06)','100 (1.18)',...
%         '110 (1.29)','120 (1.41)','130 (1.52)','140 (1.64)','150 (1.74)',...
%         '160 (1.85)','170 (1.96)','180 (2.07)','190 (2.19)','200 (2.29)'});
%     fix_xticklabels();
%     ylabel(y_XYZlabel);
%     % legend('Tension','G_x','G_y','G_z','G_{xyz}');
%     legend('Tension','G_x','G_y','G_z');
%     xlabel(x_label)
%     title('160Hz Result')
%     %�\��������X�N���[���T�C�Y�𒲐�����Bnw�i���j��nh�i�����j�𒲐����邾���ł���
%     scrsz = get(groot,'ScreenSize');
%     nw = 2;
%     nh =1.3;
%     maxW = scrsz(3);
%     maxH = scrsz(4);
%     p = get(gcf,'Position');
%     dw = p(3)-min(nw*p(3),maxW);
%     dh = p(4)-min(nh*p(4),maxH);
%     set(gcf,'Position',[p(1)+dw/2  p(2)+dh  min(nw*p(3),maxW)  min(nh*p(4),maxH)])
%
%     hold off
% end
%% �O���t�`��i�N���d���j
% % if contains(AwakeFlag.name, "awake")
% if isfile('awake.txt')
%     close all;
%
%     RMS_Graph40Hz = flip(AVG40Hz);
%     RMS_Graph160Hz = flip(AVG160Hz);
%
%     x40_axis = RMS_Graph40Hz(:,1);
%     x160_axis = RMS_Graph160Hz(:,1);
%     ylimN_max = 2.1;
%     xlim40_min = min(RMS_Graph40Hz(:,1));
%     xlim40_max = max(RMS_Graph40Hz(:,1));
%     xlim160_min = min(RMS_Graph160Hz(:,1));
%     xlim160_max = max(RMS_Graph160Hz(:,1));
%     % y_N40axis = 0 : 0.2 : max(RMS_Graph40Hz(:,2);
%     x_label = 'Input Voltage (Top: Displayed on Fuction Generator (mV), Bot: Motor Voltage (mV) )'
%     y_Nlabel = 'Tension(N)';
%
%     % RMS_Graph40Hz = sortrows(RMS_Graph40Hz);
%     % RMS_Graph160Hz = sortrows(RMS_Graph160Hz);
%
%     %40Hz�̃O���t
%     f1 = figure;
%     hold on
%     % ���͂�y�������ɁA�����x��y�����E��
%     ylabel(y_Nlabel);
%     plot(x40_axis, RMS_Graph40Hz(:,2),'-ro',x40_axis, RMS_Graph40Hz(:,3),'-r*', ...
%         x40_axis, RMS_Graph40Hz(:,4),'-go',x40_axis, RMS_Graph40Hz(:,5),'-g*',...
%         x40_axis, RMS_Graph40Hz(:,6),'-bo',x40_axis, RMS_Graph40Hz(:,7),'-b*');
%     % x���͈̔�
%     %     ylim([0 yN_max])
%     xlim([xlim40_min xlim40_max] )
%         set(gca,'FontSize',9,'XTickLabel',{'20 (253)','21 (265)','22 (278)','23 (289)',...
%         '24 (300)','25 (312)','26 (323)','27 (338)','28 (350)','29 (362)','30 (376)'});
%     fix_xticklabels();
%     % legend('Tension','G_x','G_y','G_z','G_{xyz}');
%     legend('1st','2nd','3rd','4th','5th','6th');
%     xlabel(x_label)
%     title('40Hz Result')
%
%         %�\��������X�N���[���T�C�Y�𒲐�����Bnw�i���j��nh�i�����j�𒲐����邾���ł���
%     scrsz = get(groot,'ScreenSize');
%     nw = 1;
%     nh =1.3;
%     maxW = scrsz(3);
%     maxH = scrsz(4);
%     p = get(gcf,'Position');
%     dw = p(3)-min(nw*p(3),maxW);
%     dh = p(4)-min(nh*p(4),maxH);
%     set(gcf,'Position',[p(1)+dw/2  p(2)+dh  min(nw*p(3),maxW)  min(nh*p(4),maxH)])
%
%
%     hold off
%
%     % 160Hz�̃O���t
%     f2 = figure;
%     hold on
%     ylabel(y_Nlabel);
%     plot(x160_axis, RMS_Graph160Hz(:,2),'-ro',x160_axis, RMS_Graph160Hz(:,3),'-r*', ...
%         x160_axis, RMS_Graph160Hz(:,4),'-go',x160_axis, RMS_Graph160Hz(:,5),'-g*',...
%         x160_axis, RMS_Graph160Hz(:,6),'-bo',x160_axis, RMS_Graph160Hz(:,7),'-b*');        % ���͈̔͐ݒ�
% %     ylim([0 yN_max])
%     xlim([xlim160_min xlim160_max] )
%         set(gca,'FontSize',9,'XTickLabel',{'15 (200)','16 (212)','17 (222)','18 (234)',...
%         '19 (244)','20 (254)','21 (265)','22 (277)','23 (288)','24 (299)','25 (311)'});
%     fix_xticklabels();
%     % legend('Tension','G_x','G_y','G_z','G_{xyz}');
%     % legend('Tension','G_x','G_y','G_z','G_{xyz}');
%     legend('1st','2nd','3rd','4th','5th','6th');
%     xlabel(x_label)
%     title('160Hz Result')
%
%             %�\��������X�N���[���T�C�Y�𒲐�����Bnw�i���j��nh�i�����j�𒲐����邾���ł���
%     scrsz = get(groot,'ScreenSize');
%     nw = 1;
%     nh =1.3;
%     maxW = scrsz(3);
%     maxH = scrsz(4);
%     p = get(gcf,'Position');
%     dw = p(3)-min(nw*p(3),maxW);
%     dh = p(4)-min(nh*p(4),maxH);
%     set(gcf,'Position',[p(1)+dw/2  p(2)+dh  min(nw*p(3),maxW)  min(nh*p(4),maxH)])
%     hold off
% end
% %% ���`�͈�20~200mV
% if IsNXYZ
%     L200mV = Mx{1,3};
%     L190mV = Mx{2,3};
%     L180mV = Mx{3,3};
%     L170mV = Mx{4,3};
%     L160mV = Mx{5,3};
%     L150mV = Mx{6,3};
%     L140mV = Mx{7,3};
%     L130mV = Mx{8,3};
%     L120mV = Mx{9,3};
%     L110mV = Mx{10,3};
%     L100mV = Mx{11,3};
%     L90mV = Mx{12,3};
%     L80mV = Mx{13,3};
%     L70mV = Mx{14,3};
%     L60mV = Mx{15,3};
%     L50mV = Mx{16,3};
%     L40mV = Mx{17,3};
%     L30mV = Mx{18,3};
%     L20mV = Mx{19,3};
%     H200mV = Mx{20,3};
%     H190mV = Mx{21,3};
%     H180mV = Mx{22,3};
%     H170mV = Mx{23,3};
%     H160mV = Mx{24,3};
%     H150mV = Mx{25,3};
%     H140mV = Mx{26,3};
%     H130mV = Mx{27,3};
%     H120mV = Mx{28,3};
%     H110mV = Mx{29,3};
%     H100mV = Mx{30,3};
%     H90mV = Mx{31,3};
%     H80mV = Mx{32,3};
%     H70mV = Mx{33,3};
%     H60mV = Mx{34,3};
%     H50mV = Mx{35,3};
%     H40mV = Mx{36,3};
%     H30mV = Mx{37,3};
%     H20mV = Mx{38,3};
% end
% %% 40,160Hz  �N���_
% L30mV = Mx{1,3};
% L29mV = Mx{2,3};
% L28mV = Mx{3,3};
% L27mV = Mx{4,3};
% L26mV = Mx{5,3};
% L25mV = Mx{6,3};
% L24mV = Mx{7,3};
% L23mV = Mx{8,3};
% L22mV = Mx{9,3};
% L21mV = Mx{10,3};
% L20mV = Mx{11,3};
% H25mV = Mx{12,3};
% H24mV = Mx{13,3};
% H23mV = Mx{14,3};
% H22mV = Mx{15,3};
% H21mV = Mx{16,3};
% H20mV = Mx{17,3};
% H19mV = Mx{18,3};
% H18mV = Mx{19,3};
% H17mV = Mx{20,3};
% H16mV = Mx{21,3};
% H15mV = Mx{21,3};