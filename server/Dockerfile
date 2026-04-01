FROM python:3.12-slim
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends libglib2.0-0 && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
# Pre-download the MediaPipe hand landmarker model so there is no runtime latency
RUN python - <<'EOF'
import urllib.request, pathlib
url = ("https://storage.googleapis.com/mediapipe-models/"
       "hand_landmarker/hand_landmarker/float16/latest/hand_landmarker.task")
dest = pathlib.Path("cv_pipeline/hand_landmarker.task")
urllib.request.urlretrieve(url, dest)
print(f"Downloaded model ({dest.stat().st_size} bytes)")
EOF
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
