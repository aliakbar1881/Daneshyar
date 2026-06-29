from fastapi import APIRouter
from pydantic import BaseModel
from typing import List, Dict

router = APIRouter(prefix="/user", tags=["user"])

# ذخیره موقت در حافظه (در تولید از پایگاه داده استفاده کنید)
saved_articles: Dict[str, List[str]] = {}
reviews: Dict[str, List[dict]] = {}

class SaveArticleRequest(BaseModel):
    user_id: str
    article_id: str

@router.post("/save")
async def save_article(req: SaveArticleRequest):
    if req.user_id not in saved_articles:
        saved_articles[req.user_id] = []
    if req.article_id not in saved_articles[req.user_id]:
        saved_articles[req.user_id].append(req.article_id)
    return {"status": "saved"}

@router.delete("/save")
async def unsave_article(req: SaveArticleRequest):
    if req.user_id in saved_articles and req.article_id in saved_articles[req.user_id]:
        saved_articles[req.user_id].remove(req.article_id)
    return {"status": "removed"}

@router.get("/saved/{user_id}")
async def get_saved_articles(user_id: str):
    return {"article_ids": saved_articles.get(user_id, [])}
