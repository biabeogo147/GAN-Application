import io
import torch
import base64
import numpy as np
import torchvision
from PIL import Image
from matplotlib import pyplot as plt
from transformers import AutoImageProcessor, AutoModelForImageClassification


def gen_image():
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    use_gpu = True if torch.cuda.is_available() else False
    model = torch.hub.load('facebookresearch/pytorch_GAN_zoo:hub',
                           'PGAN', model_name='celebAHQ-512',
                           pretrained=True, useGPU=use_gpu)

    print("Generating image...")

    gnet = model.netG.to(device)
    noise, _ = model.buildNoiseData(1)
    with torch.no_grad():
        image = gnet(noise)
    grid = torchvision.utils.make_grid(image.clamp(min=-1, max=1), scale_each=True, normalize=True)
    image = grid.permute(1, 2, 0).cpu().numpy()
    image = (image * 255).astype(np.uint8)

    print("Image generated")

    return image


def fake_detect(image):
    print("Detecting fake image...")

    processor = AutoImageProcessor.from_pretrained("prithivMLmods/Deep-Fake-Detector-Model")
    model = AutoModelForImageClassification.from_pretrained("prithivMLmods/Deep-Fake-Detector-Model")

    inputs = processor(images=image.convert("RGB"), return_tensors="pt")
    with torch.no_grad():
        outputs = model(**inputs)
        logits = outputs.logits
        print(logits)
        predicted_class = torch.argmax(logits, dim=1).item()
    label = model.config.id2label[predicted_class]

    print("Fake image detected")

    return label