from typing import Dict, Any
import asyncio

class InMemoryCache:
    def __init__(self):
        self._data: Dict[str, Any] = {}
        self._locks: Dict[str, asyncio.Lock] = {}

    async def get(self, key: str) -> Any:
        return self._data.get(key)

    async def set(self, key: str, value: Any):
        self._data[key] = value

    async def lock(self, key: str) -> asyncio.Lock:
        if key not in self._locks:
            self._locks[key] = asyncio.Lock()
        return self._locks[key]

    async def clear(self):
        self._data.clear()

# نمونه سراسری
cache = InMemoryCache()