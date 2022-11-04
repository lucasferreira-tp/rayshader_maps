#Load packages
source('./fun/setup.R')

## set login credentials and archive directory

username2<- readline("Give the username : ")


login_USGS(username = username2) #asks you for password

dir.create("data/satellite", recursive = TRUE)

set_archive("data/satellite") 
