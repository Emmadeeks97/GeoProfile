find_funs <- function(f) {
  # Returns dataframe with two columns:
  # `package_name`: packages(s) which the function is part of (chr)
  # `builtin_package`:  whether the package comes with standard R (a 'builtin'  package)

  # Arguments:
  # f: name of function for which the package(s) are to be identified.


  rlang::check_installed("tidyverse")

  suppressMessages(library(tidyverse))


  # search for help in list of installed packages
  help_installed <- help.search(paste0("^",f,"$"), agrep = FALSE)

  # extract package name from help file
  pckg_hits <- help_installed$matches[,"Package"]

  if (length(pckg_hits) == 0) pckg_hits <- "No_results_found"


  # get list of built-in packages

  pckgs <- installed.packages()  %>% as_tibble
  pckgs %>%
    dplyr::filter(Priority %in% c("base","recommended")) %>%
    dplyr::select(Package) %>%
    distinct -> builtin_pckgs_df

  # check for each element of 'pckg hit' whether its built-in and loaded (via match). Then print results.

  results <- data_frame(
    package_name = pckg_hits,
    builtin_pckage = match(pckg_hits, builtin_pckgs_df$Package, nomatch = 0) > 0,
    loaded = match(paste("package:",pckg_hits, sep = ""), search(), nomatch = 0) > 0
  )

  return(results)

}

rfq <- function(func, pkg, times = 1) {
  cat(paste0("- `", func,"()` -> `", pkg,"::", func,"()` (x", times,")\n"))
}
