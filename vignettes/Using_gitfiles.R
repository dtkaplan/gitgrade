## ----include = FALSE-----------------------------------------------------
library(gitgrade)

## ----echo = FALSE--------------------------------------------------------
ASSIGNMENTS <- gitgrade::read_assignment_file(example = TRUE)
knitr::kable(head(ASSIGNMENTS))

## ----echo = FALSE--------------------------------------------------------
STUDENTS <- gitgrade:::read_student_file(example = TRUE)
knitr::kable(head(STUDENTS))

## ----eval = FALSE--------------------------------------------------------
#  CommitLog <- get_log()

