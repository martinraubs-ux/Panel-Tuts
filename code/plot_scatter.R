plot_scatter <- function(df, x, y, color = NULL, alpha_var = NULL, facet = NULL, alpha_const = 0.5) {

    # 1. Initialize plot with required aesthetics
    p <- ggplot(df, aes(x = {{x}}, y = {{y}}))

    # 2. Add points with conditional alpha mapping
    if (!missing(alpha_var)) {
        p <- p + geom_point(aes(color = {{color}}, alpha = {{alpha_var}}))
    } else {
        p <- p + geom_point(aes(color = {{color}}), alpha = alpha_const)
    }

    # 3. Add faceting if requested
    if (!missing(facet)) {
        p <- p + facet_wrap(vars({{facet}}))
    }

    return(p + theme_minimal())
}

# plot_scatter(,TIME_PERIOD,REER,color = Reserves_excluding_gold)