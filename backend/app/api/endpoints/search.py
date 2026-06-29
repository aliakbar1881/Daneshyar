from fastapi import APIRouter, Query
from app.core.agents.searcher import search_arxiv

router = APIRouter(prefix="/search", tags=["search"])

@router.get("/api/search")
async def search_papers(
    q: str = Query(..., description="کوئری جستجو"),
    field: str = Query("", description="فیلتر حوزه (اختیاری)"),
    year_from: int = Query(1900, description="از سال"),
    year_to: int = Query(2025, description="تا سال")
):
    # در حال حاضر از arXiv استفاده می‌کنیم، فیلتر سال و حوزه ساده
    papers = await search_arxiv(q, limit=30)
    # اعمال فیلتر سال
    papers = [p for p in papers if year_from <= p["year"] <= year_to]
    return papers
