# Load necessary libraries
library(stringr)

# Ask for directory containing the .nc files
data_dir <- readline(prompt = "Enter the directory path containing the .nc files: ")

# Get list of all files in the directory
all_files <- list.files(path = data_dir, pattern = "_meyad\\.nc$", full.names = TRUE)

# Extract subject IDs using regular expression
subject_ids <- str_extract(basename(all_files), "\\d+(?=_meyad\\.nc)")

# Generate new random IDs, ensuring uniqueness
new_id_set <- sample(1000:9999, length(subject_ids), replace = FALSE)  # Replace 1000:9999 with an appropriate range
random_ids <- as.character(new_id_set)

# Create a data frame to store the original IDs and their corresponding random IDs
key_df <- data.frame(Original_ID = subject_ids, Random_ID = random_ids)

# Save the key data frame to a CSV file in the same directory
write.csv(key_df, file.path(data_dir, "ID_key.csv"), row.names = FALSE)

# Rename files
for (i in 1:length(all_files)) {
  original_filename <- all_files[i]
  new_filename <- gsub(subject_ids[i], random_ids[i], basename(all_files[i]))
  new_filepath <- file.path(data_dir, new_filename)
  
  # Rename the file
  file.rename(from = original_filename, to = new_filepath)
}

# Print out the key for your review
print(key_df)
