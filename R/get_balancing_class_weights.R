get_balancing_class_weights <- function(result) {
  homes <- sum(result == "H")
  draws <- sum(result == "D")
  aways <- sum(result == "A")
  cw <- list(1, homes / draws, aways / draws)
  return(cw)
}