# An application for viewing and scoring RMD/HTML/R files
library(shiny)
library(gitgrade)

shinyServer(function(input, output, session) {

  update_file_choices <- observe({
    new_names <-
      format_file_names(COMMIT_LOG,
                        id = input$which_student,
                        assignment = input$which_assignment)
    updateSelectizeInput(session, "which_file", choices = new_names)
  })

  # Handle updating the repos
  observe({
    if (input$pull > 0) {
      progress <- shiny::Progress$new()
      on.exit(progress$close())
      progress$set("Pulling repos", value = 0)
    }
  })

  display_assignment <- reactive({
    THESE_FILES[get_file_selected(), ]$assignment
  })
  display_id <- reactive({
    THESE_FILES[get_file_selected(), ]$id
  })
  grade_for_this_file <- reactive({
    tmp <-
      GRADES %>%
      filter(id == display_id(), assignment == display_assignment()) %>%
      filter(date == max(date)) %>%
      filter(row_number() == 1)
    selected <- if (nrow(tmp) == 0) "NA" else tmp$grade

    selected
  })
  get_file_selected <- reactive({
    # get the number for this item in the menu of files.
    # for the dependencies
    input$which_student
    input$which_assignment

    as.numeric(input$which_file)
  })

  files_to_display <- reactive({
    # Get a list of all the files (Rmd, R, HTML) that are available
    # for the selected student/assignment
    files <- current_student_assignment_files()
    res <- as.list(files$file_name)
    names(res) <- files$extension
    res
  })

  # get a data table of the files associated with the current student and the current
  # assignment
  current_student_assignment_files <- reactive({
    # get the files for one student for one assignment
    Tmp <- COMMIT_LOG %>%
      filter(id == display_id(), assignment == display_assignment()) %>%
      mutate(extension = tools::file_ext(tolower(file_name))) %>%
      group_by(extension, assignment) %>%
      filter(date == max(date)) %>%
      select(id, file_name, extension, commit, date, comment, assignment) %>%
      ungroup() %>% group_by(extension, assignment) %>%
      filter(row_number() == 1) %>% # Make sure there's just one of each file
      ungroup()
    are_present <- file.exists(paste0(repo_directory, Tmp$file_name))
    Tmp <- Tmp[are_present, ]

    # The following update is here so that it happens only once for each set of files
    # for one student+assignment
    available_files <- intersect(c("rmd", "html", "r"), Tmp$extension)
    updateRadioButtons(session, "display_type",
                       choices = available_files,
                       selected = available_files[1])


    Tmp <-
      Tmp %>%
      rename(commit_comment = comment) %>%
      left_join(GRADES %>%
                  filter(id == display_id(), assignment == display_assignment() ) %>%
                  filter(date == max(date)) %>%
                  rename(grade_date = date, grade_commit = commit)
      )

      Tmp
  })

  new_grade_record <- reactive({
    file_being_graded <- THESE_FILES[get_file_selected(), ]
    record <- data.frame(stringsAsFactors = FALSE,
                         date = Sys.time(),
                         assignment = file_being_graded$assignment,
                         id = file_being_graded$id,
                         grade = "bogus",
                         commit = file_being_graded$commit,
                         comment = isolate(input$comment)
    )
    record
  })
  observe({
    if (input$score_0 == 0) return()

    record <- isolate(new_grade_record())
    record$grade <- 0
    cat("Changing", record$assignment, "grade to 0\n")
    output$previous_score <- renderText(0)
    GRADES <<- rbind(GRADES, record)
    write_grades(GRADES)
  })
  observe({
    if (input$score_1 == 0) return()

    record <- isolate(new_grade_record())
    record$grade <- 1
    cat("Changing", record$assignment, "grade to 1\n")
    output$previous_score <- renderText(1)
    GRADES <<- rbind(GRADES, record)
    write_grades(GRADES)
  })
  observe({
    if (input$score_2 == 0) return()

    record <- isolate(new_grade_record())
    record$grade <- 2
    cat("Changing", record$assignment,  "grade to 2\n")
    output$previous_score <- renderText(2)
    GRADES <<- rbind(GRADES, record)
    write_grades(GRADES)
  })
  observe({
    if (input$score_3 == 0) return()

    record <- isolate(new_grade_record())
    record$grade <- 3
    cat("Changing", record$assignment,  "grade to 3\n")
    output$previous_score <- renderText(3)
    GRADES <<- rbind(GRADES, record)
    write_grades(GRADES)
  })
  observe({
    if (input$score_4 == 0) return()

    record <- isolate(new_grade_record())
    record$grade <- 4
    cat("Changing", record$assignment,  "grade to 4\n")
    output$previous_score <- renderText(4)
    GRADES <<- rbind(GRADES, record)
    write_grades(GRADES)
  })
  observe({
    if (input$score_5 == 0) return()

    record <- isolate(new_grade_record())
    record$grade <- 5
    cat("Changing", record$assignment,  "grade to 5\n")
    output$previous_score <- renderText(5)
    GRADES <<- rbind(GRADES, record)
    write_grades(GRADES)
  })

  observe({
    if (input$next_paper == 0) return()

    current_index <- as.numeric(isolate(input$which_file))
    if(current_index < nrow(THESE_FILES))
      updateSelectizeInput(session, "which_file", selected = current_index + 1)

  })

   # update filedisplay
  observe({
    # for the dependency
    input$which_student
    input$which_assignment
    input$which_file


    # Display the various varieties of the assignment selected selected
    nms <- current_student_assignment_files()

    if (all(is.na(nms$file_name))) return()


    # change this to loop over the entries in nms, using the extension
    # to direct the output to a given display.
    keepers <- nms$extension == input$display_type
    if (all( ! keepers))
      keepers <- 1


    nms <- nms[keepers, ]
    nms <- nms[1,] # handle glitch in GRADES when there is more than one entry at the same time.

    contents <- ""
    this_file <- nms$file_name
    # add the directory
    this_file <- paste0(repo_directory, this_file)
    con <- file(this_file, open = "rt", raw = TRUE)
    contents <- readLines(con)
    close(con)
    file_type <- input$display_type
    # display the contents
    updateTextAreaInput(session, "comment", value = nms$comment)
    contents <-
      if (file_type == "html") {
        HTML(paste(contents, collapse = "\n"))
      } else {
        HTML(paste("<pre>", paste(contents, collapse = "\n"), "</pre>"))
      }
    output$file_display <- renderText(contents)
    grade <- grade_for_this_file()
    output$previous_score <- renderText(grade)
  })
})
