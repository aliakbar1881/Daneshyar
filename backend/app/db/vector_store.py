from app.config import settings
from qdrant_client import QdrantClient
from sentence_transformers import SentenceTransformer
from typing import List

class VectorStore:
    def __init__(self):
        self.client = QdrantClient(url=settings.qdrant_url, prefer_grpc=False)
        self.encoder = SentenceTransformer('all-MiniLM-L6-v2')
        self.collection_name = "articles"
        self._ensure_collection()

    def _ensure_collection(self):
        from qdrant_client.http.models import VectorParams, Distance
        collections = self.client.get_collections().collections
        if not any(c.name == self.collection_name for c in collections):
            self.client.create_collection(
                collection_name=self.collection_name,
                vectors_config=VectorParams(size=384, distance=Distance.COSINE)
            )

    def add_article(self, article_id: str, text: str, metadata: dict):
        vector = self.encoder.encode(text).tolist()
        self.client.upsert(
            collection_name=self.collection_name,
            points=[{
                "id": article_id,
                "vector": vector,
                "payload": metadata
            }]
        )

    def search_similar(self, query: str, limit: int = 10) -> List[str]:
        query_vec = self.encoder.encode(query).tolist()
        hits = self.client.search(
            collection_name=self.collection_name,
            query_vector=query_vec,
            limit=limit
        )
        return [hit.payload.get("article_id", hit.id) for hit in hits]
