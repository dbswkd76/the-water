from langchain_openai import OpenAIEmbeddings
from langchain_redis import RedisVectorStore
import os
from dotenv import load_dotenv
load_dotenv()

port = os.getenv("REDIS_INSTNACE_PORT")
adress=os.getenv("REDIS_INSTANCE_ADDRESS")
redis_url=f"redis://{adress}:{port}"
embedding_model = OpenAIEmbeddings()
index_name="fishing-infomation"
vectorstore = RedisVectorStore(embeddings=embedding_model,redis_url=redis_url,index_name=index_name)
retriever = vectorstore.as_retriever()