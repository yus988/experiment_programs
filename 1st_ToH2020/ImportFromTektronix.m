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
    Mx{i,2}(:,1) = -1 * ( Mx{i,1}(:,1) - mean(Mx{i,1}(:,1)) ) / V2G15; %下に引っ張った時を正に（標準では負）
    Mx{i,2}(:,2) = ( Mx{i,1}(:,2) - mean(Mx{i,1}(:,2)) ) / V2G15;
    Mx{i,2}(:,3) = ( Mx{i,1}(:,3) - mean(Mx{i,1}(:,3)) ) /V2G15;
    Mx{i,2}(:,4) = ( Mx{i,1}(:,4) - mean(Mx{i,1}(:,4)) );
    
    %  各ch記録結果のthdおよびharmfreqを記録する
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
    %          Mx{i,7} = thd(Mx{i,2}(:,3),Fs,nharm);
    %          Mx{i,8} = thd(Mx{i,2}(:,4),Fs,nharm);
    %3軸加速度を加算したものを記録
    %          Mx{i,2} = xyz;
    
    % timetable を各列ごとに追加
    Mx{i,3} = timetable(Mx{i,2}(:,1), Mx{i,2}(:,2), Mx{i,2}(:,3), Mx{i,2}(:,4),'SampleRate',Fs);
    Mx{i,3}.Properties.VariableNames{'Var1'}='T' ;
    Mx{i,3}.Properties.VariableNames{'Var2'}='x' ;
    Mx{i,3}.Properties.VariableNames{'Var3'}='y' ;
%     Mx{i,3}.Properties.VariableNames{'Var4'}='z' ;
    Mx{i,3}.Properties.VariableNames{'Var4'}='Input' ;
    %   各列を2回積分して変位に
    %         temp = 1/fs * cumtrapz(xyz);
    %         temp = temp - mean(temp);
    %         XYZ = 1/fs * cumtrapz(temp) * 9.80665 * 1e6;
    %         F(:,i) = XYZ;
end

%% 行末に説明を追加
Mx{i+1,1} = '生データ';
Mx{i+1,2} = 'オフセット除去後';
Mx{i+1,3} = 'タイムテーブル';
Mx{i+1,4} = '周波数';
Mx{i+1,5} = '測定電圧（計算後）';
if  IsNXYZ  % 第1chが加速度の場合（acc.txtがフォルダにあるとき）2,3chと同様1chにも加速度用の処理を行う
    for k=0:3
        Mx{i+1,6+3*k} = strcat('ch', num2str(k+1), 'Hz');
        Mx{i+1,7+3*k} = strcat('ch', num2str(k+1), 'RMS');
        Mx{i+1,8+3*k} = strcat('ch', num2str(k+1), 'THD');
    end
else
    for k=0:2
        Mx{i+1,6+3*k} = strcat('ch', num2str(k+1), 'Hz');
        Mx{i+1,7+3*k} = strcat('ch', num2str(k+1), 'RMS');
        Mx{i+1,8+3*k} = strcat('ch', num2str(k+1), 'THD');
    end
