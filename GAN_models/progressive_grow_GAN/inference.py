import os
import torch
import argparse
import numpy as np
from PIL import Image
from torchvision.transforms import ToTensor

from model import Generator, Discriminator
from torchvision.utils import save_image


def get_parser():
	parser = argparse.ArgumentParser()
	parser.add_argument('--seed', type=int, default= 0, help='Seed for generate images')
	parser.add_argument('--out_dir', type=str, default='./inference_output', help='Directory for the output images')
	parser.add_argument('--num_imgs', type=int, default=1, help='Number of images to generate')
	parser.add_argument('--weight', type=str, default="./weight", help='Generator weight')
	parser.add_argument('--out_res', type=int, default=128, help='The resolution of final output image')
	parser.add_argument('--cuda', action='store_true', help='Using GPU to train')
	parser.add_argument('--image', type=str, help='Path to the image to be used for feature extraction')
	return parser


def gen_image(out_dir: str, out_res: int, weight: str):
	G_net = Generator(latent_size, out_res).to(device)
	G_net.load_state_dict(torch.load(weight))

	# saved_state_dict = torch.load(opt.weight)
	# model_state_dict = G_net.state_dict()
	# filtered_state_dict = {k: v for k, v in saved_state_dict.items() if k in model_state_dict}
	# G_net.load_state_dict(filtered_state_dict, strict=False)

	G_net.depth = int(np.log2(out_res)) - 1
	noise = torch.randn(opt.num_imgs, latent_size, 1, 1, device=device)

	G_net.eval()
	with torch.no_grad():
		out_imgs = G_net(noise)
		save_image(out_imgs, f"./{out_dir}/out.png", normalize=True)


def extract_feature(img_res, weight: str, image: str):
	D_net = Discriminator(latent_size, img_res).to(device)

	saved_state_dict = torch.load(weight)
	model_state_dict = D_net.state_dict()
	filtered_state_dict = {k: v for k, v in saved_state_dict.items() if k in model_state_dict}

	# print(saved_state_dict)
	# print(model_state_dict)
	# print(filtered_state_dict)

	D_net.load_state_dict(filtered_state_dict, strict=False)
	D_net.depth = int(np.log2(img_res)) - 1

	x_rgb = Image.open(image).convert("RGB")
	x_rgb = ToTensor()(x_rgb).unsqueeze(0).to(device)

	x_rgb = D_net.fromRGBs[D_net.depth-1](x_rgb)
	x = D_net.current_net[D_net.depth-1](x_rgb)

	feature_map = x.cpu().detach().numpy()
	print(feature_map.shape)


if __name__ == '__main__':
	opt = get_parser().parse_args()

	if not os.path.exists(opt.out_dir):
		os.makedirs(opt.out_dir)
	device = torch.device('cuda:0' if (torch.cuda.is_available() and opt.cuda)  else 'cpu')
	latent_size = 512

	# gen_image(opt.out_dir, opt.out_res, opt.weight)
	extract_feature(opt.out_res, opt.weight, opt.image)















