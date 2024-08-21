from pathlib import Path
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
from dotenv import load_dotenv

# Determine the root directory (assuming database.py is located in backend/app/)
project_root = Path(__file__).resolve().parent.parent.parent

# Path to the .env file
env_path = project_root / ".env"

# Load environment variables from .env file
if not env_path.is_file():
    raise FileNotFoundError(f".env file not found at: {env_path}")
load_dotenv(env_path)

# Fetch environment variables using os.getenv
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_NAME = os.getenv("DB_NAME")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")

# Debugging print statements to check if the variables are loaded
print(f"DB_USER: {DB_USER}")
print(f"DB_PASSWORD: {DB_PASSWORD}")
print(f"DB_NAME: {DB_NAME}")
print(f"DB_HOST: {DB_HOST}")
print(f"DB_PORT: {DB_PORT}")

# Ensure DB_PORT is an integer
if DB_PORT is None:
    raise ValueError("DB_PORT environment variable is not set")

try:
    DB_PORT = int(DB_PORT)
except ValueError:
    raise ValueError("DB_PORT must be a valid integer")

# Construct the DATABASE_URL
DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# Create the SQLAlchemy engine
engine = create_engine(DATABASE_URL)

# Create a configured "Session" class
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base class for declarative models
Base = declarative_base()
