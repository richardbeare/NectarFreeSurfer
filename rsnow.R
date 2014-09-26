cl <- makeCluster()
print(clusterCall(cl, function() Sys.info()))
