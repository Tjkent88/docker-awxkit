# Use the official Python image as the base image
FROM python:3.9.18-slim-bullseye
# Install required packages
RUN apt-get update && apt-get install -y \
    unzip \
    curl \
    gnupg

# Download and add the GitHub CLI archive keyring
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg

# Add the GitHub CLI repository to apt sources
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list

# Update the package list and install GitHub CLI
RUN apt-get update && apt-get install -y gh

# Install awxkit using pip
RUN pip install awxkit ansible-tower-cli

# Download and install awscliv2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm awscliv2.zip

# Clean up
RUN apt-get remove -y unzip curl gnupg && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN addgroup builder && adduser --system --ingroup builder builder

# Switch to the non-root user.
USER builder

# Set a working directory
WORKDIR /app

# Example command to run as the non-root user
CMD ["/bin/sh"]

# You can add additional commands or configurations as needed

# Example: CMD ["python", "your_script.py"]
