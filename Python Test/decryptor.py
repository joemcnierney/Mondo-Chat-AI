import os
from cryptography.fernet import Fernet

def decrypt_folder(folder_path, password):
    """Decrypts all files within a folder."""

    # Read the password from the file
    password_file_path = os.path.join(folder_path, "password.txt")
    if not os.path.exists(password_file_path):
        print(f"Error: Password file not found at '{password_file_path}'")
        return

    with open(password_file_path, "r") as password_file:
        stored_password = password_file.read().strip()

    if password != stored_password:
        print("Error: Incorrect password.")
        return

    # Read the encryption key from the file
    key_file_path = os.path.join(folder_path, "encryption_key.txt")
    if not os.path.exists(key_file_path):
        print(f"Error: Encryption key file not found at '{key_file_path}'")
        return

    with open(key_file_path, "rb") as key_file:
        key = key_file.read()

    f = Fernet(key)

    for filename in os.listdir(folder_path):
        file_path = os.path.join(folder_path, filename)
        if os.path.isfile(file_path) and filename not in ("encryption_key.txt", "password.txt"):
            with open(file_path, "rb") as file:
                encrypted_data = file.read()
            decrypted_data = f.decrypt(encrypted_data)
            with open(file_path, "wb") as file:
                file.write(decrypted_data)

    print(f"Folder '{folder_path}' decrypted successfully!")

if __name__ == "__main__":
    folder_path = input("Enter the folder path: ")
    password = input("Enter the password: ")
    decrypt_folder(folder_path, password)
