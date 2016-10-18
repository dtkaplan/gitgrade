# Consolidate all the "Scores.csv" files in a directory tree.

# # Example: Grading Math 253
# setwd("/Users/kaplan/Dropbox/Courses-Fall-2015/253-Student-Work")
# activities <- assignments_handed_in() # just the .R files
# homework <- get_all_scores() # the Scores.csv files from the app
# exam <- read.csv("Math-253-Final.csv", stringsAsFactors = FALSE) # entered by hand
# together <- full_join(activities, homework, by = "student")
# together <- full_join(together, exam, by = "student")

get_all_scores <- function(path = ".", pattern = "Scores.csv",
                           merge_by = "student", score_name = "score") {
  fnames <- list.files(path = path, pattern = pattern, 
                       full.names = TRUE, recursive = TRUE)
  for (file_name in fnames) {
    Scores <- readr::read_csv(file_name)
    directory <- get_last_directory(file_name)
    Scores <- dplyr::select_(Scores, merge_by, score_name)
    names(Scores) <- c(merge_by, directory)
    if (!exists("Together", inherits = FALSE))
      Together <- Scores
    else {
      Together <- full_join(Together, Scores, by = merge_by)
    }
  }
  
  return(Together)
  
}


# What assignments did students hand in files for
assignments_handed_in <- function(path = ".", pattern = "[.R|.r]$") {
  library(dplyr)
  fnames <- list.files(path = path, pattern = pattern, 
                       full.names = TRUE, recursive = TRUE)
  students <- get_student_name(fnames)
  dir <- get_last_directory(fnames)
  Sfiles <- data.frame(student = students, assignment = dir,
                       stringsAsFactors = FALSE)
  Sfiles$n <- 1
  Res <- tidyr::spread(unique(Sfiles), key = assignment, value = n, fill = 0)
  
  return(Res)
  
}


# Utility functions
get_last_directory <- function(file_names) {
  res <- character(length(file_names))
  for (k in 1:length(file_names)) {
    directory <- unlist(strsplit(file_names[[k]], split="/"))
    res[k] <- directory[length(directory) - 1]
  }
  res
}

get_student_name <- function(file_names, system = "moodle") {
  gsub("^.+/|_.*$", "", file_names)
}
  