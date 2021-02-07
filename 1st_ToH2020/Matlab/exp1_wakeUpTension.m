clear
Fs = 1e4;%サンプル周波数
t = 0:1/Fs:1;
%加速度センサの感度
V2G6 = 0.206; %MMA7361L 6Gモード
V2G15 = 0.800; %MMA7361L 1.5Gモード
V2N = 0.01178; %力センサ5916
nharm = 6;%thdの高調波数
%10列2行のセルを作成。1列目にy軸加速度の行列、2列目に力センサ
%（できれば1-の連番にして一々ファイル名を変更しないでも良いようにしたい
list = dir('*.csv');
IsNXYZ = contains(pwd, "NXYZ"); %NXYZの測定の場合True
numFiles = length(list);
Mx = cell(numFiles,2);
% RMS_Graph40Hz = zeros(numFiles/2,5);
% RMS_Graph160Hz = zeros(numFiles/2,5);
% AVG40Hz = zeros(numFiles/2,5);
% AVG160Hz = zeros(numFiles/2,5);
xyz = 0;
%%
% データのインポートおよびラベル用データ生成
for i = 1:numFiles
    Mx{i,1}= csvread(list(i).name,21,1,[21,1,10020,4]);
    % オフセット除去（すべての要素から平均値を引く）
    Mx{i,2}(:,1) = -1 * ( Mx{i,1}(:,1) - mean(Mx{i,1}(:,1)) ) / V2N; %下に引っ張った時を正に（標準では負）
    Mx{i,2}(:,2) = -1 * ( Mx{i,1}(:,2) - mean(Mx{i,1}(:,2)) ) / V2G6;
    Mx{i,2}(:,3) = ( Mx{i,1}(:,3) - mean(Mx{i,1}(:,3)) ) / V2G6;
    Mx{i,2}(:,4) = -1 *  ( Mx{i,1}(:,4) - mean(Mx{i,1}(:,4)) );
  
    for k = 0:2
        [thd_db, harmpow, harmfreq] = thd(Mx{i,2}(:,1+k), Fs, nharm);
        %thd(Mx{8,2}(:,1), Fs, nharm); % 個別のTHDを見たいとき
        Mx{i,6+3*k} = harmfreq(1,1);
        Mx{i,7+3*k} = rms((Mx{i,2}(:,1+k)));
        Mx{i,8+3*k} = thd_db;
    end
    %入力電圧の周波数を取得し記録（harmfreqで高調波が分かる、その始めの値を利用)
    [thd_db, harmpow, harmfreq] = thd(Mx{i,1}(:,4), Fs, nharm);
    Mx{i,4} = harmfreq(1,1);
    
    % FGから入力電圧のVppを求める。2倍は負の値を考慮
    Vin = 2*sqrt(2)*rms((Mx{i,1}(:,4)));
    Mx{i,5} = Vin;
    Mx{i,9+3*k} = xyz;
    xyz = 0;

    % timetable を各列ごとに追加
    Mx{i,3} = timetable(Mx{i,2}(:,1), Mx{i,2}(:,2), Mx{i,2}(:,3), Mx{i,2}(:,4),'SampleRate',Fs);
    Mx{i,3}.Properties.VariableNames{'Var1'}='T' ;
    Mx{i,3}.Properties.VariableNames{'Var2'}='y' ;
    Mx{i,3}.Properties.VariableNames{'Var3'}='z' ;
    Mx{i,3}.Properties.VariableNames{'Var4'}='Input' ;
end

%% 行末に説明を追加
Mx{i+1,1} = '生データ';
Mx{i+1,2} = 'オフセット除去後';
Mx{i+1,3} = 'タイムテーブル';
Mx{i+1,4} = '周波数';
Mx{i+1,5} = '測定電圧（計算後）';

for k=0:2
    Mx{i+1,6+3*k} = strcat('ch', num2str(k+1), 'Hz');
    Mx{i+1,7+3*k} = strcat('ch', num2str(k+1), 'RMS');
    Mx{i+1,8+3*k} = strcat('ch', num2str(k+1), 'THD');
end
%% step 解析用
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
% 入力、張力を0-1に正規化
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
N_In = normalize(TT6.Input, 'range'); %論文で使用
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
% N_T(N_T == 1) % これだと、N_Tに1が存在するか否かを聞いている
% Tの最大値のindexを導出
idx_Tmax =  find(N_T > 0.9999);

% risetimeで1を最大とするため、Tが1を取ったindex以降の値を1に
for idx = 1:10000
    if idx > idx_Tmax
        N_T_fixed(idx, 1) = 1;
    end
end

N_T_final = normalize(N_T_fixed ,'range');

% 1%(0.01)を超えた点を抽出
idx_over1p_T = find(N_T_final >0.01);
idx_over1p_In = find(N_In >0.01);
idx_1p_T = idx_over1p_T(1,1);
idx_1p_In = idx_over1p_In(1,1);
Time_1p_T = (idx_1p_T-1)/10000;
Time_1p_In = (idx_1p_In-1)/10000;

% 10%(0.1)を超えた点を抽出
idx_over10p_T = find(N_T_final >0.1);
idx_over10p_In = find(N_In >0.1);
idx_10p_T = idx_over10p_T(1,1);
idx_10p_In = idx_over10p_In(1,1);
Time_10p_T = (idx_10p_T-1)/10000;
Time_10p_In = (idx_10p_In-1)/10000;

% 90%(0.9)を超えた点を抽出
idx_over90p_T = find(N_T_final >0.9);
idx_over90p_In = find(N_In >0.9);
% 上記は複数の値が得られるので、そのうち始めの値を取得
idx_90p_T = idx_over90p_T(1,1);
idx_90p_In = idx_over90p_In(1,1);
Time_90p_T = (idx_90p_T-1)/10000;
Time_90p_In = (idx_90p_In-1)/10000;
Time_100p_T = (idx_Tmax-1)/10000;

% 得られた結果（1%, 10%, 90%のdelay）をmsecで表示
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

% デバッグとして描画用
    % plot(N_T_final)
    % risetime(N_T_fixed,Fs);
    % risetime(N_In,Fs);

% risetimeを用いた場合（およそ10, 90%の値）
    % [R_In,  LTime_In,  UTime_In] = risetime(N_In, Fs);
    % % [R_T,  LTime_T,  UTime_T] = risetime(N_T_fixed ,Fs);
    % [R_T,  LTime_T,  UTime_T] = risetime(N_T_final ,Fs);
    % % risetimeで得られたx値（indexの中間もあり得る）より、該当のindexを特定（行列：1~, 秒数：0~なので+1する）
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
% グラフの描画
plot(time,N_In);
plot(time,N_T_final);
% 1%起動点
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


%% 描画調整
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



% % risetimeを用いた時の10%、90%の動画
% plot(time,N_In,'o','MarkerIndices', [idx_LTime_In idx_UTime_In] ,...
%     'MarkerFaceColor','red',...
%     'MarkerSize',10)
% 
% plot(time,N_T_final,'o','MarkerIndices', [idx_LTime_T idx_UTime_T],...
%     'MarkerFaceColor','red',...
%     'MarkerSize',10)


% 変化率が大きい点の抽出および描画
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
