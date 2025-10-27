# Dockerfile

# Start from an official Python 3.9 base image
FROM python:3.9-slim

# Set the "working directory" inside the container
WORKDIR /app

# Copy the requirements file *first*
COPY requirements.txt .

# Install the Python dependencies
# --no-cache-dir saves space
RUN pip install --no-cache-dir -r requirements.txt

# Now, copy the rest of our application code into the container
COPY . .

# Set an environment variable (this is the default)
ENV GREETING="Container"

# Expose port 8000 (where gunicorn will run)
EXPOSE 8000

# This is the command that runs when the container starts
# It runs gunicorn, binding to all IPs on port 8000, and points to our 'app'
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]