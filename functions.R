get_location <- function(tree, clade, locationannotation="locationslocation"){
  tr <- tree@phylo
  node <- getMRCA(tr, clade)
  tree@data[locationannotation][which(tree@data$node == node)][[1]]
}

ancestral_locations <- function(treelist, clade, locationannotation="locationslocation"){
  ancloc <- lapply(treelist, get_location, clade, locationannotation)
  df <- as.data.frame(do.call(rbind, ancloc))
  names(df) <- c("Latitude", "Longitude")
  df$Latitude <-as.numeric(df$Latitude)
  df$Longitude <-as.numeric(df$Longitude)
  return(df)
}

ancestor_heatmap <- function(language_locations, ancestral_locations){

  world <- ne_countries(scale = "medium", returnclass = "sf")
  xlim <- range(language_locations$Longitude, na.rm = TRUE)
  ylim <- range(language_locations$Latitude, na.rm = TRUE)
  xlim <- as.numeric(xlim) + c(-1, 1)
  ylim <- as.numeric(ylim) + c(-1, 1)
  
  p <- ggplot() +
    geom_sf(data = world, fill = "grey95", color = "grey70", linewidth = 0.2) +
    geom_point(data=language_locations, aes(x=Longitude, y=Latitude)) +
    geom_text_repel(data=language_locations, aes(x=Longitude, y=Latitude, label=ID), max.overlaps=25, size=1.5) +
    stat_density_2d(
      data = ancestral_locations,
      aes(x = Longitude, y = Latitude,
          fill = after_stat(density),
          alpha = after_stat(density)),
      geom = "raster", contour = FALSE, n = 300, na.rm = TRUE
    ) +
    scale_fill_viridis_c(option = "magma", trans = "sqrt", name = "density") +
    scale_alpha(range = c(0, 0.9), trans = "sqrt", guide = "none") +
    coord_sf(xlim = xlim, ylim = ylim, expand = FALSE, default_crs = NULL) +
    theme_minimal() +
    theme(legend.position = "none") +
    labs(x = "Longitude", y = "Latitude")
}

tree_on_map <- function(tree, language_locations){
  world <- ne_countries(scale = "medium", returnclass = "sf")
  xlim <- range(language_locations$Longitude, na.rm = TRUE)
  ylim <- range(language_locations$Latitude, na.rm = TRUE)
  xlim <- as.numeric(xlim) + c(-1, 1)
  ylim <- as.numeric(ylim) + c(-1, 1)
  
  p <- ggplot() +
    geom_sf(data = world, fill = "grey95", color = "grey70", linewidth = 0.2) +
    geom_point(data=language_locations, aes(x=Longitude, y=Latitude)) +
    geom_text_repel(data=language_locations, aes(x=Longitude, y=Latitude, label=ID), max.overlaps=25, size=1.5) +
    coord_sf(xlim = xlim, ylim = ylim, expand = FALSE, default_crs = NULL) +
    theme_minimal() +
    labs(x = "Longitude", y = "Latitude")
  
  phylo <- as.phylo(tree)
  l <- as_tibble(tree)
  node_locs <- as.data.frame(do.call(rbind, l$locationslocation))
  colnames(node_locs) <- c("Latitude", "Longitude")
  node_locs$Latitude <- as.numeric(node_locs$Latitude)
  node_locs$Longitude <- as.numeric(node_locs$Longitude)
  
  l2 <- as.data.frame(cbind(l$node, node_locs$Latitude, node_locs$Longitude))
  colnames(l2) <- c("node", "Latitude", "Longitude")
  
  edges <- as.data.frame(phylo$edge)
  names(edges) <- c("parent","child")
  edges$parent <- as.numeric(edges$parent)
  edges$child <- as.numeric(edges$child)
  l2$node <- as.numeric(l2$node)
  l2$Latitude <- as.numeric(l2$Latitude)
  l2$Longitude <- as.numeric(l2$Longitude)
  
  edges <- edges |>
    left_join(l2, by = c("parent" = "node")) |>
    rename(lon0 = Longitude, lat0 = Latitude) |>
    left_join(l2, by = c("child" = "node")) |>
    rename(lon1 = Longitude, lat1 = Latitude) |>
    mutate(edge_id = row_number()) |>
    filter(is.finite(lon0), is.finite(lat0), is.finite(lon1), is.finite(lat1))
  
  p <- p+geom_segment(data=edges, aes(y=lat0, x=lon0, yend=lat1, xend=lon1), color="darkblue")
  return(p)
}

