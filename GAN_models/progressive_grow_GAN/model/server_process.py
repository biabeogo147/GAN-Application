import PIL
import torch
from PIL import Image
from transformers import AutoImageProcessor, AutoModelForImageClassification


def gen_image():
    use_gpu = True if torch.cuda.is_available() else False
    model = torch.hub.load('facebookresearch/pytorch_GAN_zoo:hub',
                           'PGAN', model_name='celebAHQ-512',
                           pretrained=True, useGPU=use_gpu)
    gnet = model.netG.to('cuda')
    noise, _ = model.buildNoiseData(1)
    with torch.no_grad():
        image = gnet(noise)
    image = image.to('cpu')
    return Image.fromarray(image)


def fake_detect(image):
    processor = AutoImageProcessor.from_pretrained("prithivMLmods/Deep-Fake-Detector-Model")
    model = AutoModelForImageClassification.from_pretrained("prithivMLmods/Deep-Fake-Detector-Model")

    inputs = processor(images=image.convert("RGB"), return_tensors="pt")

    with torch.no_grad():
        outputs = model(**inputs)
        logits = outputs.logits
        predicted_class = torch.argmax(logits, dim=1).item()

    label = model.config.id2label[predicted_class]
    return label
