#' Set up grading system
#'
#' Set up blank files for grading system
#' export
setup_grading_files <- function(dir = ".") {
  current_dir <- getwd()
  on.exit(setwd(current_dir))
  setwd(dir)

  files <- dir()

  grade_file_name <- "GRADES.rds"
  student_file_name <- "STUDENTS.csv"
  assignment_file_name <- "ASSIGNMENTS.csv"

  if(grade_file_name %in% files) {
    warning(grade_file_name, "already exists")
  } else {
    stub <- data.frame(date=Sys.time(), id = "student", assignment = "One",
                       grade = 10L, commit = "", comment = "Good job!",
                       stringsAsFactors = FALSE)

    stub <- stub[-1,] # start with a blank
    saveRDS(stub, file = grade_file_name)
  }

  if(student_file_name %in% files) {
    warning(student_file_name, "already exists")
  } else {
    # stub <- data.frame(name = "student name",
    #                    github_account = "https://github.com/dtkaplan/",
    #                    repo = "repo name",
    #                    github_id = "repo owner",
    #                    stringsAsFactors = FALSE)
    stub <- read.csv("inst/STUDENTS-example.csv", package = "gitgrade")
    stub <- stub[,-1] # start with a blank
    write.csv(stub, file = grade_file_name, row.names = FALSE )
  }

  if(assignment_file_name %in% files) {
    warning(assignment_file_name, "already exists")
  } else {
    stub <- data.frame(assignment = "Homework-01", due_date=Sys.Date(),
                       stringsAsFactors = FALSE)
    # stub <- read.csv(
    #   system.file("inst/ASSIGNMENTS-example.csv", package = "gitgrade"),
    #   stringsAsFactors = FALSE)
    stub$due_date <- as.POSIXct(strptime(stub$due_date, "%Y-%m-%d"))
    stub <- stub[,-1] # start with a blank
    write.csv(stub, file = assignment_file_name, row.names = FALSE)
  }
}

# Read the data from the STUDENTS.csv file
read_student_file <- function(dir = ".", example = FALSE) {

  if (example) {
  contents <- read.csv(system.file("STUDENTS-example.csv", package = "gitgrade"),
                         stringsAsFactors = FALSE)
  } else {
    current_dir <- getwd()
    on.exit(setwd(current_dir))
    setwd(dir)
    all_files <- dir()
    if ( ! "STUDENTS.csv" %in% all_files)
      stop("No STUDENTS.csv file in ", getwd(), ". Are you in the right directory? Have you setup the repo?")

    contents <- read.csv("STUDENTS.csv", stringsAsFactors = FALSE)
  }

  contents
}
#' Read the data from the ASSIGNMENTS.csv file
#' @export
read_assignment_file <- function(dir = ".", example = FALSE) {

  if (example) {
    contents <- read.csv(system.file("ASSIGNMENTS-example.csv", package = "gitgrade"),
                         stringsAsFactors = FALSE)
  } else {
    current_dir <- getwd()
    on.exit(setwd(current_dir))
    setwd(dir)
    all_files <- dir()
    if ( ! "ASSIGNMENTS.csv" %in% all_files)
      stop("No ASSIGNMENTS.csv file in ", getwd(), ". Are you in the right directory? Have you setup the repo?")
    contents <- read.csv("ASSIGNMENTS.csv", stringsAsFactors = FALSE)
  }
  contents$due_date <- as.POSIXct(strptime(contents$due_date, "%Y-%m-%d"))

  contents
}

read_grade_file <- function(dir = ".") {
  current_dir <- getwd()
  on.exit(setwd(current_dir))
  setwd(dir)
  readRDS("GRADES.rds")
}
