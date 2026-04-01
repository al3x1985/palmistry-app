from fastapi import FastAPI, HTTPException
from cv_pipeline.models import AnalyzeRequest, PalmAnalysisResponse
from cv_pipeline.pipeline import analyze_palm

app = FastAPI(title="Palmistry CV Pipeline", version="1.0.0")

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.post("/analyze", response_model=PalmAnalysisResponse)
async def analyze(request: AnalyzeRequest):
    try:
        result = analyze_palm(request)
        return result
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {e}")
