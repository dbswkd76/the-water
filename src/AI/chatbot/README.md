# 낚시 전용 RAG 기반의 LLM 챗봇

낚시 어플에 특화된 챗봇을 개발하기 위해 **RAG (Retrieval-Augmented Generation)** 기반의 **LLM (Large Language Model)** 시스템을 구축하였습니다.


---
## 주요 기능
- 낚시 전문 사이트에서 크롤링한 데이터를 **Redis 기반 벡터 스토어**에 저장하여, 전문적인 응답 생성을 위한  **RAG** 데이터로 활용하였습니다.
<img src="./assets/ragpng.png">   

- 동일한 질문에 대해 **비용 절감**을 위해 **Redis Cache**를 사용, LLM 호출을 최소화 하였습니다.
<img src="./assets/cache.png">   

- Prompt를 **System Prompt**와 **Human Prompt**로 나눠 질문 데이터 양이 많아짐에 따른 
**지시사항 무시 현상**을 개선하였습니다.
<img src="./assets/prompt.png">   

---  

### 기술스택
  <img src="https://img.shields.io/badge/python-3776AB?style=for-the-badge&logo=python&logoColor=white"> 
   <img src="https://img.shields.io/badge/langchain-1C3C3C?style=for-the-badge&logo=langchain&logoColor=white"> 
  <img src="https://img.shields.io/badge/googlegemini-8E75B2?style=for-the-badge&logo=googlegemini&logoColor=white"> 
  <img src="https://img.shields.io/badge/selenium-43B02A?style=for-the-badge&logo=selenium&logoColor=white"> 
  <img src="https://img.shields.io/badge/redis-FF4438?style=for-the-badge&logo=redis&logoColor=white"> 
 