end
%% グラフ描画（AVG）
if isfile('awake.txt')
    close all;
    % RMS_Graph40Hz(:,1) = [7.176800356; 15.71619743; 27.86718577;45.15739219; 65.99584052; 88.54207624;
    x40_axis = RMS_Graph40Hz(:,1);
    x160_axis = RMS_Graph160Hz(:,1);
    ylimN_max = 2.1;
    xlim_min = 20;
    % グラフの色
    def_blue =[0 0.4470 0.7410];
    def_orange = [0.8500 0.3250 0.0980];
    % y_N40axis = 0 : 0.2 : max(RMS_Graph40Hz(:,2);
    x_label ='Input Voltage (Top: Displayed on Fuction Generator (mV), Bot: Motor Voltage (mV) )';
    y_Nlabel = 'Tension(N)';
    y_XYZlabel = 'Acceleralation(G)';
    %記録したデータが降順の場合、グラフ表示用に行列を並び替えて代入する
    AVGflag = dir('*.txt');
    if contains(pwd, "RVS") | contains(AVGflag.name, "AVG")
        RMS_Graph40Hz = flip(AVG40Hz);
        RMS_Graph160Hz = flip(AVG160Hz);
    else
        RMS_Graph40Hz = AVG40Hz;
        RMS_Graph160Hz = AVG160Hz;
    end
    % 40Hzのグラフ
    f1 = figure;
    hold on 
    % 張力のy軸を左に、加速度のy軸を右に
    yyaxis left
    ylabel(y_Nlabel);
    plot(x40_axis, RMS_Graph40Hz(:,2), '-o','MarkerFaceColor',def_blue,'MarkerSize',5)

    ylim([0 ylimN_max])
    %加速度のプロット（y軸右）
    yyaxis right
    plot(x40_axis, RMS_Graph40Hz(:,3),'-->','MarkerFaceColor',def_orange,'MarkerSize',5);
    plot(x40_axis, RMS_Graph40Hz(:,4),'-^','MarkerFaceColor',def_orange,'MarkerSize',5);
    plot( x40_axis, RMS_Graph40Hz(:,5),'-.d','MarkerFaceColor',def_orange,'MarkerSize',5);
    ylim([0 0.45])
    % x軸の範囲
    xlim([xlim_min max(RMS_Graph40Hz(:,1))] )
    xticks([20:10:200])

    % xtl = '\begin{tabular}{c} 20 \\ 30\end{tabular}'; 
    % set(gca,'XTick',[20:10:200],'XTickLabels',xtl,'TickLabelInterpreter','latex')
    set(gca,'FontSize',9,'XTickLabel',{'20 (0.25)','30 (0.37)','40 (0.50)','50 (0.63)',...
        '60 (0.76)','70 (0.88)','80 (1.01)','90 (1.14)','100 (1.27)',...
        '110 (1.39)','120 (1.52)','130 (1.64)','140 (1.77)','150 (1.89)',...
        '160 (2.01)','170 (2.13)','180 (2.25)','190 (2.37)','200 (2.49)'});
    fix_xticklabels();
    ylabel(y_XYZlabel);
    % legend('Tension','G_x','G_y','G_z','G_{xyz}');
    legend('Tension','G_x','G_y','G_z');
    xlabel(x_label)
    title('40Hz Result')
    %表示させるスクリーンサイズを調整する。nw（横）とnh（高さ）を調整するだけでおｋ
    scrsz = get(groot,'ScreenSize');
    nw = 2;
    nh =1.3;
    maxW = scrsz(3);
    maxH = scrsz(4);
    p = get(gcf,'Position');
    dw = p(3)-min(nw*p(3),maxW);
    dh = p(4)-min(nh*p(4),maxH);
    set(gcf,'Position',[p(1)+dw/2  p(2)+dh  min(nw*p(3),maxW)  min(nh*p(4),maxH)])
    hold off
    % 160Hzのグラフ
    f2 = figure;
    hold on 
    % 張力のy軸を左に、加速度のy軸を右に
    yyaxis left
    ylabel(y_Nlabel);
    plot(x160_axis, RMS_Graph160Hz(:,2), '-o','MarkerFaceColor',def_blue,'MarkerSize',5)
    ylim([0 ylimN_max])
    %加速度のプロット（y軸右）
    yyaxis right
    % plot( x_axis, RMS_Graph160Hz(:,3), x_axis, RMS_Graph160Hz(:,4), x_axis, RMS_Graph160Hz(:,5), x_axis, RMS_Graph160Hz(:,6) )
    plot(x160_axis, RMS_Graph160Hz(:,3),'-->','MarkerFaceColor',def_orange,'MarkerSize',5);
    plot(x160_axis, RMS_Graph160Hz(:,4),'-^','MarkerFaceColor',def_orange,'MarkerSize',5);
    plot( x160_axis, RMS_Graph160Hz(:,5),'-.d','MarkerFaceColor',def_orange,'MarkerSize',5);
    ylim([0 0.45])
    %160Hz 軸の範囲設定
    xlim([xlim_min max(RMS_Graph160Hz(:,1))] )
    xticks([20:10:200])
    set(gca,'FontSize',9,'XTickLabel',{'20 (0.25)','30 (0.35)','40 (0.47)','50 (0.60)',...
        '60 (0.72)','70 (0.83)','80 (0.95)','90 (1.06)','100 (1.18)',...
        '110 (1.29)','120 (1.41)','130 (1.52)','140 (1.64)','150 (1.74)',...
        '160 (1.85)','170 (1.96)','180 (2.07)','190 (2.19)','200 (2.29)'});
    fix_xticklabels();
    ylabel(y_XYZlabel);
    % legend('Tension','G_x','G_y','G_z','G_{xyz}');
    legend('Tension','G_x','G_y','G_z');
    xlabel(x_label)
    title('160Hz Result')
    %表示させるスクリーンサイズを調整する。nw（横）とnh（高さ）を調整するだけでおｋ
    scrsz = get(groot,'ScreenSize');
    nw = 2;
    nh =1.3;
    maxW = scrsz(3);
    maxH = scrsz(4);
    p = get(gcf,'Position');
    dw = p(3)-min(nw*p(3),maxW);
    dh = p(4)-min(nh*p(4),maxH);
    set(gcf,'Position',[p(1)+dw/2  p(2)+dh  min(nw*p(3),maxW)  min(nh*p(4),maxH)])

    hold off
end
%% グラフ描画（起動電圧）
% if contains(AwakeFlag.name, "awake")
if isfile('awake.txt')
    close all;
    
    RMS_Graph40Hz = flip(AVG40Hz);
    RMS_Graph160Hz = flip(AVG160Hz);
    
    x40_axis = RMS_Graph40Hz(:,1);
    x160_axis = RMS_Graph160Hz(:,1);
    ylimN_max = 2.1;
    xlim40_min = min(RMS_Graph40Hz(:,1)); 
    xlim40_max = max(RMS_Graph40Hz(:,1));
    xlim160_min = min(RMS_Graph160Hz(:,1));
    xlim160_max = max(RMS_Graph160Hz(:,1));
    % y_N40axis = 0 : 0.2 : max(RMS_Graph40Hz(:,2);
    x_label = 'Input Voltage (Top: Displayed on Fuction Generator (mV), Bot: Motor Voltage (mV) )';
    y_Nlabel = 'Tension(N)';

    % RMS_Graph40Hz = sortrows(RMS_Graph40Hz);
    % RMS_Graph160Hz = sortrows(RMS_Graph160Hz);

    %40Hzのグラフ
    f1 = figure;
    hold on 
    % 張力のy軸を左に、加速度のy軸を右に
    ylabel(y_Nlabel);
    plot(x40_axis, RMS_Graph40Hz(:,2),'-ro',x40_axis, RMS_Graph40Hz(:,3),'-r*', ...
        x40_axis, RMS_Graph40Hz(:,4),'-go',x40_axis, RMS_Graph40Hz(:,5),'-g*',...
        x40_axis, RMS_Graph40Hz(:,6),'-bo',x40_axis, RMS_Graph40Hz(:,7),'-b*');
    % x軸の範囲
    %     ylim([0 yN_max])
    xlim([xlim40_min xlim40_max] )
        set(gca,'FontSize',9,'XTickLabel',{'20 (253)','21 (265)','22 (278)','23 (289)',...
        '24 (300)','25 (312)','26 (323)','27 (338)','28 (350)','29 (362)','30 (376)'});
    fix_xticklabels();
    % legend('Tension','G_x','G_y','G_z','G_{xyz}');
    legend('1st','2nd','3rd','4th','5th','6th');
    xlabel(x_label)
    title('40Hz Result')
    
        %表示させるスクリーンサイズを調整する。nw（横）とnh（高さ）を調整するだけでおｋ
    scrsz = get(groot,'ScreenSize');
    nw = 1;
    nh =1.3;
    maxW = scrsz(3);
    maxH = scrsz(4);
    p = get(gcf,'Position');
    dw = p(3)-min(nw*p(3),maxW);
    dh = p(4)-min(nh*p(4),maxH);
    set(gcf,'Position',[p(1)+dw/2  p(2)+dh  min(nw*p(3),maxW)  min(nh*p(4),maxH)])

    
    hold off

    % 160Hzのグラフ
    f2 = figure;
    hold on 
    ylabel(y_Nlabel);
    plot(x160_axis, RMS_Graph160Hz(:,2),'-ro',x160_axis, RMS_Graph160Hz(:,3),'-r*', ...
        x160_axis, RMS_Graph160Hz(:,4),'-go',x160_axis, RMS_Graph160Hz(:,5),'-g*',...
        x160_axis, RMS_Graph160Hz(:,6),'-bo',x160_axis, RMS_Graph160Hz(:,7),'-b*');        % 軸の範囲設定
%     ylim([0 yN_max])
    xlim([xlim160_min xlim160_max] )
        set(gca,'FontSize',9,'XTickLabel',{'15 (200)','16 (212)','17 (222)','18 (234)',...
        '19 (244)','20 (254)','21 (265)','22 (277)','23 (288)','24 (299)','25 (311)'});
    fix_xticklabels();
    % legend('Tension','G_x','G_y','G_z','G_{xyz}');
    % legend('Tension','G_x','G_y','G_z','G_{xyz}');
    legend('1st','2nd','3rd','4th','5th','6th');
    xlabel(x_label)
    title('160Hz Result')
   
            %表示させるスクリーンサイズを調整する。nw（横）とnh（高さ）を調整するだけでおｋ
    scrsz = get(groot,'ScreenSize');
    nw = 1;
    nh =1.3;
    maxW = scrsz(3);
    maxH = scrsz(4);
    p = get(gcf,'Position');
    dw = p(3)-min(nw*p(3),maxW);
    dh = p(4)-min(nh*p(4),maxH);
    set(gcf,'Position',[p(1)+dw/2  p(2)+dh  min(nw*p(3),maxW)  min(nh*p(4),maxH)])
    hold off
end



%% step 解析用
TT1 = Mx{1,3};
TT2 = Mx{2,3};
TT3 = Mx{3,3};
TT4 = Mx{4,3};
TT5 = Mx{5,3};
TT6 = Mx{6,3};
time = transpose([0:0.0001:0.9999]); 
S = stepinfo(TT1.T,time);
%%

clf
% 入力、張力を0-1に正規化
% N_In = normalize(TT2.Input, 'range');
% N_T = normalize(TT2.T ,'range');
% N_In = normalize(TT3.Input, 'range');
% N_T = normalize(TT3.T ,'range');
N_In = normalize(TT6.Input, 'range');
N_T = normalize(TT6.T ,'range');
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
idx_90p_T = idx_over90p_T(1,1);
idx_90p_In = idx_over90p_In(1,1);
Time_90p_T = (idx_90p_T-1)/10000;
Time_90p_In = (idx_90p_In-1)/10000;

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
plot(time,N_In,'p','MarkerIndices', [idx_1p_In idx_10p_In idx_90p_In],...
    'MarkerFaceColor','red',...
    'MarkerSize',10)
plot(time,N_T_final,'p','MarkerIndices', [idx_1p_T idx_10p_T idx_90p_T],...
    'MarkerFaceColor','red',...
    'MarkerSize',10)

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
hold off


%% 線形範囲20~200mV
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
%% 40,160Hz  起動点
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