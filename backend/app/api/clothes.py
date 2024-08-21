from fastapi import APIRouter

router = APIRouter()


@router.get("/")
def get_clothes():
    return {"message": "List of clothes"}
