#Load packages
source('./fun/setup.R')



# 00. Get Topography data -------------------------------------------------
cod_muni<-lookup_muni("Ubajara")$code_muni[[1]]

city <- geobr::read_municipality(cod_muni)

raster_top <- get_elev_raster(city, z = 10, clip = "location")


# 01. Load the data -------------------------------------------------------
raster_top_mat <- rayshader::raster_to_matrix(raster_top)



sat_crop_images<- list.files("data/satellite/crop/",pattern = ".tif",full.names = TRUE
)

raster_sat<- lapply(sat_crop_images,raster)


#First maps
raster_st_rbg <- raster::stack(raster_sat[[3]], raster_sat[[2]], raster_sat[[1]])
raster::plotRGB(raster_st_rbg, scale=255^2)

raster_st_rbg_corrected <- sqrt(raster::stack(raster_sat[[3]], raster_sat[[2]], raster_sat[[1]]))
raster::plotRGB(raster_st_rbg_corrected)




# 02. 02. Treat satellite data --------------------------------------------


names(raster_st_rbg_corrected) = c("r","g","b")

raster_st_r_mat <- rayshader::raster_to_matrix(raster_st_rbg_corrected$r)
raster_st_g_mat <- rayshader::raster_to_matrix(raster_st_rbg_corrected$g)
raster_st_b_mat <- rayshader::raster_to_matrix(raster_st_rbg_corrected$b)

raster_rgb_array <- array(0,dim=c(nrow(raster_st_r_mat),ncol(raster_st_r_mat),3))

raster_rgb_array[,,1] <- raster_st_r_mat/255
raster_rgb_array[,,2] <- raster_st_g_mat/255
raster_rgb_array[,,3] <- raster_st_b_mat/255



# 03. 3D Initial Plot ----------------------------------------------------

raster_rgb_array <- aperm(raster_rgb_array, c(2,1,3))

plot_map(raster_rgb_array)

raster_rgb_contrast<- scales::rescale(raster_rgb_array,to=c(0,1))

plot_map(raster_rgb_contrast)


plot_3d(raster_rgb_contrast, raster_top_mat, windowsize = c(720,600), zscale = 15, shadowdepth = -50,
        zoom=0.5, phi=45,theta=-45,fov=70, background = "#F2E1D0", shadowcolor = "#523E2B")




