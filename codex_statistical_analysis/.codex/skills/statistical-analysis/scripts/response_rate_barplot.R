# Renders the two-group response-rate comparison as a styled horizontal bar
# chart to a PNG file. Added during the Claude -> Codex migration to replace
# the inline HTML/SVG widget the source skill used (Codex has no equivalent
# to an in-chat interactive widget; it can only display a rendered image via
# view_image), while preserving the same visual: a blue Treatment bar and a
# gray Control bar, each labeled with its percentage, sized proportionally to
# the response rate.
plot_response_rates <- function(resp.tx, n.tx, resp.ctrl, n.ctrl,
                                 file = "response_rates.png") {
  treat_pct <- round(resp.tx / n.tx * 100, 2)
  ctrl_pct  <- round(resp.ctrl / n.ctrl * 100, 2)

  png(file, width = 900, height = 320, res = 120)
  op <- par(mar = c(3, 8, 3, 2))
  bar_heights <- barplot(
    rev(c(treat_pct, ctrl_pct)),
    horiz = TRUE,
    names.arg = rev(c("Treatment", "Control")),
    col = rev(c("#3b6fd4", "#888888")),
    border = NA,
    xlim = c(0, 100),
    main = "RESPONSE RATES",
    las = 1,
    cex.names = 1.1
  )
  labels <- rev(sprintf(
    "%.2f%%  (%d/%d)",
    c(treat_pct, ctrl_pct),
    c(resp.tx, resp.ctrl),
    c(n.tx, n.ctrl)
  ))
  text(
    x = rev(c(treat_pct, ctrl_pct)) + 2,
    y = bar_heights,
    labels = labels,
    adj = 0,
    col = "black",
    cex = 0.95
  )
  par(op)
  dev.off()
  invisible(file)
}
