clear;
list = dir('*.csv');
numFiles = length(list);
Mx = cell(numFiles,2);    
Fx = cell(numFiles,2);  
G = cell(numFiles,2);
GraphCell = cell(numFiles, 2);
% GraphCell{2,1} = zeros(10);
% GraphCell{2,2} = zeros(10);
TRUE = 0;
REVERSE = 0;
FALSE = 0;
%�������Ƃ�Index�̈Ⴂ
EnvDelayIndex = 6;
AmpDifIndex = 5;
vibType = 0; % Vibration type
%�f�[�^�i�[�Z����1��ڂɍs�̖��O�t��
    Mx{1,1} = "ImportData";
    for k = 0 : 6
          Mx{k+2,1} = k;
    end

%Index���Ƃ̍s��̔����o��
    for i = 2:numFiles+1
%       [row, colmun] = size(list(i))
      Mx{1,i}= csvread(list(i-1).name,1,0);%csv�t�@�C����2�s�ڂ���ǂݍ��݁i���l�݂̂����ǂ߂Ȃ��j   
      % 0�����荞��index��̍ő�l�܂�
      for indexNum = 0:max(Mx{1,i}(:,2)) 
          pickIndex = find(Mx{1,i}(:,2) == indexNum); %IndexNum(0~5,6)�Ɠ����s�ԍ��𔲂��o�� 
           
          for k = 1 : length(pickIndex)
            pick = pickIndex(k,1); %���f�[�^������o�������s�ԍ���pick�ɑ������(1�񂲂ƂɍX�V�����j
            Mx{indexNum + 2, i}(k,:) = Mx{1,i}(pick,:);%���f�[�^��pick�s�ڂ��܂Ƃߗp�Z���s��ɑ��
          end          
      end      
    end
IndexMax = max(Mx{1,2}(:,2)); 
GraphCell{2,1} = zeros(IndexMax, 6);
GraphCell{2,2} = zeros(IndexMax, 6);
GraphCell{2,3} = zeros(IndexMax, 6);
GraphCell{2,4} = zeros(IndexMax, 6);
    %�O���t���p�Ƀf�[�^�𐮗�
    for i = 1 : numFiles  % �����ł�i��csv�t�@�C���̐�
        
      for indexNum = 0: max(Mx{1,i +1}(:,2)) %������Index(0-5,6)���Ƃ̏���
%�e�������ƁiAmpdif��7:3�̎��A�Ȃǁj�Ɏd�󂵂��s�����
            IndexArray = Mx{indexNum + 2, i + 1}; 
%����Index�̍ő�B���Amp��Env���敪���邽��
            IndexMax = max(Mx{1,i +1}(:,2)); 
%�O���t�p�Z���ɑ}��
            GraphCell{1,i}(indexNum + 1, 1) = indexNum; %indexNum��}��
            GraphCell{2,1}(indexNum + 1, 1) = indexNum; %indexNum��}�� 
            GraphCell{2,2}(indexNum + 1, 1) = indexNum; %indexNum��}��  
            GraphCell{2,3}(indexNum + 1, 1) = indexNum; %indexNum��}��  
            GraphCell{2,4}(indexNum + 1, 1) = indexNum; %indexNum��}��  
            GraphCell{1,i}(indexNum + 1, 2) = mean(Mx{indexNum +2, i +1}(:,5)); %�񓚎��Ԃ̕��ϒl��}��

%%%%%%%%%%%%%%%            
        for k = 1:length(Mx{2,i +1}(:,2))%�Ώۂ̎��s�񐔕�,1�s���̏���
            
%�����̎�ނɂ���Đ��ۂ̏������@��ύX
%EnvDelay�̎�
            if IndexMax == EnvDelayIndex
            VibTypeMax = 4;
                switch indexNum
