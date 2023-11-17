# ScRNAIMM

[![CRAN RStudio mirror downloads](https://cranlogs.r-pkg.org/badges/grand-total/ScRNAIMM?color=blue)](https://CRAN.R-project.org/package=ScRNAIMM) 
[![CRAN RStudio mirror downloads](https://cranlogs.r-pkg.org/badges/ScRNAIMM)](https://CRAN.R-project.org/package=ScRNAIMM) 
[![](https://www.r-pkg.org/badges/version/ScRNAIMM?color=green)](https://CRAN.R-project.org/package=ScRNAIMM) 

```R
install.packages("ScRNAIMM")
```

# Description
Performing single-cell imputation in a way that preserves the biological variations in the data. The package clusters the input data to do imputation for each cluster, and do a distribution check using the Anderson-Darling normality test to impute dropouts using mean or median.

# Documentation

For the documentation see: [ScRNAIMM Documentation](https://cran.r-project.org/web/packages/ScRNAIMM/index.html).

# Package information

- link to package on CRAN: [ScRNAIMM](https://cran.r-project.org/package=ScRNAIMM)

# Usage

**Example**

```R
library(scDHA)
library(ScRNAIMM)

data('Goolam')
label <- as.character(Goolam$label)

data <- data.frame(log2(Goolam$data + 1))

imputed_data <- run_pipeline(data, label = label, outdir = "outdir/", dataset = "Goolam")
```

# Contribution Guidelines

For bugs and suggestions, the most effective way is by raising an issue on the GitHub issue tracker. GitHub allows you to classify your issues so that we know if it is a bug report, feature request, or feedback to the authors.

**Email: MohmedSoudy2009@gmail.com**