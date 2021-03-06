clust_it <- function(pop, m = 5, l = 4, o = 3, g1 = 50, g2 = g1 * 0.5, d1 = 1000, d2 = d1 * 2){
  clusterizados <- as.list(NA)
  j <- 1 #iteration index
  n <- 1 #pob remainder
  while (j <= m & n >=  1 & ceiling(nrow(pop) / (ifelse(j <= l,g1,g2)*0.75)) >= 2){ 
    pop <- clust_pop(pop, ceiling(nrow(pop) / (ifelse(j <= l,g1,g2)*0.75))) 
    list_1 <- vector("list")
    for (i in sort(unique(pop$cluster))){
      list_1[[i]] <- rank(subset(pop,pop$cluster == i)[,"dist"],ties.method = "random")
    } # provides a list of ranks for each cluster, based on distance to the median center
    orden_dist <- as.data.frame(NULL)
    for (i in 1:length(list_1)) {
      orden_dist <- rbind(orden_dist,as.data.frame(list_1[[i]]))
    }
    colnames(orden_dist) <- "orden_dist"
    pop <- cbind(pop[order(pop$cluster,pop$dist),],orden_dist) # assigns the rank to the population
    remove(i,list_1)
    max_n_cl <- as.data.frame(as.vector(tapply(pop$orden_dist[pop$dist <= ifelse(j <= l,d1,d2)], pop$cluster[pop$dist <= ifelse(j <= l,d1,d2)] ,max)))
    max_n_cl$cluster <- as.factor(row.names(max_n_cl))
    names(max_n_cl) <- c("max_n_cl","cluster")
    max_n_cl$max_n_cl <- ifelse(is.na(max_n_cl$max_n_cl),1,max_n_cl$max_n_cl)
    pop <- merge(pop,max_n_cl,by = "cluster" )
    pop$a_reasig <- ifelse(pop$orden_dist <= pop$max_n_cl & pop$orden_dist <= ifelse(j <= l,g1,g2), 0, 1)
    clusterizados[[j]] <- subset(pop,pop$a_reasig == 0)
    clusterizados[[j]]$round <- as.factor(j)
    pop <- subset(pop,pop$a_reasig == 1,select = c(x,y,weight))
    n <- nrow(pop)
    j <- j + 1
  }
  clust_it.output <- list(clustered = clusterizados, pop = pop)
}
