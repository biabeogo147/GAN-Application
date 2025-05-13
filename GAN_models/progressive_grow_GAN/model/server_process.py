import io
import torch
import base64
import numpy as np
from PIL import Image
from transformers import AutoImageProcessor, AutoModelForImageClassification


def gen_image():
    use_gpu = True if torch.cuda.is_available() else False
    model = torch.hub.load('facebookresearch/pytorch_GAN_zoo:hub',
                           'PGAN', model_name='celebAHQ-512',
                           pretrained=True, useGPU=False)

    print("Generating image...")

    gnet = model.netG.to('cpu')
    noise, _ = model.buildNoiseData(1)
    with torch.no_grad():
        image = gnet(noise)
    image = image.to('cpu').detach().numpy()

    print("Image generated")

    image = image[0].transpose(1, 2, 0)  # Reshape to (512, 512, 3)
    image = (image * 255).astype(np.uint8)  # Scale to 0-255

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

