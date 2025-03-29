from model import Generator
from utils.utils import *


def inference():
    netG = Generator(ngpu).to(device)
    if os.path.exists(os.path.join(model_path, 'last.pt')):
        print("Loading checkpoint...")
        checkpoint = torch.load(os.path.join(model_path, 'last.pt'))
        netG.load_state_dict(checkpoint["model_state_dict_Generator"])
        print("Checkpoint loaded")

    fixed_noise = torch.randn(64, nz, 1, 1, device=device)
    fake = netG(fixed_noise).detach().cpu()
    plt.figure(figsize=(8, 8))
    plt.axis("off")
    plt.imshow(np.transpose(vutils.make_grid(fake, padding=2, normalize=True), (1, 2, 0)))
    plt.show()


if __name__ == '__main__':
    inference()
