from fastapi import APIRouter
from fastapi.responses import JSONResponse


router = APIRouter(prefix="/v1")


@router.get("/add-numbers")
async def add_numbers(a: int, b: int) -> JSONResponse:
    """
    Just add 2 numbers as an example.
    :param a: Number
    :param b: Other Number
    :return:
        Keys
        ----
        - result
        - message
    """
    result = a + b
    return JSONResponse(
        {"result": result, "message": "I added the numbers."}
    )
