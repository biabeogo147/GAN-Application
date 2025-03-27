import cv2
import os

image_dir = "train_progress"
num_images = 1001
fps = 100

sample_image_path = os.path.join(image_dir, "epoch_0.png")
sample_img = cv2.imread(sample_image_path)
if sample_img is None:
    raise FileNotFoundError("Không tìm thấy ảnh mẫu epoch_0.png")
height, width, channels = sample_img.shape

fourcc = cv2.VideoWriter_fourcc(*'mp4v')
out_video = cv2.VideoWriter('train_progress.mp4', fourcc, fps, (width, height))

for i in range(50):
    img_path = os.path.join(image_dir, f"epoch_{i}.png")
    img = cv2.imread(img_path)
    if img is None:
        continue
    for _ in range(20):
        out_video.write(img)

for i in range(50, num_images):
    img_path = os.path.join(image_dir, f"epoch_{i}.png")
    img = cv2.imread(img_path)
    if img is None:
        continue
    out_video.write(img)

out_video.release()
cv2.destroyAllWindows()

print("Done.")
