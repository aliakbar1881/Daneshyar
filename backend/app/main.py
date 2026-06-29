import asyncio
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.endpoints import (
    analyze,
    articles,
    insights,
    search,
    subfield_summary,
    user,
)
from app.api.endpoints.subfield_summary import (
    compute_subfield_summary,
    get_persian_keys,
)
from app.config import settings
from app.services.cache import cache


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Start background precomputation (does NOT block startup)
    asyncio.create_task(precompute_all())
    print("🚀 Server started. Precomputation is running in background.")
    yield
    # (Optional) cleanup code here
    print("👋 Shutting down...")


app = FastAPI(title="Research Assistant Backend", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(articles.router, prefix="/api")
app.include_router(search.router, prefix="/api")
app.include_router(insights.router, prefix="/api")
app.include_router(user.router, prefix="/api")
app.include_router(subfield_summary.router, prefix="/api")
app.include_router(analyze.router, prefix="/api")


async def precompute_all():
    """
    Precompute all subfield summaries in background with rate limiting.
    Skips items already present in cache (useful after restarts).
    """
    print("🚀 Background precomputation started...")
    persian_names = get_persian_keys()
    print(persian_names[1:2])
    semaphore = asyncio.Semaphore(1)

    async def process_one(name: str):
        async with semaphore:
            cached = await cache.get(f"subfield:{name}")
            if cached:
                print(f"⏭️ Already cached: {name}")
                return
            try:
                print(f"🔄 Computing: {name}")
                result = await compute_subfield_summary(name)
                await cache.set(f"subfield:{name}", result)
                print(f"✅ Cached: {name}")
            except Exception as e:
                print(f"❌ Failed: {name} - {e}")
            finally:
                await asyncio.sleep(3)

    tasks = [process_one(name) for name in persian_names[1:2]]
    await asyncio.gather(*tasks)
    print("🎉 Background precomputation complete. Full cache ready.")


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
