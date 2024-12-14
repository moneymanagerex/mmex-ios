import os
import shutil
import stat

# Define the base directory and output file
base_dir = "MMEX/Resources/"
output_file = os.path.join(base_dir, "Localizable.xcstrings")

# List to store translation file paths for merging and deletion
translation_files = []

# Walk through the directory to find language-specific files
for root, dirs, files in os.walk(base_dir):
    for file in files:
        if file == "Localizable.xcstrings" and root != base_dir:
            translation_files.append(os.path.join(root, file))

# Merge all translation files into one
with open(output_file, "w", encoding="utf-8") as outfile:
    for file in translation_files:
        with open(file, "r", encoding="utf-8") as infile:
            outfile.write(f"// From {file}\n")
            outfile.write(infile.read())
            outfile.write("\n")

# Helper to ensure file deletability
def make_writable(file_path):
    os.chmod(file_path, stat.S_IWRITE)  # Add write permission

# Delete the individual language files and directories
for file in translation_files:
    make_writable(file)  # Ensure writable
    os.remove(file)  # Remove the file
    folder = os.path.dirname(file)
    if not os.listdir(folder):  # Check if the folder is empty
        os.rmdir(folder)  # Remove the folder if empty

print("Merge completed. Individual files and directories deleted.")
