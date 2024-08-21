# Use the official Python image from the Docker Hub
FROM python:3.12-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install any dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY backend .

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Run the FastAPI app with Uvicorn
#CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
CMD ["sh", "-c", "sleep 10 && uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload"]
