import os
import torch
import random
import argparse
import numpy as np
import torch.nn as nn
import torch.utils.data
import torch.nn.parallel
import torch.optim as optim
import matplotlib.pyplot as plt
from IPython.display import HTML
from tqdm.autonotebook import tqdm
import torchvision.utils as vutils
import torchvision.datasets as dset
from torch.utils.data import DataLoader
import matplotlib.animation as animation
import torchvision.transforms as transforms


manualSeed = 999
random.seed(manualSeed)
torch.manual_seed(manualSeed)
torch.use_deterministic_algorithms(True)

train_progress_path = 'train_progress'
dataroot = "../data/celeba"
model_path = 'models'

workers = 20
batch_size = 4096
image_size = 64
num_epochs = 1000
lr = 0.0002


# Number of channels in the training images. For color images this is 3
nc = 3

# Size of z latent vector (i.e. size of generator input)
nz = 100

# Size of feature maps in generator
ngf = 64

# Size of feature maps in discriminator
ndf = 64

# Beta1 hyperparameter for Adam optimizers
beta1 = 0.5

# Number of GPUs available. Use 0 for CPU mode.
ngpu = 1

device = torch.device("cuda:0" if (torch.cuda.is_available() and ngpu > 0) else "cpu")


def data_loader():
    dataset = dset.ImageFolder(root=dataroot,
                               transform=transforms.Compose([
                                   transforms.Resize(image_size),
                                   transforms.CenterCrop(image_size),
                                   transforms.ToTensor(),
                                   transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5)),
                               ]))
    dataloader = DataLoader(dataset, batch_size=batch_size,
                            shuffle=True, num_workers=workers)
    return dataloader
