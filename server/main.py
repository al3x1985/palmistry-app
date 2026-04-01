from fastapi import FastAPI

app = FastAPI(title="Palmistry CV Pipeline", version="1.0.0")

@app.get("/health")
async def health():
    return {"status": "ok"}
