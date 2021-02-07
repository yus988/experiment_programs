# 静止画を色を元に二値化し、重心の座標や面積などを記載した画像を出力するプログラム

import cv2
import numpy as np
import sys

def color_detect(img):

    s_min = 100  # satulartion、範囲が大きい→明るい方までカバー、0だとグレースケール
    v_min = 100  # value, 範囲が大きい→暗い方までカバー

    # HSV色空間に変換
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    # 緑HSVの値域1
    hsv_min = np.array([30, s_min, v_min])
    hsv_max = np.array([90, 255, 255])
    # 1 or 0 に変換,指定した範囲内で dst = cv2.inRange(src, lowerb, upperb[, dst])
    mask1 = cv2.inRange(hsv, hsv_min, hsv_max)

    # # 赤色のHSVの値域2
    # hsv_min = np.array([245,s_min,v_min])
    # hsv_max = np.array([255,255,255])
    # mask2 = cv2.inRange(hsv, hsv_min, hsv_max)

    # 2つのマスク画像を加算（255を跨げないので二つ用意している）
    # 跨ぐ必要が無い場合は一つでおk
    mask = mask1  # + mask2

    # 膨張・収縮処理で10ビットマップのノイズ低減
    kernel = np.ones((6, 6), np.uint8)
    mask = cv2.dilate(mask, kernel)
    mask = cv2.erode(mask, kernel)

    return mask
def calc_max_point(mask):
    if np.count_nonzero(mask) <= 0:
        return(-20, -20)

    # ラベリング処理
    label = cv2.connectedComponentsWithStats(mask)
    data = np.delete(label[2], 0, 0)
    # ブロブ情報を項目別に抽出
    # print (data[0][4])
    # for i in range(0, label[0] - 1):
    #     # print (data[i][4])
    #     if data[i][4] < 100:
    #         np.delete(label[0],i, axis=0)
    #         np.delete(label[1],i,axis=0)
    #         np.delete(label[2],i,axis=0)
    #         np.delete(label[3],i,axis=0)

    #         # bugCount += 1
    # n -= bugCount
    # data[i][4]
    n = label[0] - 1
    center = np.delete(label[3], 0, 0)

    # bugCount = 0

    # np.savetxt("labeling_data.csv", np.array(center), delimiter=",")
    return n, center, data
radius = [74,61,64,67,80,51]
# 画像の読み込み
img = cv2.imread('./output/img.jpg')
# 色に寄ってマスク
masked = color_detect(img)
n, center, data = calc_max_point(masked)  # 各マスクの重心

# オブジェクト情報を利用してラベリング結果を表示
for i in range(0, n):
    # # 中心座標に赤丸を描く
    img_circle = cv2.circle(img, (int(center[i, 0]), int(center[i, 1])), radius[i], (0, 0, 255), 1)
    cv2.putText(img, "ID:" + str(i + 1), (int(center[i, 0]) - 30, int(center[i, 1]) + 70), cv2.FONT_HERSHEY_PLAIN, 2, (0, 255, 255))
    
# 画像の保存
cv2.imwrite('./output/img_draw.jpg', img)