# Building a route landscape from {{{ from }}} to {{{ to }}}

# Step 1: Get the route coordinates
routes2019::route(from = "{{{ from }}}",
  to = "{{{ to }}}", shortname = "{{{ shortname }}}")

# Step 2: Get the StreetView images
routes2019::streetview(from = "{{{ from }}}",
  to = "{{{ to }}}", shortname = "{{{ shortname }}}")

# Step 3: Cluster, count and plot the colors
routes2019::cluster(from = "{{{ from }}}",
  to = "{{{ to }}}", shortname = "{{{ shortname }}}")

