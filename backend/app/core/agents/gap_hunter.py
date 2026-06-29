from app.utils.llm_client import call_llm

async def find_gaps(abstract: str) -> list:
    prompt = f"بر اساس چکیده زیر، شکاف‌های تحقیقاتی موجود را فهرست کن (حداکثر ۵ مورد):\n\n{abstract}"
    response = await call_llm(prompt, json_mode=False)
    gaps = [g.strip("-• ").strip() for g in response.split("\n") if g.strip()]
    return gaps[:5]
