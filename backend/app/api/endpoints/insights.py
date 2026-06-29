from fastapi import APIRouter
from app.services.cache import cache

router = APIRouter(prefix="/insights", tags=["insights"])

@router.get("/hot-ideas")
async def hot_ideas(limit: int = 5):
    cached = await cache.get("insights:hot_ideas")
    if cached:
        return cached[:limit]
    fallback = ["ایده نمونه ۱", "ایده نمونه ۲", "ایده نمونه ۳", "ایده نمونه ۴", "ایده نمونه ۵"]
    await cache.set("insights:hot_ideas", fallback)
    return fallback[:limit]

@router.get("/trending-gaps")
async def trending_gaps(limit: int = 5):
    cached = await cache.get("insights:trending_gaps")
    if cached:
        return cached[:limit]
    fallback = ["شکاف نمونه ۱", "شکاف نمونه ۲", "شکاف نمونه ۳", "شکاف نمونه ۴", "شکاف نمونه ۵"]
    await cache.set("insights:trending_gaps", fallback)
    return fallback[:limit]