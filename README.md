
<!-- README.md is generated from README.Rmd. Please edit that file -->

# routes

<!-- badges: start -->

<!-- badges: end -->

This is mostly a package to help me create [routes](routes.cwick.co.nz).
It is provided with minimal documentation and no guarantees.

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
#> ✔ Setting active project to '/Users/wickhamc/Documents/Projects/routes/routes'
```

You need to specify `from` and `to` as strings interpretable to Google
Maps as locations. `setup()` creates a folder called `shortname` and
creates a file `00-setup.R` from a template inside this directory.
(*routes uses `here::here()` extensively in its templates under the
assumption that `shortname/` is in the root directory of your project*).

`00-setup.R` will open for editing. You will see the three required
steps for creating a route. Run each step to create and open a new file,
run the code in the file to complete the step.

An example of running through these steps can be found in
[oregon](oregon/). In particular the result of Knitting the steps:

  - [01-route.md](oregon/01-route.md)
  - [02-streetview.md](oregon/02-streetview.md)
  - [03-cluster.md](oregon/03-cluster.md)
