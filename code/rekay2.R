# Load necessary libraries
library(stringr)

# Ask for the directory containing the subdirectories
data_dir <- readline(prompt = "Enter the directory path containing the subdirectories: ")

# Ask for the directory containing the key file
key_dir <- readline(prompt = "Enter the directory path containing the key file (ID_key.csv): ")

# Read in the key data frame from the CSV file
key_df <- read.csv(file.path(key_dir, "ID_key.csv"))

# Get list of all subdirectories in the directory
sub_dirs <- list.dirs(path = data_dir, recursive = FALSE)

# Loop through each subdirectory to rename it and its contents
for (sub_dir in sub_dirs) {
  # Extract original subject ID from the subdirectory name
  original_id <- str_extract(basename(sub_dir), "\\d+")
  
  # Find the corresponding new random ID
  new_id <- key_df$Random_ID[which(key_df$Original_ID == original_id)]
  
  # Skip to the next iteration if the original ID was not found in key_df
  if (is.na(new_id)) next
  
  # Define new subdirectory name
  new_sub_dir_name <- gsub(original_id, new_id, basename(sub_dir))
  new_sub_dir_path <- file.path(data_dir, new_sub_dir_name)
  
  # Rename the subdirectory
  file.rename(from = sub_dir, to = new_sub_dir_path)
  
  # List all files in the newly renamed subdirectory
  files_in_subdir <- list.files(path = new_sub_dir_path, full.names = TRUE)
  
  # Rename each file within the subdirectory
  for (file_path in files_in_subdir) {
    # Generate new file name
    new_file_name <- gsub(original_id, new_id, basename(file_path))
    new_file_path <- file.path(new_sub_dir_path, new_file_name)
    
    # Rename the file
    file.rename(from = file_path, to = new_file_path)
  }
}

# Confirm that the renaming is done
cat("Renaming complete.\n")
