# 動画のノイズを除去するサンプルプログラム。綺麗にはなるが、元々画像用なので時間がかかりすぎる。

import numpy as np
import cv2
from matplotlib import pyplot as plt

cap = cv2.imread('./media/exp_sample.png')

# create a list of first 5 frames
img = [cap.read()[1] for i in range(5)] #xrangeは古いのでerror画出る

# convert all to grayscale
gray = [cv2.cvtColor(i, cv2.COLOR_BGR2GRAY) for i in img]

# convert all to float64
gray = [np.float64(i) for i in gray]

# create a noise of variance 25
noise = np.random.randn(*gray[1].shape)*10

# Add this noise to images
noisy = [i+noise for i in gray]

# Convert back to uint8
noisy = [np.uint8(np.clip(i,0,255)) for i in noisy]

# Denoise 3rd frame considering all the 5 frames
dst = cv2.fastNlMeansDenoisingMulti(noisy, 2, 5, None, 4, 7, 35)

plt.subplot(131),plt.imshow(gray[2],'gray')
plt.subplot(132),plt.imshow(noisy[2],'gray')
plt.subplot(133),plt.imshow(dst,'gray')
plt.show()

# -*- coding: utf-8 -*-


# import cv2
# import numpy as np
# import time


# def main():
#     # データ格納用のリスト
#     savedata = []

#     # Path = 'D:\Dropbox\■実験関連\★実験データ\10.6\C0076.MP4'
#     # カメラのキャプチャ
#     # cap = cv2.VideoCapture(0)
#     cap = cv2.VideoCapture('./media/C0076.MP4') #動画の読み込み

#     # 開始時間
#     start = time.time()

#     while(cap.isOpened()):
#         # フレームを取得
#         ret, frame = cap.read()
#         height = frame.shape[0]
#         width = frame.shape[1]

#         filtered = cv2.fastNlMeansDenoisingColored(frame,None,10,10,7,21)

#         # ウィンドウ表示19201080
#         window_width = int(width/2)
#         window_height = int(height/2)

#         resized_frame = cv2.resize(frame,(window_width, window_height))
#         resized_mask = cv2.resize(filtered,(window_width, window_height))

#         cv2.namedWindow("Mask", cv2.WINDOW_KEEPRATIO | cv2.WINDOW_NORMAL)
#         cv2.imshow("Frame", resized_frame)
#         cv2.imshow("Mask", resized_mask)

#         cv2.resizeWindow("Frame", window_width, window_height)
#         cv2.resizeWindow("Mask", window_width, window_height)


#         # qキーが押されたら途中終了
#         if cv2.waitKey(25) & 0xFF == ord('q'):
#             break

#     # CSVファイルに保存

#     # キャプチャ解放・ウィンドウ廃棄
#     cap.release()
#     cv2.destroyAllWindows()


# if __name__ == '__main__':
#     main()