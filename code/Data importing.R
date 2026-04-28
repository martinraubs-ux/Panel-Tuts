# Loading libraries
pacman::p_load(tidyverse, imfapi)

#1. Importing SA Export data
# Find codes for SA export data
imf_get_dataflows()
imf_get_datastructure("IMTS")
imf_get_codelists("COUNTRY","IMTS")

# Pull the South Africa Export Data
sa_exports <- imf_get(
    dataflow_id = "IMTS",
    dimensions = list(
        FREQUENCY = "M",             # Monthly
        COUNTRY = "ZAF",             # South Africa
        COUNTERPART_COUNTRY = "",    # "" is World (Total Exports per country), while "G001" is aggregate
        INDICATOR = "XG_FOB_USD"     # Exports, Goods, US Dollars
    ),
    start_period = "2010-Q1"       # No end period, that the data is pulled up till most recent period
)

head(sa_exports)

#2. Importing SA Foreign reserve data
# Finding codes
imf_get_datastructure("IL")


sa_foreign_reserves <- imf_get(
    dataflow_id = "IL",
    dimensions = list(
        COUNTRY = "ZAF",              # South Africa
        INDICATOR = c("RXF11FX_REVS", # Reserves excluding gold, foreign exchange
                      "NFAOFA_ACO_NRES_S121", # Net foreign assets, Claims on Nonresidents, Other depository corporations
                      "NFAOFL_LT_NRES_S121",  # Net foreign assets, other foreign liabilities, Liabilities to Nonresidents, Central bank
                      "TRGMV_REVS") ,
        UNIT = "USD",                # Measurement currency
        FREQUENCY = "M"             # Monthly
    ),
    start_period = "2010-Q1"       # No end period, that the data is pulled up till most recent period
)

head(sa_foreign_reserves)


#3. IMPORTING sA IIP
# Finding codes
imf_get_datastructure("IIP")


sa_IIP <- imf_get(
    dataflow_id = "IIP",
    dimensions = list(
        COUNTRY = "ZAF",              # South Africa
        BOP_ACCOUNTING_ENTRY = c("A_P", "L_P"),
        INDICATOR = c("P_MV",         # Portofolio investment
                      "D",            # Direct investment
                      "O",            # Other investment
                      "R",            # Reserve assets
                      "R_F2_NV",      # Reserve assets, Other reserve (currency, deposits, securities, financial derivatives and other claims)
                      "TL_AFR",       # Total assets, Adjusted using IMF accounting records
                      "TA_AFR"),      # Total liabilities, Adjusted using IMF accounting records
        UNIT = "USD",                 # Measurement currency
        FREQUENCY = "Q"               # Monthly
    ),
    start_period = "2010-Q1"          # No end period, that the data is pulled up till most recent period
)

head(sa_IIP)

#4. IMPORTING EFFECTIVE EXCAHNGE RATE DATA
# Finding codes
imf_get_datastructure("EER")

# Importing EER
sa_EER <- imf_get(
    dataflow_id = "EER",
    dimensions = list(
        COUNTRY = "ZAF",                         # South Africa
        INDICATOR = c("REER_IX_RY2010_ACW_RCPI", # Real
                      "NEER_IX_RY2010_ACW"),     # Nominal
        FREQUENCY = "M"                          # Monthly
    ),
    start_period = "2010-Q1"                     # No end period, that the data is pulled up till most recent period
)

head(sa_EER)

#5. Importing Exchange rate data
# Finding codes
imf_get_datastructure("ER")

# Importing FX
sa_FX <- imf_get(
    dataflow_id = "ER",
    dimensions = list(
        COUNTRY = "ZAF",                         # South Africa
        INDICATOR = c("XDC_EUR",
                      "XDC_USD"),
        TYPE_OF_TRANSFORMATION = c("EOP_RT","PA_RT"),
        FREQUENCY = "M"                          # Monthly
    ),
    start_period = "2010-Q1"                     # No end period, that the data is pulled up till most recent period
)

head(sa_FX)