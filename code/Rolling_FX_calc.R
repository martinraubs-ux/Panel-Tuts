library(dplyr)
library(zoo)

calc_rolling_vol <- function(df, date, fx_col, window = 12) {
    df %>%
        arrange({{date}}) %>% # Ensure data is in chronological order
        mutate(
            # 1. Calculate Log Returns: ln(Price_t / Price_t-1)
            log_ret = log({{fx_col}} / lag({{fx_col}})),

            # 2. Calculate Rolling Standard Deviation
            # align = "right" ensures we only use trailing data (no look-ahead bias)
            rolling_vol = rollapplyr(log_ret, width = window, FUN = sd, fill = NA)
        )
}

# Example Usage with your monthly average data:
# df_final <- calc_rolling_vol(sa_FX, TIME_PERIOD, ZAR_USD_PA,12)
# df_final <- df_final %>% slice(-12)