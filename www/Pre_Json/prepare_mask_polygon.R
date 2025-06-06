# prepare_mask_polygon.R
# Purpose: Retrieve US boundary from rnaturalearth and generate the difference (world - USA) for use as a mask in Mapbox

library(rnaturalearth)
library(rnaturalearthdata)
library(sf)
library(dplyr)
library(geojsonio)

# Get the US states boundaries and convert to sf format
# ne_states() returns state/province boundaries worldwide; we filter for the United States only
us_states <- ne_states(country = "United States of America", returnclass = "sf")

# Merge all states into a single polygon (national boundary)
us_polygon <- st_union(us_states)

# Ensure the coordinate reference system is WGS84 (EPSG:4326), matching Mapbox
us_polygon <- st_transform(us_polygon, crs = 4326)

# Create a polygon covering the entire world
coords <- matrix(c(-180, -90,
                   180, -90,
                   180,  90,
                   -180,  90,
                   -180, -90),
                 ncol = 2, byrow = TRUE)
world_polygon <- st_polygon(list(coords)) %>%
  st_sfc(crs = 4326) %>%
  st_sf()


# 1. turn off s2
sf::sf_use_s2(FALSE)
# 2.Compute the difference: world minus the USA 
mask_polygon <- st_difference(world_polygon, us_polygon)
# 3.. reopen s2
sf::sf_use_s2(TRUE)

mask_sf <- st_sf(geometry = mask_polygon)

# write to under www folder
st_write(
  mask_sf,
  "www/mask_polygon.geojson",
  driver = "GeoJSON",
  delete_dsn = TRUE
)








