from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.utils.llm_client import call_llm

router = APIRouter()

class TextRequest(BaseModel):
    text: str

@router.post("/analyze-text")
async def analyze_text(request: TextRequest):
    if not request.text:
        raise HTTPException(status_code=400, detail="متن نباید خالی باشد")
    prompt = f"""به عنوان یک تحلیلگر علمی، متن زیر را تحلیل کن و یک نظر مفید و کوتاه (حداکثر ۱۰۰ کلمه) به فارسی ارائه بده. متن:\n{request.text}"""
    try:
        comment = await call_llm(prompt, json_mode=False)
        return {"comment": comment}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))