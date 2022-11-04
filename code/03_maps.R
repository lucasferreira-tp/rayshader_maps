#Load packages
source('./fun/setup.R')




# 1. Explore the data -----------------------------------------------------

#Load the data
raster_city<- raster(paste0("data/topografia_", city_initials, ".tif"))

raster_city<-mask(raster_city,city)


raster_st<- raster('data/satellite/LO82170662021252CUB00_B1.TIF')

raster_st<- mask(raster_st,city)
raster::crs(raster_st)

crs


tm_shape(raster_city)+ 
  tm_shape(raster_st)+
  tm_raster()


height_shade(raster_to_matrix(raster_city)) %>%
  plot_map()



