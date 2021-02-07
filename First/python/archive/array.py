import numpy as np
a = np.arange(8).reshape(2, 2, 2)
np.save('output.npy', a)  # 保存

a = np.load('output.npy')  # 読み込み