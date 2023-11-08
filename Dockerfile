# Use the official Python image as the base image
FROM python:3.9.18-slim-bullseye

# Install required packages
RUN apt-get update && apt-get install -y \
    unzip \
    curl \
    gh \
    && rm -rf /var/lib/apt/lists/*

# Install awxkit using pip
RUN pip install awxkit

# Download and install awscliv2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm awscliv2.zip

# Clean up
RUN apt-get remove -y unzip curl && apt-get autoremove -y && apt-get clean

# Set the entry point if needed
ENTRYPOINT [ "/bin/bash" ]


# You can add additional commands or configurations as needed

# Example: CMD ["python", "your_script.py"]
