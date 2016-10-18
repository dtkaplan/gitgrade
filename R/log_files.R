#' @export
get_log <- function(user = NULL, after = "2016-09-01", save = TRUE) {
  STUDENTS <- read_student_file()
  current_dir <- getwd()
  on.exit(setwd(current_dir))
  Res <- NULL
  for (k in 1:nrow(STUDENTS)) {
    this_repo <- STUDENTS$repo[k]
    message("Getting log of ", this_repo)
    setwd(this_repo)
    this_log <- system("git log", intern = TRUE)
    this_log <- process_log(this_log, after)
    file_name <- character()
    commit <- character()
    for (i in 1:nrow(this_log)) {
      this_commit <- this_log$commit[i]
      temp <- system(
        paste("git diff-tree --no-commit-id --name-only -r ", this_commit ),
        intern = TRUE)
      if(length(temp) > 0) temp <- paste0(this_repo, "/", temp)
      file_name <- c(file_name, temp)
      commit <- c(commit, rep(this_commit, length(temp)))
    }
    Files <- data.frame(commit, file_name, stringsAsFactors = FALSE )
    setwd(current_dir)
    this_log <- merge(this_log, Files)
    Res <- rbind(Res, this_log)
  }
  Commit_log <-
    Res %>%
    filter(after < date) %>%
    mutate(assignment = gsub("^.*/","", file_name)) %>%
    filter(tools::file_ext(tolower(assignment)) %in% c("r", "rmd", "html")) %>%
    mutate(assignment = tools::file_path_sans_ext(assignment)) %>%
    mutate(id = gsub("^.*<", "", author)) %>%
    mutate(id = gsub("@.*$", "", id))
  if (save) saveRDS(Commit_log, file = "LOGFILE.rds")
  return(Commit_log)
}


process_log <- function(log_string, after = "2016-09-19") {
  require(dplyr)
  after = as.POSIXct(strptime(after, "%Y-%m-%d"))
  commit <- log_string[grepl("^commit", log_string)]
  commit <- gsub("^commit ", "", commit)
  author <- log_string[grepl("^Author: +", log_string)]
  author <- gsub("^Author: ", "", author)
  date <- log_string[grepl("^Date: ", log_string)]
  date <- gsub("^ ?Date: +", "", date)
  date <- gsub("^[A-Z][a-z]+ ", "", date)
  time_format <- "%b %d %H:%M:%S %Y"
  comment_pos <- grep("^Date: ", log_string) + 2
  comment <- log_string[comment_pos]
  comment <- gsub("^  *", "", comment)
  date <- as.POSIXct(strptime(date, time_format))
  res <- data.frame(author, date, commit, comment,
                    stringsAsFactors = FALSE)
}

#' Files not in the assignments
#' @export
oddball_files <- function(Log) {
  ASSIGNMENTS <- read_assignment_file()
  Log %>%
    filter( ! assignment %in% ASSIGNMENTS$assignment) %>%
    select(id, file_name) %>%
    arrange(id) %>%
    filter( ! grepl("note[^/]*$", file_name, ignore.case = TRUE))
}

#' @export
missing_assignments <- function(Log, as_of_date = Sys.Date()) {
  ASSIGNMENTS <- read_assignment_file()
  Already_due <-
    ASSIGNMENTS %>%
    filter(due_date <= as_of_date)
  # Files handed in that are already due.
  Log <-
    Log %>%
    filter(assignment %in% Already_due$assignment) %>%
    group_by(file_name) %>%
    filter(date == max(date)) %>%
    mutate(file_stub = gsub("\\..{1,5}$", "", file_name)) %>%
    ungroup()
  STUDENTS <- read_student_file()
  Unique_student_list <-
    STUDENTS %>%
    select(github_id, repo) %>%
    unique()
  Due_for_each_student <-
    Already_due %>%
    merge(Unique_student_list) %>%
    mutate(file_stub = paste0(repo, "/", assignment))
  Thin_log <-
    Log %>%
    select(assignment, id, file_stub)

  Due_for_each_student %>%
    anti_join(Thin_log, by = c(file_stub = "file_stub")) %>%
    select(assignment, github_id) %>%
    arrange(github_id, assignment)
}

#' @export
get_assignment_list <- function(Log) {
  require(dplyr)
  # For each assignment name, count how many there are.
  Log %>%
    group_by(assignment, author) %>%
    filter(date == max(date)) %>%
#    mutate(week = lubridate::week(date)) %>%
    group_by(assignment) %>%
    tally()
}

#' @export
get_student_assignment_count <- function(Log) {
  Log %>%
    group_by(id) %>%
    filter(date == max(date)) %>%
    tally()
}

#' @export
get_students_files <- function(Log, .id, .assignment) {
  Log %>%
    group_by(id, file_name) %>%
    filter(date == max(date)) %>%
    filter(id == .id & assignment == .assignment)
}


