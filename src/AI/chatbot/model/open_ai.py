import os
from dotenv import load_dotenv
from langchain_teddynote import logging
from langchain_openai import ChatOpenAI
from langchain.globals import set_llm_cache
from langchain_redis import RedisCache
load_dotenv()
REDIS_URL = os.getenv("REDIS_URL", "redis://j12c201.p.ssafy.io:6379")

redis_cache =RedisCache(redis_url=REDIS_URL)
set_llm_cache(
    redis_cache
)



logging.langsmith("that-water")
model=ChatOpenAI(
    model="gpt-4o",
    temperature=0.7,
)
