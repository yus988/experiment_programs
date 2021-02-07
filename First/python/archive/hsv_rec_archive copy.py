# 画像からhsvを出力するプログラム
import cv2
import os
import numpy as np
savedata = []
lst_intensities = []
# 対象画像読み込み
img = cv2.imread("./media/exp_sample.png", cv2.IMREAD_COLOR)
# img = cv2.imread("./media/sample.jpg", cv2.IMREAD_COLOR)
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

    # ブロブ情報を項目別に抽出
    n = label[0] - 1
    data = np.delete(label[2], 0, 0)
    center = np.delete(label[3], 0, 0)
    np.savetxt("labeling_data.csv", np.array(center), delimiter=",")
    return n, center

masked = color_detect(img) # 緑色で二値化、白黒
n, center = calc_max_point(masked)  # 各マスクの重心
# Access the image pixels and create a 1D numpy array then add to list
# print(center)
radius = 10
rectsize = 4

# for i in range(0, n):
for i in range(0,1):
    # 経過時間, x, yをリストに追加
    # data.append([time.time() - start, x, y])
    # center[]は二次元配列、appendするときは要素一つずつ入れていく
    # savedata.append([time.time() - start, center[i, 0], center[i, 1]])

    # # 中心座標に赤丸を描く
    # img_circle = cv2.circle(img, (int(center[i, 0]), int(center[i, 1])), radius, (0, 0, 255), 1)
    cv2.putText(img, "ID:" +str(i + 1), (int(center[i, 0]) -30, int(center[i, 1]) + 50), cv2.FONT_HERSHEY_PLAIN, 2, (0, 255, 255))
    # print(img_circle)

    # # 対象範囲を切り出し
    boxFromX = int(center[i, 0]) - rectsize * radius  # 対象範囲開始位置 X座標
    boxFromY = int(center[i, 1]) - rectsize * radius  # 対象範囲開始位置 Y座標
    boxToX = int(center[i, 0]) +  rectsize * radius  # 対象範囲終了位置 X座標
    boxToY = int(center[i, 1]) + rectsize * radius  # 対象範囲終了位置 Y座標
    # y:y+h, x:x+w　の順で設定
    maskedBox = masked[boxFromY:boxToY, boxFromX:boxToX]
    imgBox = img[boxFromY:boxToY, boxFromX:boxToX]
    imgBoxHsv = cv2.cvtColor(imgBox, cv2.COLOR_RGB2HSV) 
    # cv2.rectangle(img,(boxFromX,boxFromY), (boxToX,boxToY),(0, 0, 255))

    savedata = np.array(maskedBox)
    pts = np.where(maskedBox == 255)  # 2値化された白部分の配列インデックスを抽出
    # ここで得られるインデックスは切り取ったmaskedBoxの中での話なので注意

    # np.savetxt('out1.csv', savedata, delimiter=',')
    # np.savetxt('out2.csv', pts, delimiter=',')
    maxpts = len(pts[0])
    # hsv = []
    # hsv.append(imgBoxHsv[pts[0][0], pts[1][0]] [0])
    # hsv.append(imgBoxHsv[pts[0][1], pts[1][1]] [0])
    # print((pts[0][1],pts[1][1]))
    # print(np.mean(hsv))

    h = []
    s = []
    v = []

    for k in range(0, maxpts):
        h.append(imgBoxHsv[pts[0][k], pts[1][k]][0])
        s.append(imgBoxHsv[pts[0][k], pts[1][k]][1])
        v.append(imgBoxHsv[pts[0][k], pts[1][k]][2])
    

    print(h)
    print(np.mean(h))
    print(np.mean(s))
    print(np.mean(v))




        

    # print(maskedBox[x0[0], y0[0]])
    # print(maskedBox[0, 0])
    
    # print(imgBoxHsv[x0[0], y0[0]])
    # print(imgBoxHsv[0, 0])
    

    # print(x0[0])
    # print(y0[0])
    # imgBox = img_circle

    # # RGB平均値を出力
    # # flattenで一次元化しmeanで平均を取得
    # b = imgBox.T[0].flatten().mean()
    # g = imgBox.T[1].flatten().mean()
    # r = imgBox.T[2].flatten().mean()

    # # RGB平均値を取得
    # print("B: %.2f" % (b))
    # print("G: %.2f" % (g))
    # print("R: %.2f" % (r))

    # # BGRからHSVに変換
    # imgBoxHsv = cv2.cvtColor(imgBox, cv2.COLOR_RGB2HSV)

    # # HSV平均値を取得
    # # flattenで一次元化しmeanで平均を取得
    # h = imgBoxHsv.T[0].flatten().mean()
    # s = imgBoxHsv.T[1].flatten().mean()
    # v = imgBoxHsv.T[2].flatten().mean()


    # HSV平均値を出力
    # uHeは[0,179], Saturationは[0,255]，Valueは[0,255]
    # print("Hue: %.2f" % (h))
    # print("Salute: %.2f" % (s))
    # print("Value: %.2f" % (v))

# while(1):
#     cv2.imshow("img", img)
#     cv2.imshow("maskedbox", maskedBox)
#     cv2.imshow("imgBox", imgBox)

#     if cv2.waitKey(25) & 0xFF == ord('q'):
#             break

