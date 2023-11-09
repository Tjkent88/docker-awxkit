# Use the official Python image as the base image
FROM python:latest

RUN pip install --upgrade pip

# Create a directory to store the fontscurl -sS https://starship.rs/install.sh | sh
RUN mkdir -p /usr/share/fonts/nerd-fonts

# Install required packages
RUN apt-get update && apt-get install -y \
    unzip \
    curl \
    gnupg \
    fontconfig \
    nano \
    zsh

# Download the Nerd Fonts from the URL
RUN curl -fsSL -o /tmp/nerd-fonts.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip

# Unzip and copy the fonts to the appropriate directory
RUN unzip /tmp/nerd-fonts.zip -d /usr/share/fonts/nerd-fonts/ && rm /tmp/nerd-fonts.zip

# Update the font cache
RUN fc-cache -fv

# Uses "Spaceship" theme with some customization. Uses some bundled plugins and installs some more from github
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -t https://github.com/denysdovhan/spaceship-prompt \
    -a 'SPACESHIP_PROMPT_ADD_NEWLINE="false"' \
    -a 'SPACESHIP_PROMPT_SEPARATE_LINE="false"' \
    -p git \
    -p ssh-agent \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions

# Add .zshrc file to the container for root and builder
COPY .zshrc /home/builder/.zshrc
COPY .zshrc /root/.zshrc

# Download and add the GitHub CLI archive keyring
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg

# Add the GitHub CLI repository to apt sources
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list

# Update the package list and install GitHub CLI
RUN apt-get update && apt-get install -y gh

# Install pipx for ansible
RUN pip install ansible ansible-tower-cli boto3 awxkit setuptools

# Download and install awscliv2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm awscliv2.zip

# Clean up
RUN apt-get remove -y unzip gnupg && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN addgroup builder && adduser --system --ingroup builder builder

# Switch to the non-root user.
USER builder

# Set a working directory
WORKDIR /repos

# Keep the container running with an infinite loop
CMD ["sh", "-c", "while true; do sleep 3600; done"]

# You can add additional commands or configurations as needed

# Example: CMD ["python", "your_script.py"]
