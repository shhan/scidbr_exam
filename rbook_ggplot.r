/* page 5 in R for Data science */
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))