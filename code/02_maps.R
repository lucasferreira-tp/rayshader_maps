#Load packages
source('./fun/setup.R')


# 1. Load the data -----------------------------------------------------

#Load topography data
raster_top<- raster(paste0("data/topografia_", city_initials, ".tif"))

raster_top<-mask(raster_top,city)

#Load satellite data
raster_st_r<- raster('data/satellite/Sat_B4.tif')

raster_st_r<- projectRaster(raster_st_r,
                          crs=crs(raster_top))

raster_st_r<- mask(raster_st_r,city)



raster_st_g<- raster('data/satellite/Sat_B3.tif')

raster_st_g<- projectRaster(raster_st_g,
                            crs=crs(raster_top))

raster_st_g<- mask(raster_st_g,city)



raster_st_b<- raster('data/satellite/Sat_B2.tif')

raster_st_b<- projectRaster(raster_st_b,
                            crs=crs(raster_top))

raster_st_b<- mask(raster_st_b,city)



#Show raster
raster_st_rbg <- raster::stack(raster_st_r, raster_st_g, raster_st_b)
raster::plotRGB(raster_st_rbg, scale=255^2)

raster_st_rbg_corrected <- sqrt(raster::stack(raster_st_r, raster_st_g, raster_st_b))
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

plot_3d(raster_rgb_contrast, raster_top_mat, windowsize = c(1100,900), zscale = 15, shadowdepth = -50,
        zoom=0.5, phi=45,theta=-45,fov=70, background = "#F2E1D0", shadowcolor = "#523E2B")
render_snapshot(title_text = "Juazeiro-BA, Brazil | Imagery: Landsat 8 | DEM: 30m SRTM",
                title_bar_color = "#00255C", title_color = "white", title_bar_alpha = 1)




