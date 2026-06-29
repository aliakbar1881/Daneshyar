from app.utils.llm_client import call_llm

async def generate_cross_ideas(title: str, abstract: str) -> list:
    prompt = f"""از ترکیب روش این مقاله با حوزه‌های کنترل، مخابرات، هوافضا، علوم سایبری ایده‌های جدید بده.
عنوان: {title}
چکیده: {abstract}
هر ایده را در یک خط مجزا بنویس.
"""
    response = await call_llm(prompt, json_mode=False)
    ideas = [line.strip() for line in response.split("\n") if line.strip()]
    return ideas[:5]
