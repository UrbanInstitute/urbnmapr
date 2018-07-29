library(tidyverse)
library(urbnmapr)
library(urbnthemes)
library(hexSticker)

set_urbn_defaults("map")

urbnmapr1 <- states %>%
  ggplot(mapping = aes(long, lat, group = group)) +
  geom_polygon(color = "#1696d2", fill = "#1696d2", size = 0.25) +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  theme(panel.background = element_rect(fill = "#000000"),
        plot.margin = margin(0, 0, 0, 0))

sticker(urbnmapr1,
        package="urbnmapr",
        filename="hexsticker_black.png",
        p_size=8,
        s_x = 1,       # subplot position
        s_y = 0.75,    # subplot position
        s_width = 1.3, # subplot width
        s_height = 1,  # subplot height
        p_color = "#ffffff",
        p_family = "Lato",
        h_fill = "#000000",
        h_size = 0     # no border
        )

urbnmapr <- states %>%
  ggplot(mapping = aes(long, lat, group = group)) +
  geom_polygon(color = "#000000", fill = "#000000", size = 0.25) +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  theme(panel.background = element_rect(fill = "#1696d2", color = "#1696d2"),
        plot.margin = margin(0, 0, 0, 0))

sticker(urbnmapr,
        package="urbnmapr",
        filename="hexsticker_blue.png",
        p_size=8,
        s_x = 1,       # subplot position
        s_y = 0.75,    # subplot position
        s_width = 1.3, # subplot width
        s_height = 1,  # subplot height
        p_color = "#ffffff",
        p_family = "Lato",
        h_fill = "#1696d2",
        h_size = 0     # no border
)
