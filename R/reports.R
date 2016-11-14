#' Convert the grade table to a gradebook format
#'

#' @export
gradebook <- function() {
  readRDS("GRADES.rds") %>%
    select(date, id, assignment, grade) %>%
    group_by(id, assignment) %>%
    filter(date == max(date)) %>%
    filter(row_number(desc(grade)) == 1) %>%
    select(-date) %>%
    spread(assignment, grade)
}

