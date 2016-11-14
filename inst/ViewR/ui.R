library(shiny)
library(gitgrade)

shinyUI(fluidPage(

  fluidRow(
    column(3,
           HTML("<b>Grading papers from git</b>")),
    column(2,
           actionButton("pull", "git pull"))
  ),

  fluidRow(
      column(5, selectizeInput("which_file", "File displayed:", width = "100%",
                     choices = format_file_names(COMMIT_LOG))),

      column(3, selectizeInput("which_assignment", "Select assignment:", multiple=TRUE,
                  choices = ASSIGNMENTS$assignment)),
      column(3, selectizeInput("which_student", multiple = TRUE,
                  "or select student:",
                  choices = STUDENTS$github_id))
  ),
  fluidRow(
     column(1,
            radioButtons("display_type", "Type:",
                   choices = c("rmd", "html", "r"), inline = TRUE)),
     column(4, "score:", textOutput("previous_score", inline = TRUE),
      actionButton("score_0", "0"),
      actionButton("score_1", "1"),
      actionButton("score_2", "2"),
      actionButton("score_3", "3"),
      actionButton("score_4", "4"),
      actionButton("score_5", "5")),
      column(1, actionButton("next_paper", "Next")),
      # Comment text entry area
      column(4, tags$textarea(id = 'comment',
                    placeholder = 'Comments for student:', cols = 60, rows = 2, ""))
  ),

      wellPanel(id = "scroll_display",
                style = "overflow-y:scroll; max-height: 600px",
                htmlOutput("file_display")
                )
    )

#)
)
