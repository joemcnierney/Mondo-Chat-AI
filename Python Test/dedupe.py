import os
import hashlib
from tqdm import tqdm
from PIL import Image
import imagehash

def calculate_hash(file_path):
    """Calculates the MD5 hash of a file."""
    hash_md5 = hashlib.md5()
    with open(file_path, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def find_duplicates(folder_path, similarity_threshold=100):
    """Finds duplicate files within a folder based on their hashes and image similarity."""
    duplicates = []
    seen_hashes = {}
    for filename in tqdm(os.listdir(folder_path), desc="Scanning Files"):
        file_path = os.path.join(folder_path, filename)
        if os.path.isfile(file_path) and file_path.lower().endswith(('.png', '.jpg', '.jpeg', '.gif')):
            try:
                with Image.open(file_path) as img:
                    image_hash = imagehash.average_hash(img)
                    for existing_hash, existing_path in seen_hashes.items():
                        if image_hash - existing_hash <= (100 - similarity_threshold):
                            duplicates.append((file_path, existing_path))
                            break  # Consider it a duplicate of the first match
                    else:
                        seen_hashes[image_hash] = file_path
            except IOError:
                print(f"Skipping invalid image file: {file_path}")
    return duplicates

def confirm_delete(duplicates):
    """Presents the duplicates, prompts for deletion, and shows storage saved."""
    if not duplicates:
        print("No duplicate files found.")
        return

    print("\nFound the following duplicate files:")
    total_size_saved = 0
    for i, (duplicate, original) in enumerate(duplicates):
        print(f"{i+1}. {duplicate} (Duplicate of {original})")
        total_size_saved += os.path.getsize(duplicate)

    if total_size_saved > 0:
        print(f"\nTotal storage that can be saved: {total_size_saved} bytes")

    while True:
        response = input("\nDelete duplicate files? (y/n): ").lower()
        if response in ("y", "n"):
            break
        print("Invalid input. Please enter 'y' or 'n'.")

    if response == "y":
        for duplicate, _ in tqdm(duplicates, desc="Deleting Duplicates"):
            os.remove(duplicate)
        print(f"Duplicate files deleted successfully. {total_size_saved} bytes freed up!")
    else:
        print("Deletion cancelled.")

if __name__ == "__main__":
    folder_path = input("Enter the folder path: ")
    duplicates = find_duplicates(folder_path)
    confirm_delete(duplicates)
