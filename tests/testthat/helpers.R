quiet_cli <- function(expr) {
    suppressMessages(expr, "cliMessage")
}
