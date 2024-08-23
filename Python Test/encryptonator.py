import os
import cryptography
from cryptography.fernet import Fernet

def encrypt_folder(folder_path, password):
    """Encrypts all files within a folder."""
    key = Fernet.generate_key()
    f = Fernet(key)

    for filename in os.listdir(folder_path):
        file_path = os.path.join(folder_path, filename)
        if os.path.isfile(file_path):
            with open(file_path, "rb") as file:
                data = file.read()
            encrypted_data = f.encrypt(data)
            with open(file_path, "wb") as file:
                file.write(encrypted_data)

    # Save the encryption key to a file
    with open(os.path.join(folder_path, "encryption_key.txt"), "wb") as key_file:
        key_file.write(key)

    # Save the password to a file
    with open(os.path.join(folder_path, "password.txt"), "w") as password_file:
        password_file.write(password)

if __name__ == "__main__":
    folder_path = input("Enter the folder path: ")
    password = input("Enter the password: ")
    encrypt_folder(folder_path, password)
    print(f"Folder '{folder_path}' encrypted successfully!")