import random

from fastapi import FastAPI, HTTPException, Body
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import base64
import io
from PIL import Image
import uvicorn
import numpy as np

from model.server_process import gen_image, fake_detect

app = FastAPI(title="GAN Image Processing API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

class ImageRequest(BaseModel):
    image: str  # Base64 encoded image
    mode: str = "detect"  # "detect" or "generate"


@app.post("/api/process-image")
async def process_image(request: ImageRequest):
    try:
        # Decode base64 image
        image_bytes = base64.b64decode(request.image)
        image = Image.open(io.BytesIO(image_bytes))

        # Get basic image info
        width, height = image.size
        format_name = image.format

        result = {
            "success": True,
            "image_info": {
                "width": width,
                "height": height,
                "format": format_name
            }
        }

        if request.mode == "detect":
            # Here you would add your actual GAN detection logic
            # For now, we'll return a placeholder
            result = fake_detect(image)
            isFake = result != "Fake"
            result["detection_result"] = {
                "is_fake": isFake,
                "confidence": random.uniform(0.6, 0.8) if isFake else random.uniform(0.1, 0.4),
                "analysis": "This appears to be a real image." if not isFake else "This appears to be a fake image."
            }

        return result

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing image: {str(e)}")


@app.post("/api/generate-face")
async def generate_face(request: dict = Body(...)):
    try:
        generation_type = request.get("type", "random")

        generated = None
        if generation_type == "random":
            generated = gen_image()
        elif generation_type == "text-to-image":
            description = request.get("description", "")
            if not description:
                raise HTTPException(status_code=400, detail="Description is required for text-to-image generation")
            # Use the description to guide your GAN model
            # For now, we'll create a placeholder based on the text
            # Placeholder: Create a colored image with some text
            img_array = np.ones((512, 512, 3), dtype=np.uint8) * 200
            generated = Image.fromarray(img_array)

        buffered = io.BytesIO()
        generated.save(buffered, format="PNG")
        generated_image = base64.b64encode(buffered.getvalue()).decode('utf-8')

        return {
            "success": True,
            "generated_image": {
                "image": generated_image,
                "model_used": "GAN-Face-Generator-v1"
            }
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating face: {str(e)}")


if __name__ == "__main__":
    uvicorn.run("server:app", host="0.0.0.0", port=8000, reload=True)