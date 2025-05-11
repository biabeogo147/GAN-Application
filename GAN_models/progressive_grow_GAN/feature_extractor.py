import torch
import torchvision
from PIL import Image
from facenet_pytorch import MTCNN, InceptionResnetV1
from matplotlib import pyplot as plt

mtcnn = MTCNN(image_size=512, margin=0)
resnet = InceptionResnetV1(pretrained='vggface2').eval()




resnet.classify = True
img_probs = resnet(img_cropped.unsqueeze(0))

print(img_embedding.shape)
print(img_probs.shape)

# help(MTCNN)

use_gpu = True if torch.cuda.is_available() else False
model = torch.hub.load('facebookresearch/pytorch_GAN_zoo:hub',
                       'PGAN', model_name='celebAHQ-512',
                       pretrained=True, useGPU=use_gpu)
gnet = model.netG.to('cuda')
img_embedding = img_embedding.to('cuda')
with torch.no_grad():
    image = gnet(img_embedding)
image = image.to('cpu')
print(image.shape)
grid = torchvision.utils.make_grid(image.clamp(min=-1, max=1), scale_each=True, normalize=True)
plt.imshow(grid.permute(1, 2, 0).cpu().numpy())
plt.axis('off')
plt.show()