install.package("tidyverse")
library(tidyverse)

# page 5 in R for Data science
# displ vs. hwy
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))

# add visual property ; color
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, colour=class))
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color=class))

# add visual property ; size
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, size=class))
# add visual property ; alpha
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, alpha=class))
# add visual property ; shape
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, shape=class))
# add visual property ; shape

# p12, ex 6; map an aesthetic to something
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color=displ))

# Facets
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_wrap(~ class, nrow = 2)

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_grid(drv ~ cyl)

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_grid(. ~ cyl)


# hwy vs. cyl
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = hwy, y = cyl))

# class vs. drv
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = class, y = drv))

