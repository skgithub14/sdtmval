strip_haven_meta <- function(x) {
  x[] <- lapply(x, `attr<-`, "haven_meta", NULL)
  attr(x, "haven_meta") <- NULL
  x
}
