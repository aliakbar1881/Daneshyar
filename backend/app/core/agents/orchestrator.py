import asyncio

from app.core.agents.critic import deep_critic
from app.core.agents.gap_hunter import find_gaps
from app.core.agents.idea_gen import generate_cross_ideas
from app.core.agents.searcher import fetch_paper_by_id
from app.core.agents.summarizer import summarize
from app.core.agents.validator import credibility_score


async def analyze_paper(paper_id: str) -> dict:
    try:
        print("1")
        paper = await fetch_paper_by_id(paper_id)
        print("2")

        summary_task = summarize(paper["abstract"])
        critic_task = deep_critic(paper["title"], paper["abstract"])
        gaps_task = find_gaps(paper["abstract"])
        ideas_task = generate_cross_ideas(paper["title"], paper["abstract"])

        results = await asyncio.gather(
            summary_task, critic_task, gaps_task, ideas_task, return_exceptions=True
        )

        summary, critic, gaps, ideas = results

        if isinstance(summary, Exception):
            print(f"Summarize failed: {summary}")
            summary = "Summary not available"
        if isinstance(critic, Exception):
            print(f"Deep critic failed: {critic}")
            critic = {"assumptions": [], "weaknesses": []}
        if isinstance(gaps, Exception):
            print(f"Find gaps failed: {gaps}")
            gaps = []
        if isinstance(ideas, Exception):
            print(f"Generate ideas failed: {ideas}")
            ideas = []

        print("3+4+5+6 done concurrently")
        score = credibility_score(critic, citations=0)
        print("7")

        return {
            "id": paper_id,
            "title": paper["title"],
            "authors": paper["authors"],
            "year": paper["year"],
            "summary": summary,
            "hidden_assumptions": critic.get("assumptions", []),
            "weaknesses": critic.get("weaknesses", []),
            "research_gaps": gaps,
            "cross_ideas": ideas,
            "credibility_score": score,
            "pdf_url": paper["pdf_url"],
        }
    except Exception as e:
        print(f"Fatal error in analyze_paper: {e}")
        return {
            "id": paper_id,
            "title": "مقاله در دست بررسی (موقت)",
            "authors": ["در حال دریافت اطلاعات"],
            "year": 2024,
            "summary": "به دلیل ترافیک بالا یا مشکل موقت در سرور arXiv، تحلیل کامل مقاله در حال حاضر ممکن نیست. لطفاً چند دقیقه دیگر تلاش کنید.",
            "hidden_assumptions": ["داده موقت – لطفاً مجدد تلاش کنید"],
            "weaknesses": ["داده موقت – لطفاً مجدد تلاش کنید"],
            "research_gaps": ["داده موقت – لطفاً مجدد تلاش کنید"],
            "cross_ideas": ["داده موقت – لطفاً مجدد تلاش کنید"],
            "credibility_score": 50.0,
            "pdf_url": "",
        }
