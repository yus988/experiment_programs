% hsv_rec ����o�͂��ꂽ.csv�t�@�C�����A�}�[�J�[�̃C���f�b�N�X���Ƃɕ��בւ��Ċi�[����
% 1��ځF�L�^Index�i�����ԁj�A�Q��ځF�}�[�J�[�̃C���f�b�N�X�A�R��ځF�d�S��x���W�A�S��ځF�d�S��y���W�A5,6,7��ځF�}�[�J�[��h,s,v���ϒl�A�W��ځF�ʐ�

clear;
list = dir('*.csv');
numFiles = length(list);
Import = cell(numFiles,2);    
GraphCell = cell(numFiles, 2);

 for i = 1 : numFiles
      Import{i,2} = csvread(list(i).name, 0, 0);%csv�t�@�C���̓ǂݍ��� 
 end

 num_marker =  max(Import{1,2}(:, 2));
 
 for i = 1 :  num_marker%max = �}�[�J�[�̌�, ������I�͑����̍s�iImport�j������
        pickIndex = find( Import{1,2}(:,2) == i ); %
        for k = 1 : length(pickIndex)
            pick = pickIndex(k,1); %���f�[�^������o�������s�ԍ���pick�ɑ������(1�񂲂ƂɍX�V�����j
            if  Import{1, 2}(pick,8) < 100 % �}�[�J�[�̖ʐς����ȉ���������i�댟�o�j
                len = (num_marker - Import{1, 2}(pick,2)) - 1; % �댟�o������index number����index�̍ő���������l�B�C�������
                    for m =  0  :  len  % num_marker���ő�ɂȂ�܂ŁA���o�������index�̒l��1����
                             Import{1,2}(pick+1 + (len - m) ,2)  =  Import{1,2}(pick + (len - m), 2);
                    end
                    Import{1, 2}(pick,:) = []; %�����Ō댟�o�����C���f�b�N�X�������Ă���
            end
            Import{i, 1}(k,:) = Import{1,2}(pick,:);%���f�[�^��pick�s�ڂ��܂Ƃߗp�Z���s��ɑ��
        end          
 end

 %% �O���t��
 num_marker =  max(Import{1,2}(:, 2)); %�댟�o�̍s�������Ă���̂ŁA����Ő������}�[�J�[�̌���������
 Xg_movement = 0;
 Yg_movement = 0;
%  �}�[�J�[1��1�ɑ΂��ĉ�
 for i = 1 :  num_marker 
        [row_index, column_index] = size(Import{i,1}); % �eIndex���̃f�[�^�T�C�Y���擾
        GraphCell{i,1} = i;
        for k = 1 : row_index  - 1%�e�}�[�J�[�f�[�^�̍s���܂ŁB�e�v�Z�����͂����ɏ���
            % �t���[���Ԃ̈ʒu�̍�����ώZ����
            Xg_movement = Xg_movement +  abs( Import{i,1}(k+1,3) - Import{i,1}(k,3));
            Yg_movement = Yg_movement + abs (Import{i,1}(k+1,4) - Import{i,1}(k,4));
        end
        
%             GraphCell{i,2} = Xg_movement;
%             GraphCell{i,3} = Yg_movement;
        GraphCell{i,2} = (Xg_movement + Yg_movement) / row_index;
        Xg_movement = 0;
        Yg_movement = 0;
 end

GraphData = cell2mat(GraphCell) ;
%  stem(GraphData(:,1), GraphData(:,4))
  
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
