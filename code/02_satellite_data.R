#Load packages
source('./fun/setup.R')

memory.limit(9999999)
# 1. Load the data -----------------------------------------------------

#Load topography data


raster_top<- raster(paste0("data/topografia_", city_initials, ".tif"))


#Load and crop satellite data

sat_images<- list.files("data/satellite/",pattern = ".tif",full.names = TRUE 
                          )



crop_sat<-function(image){
  rst<- raster(image)
  
  # raster_st_r<- projectRaster(raster_st_r,
  #                           crs=crs(raster_top))
  
  rst<- crop(rst,extent(city))
  rst<- mask(rst,city)
  
  
  raster::writeRaster(rst, 
                      gsub('data/satellite/','data/satellite/crop/',gsub('.tif','_crop.tif',image))                      ,
                      overwrite = TRUE)
  
 
}


purrr::walk(sat_images,crop_sat)



