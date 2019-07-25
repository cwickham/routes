
<!-- README.md is generated from README.Rmd. Please edit that file -->

# routes

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/cwickham/routes.svg?branch=master)](https://travis-ci.org/cwickham/routes)
<!-- badges: end -->

![](man/figures/README-oregon_route.jpeg)

This repo is the home of an R package that helps me create
[routes](https://routes.cwick.co.nz). It is provided with minimal
documentation and no guarantees.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("cwickham/routes")
```

## Google API

routes assumes you have a Google API key stored in the environment
variable `GOOGLE_API_KEY`. Get an [API key from
google](https://developers.google.com/maps/documentation/streetview/get-api-key),
then run:

``` r
usethis::edit_r_environ()
```

to open your `.Renviron` file and add a line of the form:

    GOOGLE_API_KEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

## Getting started

Open a new RStudio project and run `setup()`:

``` r
routes::setup(from = "Corvallis, OR", to = "Portland, OR",
  shortname = "oregon")
```

You need to specify `from` and `to` as strings interpretable to Google
Maps as locations. `setup()` creates a folder called `shortname/` and
creates a `00-setup.R` file inside this directory. (*routes uses
`here::here()` extensively in its templates under the assumption that
`shortname/` is in the root directory of your project*).

`00-setup.R` will open for editing. You will see the three required
steps for creating a route.

``` r
# Building a route landscape from Corvallis, OR to Portland, OR

# Step 1: Get the route coordinates
routes::route(from = "Corvallis, OR",
  to = "Portland, OR", shortname = "oregon")

# Step 2: Get the StreetView images
routes::streetview(from = "Corvallis, OR",
  to = "Portland, OR", shortname = "oregon")

# Step 3: Cluster, count and plot the colors
routes::cluster(from = "Corvallis, OR",
  to = "Portland, OR", shortname = "oregon")
```

Run each step to create and open a new file, run the code in the file to
complete the step.

An example of running through these steps can be found in
[oregon](oregon/). In particular, you can see the result of Knitting the
steps in the following files:

  - [01-route](oregon/01-route.md)
  - [02-streetview](oregon/02-streetview.md)
  - [03-cluster](oregon/03-cluster.md)
