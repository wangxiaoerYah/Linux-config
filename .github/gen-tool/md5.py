import os
import hashlib
import fnmatch
import re
import json

# Define the directory to be searched
dir_path = "./root"

# Define the output file
output_file = "./allmd5.sh"
json_file = "./allmd5.json"
readme_file = "./README.md"

# Define the exclude directories and files
exclude_dirs = [".git", ".github", "gen-tool"]
exclude_files = ["all.md5", ".gitignore", "LICENSE", "README.md"]


def md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()


def convert_to_shell_var(filename):
    # Remove any non-alphanumeric character and replace it with '_'
    shell_var = re.sub(r"\W+", "_", filename)
    # If the variable starts with a digit, prefix it with 'file_'
    if shell_var and shell_var[0].isdigit():
        shell_var = "file_" + shell_var
    return shell_var


with open(output_file, "w") as f_out:
    for root, dirs, files in os.walk(dir_path):
        # Exclude directories
        dirs[:] = [d for d in dirs if d not in exclude_dirs]
        for filename in files:
            # Exclude files
            if any(fnmatch.fnmatch(filename, pattern) for pattern in exclude_files):
                continue
            file_path = os.path.join(root, filename)
            shell_var = convert_to_shell_var(filename)
            f_out.write(f'{shell_var}="{md5(file_path)}"\n')
    f_out.write('ALL_MD5_COMPLETE="true"\n')

with open(json_file, "w") as f_out:
    data = []
    for root, dirs, files in os.walk(dir_path):
        # Exclude directories
        dirs[:] = [d for d in dirs if d not in exclude_dirs]
        for filename in files:
            # Exclude files
            if any(fnmatch.fnmatch(filename, pattern) for pattern in exclude_files):
                continue
            file_path = os.path.join(root, filename)
            file_md5 = md5(file_path)
            data.append({filename:file_md5})
    data.append({"ALL_MD5_COMPLETE": True})
    json.dump(data, f_out, indent=4)

with open(readme_file, "w") as f_out:
    # Write the table headers
    f_out.write("| filename | md5 |\n")
    f_out.write("| --- | --- |\n")

    for root, dirs, files in os.walk(dir_path):
        # Exclude directories
        dirs[:] = [d for d in dirs if d not in exclude_dirs]
        for filename in files:
            # Exclude files
            if any(fnmatch.fnmatch(filename, pattern) for pattern in exclude_files):
                continue
            file_path = os.path.join(root, filename)
            # Calculate the MD5 hash of the file
            file_md5 = md5(file_path)
            # Write the file name and MD5 hash to the README
            f_out.write(f"| {filename} | {file_md5} |\n")