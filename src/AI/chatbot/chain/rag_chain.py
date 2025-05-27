from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.runnables import RunnableLambda
from prompt.prompt import prompt
from model.open_ai import model
from vectorstore.redis_store import retriever


def retrieve_context(input):
    question = input["question"]
    
    return {
        "context": retriever.invoke(question)[:4],
        "question": question,
    }

context_retrieval = RunnableLambda(retrieve_context)

output_parser=StrOutputParser()
document_chain = create_stuff_documents_chain(llm=model, prompt=prompt)
rag_chain = context_retrieval | document_chain


