# Data wrangling

# Loading libraries
pacman::p_load(tidyverse, RColorBrewer,zoo)

#sa_EER
sa_EER <- sa_EER %>% select(-FREQUENCY)

#sa_foreign_reserves
sa_foreign_reserves <- sa_foreign_reserves %>% select(-c("FREQUENCY", "UNIT")) %>%
    spread(INDICATOR, OBS_VALUE) %>%
    rename(Reserves_excl_gold = RXF11FX_REVS) %>%
    select(COUNTRY, TIME_PERIOD, Reserves_excl_gold) %>%
    mutate(reserves_indexed = Reserves_excl_gold/32309728657) # reserves indexed to 2010

#sa_FX
sa_FX <- sa_FX %>%
    pivot_wider(
        names_from = c(INDICATOR, TYPE_OF_TRANSFORMATION),
        values_from = OBS_VALUE,
        names_sep = "_") %>%
    rename(ZAR_EUR_PA = XDC_EUR_PA_RT,
           ZAR_EUR_EOP = XDC_EUR_EOP_RT,
           ZAR_USD_PA = XDC_USD_PA_RT,
           ZAR_USD_EOP = XDC_USD_EOP_RT)


# sa_exports
sa_exports <- sa_exports %>%
    # 1. Remove Frequency
    select(-FREQUENCY) %>%

    # 2. Filter out regions with numbers (using your regex)
    filter(!grepl("[0-9]", COUNTERPART_COUNTRY)) %>%

    # 3. Create the date and year columns FIRST
    mutate(date_fixed = lubridate::ym(TIME_PERIOD),
           year = lubridate::year(date_fixed)) %>%

    # 4. NOW you can safely remove the old columns
    select(-date_fixed) %>%

    # 5. Rename the indicator
    mutate(INDICATOR = "Exports_USD")



# Analysis
sa_exports_ranked <- sa_exports %>%
    # 1. Sum values for each country per year
    group_by(COUNTERPART_COUNTRY, year) %>%
    summarise(annual_exp = sum(OBS_VALUE, na.rm = TRUE), .groups = "drop") %>%

    # 2. Rank countries within each year
    group_by(year) %>%
    mutate(export_rank = rank(desc(annual_exp))) %>%
    ungroup() %>%

    # Calculating each country's percentage of total exports per year
    group_by(year) %>%
    mutate(annual_exp_perc = (annual_exp/sum(annual_exp))*100) %>%
    arrange(year,annual_exp_perc) %>%

# aggregating exports by year and indexing
sa_exports_total <- sa_exports %>%  ungroup() %>%
    group_by(TIME_PERIOD) %>%
    summarise(tot_mon_exports = sum(OBS_VALUE ,na.rm = T)) %>%

    # Indexed to 2010-m01
    mutate(tot_export_index = tot_mon_exports/5279270626)




# Making pie chart of 2010 and 2025
 sa_ex_ranked_filtered_piechart <- sa_exports_ranked %>%
     filter(year %in% c(2010, 2025)) %>%
     ggplot(aes(x = "", y = annual_exp_perc, fill = `COUNTERPART_COUNTRY`)) +
     geom_col(width = 1) +                 # Using geom_col is often more stable for pre-calculated percentages
     coord_polar("y", start = 0) +
     facet_wrap(~year) +                    # THIS creates the two separate charts
     theme_void() +
     theme(legend.position = "none")        # Hiding the legend because 200+ colors won't fit

 sa_ex_ranked_filtered_piechart


 library(dplyr)
 library(ggplot2)


 # Set a floor: Countries must have at least 2% of total exports
 export_floor <- 2

 sa_ex_clean <- sa_exports_ranked %>%
     filter(year %in% c(2010, 2025)) %>%
     mutate(Country_Grouped = ifelse(annual_exp_perc >= export_floor,
                                     `COUNTERPART_COUNTRY`,
                                     "Other")) %>%
     # Re-summarize so "Other" is one big slice
     group_by(year, Country_Grouped) %>%
     summarise(annual_exp_perc = sum(annual_exp_perc, na.rm = TRUE), .groups = "drop")

 # Plotting the two pies
 # 1. Count how many unique categories you have
 num_countries <- length(unique(sa_ex_clean$Country_Grouped))

 # 2. Create an expanded palette
 my_colors <- colorRampPalette(brewer.pal(12, "Set3"))(num_countries)

 # 3. Apply it to your plot
 ggplot(sa_ex_clean, aes(x = "", y = annual_exp_perc, fill = Country_Grouped)) +
     geom_col(width = 1, color = "white") +
     coord_polar("y") +
     facet_wrap(~year) +
     theme_void() +
     scale_fill_manual(values = my_colors) + # Use manual instead of brewer
     labs(title = "SA Export Share by Country",
          fill = "Country")





 #############
 df_final <- calc_rolling_vol(sa_FX, TIME_PERIOD, ZAR_USD_PA,12)
 df_final <- df_final %>% slice(-(1:12))
sa_foreign_reserves <- sa_foreign_reserves %>% slice(-(1:12))


scatterplot_data <- left_join(df_final,sa_foreign_reserves, by = "TIME_PERIOD")

# 1. Filter the EER data FIRST to avoid the many-to-many explosion
sa_REER_only <- sa_EER %>%
    filter("REER_IX_RY2010_ACW_RCPI" == INDICATOR)

scatterplot_data <- scatterplot_data %>%
    left_join(sa_REER_only, by = "TIME_PERIOD") %>%
    # Use everything() first to see where the column went,
    # or use this specific select that accounts for renaming:
    select(
        TIME_PERIOD,
        rolling_vol,
        reserves_indexed,
        # This picks up INDICATOR even if R renamed it to INDICATOR.y
        any_of(c("OBS_VALUE", "OBS_VALUE.y", "OBS_VALUE.x")),
        Reserves_excl_gold
    )
scatterplot_data <- scatterplot_data %>%  left_join(sa_exports_total)

# 1. Update the data (as you did)
scatterplot_data <- scatterplot_data %>%
    mutate(date_axis = ym(TIME_PERIOD))

# 2. Re-create the plot object using the NEW column 'date_axis'
g <- plot_scatter(scatterplot_data, x = date_axis, y = OBS_VALUE.y, color = reserves_indexed)

# 3. Apply the date formatting and labels
g <- g +
    scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
    labs(
        x = "Timeline", # Updated from 'Reserve Levels' because X is now a date
        y = "REER (Competitiveness)",
        title = "The Reserve Buffer vs. Real Exchange Rate"
    )

# 4. View it
g

g2 <- plot_scatter(scatterplot_data, reserves_indexed, rolling_vol , color = tot_export_index)
g2 <- g2 +
    labs(
        title = "Currency Volatility vs. Reserve Adequacy",
        subtitle = "Analyzing the relationship between ZAR volatility and SARB reserve levels",
        x = "Reserves (Indexed)",
        y = "12-Month Rolling Volatility (ZAR/USD)",
        color = "Export Performance",
        caption = "Source: IMF monthly data | Calculations: Log-returns rolling SD"
    ) +
    theme_minimal() # Optional: keeps it clean for academic printing

g2