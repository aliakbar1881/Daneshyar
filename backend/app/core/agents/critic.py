from app.utils.llm_client import call_llm
import json

async def deep_critic(title: str, abstract: str) -> dict:
    prompt = f"""عنوان: {title}
چکیده: {abstract}

به عنوان یک منتقد آکادمیک سختگیر، فرضیات پنهان نویسنده و نقاط ضعف روش‌شناسی را استخراج کن.
پاسخ را در قالب JSON با کلیدهای "assumptions" و "weaknesses" (هر دو لیستی از رشته‌ها) بده.
"""
    result = await call_llm(prompt, json_mode=True)
    if isinstance(result, str):
        result = json.loads(result)
    return result
