# 動画からマーカの情報を抽出するプログラム。メイン
#
import cv2
import os
import numpy as np
import time

# 対象画像読み込み
# cap = cv2.imread("./media/exp_sample.png", cv2.IMREAD_COLOR)
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

def main():
    timeCount = 0
    radius = 10
    rectsize = 4
    # cap = cv2.VideoCapture('./media/C0076_Trim.mp4')  #動画の読み込み
    # cap = cv2.VideoCapture('./media/C0068.MP4')  #動画の読み込み
    cap = cv2.VideoCapture('./media/C0074_Trim.mp4')  # 動画の読み込み
    print(cap.get(cv2.CAP_PROP_FPS))
    print(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    assert cap.isOpened(), 'Failed to open video file.'
    savedata = []
    ret, img = cap.read()
    cv2.imwrite('./output/img.jpg', img)

    while ret:
        # height = img.shape[0]
        # width = img.shape[1]
        # print(timeCount)
        masked = color_detect(img)  # 緑色で二値化、白黒
        n, center, data = calc_max_point(masked)  # 各マスクの重心
        # print(n)
        # マーカーの数だけループ
        for i in range(0, n):
            # # 中心座標に赤丸を描く
            img_circle = cv2.circle(img, (int(center[i, 0]), int(center[i, 1])), radius, (0, 0, 255), 1)
            cv2.putText(img, "ID:" + str(i + 1), (int(center[i, 0]) - 30, int(
                center[i, 1]) + 70), cv2.FONT_HERSHEY_PLAIN, 2, (0, 255, 255))
            # # 対象範囲を切り出し
            boxFromX = int(center[i, 0]) - rectsize * radius  # 対象範囲開始位置 X座標
            boxFromY = int(center[i, 1]) - rectsize * radius  # 対象範囲開始位置 Y座標
            boxToX = int(center[i, 0]) + rectsize * radius  # 対象範囲終了位置 X座標
            boxToY = int(center[i, 1]) + rectsize * radius  # 対象範囲終了位置 Y座標
            # y:y+h, x:x+w　の順で設定
            maskedBox = masked[boxFromY:boxToY, boxFromX:boxToX]
            imgBox = img[boxFromY:boxToY, boxFromX:boxToX]
            imgBoxHsv = cv2.cvtColor(imgBox, cv2.COLOR_RGB2HSV)
            # 範囲の矩形を表示
            cv2.rectangle(img, (boxFromX, boxFromY),
                          (boxToX, boxToY), (0, 0, 255))
            pts = np.where(maskedBox == 255)  # 2値化された白部分の配列インデックスを抽出
            # ここで得られるインデックスは切り取ったmaskedBoxの中での話なので注意
            maxpts = len(pts[0])
            h, s, v = [], [], []
            # 一つのマーカ内のすべての画素に対するループ
            for k in range(0, maxpts):
                h.append(imgBoxHsv[pts[0][k], pts[1][k]][0])
                s.append(imgBoxHsv[pts[0][k], pts[1][k]][1])
                v.append(imgBoxHsv[pts[0][k], pts[1][k]][2])

            # 重心位置、hsvの値を保存用配列に格納
            # 1列目：記録Index（≒時間）、２列目：マーカーのインデックス、３列目：重心のx座標、４列目：重心のy座標、5,6,7列目：マーカーのh,s,v平均値、８列目：面積
            savedata.append([timeCount, i+1, center[i, 0], center[i, 1], np.mean(h),
                             np.mean(s), np.mean(v), data[i][4]])  # data[i][4]], マスクの面積

        timeCount += 1
        np.savetxt("./output/data.csv", np.array(savedata), delimiter=",")

        # cv2.imshow("Frame", img)
        cv2.imshow("Frame", img)

        # qキーが押されたら途中終了
        if cv2.waitKey(25) & 0xFF == ord('q'):
            break
        ret, img = cap.read()
    else:
        print('Finish to play video.')

    cap.release()
    cv2.destroyAllWindows()
if __name__ == '__main__':
    main()

# ------------------------------------------------------------
# for label, bin_img in bin_imgs.items():
#     _, contours, _ = cv2.findContours(
#         bin_img, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
#     # 輪郭を構成する頂点数で誤検出を除く。
#     contours = list(filter(lambda cnt: len(cnt) > 30, contours))
#     count = len(contours)

#     print('color: {}, conunt: {}'.format(label, count))

#     # 描画する。
#     for cnt in contours:
#         cnt = np.squeeze(cnt, axis=1)  # (N, 1, 2) -> (N, 2)
#         ax.add_patch(Polygon(cnt, fill=None, lw=2., color=label))
# plt.show()