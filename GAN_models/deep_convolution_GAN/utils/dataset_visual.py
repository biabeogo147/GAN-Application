from utils.utils import *
from matplotlib import pyplot as plt

if __name__ == "__main__":
    dataloader = data_loader()

    # Plot some training images
    real_batch = next(iter(dataloader))
    plt.axis("off")
    plt.figure(figsize=(8, 8))
    plt.title("Training Images")
    plt.imshow(
        np.transpose(vutils.make_grid(real_batch[0].to(device)[:64], padding=2, normalize=True).cpu(), (1, 2, 0)))
    plt.show()
