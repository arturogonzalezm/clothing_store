from fastapi import FastAPI

from backend.app.api.api import api_router
from backend.app.database import Base, engine

Base.metadata.create_all(bind=engine)

app = FastAPI()


@app.get("/")
def read_root():
    return {"message": "Welcome to the FastAPI application!"}


app.include_router(api_router)
