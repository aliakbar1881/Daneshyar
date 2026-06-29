from app.utils.llm_client import call_llm

async def summarize(abstract: str) -> str:
    prompt = f"خلاصه‌ای دقیق و مختصر (حداکثر ۳ خط) از چکیده زیر بنویس:\n\n{abstract}"
    return await call_llm(prompt, json_mode=False)
