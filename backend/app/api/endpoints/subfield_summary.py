import time
from typing import List

from app.core.agents.idea_gen import generate_cross_ideas
from app.core.agents.searcher import search_arxiv_last_24h
from app.services.cache import cache
from app.utils.llm_client import call_llm
from fastapi import APIRouter, Query

router = APIRouter()

MAPPING = {
    # AI
    "یادگیری ماشین": 'cat:cs.LG AND "machine learning"',
    "یادگیری عمیق": 'cat:cs.LG AND "deep learning" -machine',
    "پردازش زبان طبیعی": 'cat:cs.CL AND "natural language processing"',
    "بینایی کامپیوتر": 'cat:cs.CV AND "computer vision"',
    "یادگیری تقویتی": 'cat:cs.LG AND "reinforcement learning" -supervised',
    "سیستم‌های عامل (Agentic)": 'cat:cs.MA AND "multi-agent system"',
    "نظریه بازی‌ها": 'cat:cs.GT AND "game theory"',
    # Cyber
    "امنیت تهاجمی (Offensive)": 'cat:cs.CR AND "offensive security"',
    "امنیت تدافعی (Defensive)": 'cat:cs.CR AND "defensive security"',
    "ادله دیجیتال (Forensic)": 'cat:cs.CR AND "digital forensics"',
    "رمزنگاری": "cat:cs.CR AND cryptography -bitcoin",
    "امنیت شبکه": 'cat:cs.CR AND "network security"',
    "حملات سایبری و تحلیل بدافزار": 'cat:cs.CR AND "malware analysis"',
    # Telecom
    "مخابرات سیستم": 'cat:eess.SP AND "communication systems"',
    "مخابرات میدان": 'cat:eess.SP AND "field communications"',
    "مخابرات نوری": 'cat:eess.SP AND "optical communications"',
    "شبکه‌های بی‌سیم": 'cat:eess.SP AND "wireless networks"',
    "پردازش سیگنال مخابراتی": 'cat:eess.SP AND "signal processing"',
    # Electronics
    "مدار مجتمع": 'cat:cs.ET AND "integrated circuits"',
    "الکترونیک قدرت": 'cat:cs.ET AND "power electronics"',
    "مدارهای فرکانس بالا": 'cat:cs.ET AND "high frequency circuits"',
    "طراحی PCB": 'cat:cs.ET AND "PCB design"',
    "الکترونیک دیجیتال": 'cat:cs.ET AND "digital electronics"',
    # Mechanics
    "جامدات": 'cat:physics.class-ph AND "solid mechanics"',
    "سیالات": 'cat:physics.flu-dyn AND "fluid mechanics"',
    "دینامیک و ارتعاشات": 'cat:physics.class-ph AND "dynamics vibrations"',
    "طراحی اجزاء": 'cat:cs.RO AND "mechanical design"',
    "ترمودینامیک": "cat:physics.class-ph AND thermodynamics",
    # Aerospace
    "آیرودینامیک": "cat:physics.flu-dyn AND aerodynamics",
    "پیشرانه": "cat:astro-ph.IM AND propulsion",
    "ساختارهای فضایی": 'cat:astro-ph.IM AND "space structures"',
    "ناوبری و کنترل ماهواره": 'cat:cs.SY AND "satellite navigation"',
    "دینامیک پرواز": 'cat:cs.SY AND "flight dynamics"',
    # Control
    "کنترل خطی": 'cat:eess.SY AND "linear control"',
    "کنترل غیرخطی": 'cat:eess.SY AND "nonlinear control"',
    "کنترل مقاوم": 'cat:eess.SY AND "robust control"',
    "کنترل تطبیقی": 'cat:eess.SY AND "adaptive control"',
    "کنترل بهینه": 'cat:eess.SY AND "optimal control"',
    "کنترل هوشمند": 'cat:eess.SY AND "intelligent control"',
}


def extract_persian_name(compositeId: str) -> str:
    """استخراج نام فارسی از compositeId (مثلاً 'ai_یادگیری ماشین' -> 'یادگیری ماشین')"""
    parts = compositeId.split("_")
    if len(parts) < 2:
        return compositeId
    return "_".join(parts[1:])


async def compute_subfield_summary(persian_name: str) -> dict:
    """محاسبه خلاصه بر اساس نام فارسی زیرشاخه (بدون پیشوند)"""
    query = MAPPING.get(persian_name)
    if not query:
        return {"error": f"No mapping for {persian_name}"}

    papers = await search_arxiv_last_24h(query, limit_per_query=30)
    print("papers length : ", len(papers), " field name : ", query)
    time.sleep(3)
    if not papers:
        return {
            "totalArticles": 0,
            "newArticles": 0,
            "keyPoints": ["هیچ مقاله جدیدی در ۲۴ ساعت گذشته یافت نشد."],
            "importantArticles": [],
            "newIdeas": ["هیچ ایده جدیدی برای این بازه زمانی وجود ندارد."],
        }

    papers.sort(key=lambda x: x.get("published", ""), reverse=True)
    all_abstracts = " ".join(p["abstract"] for p in papers[:15])
    prompt = f"""به عنوان تحلیلگر علمی، بر اساس چکیده مقالات زیر (۲۴ ساعت گذشته) یک گزارش فارسی بنویس:
{all_abstracts}
خروجی شامل روندها، روش‌ها، چالش‌ها و شکاف‌ها (حداکثر ۲۰۰ کلمه)."""
    try:
        analysis = await call_llm(prompt, json_mode=False)
    except Exception:
        analysis = f"تعداد {len(papers)} مقاله جدید در این حوزه منتشر شده است. لطفاً بعداً برای تحلیل دقیق‌تر تلاش کنید."

    important_articles = [
        {"id": p["id"], "title": p["title"], "year": p["year"]} for p in papers[:5]
    ]
    try:
        top_paper = papers[0]
        ideas = await generate_cross_ideas(top_paper["title"], top_paper["abstract"])
        new_ideas = ideas[:3] if ideas else ["تولید ایده موفق نبود."]
    except Exception:
        new_ideas = [
            "ترکیب یادگیری ماشین با کنترل",
            "کاربرد نظریه بازی‌ها در امنیت",
            "عامل‌های هوشمند در مخابرات",
        ]

    return {
        "papers": papers,
        "totalArticles": len(papers),
        "newArticles": len(papers),
        "keyPoints": [analysis],
        "importantArticles": important_articles,
        "newIdeas": new_ideas,
    }


@router.get("/subfield-summary")
async def get_subfield_summary(compositeId: str = Query(...)):
    persian_name = extract_persian_name(compositeId)
    cache_key = f"subfield:{persian_name}"

    cached = await cache.get(cache_key)
    if cached:
        print(f"✅ Cache HIT for {persian_name} (from {compositeId})")
        return cached

    print(f"🔄 Cache MISS for {persian_name} (from {compositeId}), computing...")
    result = await compute_subfield_summary(persian_name)
    await cache.set(cache_key, result)
    return result


def get_persian_keys() -> List[str]:
    """بازگرداندن لیست تمام کلیدهای فارسی MAPPING (برای پیش‌پردازش استارت)"""
    return list(MAPPING.keys())
