
#Load packages
source('./fun/setup.R')


# 01. Set login Eardata Nasa ---------------------------------------------------

message("Inform username and password to access https://urs.earthdata.nasa.gov ")
username <- readline("Give the username : ")
password <- readline("Give the password : ")




# 02. Get the topography data ---------------------------------------------


#Using geobr package

#Juazeiro, Brazil
city_initials<-"ju"
city <- geobr::read_municipality(2918407)

# extract bounding box
bbox <- st_bbox(city)
bbox <- floor(bbox)


# identify which tiles are needed to cover the whole study area
lons <- seq(floor(bbox[1]), ceiling(bbox[3]), by = 1)
lats <- seq(floor(bbox[2]), ceiling(bbox[4]), by = 1)
tiles <- expand.grid(lat = lats, lon = lons) %>%
  mutate(hx = if_else(lon < 0, "W", "E"),
         hy = if_else(lat < 0, "S", "N"))
tile = sprintf("%s%02d%s%03d", tiles$hy, abs(tiles$lat), tiles$hx, abs(tiles$lon))

# build the url's for each tile
urls <- paste0("https://e4ftl01.cr.usgs.gov/MEASURES/SRTMGL1.003/2000.02.11/",
               tile, ".SRTMGL1.hgt.zip")

# download zip files and extract raster tiles
outputdir <- tempdir()
zipfiles <- paste0(outputdir, "\\", tile, ".hgt.zip")
rstfiles <- paste0(outputdir, "\\", tile, ".hgt")

walk2(urls, zipfiles, function(url, filename) {
  httr::GET(url = url, 
            authenticate(username, password),
            write_disk(path =filename, overwrite = TRUE),
            progress())
})

walk(zipfiles, unzip, exdir = outputdir)

# read all raster tiles, merge them together, and then crop to the study area's bounding box
rst <- map(rstfiles, raster)
if (length(rst) == 1) {
  rst_layer <- rst[[1]]
} else {
  rst_layer <- do.call(raster::mosaic, args = c(rst, fun = mean))
}
rst_layer_crop <- raster::crop(rst_layer, st_bbox(city))

# save processed raster to the municipality folder
#dir.create(paste0("../../data/topografia/", sigla_muni, "/"), recursive = TRUE)


rst_layer_crop<-mask(rst_layer_crop,city)
raster::writeRaster(rst_layer_crop, 
                    paste0("data/topografia_", city_initials, ".tif"),
                    overwrite = TRUE)




#References: AOP Project (Brazil)

  

