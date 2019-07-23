# Building a route landscape from {{{ from }}} to {{{ to }}}

# Step 1: Get the route coordinates
routes::route(from = "{{{ from }}}",
  to = "{{{ to }}}", shortname = "{{{ shortname }}}")

# Step 2: Get the StreetView images
routes::streetview(from = "{{{ from }}}",
  to = "{{{ to }}}", shortname = "{{{ shortname }}}")

# Step 3: Cluster, count and plot the colors
routes::cluster(from = "{{{ from }}}",
  to = "{{{ to }}}", shortname = "{{{ shortname }}}")

