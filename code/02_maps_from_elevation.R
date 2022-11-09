#Load packages
source('./fun/setup.R')



# 00. Get Topography data -------------------------------------------------
city_name<-"Ubajara"
cod_muni<-lookup_muni(city_name)$code_muni[[1]]

city <- geobr::read_municipality(cod_muni)

raster_top <- get_elev_raster(city, z = 10, clip = "location")


# 01. Load the data -------------------------------------------------------

raster_top_mat <- rayshader::raster_to_matrix(raster_top)


# 02. Initial elevation plots ---------------------------------------------

#Set color palette

# pal <- brewer_pal("div")(5)
pal <- "VanGogh1"
colors <- met.brewer(pal)


# show_col(brewer_pal()(10))
# show_col(brewer_pal("div")(5))


#View elevation
raster_top_mat %>%
  # height_shade(texture = grDevices::colorRampPalette(pal)(256)) %>%
  height_shade(texture = grDevices::colorRampPalette(pal)(256)) %>%
  plot_3d(heightmap = raster_top_mat)

rgl::rgl.close()

#Set the plot dimension

base_dimension<- 400

w <- nrow(raster_top_mat)
h <- ncol(raster_top_mat)

multplier<-round(w/h,2) 


# Elevation map

raster_top_mat %>%
  height_shade(texture = grDevices::colorRampPalette(pal)(256)) %>%
  plot_3d(heightmap = raster_top_mat, 
          windowsize = c(base_dimension*multplier,base_dimension), 
          solid = FALSE, 
          zscale = 30,
          phi = 50, 
          zoom = .6, 
          theta = 0) 

rgl::rgl.close()



# 05. Rendered plots ------------------------------------------------------

bd_max<-10


render_highquality(paste0("maps/",city_name,"_rendered.png"), 
  parallel = TRUE,
  samples = 300,
  light = FALSE,
  interactive = FALSE,
  environment_light = "data/phalzer_forest_01_4k.hdr",
  intensity_env = 1.5,
  rotate_env = 180,
  width = round(base_dimension*multplier*bd_max),
  height = round(base_dimension*bd_max)
  )



# Edit map

map_rend <- image_read(paste0("maps/",city_name,"_rendered.png"))

text_color <- colors[1]



# Title
map_rend_ <- image_annotate(map_rend, "Ceará, Brazil", font = "Cinzel Decorative",
                       color = colors[1], size = 125, gravity = "north",
                       location = "+0+200")
# Subtitle
map_rend_ <- image_annotate(map_rend_, city_name, weight = 700, 
                       font = "Cinzel Decorative", location = "+0+400",
                       color = text_color, size = 200, gravity = "north")
plot(map_rend_)


# Caption
map_rend_ <- image_annotate(map_rend_, glue("Graphic by Lucas Ferreira (@_lucassousaf) | ", 
                                  "Data from AWS Terrain Tiles and USGS"), 
                       font = "Cinzel Decorative", location = "+0+50",
                       color = alpha(text_color, .5), size = 75, gravity = "south")




image_write(map_rend_, paste0("maps/",city_name,"_rendered_ant.png"))

