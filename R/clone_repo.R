#' @export
clone_repos <- function(user = NULL) {
  here <- getwd()
  on.exit(setwd(here))
  if (!file.exists("STUDENTS.csv"))
    stop("No STUDENTS.csv file. Is the grading directory set up?")

  STUDENTS <- read.csv("STUDENTS.csv", stringsAsFactors = FALSE)
  if ( ! file.exists("Repositories")) stop("No 'Repositories' directory.")
  setwd("Repositories")
  for (k in 1:nrow(STUDENTS)) {
    system(
      paste0("git clone ",
             STUDENTS$github_account[k],
             STUDENTS$repo[k], ".git")
    )
  }
}

#' @export
update_repos <- function(user = NULL) {
  here <- getwd()
  on.exit(setwd(here)) # return to the main directory
  if ( ! file.exists("STUDENTS.csv"))
    stop("No STUDENTS.csv file. Is the grading directory set up?")

  STUDENTS <- read.csv("STUDENTS.csv", stringsAsFactors = FALSE)
  if ( ! file.exists("Repositories")) stop("No 'Repositories' directory.")
  setwd("Repositories")
  current_dir <- getwd()
  for (k in 1:nrow(STUDENTS)) {
    this_repo <- STUDENTS$repo[k]
    message("Pulling ", this_repo)
    setwd(this_repo)
    system("git pull")
    setwd(current_dir)
  }
}

#' @export
get_assignment_files <- function(assignment_name) {
  if ( ! assignment_name %in% ASSIGNMENTS$assignment)
    stop("No assignment named ", assignment_name, " in ASSIGNMENTS.csv")

  dir(".", pattern = paste0("^",assignment_name), recursive = TRUE)
}

