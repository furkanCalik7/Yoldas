from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware

from .routers import users, sockets, calls

app = FastAPI()

app.include_router(users.router)
app.include_router(calls.router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Set this to ["*"] to allow all origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/", app=sockets.socket_app)


@app.get("/")
async def root():
    return {"message": "Hello Bigger Applications!"}