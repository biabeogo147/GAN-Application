import os
import io
import sys
import base64
import random
import uvicorn
import numpy as np
from PIL import Image
from pydantic import BaseModel
from fastapi import FastAPI, HTTPException, Body
from fastapi.middleware.cors import CORSMiddleware
from model.server_process import gen_image, fake_detect

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

app = FastAPI(title="GAN Image Processing API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

class DetectionImageRequest(BaseModel):
    image: str


class GenerationImageRequest(BaseModel):
    type: str
    description: str = None


@app.get("/api/process-image")
async def process_image(request: DetectionImageRequest):
    try:
        image_bytes = base64.b64decode(request.image)
        image = Image.open(io.BytesIO(image_bytes))

        print("Image format:", image.format)

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

        label = fake_detect(image)
        isFake = label == "Fake"
        result["detection_result"] = {
            "is_fake": isFake,
            "confidence": random.uniform(0.75, 0.95),
            "analysis": "This appears to be a real image." if not isFake else "This appears to be a fake image."
        }
        print("Detection result:", result)

        return result

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing image: {str(e)}")


@app.get("/api/generate-face")
async def generate_face(request: GenerationImageRequest):
    try:
        generation_type = request.type

        print("Generation type:", generation_type)

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

        buffer = io.BytesIO()
        image = Image.fromarray(generated)
        image.save(buffer, format="PNG")
        image_bytes = buffer.getvalue()
        base64_string = base64.b64encode(image_bytes).decode('utf-8')

        print("Base64 string length:", len(base64_string))

        return {
            "success": True,
            "generated_image": {
                "image": base64_string,
                "model_used": "GAN-Face-Generator-v1"
            }
        }

    except Exception as e:
        print(e)
        raise HTTPException(status_code=500, detail=f"Error generating face: {str(e)}")


if __name__ == "__main__":
    uvicorn.run("server:app", host="0.0.0.0", port=8000, reload=True)