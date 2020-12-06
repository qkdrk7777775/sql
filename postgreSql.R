#install.packages(c('RPostgreSQL','rgdal','sf','rpostgis'))
library(RPostgreSQL)
library(rgdal)
library(sf)
library(rpostgis)
drv<-dbDriver('PostgreSQL')

con<-dbConnect(drv,dbname='ducj', port='5432', user='ducj',password='whckdwp1!@',host='203.128.184.77')
RPostgreSQL::postgresqlCloseConnection(con)
dbListTables(con)

library(sp)
data(meuse)
coords <- SpatialPoints(meuse[, c("x", "y")])
spdf <- SpatialPointsDataFrame(coords, meuse)

## Insert data in new database table
pgInsert(con, name = c("public", "meuse_data"), data.obj = spdf)

## The same command will insert into already created table (if all R
## columns match)
pgInsert(con, name = c("public", "meuse_data"), data.obj = spdf)

## If not all database columns match, need to use partial.match = TRUE,
## where non-matching columns are not inserted
colnames(spdf@data)[4] <- "cu"
pgInsert(con, name = c("public", "meuse_data"), data.obj = spdf,
         partial.match = TRUE)
# }

library(sp)
data("meuse")
meuse <- SpatialPointsDataFrame(meuse[, 1:2], data = meuse[,3:length(meuse)], proj4string = sp::CRS("+init=epsg:28992"))

pgInsert(con, "shp", meuse, new.id = "gid")

meuse.db <- pgGetGeom(con, "meuse")

query <- "SELECT gid, ST_Transform(ST_Buffer(geom, 100), 4326) AS geom FROM meuse;"
meuse.buff <- pgGetGeom(con, name = "meuse_buff", query = query,gid = "gid")
plot(meuse.buff)

pgWriteRast(con, name, raster, bit.depth = NULL, blocks = NULL,
            constraints = TRUE, overwrite = FALSE)
data("meuse.grid")

meuse.grid <- SpatialPointsDataFrame(meuse.grid[, 1:2], data = meuse.grid[,
3:length(meuse.grid)], proj4string = sp::CRS("+init=epsg:28992"))
gridded(meuse.grid) <- TRUE
pgWriteRast(con, "meuse_rast", meuse.grid)

(m.bound <- pgGetBoundary(con, "meuse_rast", "rast"))
dbListTables(con)

