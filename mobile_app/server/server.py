from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import base64
import io
from PIL import Image
import uvicorn

app = FastAPI(title="GAN Image Processing API")

class ImageRequest(BaseModel):
    image: str  # Base64 encoded image

@app.post("/api/process-image")
async def process_image(request: ImageRequest):
    try:
        # Decode base64 image
        image_bytes = base64.b64decode(request.image)
        image = Image.open(io.BytesIO(image_bytes))

        # Here you would process the image with your GAN model
        # For now, we'll just return basic image info
        width, height = image.size
        format_name = image.format

        # Return results
        return {
            "success": True,
            "image_info": {
                "width": width,
                "height": height,
                "format": format_name
            },
            # You'll add your GAN processing results here
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing image: {str(e)}")

if __name__ == "__main__":
    uvicorn.run("server:app", host="0.0.0.0", port=8000, reload=True)