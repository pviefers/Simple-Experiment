# Define the mandatory fiedls here
# which fields get saved 
fieldsAll <- c("user", "guess")

# which fields are mandatory
fieldsMandatory <- c("guess")

responsesDir <- file.path("responses")

# Password to login for this session
session_password <- "password"

### Generate data here
### 
### 
### 
set.seed(1906)
n_rounds <- 2
n_flips <- 7
probs <- c(0.6,0.4)
prize <- 1
true_state <- "Heads"
show_up <- 10

flips <- sapply(1:n_rounds, function(x) sample(c("Heads", "Tails"), n_flips, replace = TRUE, prob = probs))
n.heads <- apply(flips, 2, function(x) length(which(x == "Heads")))
plot_data <- data.frame(n.coin.flips = rep(10, n_rounds), 
                        heads = n.heads, 
                        tails = n_flips - n.heads
                        )

# add an asterisk to an input label
labelMandatory <- function(label) {
    tagList(
        label,
        span("*", class = "mandatory_star")
    )
}

# CSS to use in the app
appCSS <-  ".mandatory_star { color: red; }
.shiny-input-container { margin-top: 25px; }
#submit_msg { margin-left: 15px; }
#error { color: red; }
#adminPanel { border: 4px solid #aaa; padding: 0 20px 20px; }"

# Helper functions
humanTime <- function() format(Sys.time(), "%d-%m-%Y-%H-%M-%S")

saveData <- function(data) {
    fileName <- sprintf("%s_%s.csv",
                        humanTime(),
                        digest::digest(data))
    
    write.csv(x = data, file = file.path(responsesDir, fileName),
              row.names = FALSE, quote = TRUE)
}

payoffRound <- function(user){
    set.seed(user)
    out <- sample(seq(1, n_rounds), 1)
    return(out)
}

epochTime <- function() {
    as.integer(Sys.time())
}
