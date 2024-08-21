import bcrypt

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from backend.app import schemas, crud, deps

router = APIRouter()


@router.post("/login", response_model=schemas.User)
def login_user(email: str, password: str, db: Session = Depends(deps.get_db)):
    user = crud.get_user_by_email(db, email=email)
    if not user or not verify_password(password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
        )
    return user


def verify_password(plain_password, hashed_password):
    return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))
