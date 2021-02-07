# 始めに開発していたプログラム。重心の位置を出す、二値化する、３窓出力するなど

# -*- coding: utf-8 -*-
import cv2
import numpy as np
import time

def color_tracking(img):

    s_min = 100 # satulartion、範囲が大きい→明るい方までカバー、0だとグレースケール
    v_min = 100 # value, 範囲が大きい→暗い方までカバー

    # HSV色空間に変換
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    # 緑HSVの値域1
    hsv_min = np.array([30,s_min,v_min])
    hsv_max = np.array([90,255,255])
    # 1 or 0 に変換,指定した範囲内で dst = cv2.inRange(src, lowerb, upperb[, dst])
    mask1 = cv2.inRange(hsv, hsv_min, hsv_max)

    # # 赤色のHSVの値域2
    # hsv_min = np.array([245,s_min,v_min])
    # hsv_max = np.array([255,255,255])
    # mask2 = cv2.inRange(hsv, hsv_min, hsv_max)
    
    # 2つのマスク画像を加算（255を跨げないので二つ用意している）
    # 跨ぐ必要が無い場合は一つでおk
    mask = mask1 # + mask2

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
    # ブロブ面積が最大のインデックス
    # max_index = np.argmax(data[:,4])

    # 最大面積をもつブロブの中心座標を返す
    # return center[max_index]

def main():
    # データ格納用のリスト
    savedata = []

    # Path = 'D:\Dropbox\■実験関連\★実験データ\10.6\C0076.MP4'
    # カメラのキャプチャ
    # cap = cv2.VideoCapture(0)
    cap = cv2.VideoCapture('./media/C0074_Trim.mp4') #動画の読み込み

    # 開始時間
    start = time.time()

    while(cap.isOpened()):
        # フレームを取得
        ret, frame = cap.read()
        height = frame.shape[0]
        width = frame.shape[1]
        frame_gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        # カラートラッキング, 2値化された画像データがmaskedに入る
        masked = color_tracking(frame)

        # 面積最大ブロブの中心座標(x, y)を取得
        # x, y = calc_max_point(masked)
        n, center = calc_max_point(masked)

        for i in range(0,n):
            # 経過時間, x, yをリストに追加
            # center[]は二次元配列、appendするときは要素一つずつ入れていく
            savedata.append([time.time() - start, center[i,0], center[i,1] ]) 
            
            # # 中心座標に赤丸を描く
            cv2.circle(frame, (int(center[i,0]), int(center[i,1])), 1, (0, 0, 255), 10)

        # ウィンドウ表示19201080
        window_width = int(width/2)
        window_height = int(height/2)

        resized_frame = cv2.resize(frame,(window_width, window_height))
        resized_mask = cv2.resize(frame_gray,(window_width, window_height))
        resized_gray = cv2.resize(masked,(window_width, window_height))

        cv2.namedWindow("Mask", cv2.WINDOW_KEEPRATIO | cv2.WINDOW_NORMAL)
        cv2.imshow("Frame", resized_frame)
        cv2.imshow("Mask", resized_mask)
        cv2.imshow("Gray", resized_gray)
        cv2.resizeWindow("Frame", window_width, window_height)
        cv2.resizeWindow("Mask", window_width, window_height)
        cv2.resizeWindow("Gray", window_width, window_height)

        # qキーが押されたら途中終了
        if cv2.waitKey(25) & 0xFF == ord('q'):
            break

    # CSVファイルに保存
    np.savetxt("data.csv", np.array(savedata), delimiter=",")

    # キャプチャ解放・ウィンドウ廃棄
    cap.release()
    cv2.destroyAllWindows()


if __name__ == '__main__':
    main()