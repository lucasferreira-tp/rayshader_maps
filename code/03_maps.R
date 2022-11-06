#Load packages
source('./fun/setup.R')


# 01. Load the data -------------------------------------------------------
raster_top<- raster(paste0("data/topografia_", city_initials, ".tif"))

sat_crop_images<- list.files("data/satellite/crop/",pattern = ".tif",full.names = TRUE 
)

raster_sat<- lapply(sat_crop_images,raster)


#First maps
raster_st_rbg <- raster::stack(raster_sat[[3]], raster_sat[[2]], raster_sat[[1]])
raster::plotRGB(raster_st_rbg, scale=255^2)

raster_st_rbg_corrected <- sqrt(raster::stack(raster_sat[[3]], raster_sat[[2]], raster_sat[[1]]))
raster::plotRGB(raster_st_rbg_corrected)



# 02. Treat the data ------------------------------------------------------

names(raster_st_rbg_corrected) = c("r","g","b")

raster_st_r_mat <- rayshader::raster_to_matrix(raster_st_rbg_corrected$r)
raster_st_g_mat <- rayshader::raster_to_matrix(raster_st_rbg_corrected$g)
raster_st_b_mat <- rayshader::raster_to_matrix(raster_st_rbg_corrected$b)

raster_top_mat <- rayshader::raster_to_matrix(raster_top)

raster_rgb_array <- array(0,dim=c(nrow(raster_st_r_mat),ncol(raster_st_r_mat),3))

raster_rgb_array[,,1] <- raster_st_r_mat/255 
raster_rgb_array[,,2] <- raster_st_g_mat/255 
raster_rgb_array[,,3] <- raster_st_b_mat/255 


# 03. Plots ---------------------------------------------------------------

raster_rgb_array <- aperm(raster_rgb_array, c(2,1,3))

plot_map(raster_rgb_array)

raster_rgb_contrast<- scales::rescale(raster_rgb_array,to=c(0,1))

plot_map(raster_rgb_contrast)


#Plot 3d

plot_3d(raster_rgb_contrast, raster_top_mat, windowsize = c(720,600), zscale = 15, shadowdepth = -50,
        zoom=0.5, phi=45,theta=-45,fov=70, background = "#F2E1D0", shadowcolor = "#523E2B")




# 04. Rendered plots ------------------------------------------------------

pal <- "OKeeffe2"
colors <- met.brewer(pal)


raster_top_mat %>%
  height_shade(texture = grDevices::colorRampPalette(colors)(256)) %>%
  plot_3d(heightmap = raster_top_mat)

rgl::rgl.close()



# Dynaimcally set window height and width based on object size
w <- nrow(raster_top_mat)
h <- ncol(raster_top_mat)

# Scale the dimensions so we can use them as multipliers
wr <- w / max(c(w,h))
hr <- h / max(c(w,h))

# Limit ratio so that the shorter side is at least .75 of longer side
if (min(c(wr, hr)) < .75) {
  if (wr < .75) {
    wr <- .75
  } else {
    hr <- .75
  }
}


# Make sure to close previous windows

raster_top_mat %>%
  height_shade(texture = grDevices::colorRampPalette(colors)(256)) %>%
  plot_3d(heightmap = raster_top_mat, 
          windowsize = c(400*wr,400*hr), 
          solid = FALSE, 
          zscale = 5,
          phi = 90, 
          zoom = 1, 
          theta = 0) 


rgl::rgl.close()

render_highquality(
  "maps/high_quality.png", 
  parallel = TRUE, 
  samples = 300,
  light = FALSE, 
  interactive = FALSE,
  environment_light = "env/phalzer_forest_01_4k.hdr",
  intensity_env = 1.5,
  rotate_env = 180,
  width = round(6000 * wr), 
  height = round(6000 * hr)
)



# raster_rgb_contrast %>%
#   plot_3d(raster_top_mat, windowsize = c(720,600), zscale = 15, shadowdepth = -50,
#         zoom=0.5, phi=45,theta=-45,fov=70, background = "#F2E1D0", shadowcolor = "#523E2B") %>%
#   height_shade(texture = grDevices::colorRampPalette(colors)(256))

rgl::rgl.close()
