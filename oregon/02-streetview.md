Get Street View images Corvallis, OR to Portland, OR
================

``` r
library(tidyverse)
library(routes)
library(here)
max_images <- 50 # download at most this many images
```

``` r
route_lat_lon <- read_rds(here("oregon", "route_coords.rds"))
```

Only get images for at most 50 points on route:

``` r
every_nth <- ceiling(nrow(route_lat_lon)/max_images)

route_lat_lon_sub <- route_lat_lon %>% 
  slice(seq(1, nrow(route_lat_lon), by = every_nth))
```

Get all StreetView images:

``` r
route_images <- route_lat_lon_sub %>% 
  mutate(
    image = pmap_chr(list(lat = lat, lon = lon), 
      possibly(get_img, NA_character_), 
      dir = here("oregon", "images"))  
  )
```

Write out image manifest:

``` r
route_images %>% 
  write_rds(here("oregon", "images", "manifest.rds")) %>% 
  write_csv(here("oregon", "images", "manifest.csv"))
```
