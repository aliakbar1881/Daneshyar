import openai
import json
from app.config import settings

# ایجاد کلاینت ناهمگام با base_url سفارشی و کلید API
client = openai.AsyncOpenAI(
    api_key=settings.openai_api_key,
    base_url="https://api.gapgpt.app/v1"
)

async def call_llm(prompt: str, json_mode: bool = False, model: str = "gapgpt-qwen-3.5") -> str:
    """
    فراخوانی ناهمگام مدل gapgpt-qwen-3.5 از طریق API gapgpt.app.
    """
    try:
        messages = [{"role": "user", "content": prompt}]
        
        # استفاده از متد chat.completions.create ناهمگام
        response = await client.chat.completions.create(
            model=model,
            messages=messages,
            temperature=0.3,
            response_format={"type": "json_object"} if json_mode else None
        )
        
        content = response.choices[0].message.content
        
        if json_mode:
            return json.loads(content)
        return content

    except openai.AuthenticationError:
        raise Exception("❌ کلید API نامعتبر است. لطفاً کلید صحیح را در فایل .env قرار دهید.")
    except openai.RateLimitError:
        raise Exception("❌ محدودیت نرخ درخواست. لطفاً بعداً تلاش کنید.")
    except Exception as e:
        raise Exception(f"❌ خطا در ارتباط با API: {str(e)}")