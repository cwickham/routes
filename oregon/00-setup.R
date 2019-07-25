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
