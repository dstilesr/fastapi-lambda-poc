from mangum import Mangum
from fastapi import FastAPI

from api.v1 import router


app = FastAPI(
    title="Mangum Example App",
    docs_url="/docs",
    openapi_prefix="/dev"
)

app.include_router(router, prefix="/api")

lambda_handler = Mangum(app, lifespan="off")
