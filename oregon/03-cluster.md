Count and cluster colors for route Corvallis, OR to Portland, OR
================

``` r
library(tidyverse)
```

    ## ── Attaching packages ────────────────────────────────────── tidyverse 1.2.1 ──

    ## ✔ ggplot2 3.2.0     ✔ purrr   0.3.2
    ## ✔ tibble  2.1.3     ✔ dplyr   0.8.3
    ## ✔ tidyr   0.8.3     ✔ stringr 1.4.0
    ## ✔ readr   1.3.1     ✔ forcats 0.4.0

    ## ── Conflicts ───────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

``` r
library(colorspace)
library(routes)
library(here)
```

    ## here() starts at /Users/wickhamc/Documents/Projects/routes/routes

``` r
set.seed(21978) # both subsampling and clustering are random, 
                # set a seed to get reproducible image
```

## Read in Street View image manifest

``` r
route_images <- read_rds(here("oregon", "images", "manifest.rds"))
```

## Get sample of pixels from images

Sample 50 pixels from each image:

``` r
pixel_sample_rgb <- route_images %>% 
  pull(image) %>% 
  map_dfr(sample_pixels, sample_size = 50) %>% 
  with(RGB(R, G, B)) 
```

## Create cluster centers

``` r
cluster_space <- "LUV"
n_clusters <- 50
```

Clustering done in LUV color space, with 50 clusters:

``` r
pixel_sample_space <- pixel_sample_rgb %>% 
  as(cluster_space)

clusters <- kmeans(pixel_sample_space@coords, centers = n_clusters)
centers <- match.fun(cluster_space)(clusters$center)

centers %>% hex() %>% pal()
```

![](03-cluster_files/figure-gfm/cluster-colors-1.png)<!-- -->

## Count pixels in each cluster

``` r
color_freq_sample <- count_colors(pixel_sample_rgb, centers,
  colorspace = cluster_space)
```

Histogram of counts based on sample:

``` r
color_freq_sample %>% 
  ggplot(aes(reorder(hex, freq), freq, fill = hex)) +
    geom_col() +
  scale_fill_identity() +
  coord_flip() +
  theme_classic()
```

![](03-cluster_files/figure-gfm/hist-colors-sample-1.png)<!-- -->

Save cluster centers and frequencies in sampled pixels:

``` r
color_freq_sample %>% 
  write_rds(here("oregon", "data", "color_freq_sample.rds")) %>% 
  write_csv(here("oregon", "data", "color_freq_sample.csv"))
```

## Count pixels in each image

``` r
route_pixels <- route_images %>% 
  mutate(
    pixels = map(image, read_pixels) %>% map(RGB),
    color_count = map(pixels, count_colors, 
      centers = centers, colorspace = "LUV")) 
```

Save some summaries so plots can be reproduced without `images/`:

``` r
route_pixels %>% 
  mutate(hex = map(pixels, hex)) %>% 
  select(-color_count, -pixels) %>% 
  unnest() %>% 
  group_by(lat, lon, order, image, hex) %>% 
  count() %>% 
  write_csv(here("oregon", "data", "route_pixels_raw_counts.csv.gz"))
```

``` r
route_pixels <- 
  route_pixels %>% 
  unnest(color_count) %>% 
  mutate(H = as(LUV(L, U, V), "polarLUV")@coords[, "H"])
```

``` r
route_pixels %>% 
  write_rds(here("oregon", "data", "route_pixels.rds"))
```

## Initial Plot

``` r
route_pixels %>% 
  ggplot(aes(order, freq)) +
    geom_area(aes(fill = hex)) +
  scale_fill_identity() +
  scale_color_identity() +
  equal_margins()
```

![](03-cluster_files/figure-gfm/initial-plot-1.png)<!-- -->

``` r
orderby <- quo(V)
```

You might try re-ordering the colors by one of the color dimensions,
e.g. V, other options are `H`, `U` or `L`:

``` r
route_pixels %>% 
  ggplot(aes(order, freq)) +
    geom_area(aes(fill = reorder(hex, !!orderby))) +
  scale_fill_identity() +
  scale_color_identity() +
  equal_margins()
```

![](03-cluster_files/figure-gfm/ordered-plot-1.png)<!-- -->

## (Optional) Smoothing

The landscape is too complex and you want to smooth out the wiggles.
This approach uses a loess smoother to average frequencies for each
color. Adjust the span closer to 1 for more smoothing, closer to zero
for less:

``` r
span <- 0.15 
n_points <- 1000 # number of points on x-axis
```

``` r
order_grid <- seq(0, max(route_pixels$order), length.out = n_points)
route_smooth <- 
  route_pixels %>% 
  group_by(hex, L, U, V, H) %>% 
  nest() %>% 
  mutate(
   smooth_fun = map(data, ~ 
      loess(sqrt(freq) ~ order, data = ., span = span)),
   smooth = map(smooth_fun, 
     ~ tibble(
        order = order_grid, 
        freq = predict(., newdata = order_grid)^2)
      )
  ) %>% 
  unnest(smooth)  
```

There is no guarantee the areas add to a constant, so this often gives a
wavy top and bottom:

``` r
route_smooth  %>% 
  ggplot(aes(order, freq)) +
    geom_area(aes(fill = reorder(hex, !!orderby), color = hex)) +
  scale_fill_identity() +
  scale_color_identity() +
  equal_margins()
```

    ## Warning: Removed 200 rows containing missing values (position_stack).

![](03-cluster_files/figure-gfm/smooth-plot-1.png)<!-- -->

Scaling to have frequencies add to 1 restores the rectangular
boundaries:

``` r
route_smooth  %>% 
  group_by(order) %>% 
  mutate(freq = freq/(sum(freq))) %>% 
  ggplot(aes(order, freq)) +
    geom_area(aes(fill = reorder(hex, !!orderby), color = hex)) +
  scale_fill_identity() +
  scale_color_identity() +
  equal_margins() 
```

    ## Warning: Removed 200 rows containing missing values (position_stack).

![](03-cluster_files/figure-gfm/smooth-scaled-plot-1.png)<!-- -->

## Save image

`height` and `width` are in inches, `dpi = 300` is good for professional
printing:

``` r
ggsave(here("oregon", "oregon_route.jpeg"), 
  height = 6, width = 20, dpi = 300)
```

    ## Warning: Removed 200 rows containing missing values (position_stack).
