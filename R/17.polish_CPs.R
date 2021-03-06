#' polish the searching results of CP sites
#'
#' remove the multiple positions of CP sites for same 3' UTRs and only keep the
#' best CP sites for proximal and distal.
#'
#' @param CPs output of [search_proximalCPs()] or [adjust_proximalCPs()]
#'
#' @return a matrix with columns: "fit_value", "Predicted_Proximal_APA",
#'   "Predicted_Distal_APA", "utr3start", "utr3end", "type"
#' @keywords internal
#' @seealso [adjust_proximalCPs()], [adjust_proximalCPsByPWM()],
#'   [adjust_proximalCPsByNBC()], [get_PAscore2()]
#' @author Jianhong Ou

polish_CPs <- function(CPs) {
  proximal.apa.len <- sapply(CPs$Predicted_Proximal_APA, length)
  CPs$Predicted_Proximal_APA[proximal.apa.len == 0] <-
    ifelse(CPs$dCPs$type[proximal.apa.len == 0] == "novel proximal", # else== novel distal
      CPs$idx1[proximal.apa.len == 0],
      CPs$saved.id[proximal.apa.len == 0]
    )
  coors <- lapply(CPs$chr.cov.merge, function(.ele) as.numeric(rownames(.ele)))
  flag <- CPs$flag

  CPs$fit_value[flag] <- mapply(function(cov_diff, idx) {
    ifelse(is.na(idx[1]) | is.null(idx[1]), NA, cov_diff[idx[1]])
  }, CPs$fit_value[flag], CPs$Predicted_Proximal_APA[flag], SIMPLIFY = FALSE)

  CPs$Predicted_Proximal_APA <- mapply(function(.ele, .id) {
    ifelse(is.na(.id[1]) | is.null(.id[1]), NA, .ele[.id[1]])
  }, coors, CPs$Predicted_Proximal_APA, SIMPLIFY = FALSE)

  CPs$fit_value[sapply(CPs$fit_value, length) == 0] <- NA
  CPs$dCPs$fit_value <- unlist(CPs$fit_value)
  CPs$Predicted_Proximal_APA[sapply(CPs$Predicted_Proximal_APA, length) == 0] <- NA
  CPs$dCPs$Predicted_Proximal_APA <- unlist(CPs$Predicted_Proximal_APA)
  CPs$dCPs[, c(
    "fit_value", "Predicted_Proximal_APA",
    "Predicted_Distal_APA", "utr3start",
    "utr3end", "type"
  )]
}
