from fastapi import APIRouter, HTTPException
from app.core.agents.searcher import search_arxiv
import random

router = APIRouter(prefix="/recommendations", tags=["recommendations"])

# برای سادگی از دیکشنری در حافظه استفاده می‌کنیم (در تولید از دیتابیس واقعی استفاده کنید)
user_saved_map = {}  # user_id -> list of article keywords

@router.get("/{user_id}")
async def get_recommendations(user_id: str, limit: int = 5):
    saved = user_saved_map.get(user_id, [])
    if not saved:
        # اگر کاربر مقاله‌ای ذخیره نکرده، بر اساس موضوعات عمومی پیشنهاد بده
        queries = ["machine learning", "cybersecurity", "control systems", "aerospace"]
        query = random.choice(queries)
    else:
        # از کلمات کلیدی مقالات ذخیره شده یک کوئری بساز
        query = " ".join(saved[:3])
    papers = await search_arxiv(query, limit=limit)
    return papers

@router.post("/save-keywords")
async def save_user_keywords(user_id: str, keywords: list):
    user_saved_map[user_id] = list(set(user_saved_map.get(user_id, []) + keywords))
    return {"status": "ok"}