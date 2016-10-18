## ----include = FALSE-----------------------------------------------------
library(gitfiles)

## ----echo = FALSE--------------------------------------------------------
ASSIGNMENTS <- gitfiles::read_assignment_file(example = TRUE)
knitr::kable(head(ASSIGNMENTS))

## ----echo = FALSE--------------------------------------------------------
STUDENTS <- gitfiles:::read_student_file(example = TRUE)
knitr::kable(head(STUDENTS))

## ----eval = FALSE--------------------------------------------------------
#  CommitLog <- get_log()

