
# Sarah's mapping and graphing hacks!!


## Maps!

#### When I make maps, the basic theme that I use is this one (I think you made this, by the way)

```
theme_map <- theme(
  axis.text = element_blank(),
  axis.ticks = element_blank(),
  axis.title = element_blank(),
  panel.grid = element_blank(),
  axis.line = element_blank()
)
```


## Graphs!
#### For graphing- the main thing I change is scale_fill_gradientn so that I can use all Urban colors- here is an example of the code for 

```
topcbsa15 %>% 
  ggplot(aes(x = reorder(abbrcity, -bhogap), y = bhogap)) +
  geom_bar(stat = "identity", aes(fill = hhogap)) +
  scale_y_continuous(expand = c(0,0), labels = scales::percent) +
  scale_fill_gradientn(colors = c("#CFE8F3","#A2D4EC","#73BFE2","#46ABDB",
                                  "#1696D2","#12719E","#0A4C6A","#062635"),
                       labels = scales::percent,
                       guide = guide_colorbar(title.position = "top")) +
  labs(x = NULL, y = "Black homeownership gap", fill = "Hispanic homeownership gap",
       caption = "Source: Urban Institute Sloan ADRF database") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5),
        legend.title = element_text(hjust = .5),
        legend.position = "top",
        legend.key.width = unit(.75, "in"),
        legend.key.height = unit(.15, "in"))
```

#### Within scale_fill_gradientn, I can make changes to the legend- putting it in percents, moving it around, etc.
```
scale_fill_gradientn(colors = c("#CFE8F3","#A2D4EC","#73BFE2","#46ABDB",
                                  "#1696D2","#12719E","#0A4C6A","#062635"),
                       labels = scales::percent,
                       guide = guide_colorbar(title.position = "top"))
```


