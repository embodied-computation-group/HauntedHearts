# Load required libraries
library(dplyr)
library(stringr)

# Specify directory paths and key file path
data_dir <- "/mnt/fast_scratch/projects/hauntedshits/data/heartrate" # Replace with your actual directory
key_file_path <- "/mnt/fast_scratch/projects/hauntedshits/data/metad/ID_key.csv" # Replace with your actual key file path

# Read in the key file
key_df <- read.csv(key_file_path)

# List files in directory
all_files <- list.files(path = data_dir, pattern = "*.csv", full.names = TRUE)

# Initialize flag for user verification
user_verified <- FALSE

# Rename files
for (file_path in all_files) {
  # Extract original ID from filename
  original_id <- str_extract(string = basename(file_path), pattern = "P\\d+")
  original_id <- gsub("P", "", original_id)
  
  # Find new random ID from key
  new_id <- key_df %>% filter(Original_ID == original_id) %>% pull(Random_ID)
  
  if (length(new_id) == 0) {
    warning(paste("Original ID", original_id, "not found in key file."))
    next
  }
  
  # Construct new filename
  new_filename <- paste0(new_id, "_IBI.csv")
  
  # Construct new full path
  new_file_path <- file.path(dirname(file_path), new_filename)
  
  # User verification for the first file
  if (!user_verified) {
    cat("About to rename:", basename(file_path), "to", new_filename, "\n")
    selection <- menu(choices = c("Yes", "No"), title = "Is this okay?")
    if (selection != 1) {
      stop("User did not verify. Stopping script.")
    }
    user_verified <- TRUE
  }
  
  
  # Rename file
  file.rename(from = file_path, to = new_file_path)
}

# All done
message("File renaming complete.")