%Index��0,(max-1)�̂Ƃ��A������2�i�����j��True�A����ȊO��False
                    case {0, IndexMax}
                        if IndexArray(k,4) == 2
                            TRUE = TRUE + 1;
                        else
                            FALSE = FALSE + 1;
                        end
%  :max(Mx{1,i +1}(:,2)) - 1
                    case {1,2,3,4,5}
                        if IndexArray(k,4) == 2                            
                               FALSE = FALSE + 1;
                        elseif IndexArray(k,3) == IndexArray(k,4)
                                 TRUE = TRUE +1; 
                           else
                                REVERSE = REVERSE + 1;
                        end
                end % switch

%AmpDif�̎�
            elseif IndexMax == AmpDifIndex
%AmpDifIndex��0,(max-1)�̂Ƃ��A������2�i�����j��True�A����ȊO��False
%160Hz�̎��́Amax-1�̂Ƃ��͓�����1�i�E�j��True�Ȃ��Ƃɒ��Ӂi�g�`����~�X�j
     	 VibTypeMax = 2;
                switch indexNum
                    case {IndexMax}%�p���j���O��5-5�̏ꍇ�i160Hz��6-5��1�������j
                        if IndexArray(k,1) == 0 && IndexArray(k,4) == 2  %40Hz�̎��ɉ񓚂�same�̏ꍇ
                            TRUE = TRUE + 1;
                            elseif IndexArray(k,1) == 1 && IndexArray(k,4) == 1 %160Hz�̎��ɉ񓚂�1(right)�̏ꍇ
                                TRUE = TRUE + 1;   
                            else
                                FALSE = FALSE + 1;
                        end
%  :max(Mx{1,i +1}(:,2)) - 1
                    case {0,1,2,3,4}
                        if IndexArray(k,4) == 2                            
                               FALSE = FALSE + 1;
                           elseif IndexArray(k,3) == IndexArray(k,4)%���E�������Ă���ꍇ
                                 TRUE = TRUE +1; 
                           else
                                REVERSE = REVERSE + 1;
                        end
                 end % switch
               
            end %elseif IndexMax == AmpDifIndex
            vibType = IndexArray(1,1); %����vibType�������Ŏw��BGraphCell�ɂ͓����Ă��Ȃ�    
            GraphCell{1,i}(indexNum + 1, 3) = TRUE;
            GraphCell{1,i}(indexNum + 1, 4) = REVERSE;
            GraphCell{1,i}(indexNum + 1, 5) = FALSE;
            GraphCell{1,i}(indexNum + 1, 6) = vibType;
         end %%% for k
            vibType = IndexArray(1,1); %����vibType�������Ŏw��BGraphCell�ɂ͓����Ă��Ȃ�   
            %�S�����̒l��vibType�ɉ����ĉ��Z���
            %���Cell�ɐ��l�������ĂȂ��ƃG���[���o��
            GraphCell{2,vibType+1}(indexNum + 1, 2)  = GraphCell{1,i}(indexNum + 1, 2) + GraphCell{2,vibType+1}(indexNum + 1, 2);        
            GraphCell{2,vibType+1}(indexNum + 1, 3)  = TRUE + GraphCell{2,vibType+1}(indexNum + 1, 3);
            GraphCell{2,vibType+1}(indexNum + 1, 4)  = REVERSE + GraphCell{2,vibType+1}(indexNum + 1, 4);
            GraphCell{2,vibType+1}(indexNum + 1, 5)  = FALSE + GraphCell{2,vibType+1}(indexNum + 1, 5);
            GraphCell{2,vibType+1}(indexNum + 1, 6)  = vibType;  
             %����Index�Ɉڂ�O�ɏ�����         
            TRUE = 0;
            REVERSE = 0;
            FALSE = 0;   
   
%%%%%%%%%%%%% for numfiles        
      end
 
%% 

        GraphArray = GraphCell{1,i};
%%% �O���t�̃^�C�g������ю��̖���  
%%EnvDelay�̏ꍇ
    if IndexMax == EnvDelayIndex
    xlabelName = "EnvelopeDelay(times period)";


        switch vibType
            case 0
                graphtitle = "1-40Hz EnvDelay";
            case 1
                graphtitle = "1-160Hz EnvDelay";
            case 2
                graphtitle = "3-40Hz EnvDelay";
            case 3
                graphtitle = "3-160Hz EnvDelay";
        end

%%% �����x��
           Xtickslabel = ["1/2","3/8","1/4","1/8","1/16","1/32","0"];
%%AmpDif�̏ꍇ           
    elseif IndexMax == AmpDifIndex
    xlabelName = "Panning Rate (Strong : Weak)";     


        switch vibType
            case 0
                graphtitle = "40Hz AmpDif";
                Xtickslabel = ["10:0","9:1","8:2","7:3","6;4","5:5"];
            case 1
                graphtitle = "160Hz AmpDif";
                Xtickslabel = ["10:0","9:1","8:2","7:3","6;4","6:5"];
        end   
    end  %%if IndexMax == EnvDelayIndex             
%%%   

                x = GraphArray(:,1);
                Time = GraphArray(:,2);
                T = GraphArray(:,3);
                R = GraphArray(:,4);
                F = GraphArray(:,5);
                
                %subplot(numFiles,2,2*(vibType+1)-1)
                subplot(1,2,1)
                 hold on
                % yyaxis right
                
                b = bar(x,[T R F],0.4,'stacked','FaceColor','flat');
                b(1).FaceColor = 'r';
                b(2).FaceColor = 'm';
                b(3).FaceColor = 'b';
                xlabel(xlabelName)
                legend("TRUE", "REVERSE","FALSE");
                ylabel("Answer Result (times)")
                ylim([0 6])
                title(graphtitle + " Answer Rate");
                xticks(0:1:6)
                xticklabels(Xtickslabel)
                     
                hold off
                
                subplot(1,2,2)
                %subplot(numFiles,2,2*(vibType+1));
                
                bar(x,Time,0.4)
                xlabel(xlabelName)
                ylabel("Answer Time (sec)");
                ylim([0 10])
                title(graphtitle + " Answer Time");
                xticks(0:1:6)
                xticklabels(Xtickslabel)
                % xlim([0 6])
                % legend("AnserTime");
    end
    %% 
for g = 1 : VibTypeMax
            GraphCell{2,g}(:, 2)  =  GraphCell{2,g}(:, 2)  / (numFiles / VibTypeMax);
end
%% 
AnswerTimes = 54;

%%�@�񓚐��̖_�O���t�\��
for i = 1:VibTypeMax
    GraphArray = GraphCell{2,i};
    vibType = GraphArray(1,6);
    
    if IndexMax == EnvDelayIndex
        xlabelName = "EnvelopeDelay(times period)";
        switch vibType
            case 0
                graphtitle = "1-40Hz EnvDelay";
            case 1
                graphtitle = "1-160Hz EnvDelay";
            case 2
                graphtitle = "3-40Hz EnvDelay";
            case 3
                graphtitle = "3-160Hz EnvDelay";
        end
        
        %%% �����x��
        Xtickslabel = ["1/2","3/8","1/4","1/8","1/16","1/32","0"];
        %%AmpDif�̏ꍇ
    elseif IndexMax == AmpDifIndex
        xlabelName = "Panning Rate (Strong : Weak)";
        switch vibType
            case 0
                graphtitle = "40Hz AmpDif";
                Xtickslabel = ["10:0","9:1","8:2","7:3","6;4","5:5"];
            case 1
                graphtitle = "160Hz AmpDif";
                Xtickslabel = ["10:0","9:1","8:2","7:3","6;4","6:5"];
        end
    end  %%if IndexMax == EnvDelayIndex
    %%%
    
    x = GraphArray(:,1);
    Time = GraphArray(:,2);
    T = GraphArray(:,3);
    R = GraphArray(:,4);
    F = GraphArray(:,5);
    
    %subplot(numFiles,2,2*(vibType+1)-1)
    subplot(VibTypeMax, 2, 2*(vibType+1)-1)
    hold on
    % yyaxis right
    
    b = bar(x, [T R F], 0.4,'stacked','FaceColor','flat');
    b(1).FaceColor = 'r';
    b(2).FaceColor = 'm';
    b(3).FaceColor = 'b';
    xlabel(xlabelName)
    legend("TRUE", "REVERSE","FALSE");
    ylabel("Answer Times")
    ylim([0 AnswerTimes])
    title(graphtitle + " Answer Rate");
    xticks(0:1:6)
    xticklabels(Xtickslabel)
    
    hold off
    
    subplot(VibTypeMax, 2, 2*(vibType+1))
    %subplot(numFiles,2,2*(vibType+1));
    
    bar(x,Time,0.4)
    xlabel(xlabelName)
    ylabel("Answer Time (sec)");
    ylim([0 10])
    title(graphtitle + " Answer Time");
    xticks(0:1:6)
    xticklabels(Xtickslabel)
    % xlim([0 6])
    % legend("AnserTime");
end

%% 
clf
%%�@�������̖_�O���t�\��
for i = 1:VibTypeMax
        GraphArray = GraphCell{2,i};
        vibType = GraphArray(1,6);
        
         if IndexMax == EnvDelayIndex
    xlabelName = "EnvelopeDelay(times period)";
        switch vibType
            case 0
                graphtitle = "1-40Hz EnvDelay";
            case 1
                graphtitle = "1-160Hz EnvDelay";
            case 2
                graphtitle = "3-40Hz EnvDelay";
            case 3
                graphtitle = "3-160Hz EnvDelay";
        end

%%% �����x��
           Xtickslabel = ["1/2","3/8","1/4","1/8","1/16","1/32","0"];
%%AmpDif�̏ꍇ           
    elseif IndexMax == AmpDifIndex
    xlabelName = "Panning Rate (Strong : Weak)";     
        switch vibType
            case 0
                graphtitle = "40Hz AmpDif";
                Xtickslabel = ["10:0","9:1","8:2","7:3","6;4","5:5"];
            case 1
                graphtitle = "160Hz AmpDif";
                Xtickslabel = ["10:0","9:1","8:2","7:3","6;4","6:5"];
        end   
    end  %%if IndexMax == EnvDelayIndex             
%%%   

                x = GraphArray(:,1);
                Time = GraphArray(:,2);
                T = GraphArray(:,3)/ AnswerTimes * 100;
                R = GraphArray(:,4);
                F = GraphArray(:,5);
                
                %subplot(numFiles,2,2*(vibType+1)-1)
                subplot(VibTypeMax, 2, 2*(vibType+1)-1)
                 hold on
                % yyaxis right
                
                b = bar(x, T, 0.4,'stacked','FaceColor','flat');
                b(1).FaceColor = 'r';
%                 b(2).FaceColor = 'm';
%                 b(3).FaceColor = 'b';
                xlabel(xlabelName)
                legend("TRUE", "REVERSE","FALSE");
                ylabel("Answer Rate (%)")
                ylim([0 100])
                title(graphtitle + " Answer Rate");
                xticks(0:1:6)
                xticklabels(Xtickslabel)
                     
                hold off
                
                subplot(VibTypeMax, 2, 2*(vibType+1))
                %subplot(numFiles,2,2*(vibType+1));
                
                bar(x,Time,0.4)
                xlabel(xlabelName)
                ylabel("Answer Time (sec)");
                ylim([0 10])
                title(graphtitle + " Answer Time");
                xticks(0:1:6)
                xticklabels(Xtickslabel)
                % xlim([0 6])
                % legend("AnserTime");
end