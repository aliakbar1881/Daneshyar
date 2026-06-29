from pydantic_settings import BaseSettings
from pydantic import Field
from dotenv import load_dotenv

load_dotenv()

class Settings(BaseSettings):
    openai_api_key: str = Field(..., env="OPENAI_API_KEY")
    semantic_scholar_api_key: str = Field("", env="SEMANTIC_SCHOLAR_API_KEY")
    qdrant_url: str = Field("http://localhost:6333", env="QDRANT_URL")
    redis_url: str = Field("redis://localhost:6379", env="REDIS_URL")
    cors_origins: list = ["*"]

    class Config:
        env_file = ".env"
        extra = "ignore"

settings = Settings()