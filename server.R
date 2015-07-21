library(shiny)
require(digest)
require(dplyr)

source('helpers.R')

values <- reactiveValues(i = 1)
values$df <- NULL

shinyServer(
    function(input, output, session) {
        
        # When the Login button is clicked, check whether user name is in list
        observeEvent(input$login, {
            
            # User-experience stuff
            shinyjs::disable("login")
            
            # Check whether user name is correct
            # Fix me: test against a session-specific password here, not username
            user_ok <- input$password==session_password
            
            # If credentials are valid push user into experiment
            if(user_ok){
                shinyjs::hide("login_page")
                shinyjs::show("form")
                
                # Save username to write into data file
                output$username <- renderText({input$user})
            } else {
            # If credentials are invalid throw error and prompt user to try again
                shinyjs::reset("login_page")
                shinyjs::show("login_error")
                shinyjs::enable("login")
            }

        })
        
        # Enable the Submit button when all mandatory fields are filled out
        observe({
            
            # Mandatory fields are only the checkbox here
            mandatoryFilled <-
                vapply(fieldsMandatory,
                       function(x) {
                           !is.null(input[[x]]) && input[[x]] != ""
                       },
                       logical(1))
            mandatoryFilled <- all(mandatoryFilled)
            
            # The element will be enabled if the condition evalutes to TRUE
            # and disabled otherwise.
            shinyjs::toggleState(id = "submit", condition = mandatoryFilled)
        })
        
        # Gather all the form inputs (and add timestamp)
        formData <- reactive({
            data <- sapply(fieldsAll, function(x) input[[x]])
            data <- c(round = values$i-1, data, timestamp = humanTime(), payoff = NA)
            data <- t(data)
            data
        }) 
        
        # This is similar to before except we use i from values
        output$count <- renderText({
            paste0("i = ", values$i)
        })
        
        # This renders the Plot shown on the main experimental screen
        output$figure <- renderPlot({
            barplot(as.matrix(plot_data[values$i,2:3]))
        })
        
        # This renders the a table shown on the main experimental screen
        output$table <- renderDataTable({
            data.frame(Wurf = seq(1, n_flips), Seite= flips[, values$i])
        })
        
        # This renders the table of choices made by a participant that is shown
        # to them on the final screen
        output$results <- renderDataTable({
            out <- values$df[,c(1,3)]
            colnames(out) <- c("Round", "Your guess")
            out
        })
        
        # When the Submit button is clicked, submit the response
        observeEvent(input$submit, {
            
            # User-experience stuff
            shinyjs::disable("submit")
            shinyjs::show("submit_msg")
            shinyjs::hide("error")
            
            isolate({
                values$i <- values$i + 1
            })
            
            # Save the data (show an error message in case of error)
            tryCatch({
                newLine <- isolate(formData())
                isolate(values$df <- rbind(values$df, newLine))
                shinyjs::reset("form")
                shinyjs::hide("form")
                shinyjs::hide("plot")
                if(values$i <= n_rounds){
                    shinyjs::show("thankyou_msg")
                    shinyjs::show("go_on")
                } else {
                    # Handle the end of the xperiment
                    
                    # Draw the round that will determine the payoff
                    isolate(values$round <- payoffRound(as.numeric(input$user)))
                    output$round <- renderText({
                        paste0("The computer selected round ", values$round, 
                               ". Because you guessed ",ifelse(values$df[values$round, 3]==true_state, "correctly ", "incorrectly "),
                               "we will add ", ifelse(values$df[values$round, 3]==true_state, prize, 0),
                               " Euro to your show-up fee. Your total payoff will therefore equals ",
                               ifelse(values$df[values$round, 3]==true_state, prize, 0) + show_up, " Euro.")  
                    })
                    isolate(values$df[, 5] <- ifelse(values$df[values$round, 3]==true_state, prize, 0) + show_up)
                    saveData(values$df)
                    shinyjs::show("Final_screen")
                }
            },
            error = function(err) {
                shinyjs::text("error_msg", err$message)
                shinyjs::show(id = "error", anim = TRUE, animType = "fade")
            },
            finally = {
                shinyjs::enable("submit")
                shinyjs::hide("submit_msg")
            })
        })
        
        # submit another response
        observeEvent(input$submit_another, {
            shinyjs::show("form")
            shinyjs::show("plot")
            shinyjs::hide("thankyou_msg")
            shinyjs::hide("go_on")
        })
        
    }
)