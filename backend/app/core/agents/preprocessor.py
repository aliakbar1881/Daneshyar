from app.core.agents.searcher import search_arxiv_last_24h
from app.core.agents.idea_gen import generate_cross_ideas
from app.utils.llm_client import call_llm
from collections import Counter
import re
from typing import List, Dict
from app.services.cache import cache
import asyncio

STOPWORDS = {'a', 'an', 'and', 'are', 'as', 'at', 'be', 'by', 'for', 'from', 'has', 'he', 'in', 'is', 'it', 'its', 'of', 'on', 'that', 'the', 'to', 'was', 'were', 'will', 'with', 'using', 'we', 'they', 'this', 'these', 'those', 'can', 'may', 'could', 'would', 'should', 'have', 'been', 'being'}

def extract_keywords(text: str, top_n: int = 5) -> List[str]:
    words = re.findall(r'\b[a-zA-Z]{3,}\b', text.lower())
    filtered = [w for w in words if w not in STOPWORDS]
    freq = Counter(filtered)
    return [kw for kw, _ in freq.most_common(top_n)]

def generate_key_points_fallback(papers: List[Dict]) -> List[str]:
    if not papers:
        return ["هیچ مقاله جدیدی یافت نشد."]
    all_abstracts = " ".join(p["abstract"] for p in papers)
    keywords = extract_keywords(all_abstracts, top_n=4)
    return [
        f"تعداد {len(papers)} مقاله جدید در این حوزه منتشر شده است.",
        f"کلیدواژه‌های پرتکرار: {', '.join(keywords)}.",
        "بیشتر مقالات به روش‌های داده‌محور و یادگیری ماشین اشاره دارند.",
        "چالش اصلی همچنان نیاز به داده‌های برچسب‌خورده با کیفیت است."
    ]

async def generate_insightful_analysis(papers: List[Dict]) -> str:
    """تولید تحلیل عمیق با LLM (در صورت امکان)"""
    if not papers:
        return "هیچ مقاله جدیدی در ۲۴ ساعت گذشته یافت نشد."
    selected = papers[:15]
    combined = "\n\n---\n\n".join([
        f"[{i+1}] عنوان: {p['title']}\nچکیده: {p['abstract']}" 
        for i, p in enumerate(selected)
    ])
    prompt = f"""به عنوان یک دانشمند ارشد و تحلیلگر بین‌رشته‌ای، لطفاً بر اساس مقالات زیر که در ۲۴ ساعت گذشته در یک حوزه تخصصی منتشر شده‌اند، یک گزارش تحلیلی عمیق و کاربردی بنویسید.

مقالات:
{combined}

خروجی شما باید دارای بخش‌های زیر باشد (به صورت متن روان و فارسی):
1. خلاصه کلی از موضوعات اصلی و نوآوری‌های مطرح‌شده
2. روش‌های پرتکرار و تکنولوژی‌های غالب
3. چالش‌های مشترک و نقاط ضعف اشاره‌شده
4. شکاف‌های تحقیقاتی که هنوز پاسخ داده نشده‌اند
5. توصیه‌هایی برای پژوهشگران

حداکثر ۳۰۰ کلمه."""
    try:
        analysis = await call_llm(prompt, json_mode=False, model="gapgpt-qwen-3.5")
        return analysis.strip()
    except Exception as e:
        print(f"⚠️ خطا در تولید تحلیل با LLM: {e}")
        return "\n".join(generate_key_points_fallback(papers))  # fallback به نکات ساده

async def precompute_subfield_summary(composite_id: str, query: str):
    """محاسبه و ذخیره خلاصه یک گرایش خاص در کش"""
    papers = await search_arxiv_last_24h(query, limit_per_query=30)
    if not papers:
        result = {
            "totalArticles": 0,
            "newArticles": 0,
            "keyPoints": ["هیچ مقاله جدیدی در ۲۴ ساعت گذشته یافت نشد."],
            "importantArticles": [],
            "newIdeas": ["هیچ ایده جدیدی برای این بازه زمانی وجود ندارد."]
        }
    else:
        papers.sort(key=lambda x: x.get("published", ""), reverse=True)
        analysis = await generate_insightful_analysis(papers)
        important_articles = [{"id": p["id"], "title": p["title"], "year": p["year"]} for p in papers[:5]]
        try:
            top_paper = papers[0]
            ideas = await generate_cross_ideas(top_paper["title"], top_paper["abstract"])
            new_ideas = ideas[:3] if ideas else ["تولید ایده با LLM امکان‌پذیر نیست."]
        except Exception as e:
            print(f"⚠️ خطا در تولید ایده برای {composite_id}: {e}")
            new_ideas = [
                "ترکیب یادگیری ماشین با کنترل پیش‌بین برای سیستم‌های بلادرنگ",
                "استفاده از نظریه بازی‌ها برای بهبود یادگیری تقویتی چندعامله",
                "کاربرد agentic systems در امنیت سایبری تطبیقی"
            ]
        result = {
            "totalArticles": len(papers),
            "newArticles": len(papers),
            "keyPoints": [analysis],  # یک لیست با یک عضو متنی بلند
            "importantArticles": important_articles,
            "newIdeas": new_ideas
        }
    await cache.set(f"subfield:{composite_id}", result)
    print(f"✅ کش برای {composite_id} به‌روز شد")

async def precompute_all_subfields(mapping: Dict[str, str]):
    """پیش‌پردازش همه گرایش‌ها به صورت همزمان (با محدودیت همزمانی)"""
    tasks = []
    semaphore = asyncio.Semaphore(5)  # حداکثر ۵ درخواست همزمان به arXiv/LLM
    async def limited_precompute(composite_id, query):
        async with semaphore:
            await precompute_subfield_summary(composite_id, query)
    for persian_name, query in mapping.items():
        composite_id = f"ai_{persian_name}"
        tasks.append(limited_precompute(composite_id, query))
    await asyncio.gather(*tasks)