
[BEAST2](https://www.beast2.org/)

[Tracer](https://github.com/beast-dev/tracer/releases/tag/v1.7.2)

[FigTree](https://github.com/rambaut/figtree/releases/tag/v1.4.4) (Optional)

[RStudio](https://posit.co/download/rstudio-desktop/) (already installed on University laptops)

---

# Beast2 packages

- start BEAUti (comes with the BEAST2 download), 
- choose File/Manage packages

Required packages: ORC, CCD, Babel, GEO_SPHERE

---

# R packages

- Open Rstudio
- copy and paste the following code into the **console**

```r
# Install packages
install.packages(c("ggplot2","rnaturalearth","rnaturalearthdata", "BiocManager", "ape", "ggrepel"))
BiocManager::install("treeio")

```


