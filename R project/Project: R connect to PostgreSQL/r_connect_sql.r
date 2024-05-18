# Using R to connect to PostgreSQL server

# load library
library(RPostgreSQL)
library(sqldf)
library(tidyverse)

# connect SQL sever
con <- dbConnect(
  PostgreSQL(),
  host = "arjuna.db.elephantsql.com",
  dbname = "qvuviyss",
  user = "qvuviyss",
  password = "g3fC5VuLRNxp8iKhTiKsloVFXhq8A7vX",
  port = 5432
)

# list table
dbListTables(con)

# create df csv
customers <- read_csv("customers.csv")

menus <- read_csv("menus.csv")

orders <- read_csv("orders.csv")

payment_method <- tribble(
  ~method_id, ~method_name,
  1, "Cash",
  2, "Mobile Bank",
  3, "Credit card",
  4, "Wallet"
)

staffs <- tribble(
  ~staffs_id, ~name, ~lastname, ~gender,
  1, "David", "Beckham", 40,
  2, "John", "Smith", 25,
  3, "Jame", "Coner", 32,
  4, "Alisa", "Gen", 20
)

# Write table into db
dbWriteTable(con, "customers", customers)

dbWriteTable(con, "menus", menus)

dbWriteTable(con, "orders", orders)

dbWriteTable(con, "payment_method", payment_method)

dbWriteTable(con, "staffs", staffs)

# Query data
df <- dbGetQuery(con, "select * from customers")
glimpse(df)
