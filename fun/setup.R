#install.packages("rayshader")
devtools::install_github("16EAGLE/getSpatialData")


ipak_rayshader<-function(){
   if (!("rayshader" %in% installed.packages()[, "Package"]))
    message("Please install Rayshader manually")
  if (!("getSpatialData" %in% installed.packages()[, "Package"]))
    message("Please install getSpatialData manually")
}


ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  
}

lpak<- function(pkg){sapply(pkg, require, character.only = TRUE)}

#List of packeges needed
packages <- c("tidyverse","sp","sf",
              "raster","scales","httr",
              'geobr',"tmap")

packages2<- c(packages,"rayshader","getSpatialData")



#Running the functions
ipak_rayshader()
suppressMessages(ipak(packages))
suppressMessages(lpak(packages2))


