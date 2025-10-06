# ~/testing-Project/app/Dockerfile

# Use a lean base image for Python applications
FROM python:3.9-slim-buster

WORKDIR /app

# Install Flask
RUN pip install Flask

# Copy the application code
COPY app.py .

EXPOSE 8080

# Run the application
CMD ["python", "app.py"]