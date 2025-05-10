import torch
import torch.nn as nn
import torch.optim as optim
import torchvision.models as models
import torchvision.transforms as transforms
from PIL import Image
import matplotlib.pyplot as plt
import torchvision

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
use_gpu = torch.cuda.is_available()
model = torch.hub.load('facebookresearch/pytorch_GAN_zoo:hub', 'PGAN', model_name='celebAHQ-512', pretrained=True,
                       useGPU=use_gpu)
model.eval().to(device)

vgg16 = models.vgg16(pretrained=True).features.to(device).eval()

vgg_layers = {
    '3': 'relu1_2',
    '8': 'relu2_2',
    '15': 'relu3_3',
    '22': 'relu4_3'
}


class VGGFeatures(nn.Module):
    def __init__(self, vgg, layers):
        super(VGGFeatures, self).__init__()
        self.vgg = vgg
        self.layers = layers
        self.features = []

    def forward(self, x):
        self.features = []
        for name, layer in self.vgg._modules.items():
            x = layer(x)
            if name in self.layers:
                self.features.append(x)
        return self.features


vgg_features = VGGFeatures(vgg16, vgg_layers).to(device)

preprocess = transforms.Compose([
    transforms.Resize((512, 512)),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])


# Tải và tiền xử lý ảnh mục tiêu
def load_image(image_path):
    image = Image.open(image_path).convert('RGB')
    image = transforms.ToTensor()(image).unsqueeze(0).to(device)
    image = image * 2 - 1  # Chuyển sang [-1, 1] cho PGAN
    return image


target_img = load_image('path_to_your_image.jpg')  # Thay bằng đường dẫn ảnh của bạn
target_img_vgg = preprocess(target_img.clamp(min=-1, max=1) * 0.5 + 0.5)  # Chuẩn hóa cho VGG

# Khởi tạo vector nhiễu
noise = torch.randn(1, 512, requires_grad=True, device=device)
optimizer = optim.Adam([noise], lr=0.01)


# Hàm mất mát perceptual
def perceptual_loss(generated, target, vgg_model):
    gen_features = vgg_model(generated)
    target_features = vgg_model(target)
    loss = 0
    for gen_f, tgt_f in zip(gen_features, target_features):
        loss += ((gen_f - tgt_f) ** 2).mean()
    return loss


# Tối ưu hóa
num_iterations = 1000
mse_loss_fn = nn.MSELoss()

for i in range(num_iterations):
    optimizer.zero_grad()

    # Tạo ảnh từ vector nhiễu
    generated_img = model.test(noise)

    # Tính MSE loss
    mse_loss = mse_loss_fn(generated_img, target_img)

    # Tính perceptual loss
    generated_img_vgg = preprocess(generated_img.clamp(min=-1, max=1) * 0.5 + 0.5)
    perceptual = perceptual_loss(generated_img_vgg, target_img_vgg, vgg_features)

    # Tổng hợp loss
    total_loss = mse_loss + 0.1 * perceptual  # Điều chỉnh trọng số perceptual loss

    # Backpropagation
    total_loss.backward()
    optimizer.step()

    # In tiến trình
    if i % 100 == 0:
        print(
            f"Iteration {i}, Total Loss: {total_loss.item()}, MSE: {mse_loss.item()}, Perceptual: {perceptual.item()}")

# Tái tạo ảnh từ vector nhiễu đã tối ưu
with torch.no_grad():
    reconstructed_img = model.test(noise)

# Hiển thị kết quả
grid = torchvision.utils.make_grid(
    [target_img.clamp(min=-1, max=1), reconstructed_img.clamp(min=-1, max=1)],
    normalize=True, scale_each=True
)
plt.imshow(grid.permute(1, 2, 0).cpu().numpy())
plt.title("Target Image (Left) vs Reconstructed Image (Right)")
plt.show()