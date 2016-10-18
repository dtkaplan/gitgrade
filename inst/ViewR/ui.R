library(shiny)
library(gitfiles)

shinyUI(fluidPage(

  # Application title
  titlePanel("Grading Papers"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      textOutput("pwd"),
      selectizeInput("which_file", "Available files:",
                     choices = format_file_names(COMMIT_LOG)),
      selectizeInput("which_assignment", "Assignments:", multiple=TRUE,
                  choices = ASSIGNMENTS$assignment),
      selectizeInput("which_student", multiple = TRUE,
                  "Students:",
                  choices = STUDENTS$github_id),
      textInput("comment", "Comments for student:", value = "None yet.", width = "100px"),
      textOutput("previous_score", inline = TRUE),
      actionButton("score_0", "0"),
      actionButton("score_1", "1"),
      actionButton("score_2", "2"),
      actionButton("score_3", "3"),
      actionButton("score_4", "4"),
      actionButton("score_5", "5")

    ),

    # Show a plot of the generated distribution
    mainPanel(
      radioButtons("display_type", "File type to display:",
                   choices = c("rmd", "html", "r"), inline = TRUE),
      wellPanel(id = "scroll_display",
                style = "overflow-y:scroll; max-height: 600px",
                htmlOutput("file_display")
                )
    )
  )
))
