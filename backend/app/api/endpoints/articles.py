from fastapi import APIRouter, Query
from app.core.agents.searcher import search_arxiv
from app.core.agents.orchestrator import analyze_paper

router = APIRouter()

@router.get("/articles")
async def get_articles(q: str = Query(...), limit: int = 20):
    # Otherwise, fallback to real arXiv search
    papers = await search_arxiv(q, limit)
    return papers

@router.get("/articles/{paper_id}")
async def get_article_detail(paper_id: str):
    print("reach here")
    return await analyze_paper(paper_id)