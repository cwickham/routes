Get coordinates of route Corvallis, OR to Portland, OR
================

``` r
library(tidyverse)
```

    ## ── Attaching packages ────────────────────────────── tidyverse 1.2.1 ──

    ## ✔ ggplot2 3.2.0     ✔ purrr   0.3.2
    ## ✔ tibble  2.1.3     ✔ dplyr   0.8.3
    ## ✔ tidyr   0.8.3     ✔ stringr 1.4.0
    ## ✔ readr   1.3.1     ✔ forcats 0.4.0

    ## ── Conflicts ───────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

``` r
library(routes)
```

    ## Attaching routes version 0.0.2

``` r
library(here)
```

    ## here() starts at /Users/wickhamc/Documents/Projects/routes/routes

``` r
start <- "Corvallis, OR"
end <- "Portland, OR"
```

## Get coordinates

``` r
route_lat_lon <- get_route(start, end)
```

## Checks

Interactive with leaflet:

``` r
library(leaflet)
leaflet() %>% 
  addTiles() %>% 
  addPolylines(~ lon, ~ lat, data = route_lat_lon)
```

Static with ggmap:

``` r
library(ggmap)
bbox <- with(route_lat_lon, 
  c(left = min(lon), bottom = min(lat), 
    right = max(lon), top = max(lat)))

map <- get_stamenmap(bbox, zoom = 9, 
  maptype = "toner-hybrid", source = "stamen", force = TRUE)
ggmap(map) +
  geom_path(data = route_lat_lon, color = "#377EB8") +
  theme_void()
```

![](01-route_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

Save for later:

``` r
route_lat_lon %>% 
  write_rds(here("oregon", "data", "route_coords.rds")) %>% 
  write_csv(here("oregon", "data", "route_coords.csv"))
```
