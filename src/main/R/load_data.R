require(sparklyr)

# fill config
config <- spark_config()
config[["sparklyr.defaultPackages"]] <- c("datastax:spark-cassandra-connector:2.3.0-s_2.11")
config[["spark.cassandra.connection.host"]] <- '0.0.0.0'
config[["spark.cassandra.connection.port"]] <- as.integer(9042)

# create spark connection
sc <- spark_connect(master = "local[*]",
                            version = "2.3.0",
                            hadoop_version = 2.7, 
                            config = config)

cass_tbl <- sc %>% spark_read_source(
  name = 'points',
  source = "org.apache.spark.sql.cassandra", 
  options = list(keyspace = 'density',
                 table    = 'points'))
View(cass_tbl)

t <- read.csv('/home/david/gitClones/EARL2018/src/main/R/App1/data/route.csv')
str(t)

source('src/main/R/App2/global.R')

# for(zl in 8:14){
  # zl <- 12
xy <- calcTile(zl,t$lat,lon = t$lon)
xy$zoom <- zl
df <- cbind(t,xy) %>%
  select(zoom,x,y,lat,lon) %>%
  rename(lng = lon)

df
df$zoom <- sample(8:14,nrow(df),replace = T)
# View(df)
tbl_cass = copy_to(sc, df, overwrite = TRUE)
crassy::spark_write_cassandra_table(tbl_cass, "density", "points")
# }




