#!/bin/bash

set -e  # Exit on any error

echo "Starting environment setup..."

# Step 1: Create Python virtual environment named 'env' if not exists
if [ ! -d "env" ]; then
    echo "Creating Python virtual environment 'env'..."
    python3 -m venv env
    echo "Virtual environment 'env' created."
else
    echo "Virtual environment 'env' already exists."
fi

# Step 2: Java setup - Install Java 17 for PySpark compatibility
echo "Setting up Java 17..."
sudo apt update
sudo apt install openjdk-17-jdk -y

# Set JAVA_HOME for Java 17
JAVA_PATH=$(dirname $(dirname $(readlink -f $(which java))))
echo "export JAVA_HOME=\"$JAVA_PATH\"" >> ~/.bashrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc

# Apply to current session
export JAVA_HOME="$JAVA_PATH"
export PATH=$JAVA_HOME/bin:$PATH

echo "Java 17 setup completed."

# Step 3: Uninstall and reinstall requirements.txt
if [ -f "requirements.txt" ]; then
    echo "Found requirements.txt, uninstalling existing packages..."
    
    # Activate virtual environment
    source env/bin/activate
    
    # Uninstall all packages from requirements.txt
    pip freeze | xargs pip uninstall -y
    
    # Reinstall from requirements.txt
    echo "Reinstalling from requirements.txt..."
    pip install -r requirements.txt
    
    echo "Requirements reinstalled successfully."
else
    echo "requirements.txt file not found. Skipping package reinstallation."
fi

echo "Environment setup completed!"
echo "Please restart your terminal or run: source ~/.bashrc && source env/bin/activate"