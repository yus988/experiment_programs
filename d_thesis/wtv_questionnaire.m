close all;clear;
% 1--8 jazz, 9--16 piano
% wtv hapt, wtv hapt, ...

% 行＝参加者No.（行1＝一人目、行2＝二人目…）
% 生の回答値
raw = readmatrix('raw.csv');
% 差分データ
diff = readmatrix('diff.csv');

% Jazz - Piano 比較用
trackDiff = zeros(10,8);
for i =1:8
    for subj = 1:10
        trackDiff(subj,i) = raw(subj,i) - raw(subj,i+8);
    end
end
%% 全体差分 wtv-hapt
<<<<<<< Updated upstream
% figureウィンドウを任意の場所に表示[xpos, ypos, width, height],左上が零点
figure('Position',[0 0 720 480])
data = diff;
=======
figure('Position',[0 -700 720 480])
% data = diff;
data  = trackDiff;
>>>>>>> Stashed changes
hold on
xl = repmat(1:size(data,2),size(data,1),1);
dotSize = .8;

boxplot(data,'Whisker',99,'Colors','k');

% beeswarm を使うため、24*6 を 144*1 に変形する
y = reshape(data,[size(data,1)*size(data,2),1]);
x = reshape(xl,[size(data,1)*size(data,2),1]);
cmap = repmat([0 0 0], size(data,2), 1);
beeswarm(x,y,'dot_size', dotSize,'colormap',cmap,...
'MarkerFaceAlpha',1,'MarkerEdgeColor','none'); 
% swarmchart(xl,data,[],...
%     'blue','filled', 'SizeData',15);
plot(1:size(data,2),mean(data),'+r', 'MarkerSize',12);
ylabel('Score difference')

% xticklabels(["Q1" "Q2" "Q3" "Q4" "Q5" "Q6"])
ax = gca; % current axes
ax.FontSize = 12;
ax.FontName = 'tahoma';

box off
hold off

%% raw 質問間にスペース

data = raw;
% %%%%% swarmplot を配置するための posX を作るパート %%%%%
init = 2; posX=zeros(1,12);
difS = 0.8; % グルーブ内の距離
difL = 1.4; % グループ間の距離
num = size(data,2);

for i =1:num
    if i == 1
        posX(1,i) = init;
    elseif rem(i,2)==0 % グループ間の場合
        posX(1,i)= posX(1,i-1)+difS;
    else
        posX(1,i)= posX(1,i-1)+difL;
    end
end 
% %%%%% posX パート終了 %%%%%
figure('Position',[0 -700 1080 540])
color_arr = repmat(["m" "r"],1,num/2);
boxplot(data,'Whisker',99,'Positions',posX,...
    'ColorGroup',color_arr,'BoxStyle','outline', ...
    'color','k');
hold on 
xl = repmat(posX,size(data,1),1);
% swarmchart(xl,data,[],...
%     'blue','filled','MarkerFaceAlpha',1,'MarkerEdgeAlpha',1);

y = reshape(data,[size(data,1)*size(data,2),1]);
x = reshape(xl,[size(data,1)*size(data,2),1]);
cmap = repmat([1 0 0; 0 0 1], 8, 1);
beeswarm(x,y,'dot_size', dotSize,'colormap',cmap,...
'MarkerFaceAlpha',1,'MarkerEdgeColor','none'); 

plot(posX,mean(data),'+r', 'MarkerSize',12);
ylabel('Score')
ax = gca; % current axes
ax.FontSize = 12;
ax.FontName = 'tahoma';
ylim([-5 5])
box off
hold off
%%  raw t検定
data = raw;
for i = 1:size(data,2)/2 % Q1--Q6
     [pVal(1,i), pVal(2,i)] = signrank(data(:,2*i-1));
end

[pVal(3,:), pVal(4,:)] = bonf_holm(pVal(1,:),0.05);

for i = 1:size(data,2) % Q1--Q6
     [rawpVal(1,i), rawpVal(2,i)] = signrank(data(:,i));
end



%% t検定
close all
% test1に判定したい列を入れればOK
% test1 = diff;

data = trackDiff;
for k= 1:size(data,2)
        [h,p] = kstest(data(:,k));
         pVal(k,1) = h;
         pVal(k,2) = p;
end

% [h,p] = kstest(ans)
% 
% muiscとhapで差があったかを検定
% ウィルコクソンの符号順位検定 対応のある比較
% https://jp.mathworks.com/help/stats/signrank.html#bti40ke-8
% 1=全体, 2=musicA, 3=musicB, 4=mz->hap, 5=hap->mz 
for i = 1:size(data,2) % Q1--Q6
     [pVal(i,3), pVal(i,4)] = ttest(data(:,i));
     [pVal(i,6), pVal(i,5)] = signrank(data(:,i));
end


%% 全体 raw
% figure('Position',[0 -700 1080 540])
% data = raw; % Q2まで
% boxplot(data,'Whisker',99,'Colors','k');
% hold on
% xl = repmat(1:size(data,2),size(data,1),1);
% dotSize = .8;
% 
% % beeswarm を使うため、10*16 を1列に変形する
% y = reshape(data,[size(data,1)*size(data,2),1]);
% x = reshape(xl,[size(data,1)*size(data,2),1]);
% cmap = repmat([1 0 0; 0 0 1], 8, 1);
% %  repmat([0 0 1],[8,1])
% beeswarm(x,y,'dot_size', dotSize,'colormap',cmap,...
% 'MarkerFaceAlpha',1,'MarkerEdgeColor','none'); 
% % swarmchart(xl,data,[],...
% %     'blue','filled','SizeData',15);
% plot(1:size(data,2),mean(data),'+r', 'MarkerSize',12);
% 
% % title('exp3 raw d1--d3');
% % xticklabels(["NT" "NT&Hap" "HapDir" "HapDirDist" ...
% %              "NT" "NT&Hap" "HapDir" "HapDirDist"]) % Q2まで
% % % ...             "NT" "NT&Hap" "HapDir" "HapDirDist"])
% ylabel('Score')
% ax = gca; % current axes
% ax.FontSize = 12;
% ax.FontName = 'tahoma';
% ylim([-5 5])
% box off
% hold off
