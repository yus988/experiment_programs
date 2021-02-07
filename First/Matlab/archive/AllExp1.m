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
%実験ごとのIndexの違い
EnvDelayIndex = 6;
AmpDifIndex = 5;
vibType = 0; % Vibration type
%データ格納セルの1列目に行の名前付け
    Mx{1,1} = "ImportData";
    for k = 0 : 6
          Mx{k+2,1} = k;
    end

%Indexごとの行列の抜き出し
    for i = 2:numFiles+1
%       [row, colmun] = size(list(i))
      Mx{1,i}= csvread(list(i-1).name,1,0);%csvファイルの2行目から読み込み（数値のみしか読めない）   
      % 0から取り込んだindex列の最大値まで
      for indexNum = 0:max(Mx{1,i}(:,2)) 
          pickIndex = find(Mx{1,i}(:,2) == indexNum); %IndexNum(0~5,6)と同じ行番号を抜き出し 
           
          for k = 1 : length(pickIndex)
            pick = pickIndex(k,1); %元データから取り出したい行番号をpickに代入する(1回ごとに更新される）
            Mx{indexNum + 2, i}(k,:) = Mx{1,i}(pick,:);%元データのpick行目をまとめ用セル行列に代入
          end          
      end      
    end
IndexMax = max(Mx{1,2}(:,2)); 
GraphCell{2,1} = zeros(IndexMax, 6);
GraphCell{2,2} = zeros(IndexMax, 6);
GraphCell{2,3} = zeros(IndexMax, 6);
GraphCell{2,4} = zeros(IndexMax, 6);
    %グラフ化用にデータを整理
    for i = 1 : numFiles  % ここでのiはcsvファイルの数
        
      for indexNum = 0: max(Mx{1,i +1}(:,2)) %差分のIndex(0-5,6)ごとの処理
%各差分ごと（Ampdifが7:3の時、など）に仕訳した行列を代入
            IndexArray = Mx{indexNum + 2, i + 1}; 
%差分Indexの最大。主にAmpとEnvを区分するため
            IndexMax = max(Mx{1,i +1}(:,2)); 
%グラフ用セルに挿入
            GraphCell{1,i}(indexNum + 1, 1) = indexNum; %indexNumを挿入
            GraphCell{2,1}(indexNum + 1, 1) = indexNum; %indexNumを挿入 
            GraphCell{2,2}(indexNum + 1, 1) = indexNum; %indexNumを挿入  
            GraphCell{2,3}(indexNum + 1, 1) = indexNum; %indexNumを挿入  
            GraphCell{2,4}(indexNum + 1, 1) = indexNum; %indexNumを挿入  
            GraphCell{1,i}(indexNum + 1, 2) = mean(Mx{indexNum +2, i +1}(:,5)); %回答時間の平均値を挿入

%%%%%%%%%%%%%%%            
        for k = 1:length(Mx{2,i +1}(:,2))%対象の試行回数分,1行ずつの処理
            
%実験の種類によって成否の処理方法を変更
%EnvDelayの時
            if IndexMax == EnvDelayIndex
            VibTypeMax = 4;
                switch indexNum
%Indexが0,(max-1)のとき、答えが2（同時）でTrue、それ以外はFalse
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

%AmpDifの時
            elseif IndexMax == AmpDifIndex
%AmpDifIndexが0,(max-1)のとき、答えが2（同時）でTrue、それ以外はFalse
%160Hzの時は、max-1のときは答えが1（右）でTrueなことに注意（波形製作ミス）
     	 VibTypeMax = 2;
                switch indexNum
                    case {IndexMax}%パンニングが5-5の場合（160Hzは6-5で1が正解）
                        if IndexArray(k,1) == 0 && IndexArray(k,4) == 2  %40Hzの時に回答がsameの場合
                            TRUE = TRUE + 1;
                            elseif IndexArray(k,1) == 1 && IndexArray(k,4) == 1 %160Hzの時に回答が1(right)の場合
                                TRUE = TRUE + 1;   
                            else
                                FALSE = FALSE + 1;
                        end
%  :max(Mx{1,i +1}(:,2)) - 1
                    case {0,1,2,3,4}
                        if IndexArray(k,4) == 2                            
                               FALSE = FALSE + 1;
                           elseif IndexArray(k,3) == IndexArray(k,4)%左右が合っている場合
                                 TRUE = TRUE +1; 
                           else
                                REVERSE = REVERSE + 1;
                        end
                 end % switch
               
            end %elseif IndexMax == AmpDifIndex
            vibType = IndexArray(1,1); %毎回vibTypeをここで指定。GraphCellには入ってこない    
            GraphCell{1,i}(indexNum + 1, 3) = TRUE;
            GraphCell{1,i}(indexNum + 1, 4) = REVERSE;
            GraphCell{1,i}(indexNum + 1, 5) = FALSE;
            GraphCell{1,i}(indexNum + 1, 6) = vibType;
         end %%% for k
            vibType = IndexArray(1,1); %毎回vibTypeをここで指定。GraphCellには入ってこない   
            %全員分の値をvibTypeに応じて加算代入
            %先にCellに数値が入ってないとエラーが出る
            GraphCell{2,vibType+1}(indexNum + 1, 2)  = GraphCell{1,i}(indexNum + 1, 2) + GraphCell{2,vibType+1}(indexNum + 1, 2);        
            GraphCell{2,vibType+1}(indexNum + 1, 3)  = TRUE + GraphCell{2,vibType+1}(indexNum + 1, 3);
            GraphCell{2,vibType+1}(indexNum + 1, 4)  = REVERSE + GraphCell{2,vibType+1}(indexNum + 1, 4);
            GraphCell{2,vibType+1}(indexNum + 1, 5)  = FALSE + GraphCell{2,vibType+1}(indexNum + 1, 5);
            GraphCell{2,vibType+1}(indexNum + 1, 6)  = vibType;  
             %次のIndexに移る前に初期化         
            TRUE = 0;
            REVERSE = 0;
            FALSE = 0;   
   
%%%%%%%%%%%%% for numfiles        
      end
 
%% 

        GraphArray = GraphCell{1,i};
%%% グラフのタイトルおよび軸の命名  
%%EnvDelayの場合
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

%%% 軸ラベル
           Xtickslabel = ["1/2","3/8","1/4","1/8","1/16","1/32","0"];
%%AmpDifの場合           
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

%%　回答数の棒グラフ表示
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
        
        %%% 軸ラベル
        Xtickslabel = ["1/2","3/8","1/4","1/8","1/16","1/32","0"];
        %%AmpDifの場合
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
%%　正答率の棒グラフ表示
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

%%% 軸ラベル
           Xtickslabel = ["1/2","3/8","1/4","1/8","1/16","1/32","0"];
%%AmpDifの場合           
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