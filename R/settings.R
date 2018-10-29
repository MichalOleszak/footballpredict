# Progress bar settings
pboptions(type = "txt", style = 3, char = "~", txt.width = NA)

# Seasons of training data
historic_seasons <- c("0203", "0304", "0405", "0506", "0607", "0708", 
                      "0809", "0910", "1011", "1112", "1213", "1314", 
                      "1415", "1516", "1617", "1718")

# Team names as in ELO data
elo_teams <- c("chelsea", "mancity", "manunited", "liverpool", "tottenham", 
               "arsenal", "leicester", "everton", "bournemouth", "crystalpalace",
               "watford", "newcastle", "southampton", "burnley", "westham", "swansea",
               "wolves", "middlesbrough", "stoke", "cardiff", "huddersfield", 
               "astonvilla", "brentford", "derby", "leeds", "sheffieldweds",
               "bristolcity", "norwich", "hull", "ipswich", "forest", "qpr",
               "wigan", "birmingham", "blackburn", "bolton", "reading", "rotherham",
               "brighton", "fulham", "westbrom", "sheffieldunited")

# Caret models to train
models_to_train <- c("LogitBoost", "rpart")#, "xgbTree")

# Keras training settings
keras_cv_k <- 3
keras_num_epochs <- 5

# Paths
path_models <- "models"
path_data <- "data"
path_results <- "predictions"
