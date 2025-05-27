from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from chain.rag_chain import rag_chain
import redis

class ChatRequest(BaseModel):
    question:str
    session_id:str="default"
    

r=redis.Redis(host='j12c201.p.ssafy.io', port=6379, db=0)
app = FastAPI()

@app.post("/chat")
async def chat(req:ChatRequest):
    if not req.question.strip():
        raise HTTPException(status_code=400, detail="질문이 비어 있습니다.")

    response = rag_chain.invoke(
        {"question": req.question},
        config={"configurable": {"session_id": req.session_id}}
    )
    return {"response": response}

@app.post("/chat/clear-session")
def clear_cache():
    for key in r.scan_iter("redis:*"):
        r.delete(key)
    return {"status": "cache cleared all"}
