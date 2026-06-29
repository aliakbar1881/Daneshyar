import asyncio
from datetime import datetime, timedelta
from typing import Dict, List
import arxiv

# ------------------------------------------------------------------
# Global rate limiter: ensures at least 3 seconds between requests
# ------------------------------------------------------------------
_last_request_time = 0
_request_lock = asyncio.Lock()

async def _wait_for_rate_limit():
    """Wait if necessary to ensure 3 seconds between API calls"""
    global _last_request_time
    async with _request_lock:
        now = asyncio.get_event_loop().time()
        elapsed = now - _last_request_time
        if elapsed < 3.0:
            await asyncio.sleep(3.0 - elapsed)
        _last_request_time = asyncio.get_event_loop().time()

# ------------------------------------------------------------------
# Core search functions
# ------------------------------------------------------------------
async def search_arxiv(query: str, limit: int = 20) -> List[Dict]:
    await _wait_for_rate_limit()
    client = arxiv.Client(delay_seconds=0, num_retries=0)
    search = arxiv.Search(
        query=query, max_results=limit, sort_by=arxiv.SortCriterion.SubmittedDate
    )
    loop = asyncio.get_event_loop()
    papers = []
    try:
        for result in await loop.run_in_executor(None, lambda: list(client.results(search))):
            papers.append({
                "id": result.entry_id.split("/")[-1],
                "title": result.title,
                "authors": [a.name for a in result.authors],
                "year": result.published.year,
                "abstract": result.summary,
                "pdf_url": result.pdf_url,
            })
    except arxiv.HTTPError as e:
        if e.status == 429:
            print(f"⚠️ Rate limit (429) for '{query}'. Retry later.")
        raise
    return papers

async def fetch_paper_by_id(paper_id: str) -> Dict:
    await _wait_for_rate_limit()
    clean_id = paper_id.split("v")[0]
    client = arxiv.Client(delay_seconds=0, num_retries=0)
    search = arxiv.Search(id_list=[clean_id])
    loop = asyncio.get_event_loop()
    try:
        results = await loop.run_in_executor(None, lambda: list(client.results(search)))
        if not results:
            raise ValueError(f"Paper {paper_id} not found")
        paper = results[0]
        return {
            "id": paper_id,
            "title": paper.title,
            "authors": [a.name for a in paper.authors],
            "year": paper.published.year,
            "abstract": paper.summary,
            "pdf_url": paper.pdf_url,
            "references": [],
        }
    except arxiv.HTTPError as e:
        if e.status == 429:
            print(f"⚠️ Rate limit (429) for ID {paper_id}. Retry later.")
        raise

async def search_arxiv_last_24h(query: str, limit_per_query: int = 30, max_retries: int = 3) -> List[Dict]:
    """
    Search arXiv for papers from the last 7 days with global rate limiting
    and exponential backoff on 429 errors.
    """
    for attempt in range(max_retries):
        await _wait_for_rate_limit()
        client = arxiv.Client(delay_seconds=0, num_retries=0)
        since = datetime.now() - timedelta(days=7)   # last 7 days (safe margin)
        search = arxiv.Search(
            query=query,
            max_results=limit_per_query,
            sort_by=arxiv.SortCriterion.SubmittedDate,
            sort_order=arxiv.SortOrder.Descending,
        )
        papers = []
        loop = asyncio.get_event_loop()
        try:
            results = await loop.run_in_executor(None, lambda: list(client.results(search)))
            for result in results:
                if result.published.replace(tzinfo=None) >= since:
                    papers.append({
                        "id": result.entry_id.split("/")[-1],
                        "title": result.title,
                        "authors": [a.name for a in result.authors],
                        "year": result.published.year,
                        "abstract": result.summary,
                        "pdf_url": result.pdf_url,
                        "published": result.published.isoformat(),
                    })
            print(f"papers length: {len(papers)}")
            return papers
        except arxiv.HTTPError as e:
            if e.status == 429:
                wait = 2 ** attempt   # 1, 2, 4 seconds
                print(f"⚠️ 429 for '{query[:50]}'. Retry in {wait}s...")
                await asyncio.sleep(wait)
            else:
                raise
        except Exception as e:
            print(f"❌ Unexpected error for '{query[:50]}': {e}")
            if attempt == max_retries - 1:
                raise
            await asyncio.sleep(2 ** attempt)

    print(f"❌ Failed after {max_retries} retries for query '{query[:50]}'")
    return []