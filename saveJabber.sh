#!/bin/bash

# Define the host IP and port
host_ip="0.0.0.0"
host_port="2222"

# Encrypt the shared secret using openssl
encrypted_secret=$(echo "password1!" | openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -pass pass:"encryptionpassword")

# Authenticate with the server
echo "$USER:$encrypted_secret:has joined the chat." | nc "$host_ip" "$host_port"

# Create a named pipe for the chat messages
mkfifo saveJabber

# Function to send messages
send_message() {
    # Encrypt the message using openssl
    echo "$USER: $1" | openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -pass pass:"encryptionpassword" | tr -d '\n' > saveJabber
}

# Function to receive messages
receive_messages() {
    while true; do
        # Read messages from the named pipe
        message=$(cat saveJabber)

        # Decrypt the message using openssl
        message=$(echo "$message" | openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 -pass pass:"encryptionpassword")

        # Print the message to the console
        echo "$message"
    done
}

# Start receiving messages in the background
receive_messages &

# Loop to send messages
while true; do
    # Read input from the console
    read -r message

    # Send the message to the server
    send_message "$message"
done
