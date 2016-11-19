# Load Libraries
import scipy.io as io   # For mat files
import os               # For directory stuff
import re               # For finding file types
import numpy as np      # For array stuff (ndarray)
import tflearn          # For high level TensorFlow 

# Get data from mat files
files = os.listdir('./eeg/train_1/')
neg_vector = []
pos_vector = []

data = io.loadmat('./fft/data.mat')
labels = io.loadmat('./fft/labels.mat')

X = data['fft_plot'][2, :]
Y = labels['label'][2, :]

print(Y.shape)

X = np.reshape(X, (-1, 4, 4))
Y = np.reshape(Y, (-1, 1))

print(Y.shape)

net = tflearn.input_data(shape=[None, 4, 4])
net = tflearn.lstm(net, 128, return_seq=True)
net = tflearn.lstm(net, 128)
net = tflearn.fully_connected(net, 1, activation='linear')
net = tflearn.regression(net, optimizer='adam',
                         loss='categorical_crossentropy', name="output1", learning_rate=0.0001)
model = tflearn.DNN(net, tensorboard_verbose=2)
model.fit(X, Y, n_epoch=1, validation_set=0.2, show_metric=True,
          snapshot_step=1)

