%% 加速度データから3次元plotアニメーション

close all;
figure;
t = size(Mx{1,3});
len = t(1,1);
% for i = 1:len
%     comet3(Mx{1,3}(i,1),Mx{2,3}(i,1),Mx{3,3}(i,1));
% end

%% mcp3008 
% アニメーションさせる信号を選択
% 現状、mcp3008_importから読み込んだデータを想定
% 範囲抽出（timetable から抽出）
% min = 14498;
% max = 15454;
% 
% % 首
% x = Mx{1,3}(min:max,1);
% y = Mx{2,3}(min:max,1);
% z = Mx{3,3}(min:max,1);
% limin = -0.2; limax = 0.2;
% 
% % 主部（腕 or 脚）
% % x = Mx{4,3}(min:max,1);
% % y = Mx{5,3}(min:max,1);
% % z = Mx{6,3}(min:max,1);
% % limin = -1; limax = 1;
% 
% %  comet3(x,y,z);
%   plot3(x(1),y(1),z(1));
%   
%% tektronix
type = 3; % 1:首歩行、2:脚歩行 3:腕銃撃 4:首銃撃
min = 7772; %3.10
max = 8426; %3.36

x = Mx{type,1}(min:max,1);
y = Mx{type,1}(min:max,2);
z = Mx{type,1}(min:max,3);
limin = -2; limax = 2;

plot3(x(1),y(1),z(1));

%% 動画の準備
axis tight manual 
set(gca,'nextplot','replacechildren'); 
v = VideoWriter('plot3d.mp4', 'MPEG-4');
open(v);
% 一連のフレームを生成し、Figure からフレームを取得して、各フレームをファイルに書き込みます。

%%

%     plot3(Mx{1,3}(i,1),Mx{2,3}(i,1),Mx{3,3}(i,1));
h = animatedline;


xlim([limin limax]);
xlabel('x axis');
ylim([limin limax]);
ylabel('y axis');
zlim([limin limax]);
zlabel('z axis');
for k = 1:length(x)
    addpoints(h,x(k),y(k),z(k));
    drawnow 
    % 動画への書き込み
    frame = getframe(gcf);
    writeVideo(v,frame);
end

close(v);
%% 
% For faster rendering, add more than one point to the line each time through 
% the loop or use |drawnow limitrate|.
% 
% Query the points of the line.