from fastapi import FastAPI, HTTPException, Body
from pydantic import BaseModel
import base64
import io
from PIL import Image
import uvicorn
import numpy as np

app = FastAPI(title="GAN Image Processing API")

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

        # Process based on mode
        if request.mode == "detect":
            # Here you would add your actual GAN detection logic
            # For now, we'll return a placeholder
            result["detection_result"] = {
                "is_fake": False,  # Replace with actual detection
                "confidence": 0.95,
                "analysis": "This appears to be a real image."
            }
        else:  # generate mode
            # Create a noisy version of the image as a placeholder for GAN generation
            # Convert PIL Image to numpy array
            img_array = np.array(image)

            # Add some noise and artistic effect
            noisy_img = img_array.copy()

            # Add random noise
            noise = np.random.normal(0, 25, img_array.shape).astype(np.uint8)
            noisy_img = np.clip(img_array + noise, 0, 255).astype(np.uint8)

            # Create a styled effect (simple color shift)
            noisy_img[:,:,0] = np.clip(noisy_img[:,:,0] * 1.2, 0, 255).astype(np.uint8)  # Enhance red

            # Convert back to PIL Image
            generated = Image.fromarray(noisy_img)

            # Convert to base64
            buffered = io.BytesIO()
            generated.save(buffered, format=format_name)
            generated_image = base64.b64encode(buffered.getvalue()).decode('utf-8')

            result["generated_image"] = {
                "image": generated_image,
                "model_used": "GAN-Model-v1"
            }

        return result

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing image: {str(e)}")

if __name__ == "__main__":
    uvicorn.run("server:app", host="0.0.0.0", port=8000, reload=True)