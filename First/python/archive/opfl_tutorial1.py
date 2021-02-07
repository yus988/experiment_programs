# オプティカルフロー。エッジ抽出をして、フレーム間の位置の差分から速度を出す。

import numpy as np 
import cv2

cap = cv2.VideoCapture('./media/C0074.MP4') #動画の読み込み
# cap = cv2.VideoCapture('./media/slow.flv') #動画の読み込み

# params for ShiTomasi corner detection
feature_params = dict(
    maxCorners = 100,
    qualityLevel = 0.1,
    minDistance = 5,
    blockSize = 10
)

# Parameters for lucas kanade optical flow
Ik_params = dict(
    winSize = (15,15),
    maxLevel = 2,
    criteria = (cv2.TERM_CRITERIA_EPS | cv2.TermCriteria_COUNT, 10, 0.03)
)

# Create some rondom colors
color = np.random.randint(0,255,(100,3))

# Take first frame and find corners in it
ret, old_frame = cap.read()
old_gray = cv2.cvtColor(old_frame, cv2.COLOR_BGR2GRAY) # 前のフレームをグレースケールに変更
p0 = cv2.goodFeaturesToTrack(old_gray, mask = None, **feature_params) # コーナーの検出

# Create a mask image for drawing purposes
mask = np.zeros_like(old_frame) # zeros_likeで元の配列と同じ形にして0を代入する。http://arduinopid.web.fc2.com/Q5-2.html

while(1):
    ret,frame = cap.read() # retはreturnの略。変数が関数の戻り値の場合に必要？
    frame_gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # calculate optical flow
    p1, st, err = cv2.calcOpticalFlowPyrLK(old_gray, frame_gray, p0, None, **Ik_params)

    # Select good points
    good_new = p1[st==1]
    good_old = p0[st==1]

    # draw the tracks
    for i,(new, old) in enumerate(zip(good_new,good_old)):
        a,b = new.ravel()
        c,d = old.ravel()
        mask = cv2.line(mask, (a,b),(c,d), color[i].tolist(), 2)
        frame = cv2.circle(frame, (a,b), 5, color[i].tolist(), -1)
    img = cv2.add(frame, mask)

    cv2.imshow('frame', img)
    if cv2.waitKey(25) & 0xFF == ord('q'):
            break

    # Now update the previous frame and previous points
    old_gray = frame_gray.copy()
    p0 = good_new.reshape(-1,1,2)

cv2.destroyAllWindows()
cap.release()