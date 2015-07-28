library(shinyjs)

source('helpers.R')


shinyUI(fluidPage(
    useShinyjs(),
    inlineCSS(appCSS),
    
    div( 
        id = "login_page",
        titlePanel("Welcome to the experiment!"),
        br(),
        sidebarLayout(
            
            sidebarPanel(
                h2("Login"),
                p("Welcome to today's experiment. Please use the user name provided on the instructions to login into the experiment."),
                hidden(
                    div(
                        id = "login_error",
                        span("Your username or password is invalid. Please check for typos and try again.", style = "color:red")
                    )
                )
            ),
            
            mainPanel(
                textInput("user", "User", "123"),
                textInput("password", "Password", "password"),
                actionButton("login", "Login", class = "btn-primary")
            )
            
        )
    ),
    
    
    hidden(
        div( 
            id = "form",
            titlePanel("Main experimental screen"),
        
            sidebarLayout(
            
                sidebarPanel(
                    p("Indicate whether you think the coin that was tossed is more likely to land heads or tails based on the throws shown to you on the left."),
                    checkboxGroupInput("guess", label = h3("Your guess for this round"),
                             choices = list("Heads" = "Heads", "Tails" = "Tails"), 
                             selected = NULL),
                    actionButton("show_more", "Show more", class = "btn-primary"),
                    actionButton("submit", "Submit", class = "btn-primary")
                
                ),
        
                mainPanel(
                    tabsetPanel(
                        tabPanel("Tabelle", dataTableOutput(outputId="table")),
                        tabPanel("Graph", plotOutput("figure"))
                    )
               
                )
            )
        )
    ),
    
    hidden(
        div(
            id = "thankyou_msg",
            h3("Thanks, your response was submitted successfully!")
            #uiOutput("count")
        )
    ),
    
    hidden(
        div(
            id = "go_on",
            actionButton("submit_another", "Next round")
        )
    ),
    
    hidden(
        div(
            id = "Final_screen",
            titlePanel("End of experiment"),
            sidebarLayout(
                sidebarPanel(
                    h4("Thank you for your participation. You have reached the end of the experiment."),
                    br(),
                    p("You can review your answers in the table on the right."),
                    uiOutput("round"),
                    width = 6
                ),
                
                mainPanel(
                    dataTableOutput(outputId="results"),
                    width = 6
                )
            )
        )
    )
)
)