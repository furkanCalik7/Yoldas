from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware

from .routers import users
from .services.sockets import socket_app

app = FastAPI()

app.include_router(users.router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Set this to ["*"] to allow all origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/", app=socket_app)


@app.get("/")
async def root():
    return {"message": "Hello Bigger Applications!"}