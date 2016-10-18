#' @export
clone_repos <- function(user = NULL) {
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

