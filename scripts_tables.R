# Copyright (c) 2014, the SAVI authors (see AUTHORS.txt).
# Licensed under the BSD 3-clause license (see LICENSE.txt)

# this file holds the table generating functions

makeTableCePlane <- function(lambda, comparator, cache) {
  costs <- cache$costs
  effects <- cache$effects
  comp <- which(colnames(costs)%in%comparator)
  incCost <- (costs - costs[, comp])[, -comp, drop=FALSE]
  incBen <- (effects - effects[, comp])[, -comp, drop=FALSE]
  inb <- incBen * lambda - incCost
  npsa <- NROW(costs)
  tableCePlane <- matrix(NA, ncol=ncol(costs) - 1, nrow = 14) # incremental, no zero column
  tableCePlane[1, ] <- colnames(costs)[-comp]
  tableCePlane[2, ] <- format(lambda, digits=4, nsmall = 0)
  tableCePlane[3, ] <- colnames(costs)[comp]
  tableCePlane[4, ] <- format(npsa)
  tableCePlane[5, ] <- format(colMeans(incBen), digits=2, nsmall=2)
  tableCePlane[6, ] <- format(colMeans(incCost), digits=2, nsmall=2)
  tableCePlane[7, ] <- format(colMeans(incCost) /  colMeans(incBen), digits=2, nsmall=2)
  tableCePlane[8, ] <- format(apply(incBen, 2, quantile, 0.025), digits=2, nsmall=2)
  tableCePlane[9, ] <- format(apply(incBen, 2, quantile, 0.975), digits=2, nsmall=2)
  tableCePlane[10, ] <- format(apply(incCost, 2, quantile, 0.025), digits=2,  nsmall=2)
  tableCePlane[11, ] <- format(apply(incCost, 2, quantile, 0.975), digits=2, nsmall=2)
  tableCePlane[12, ] <- format(apply(incCost, 2, function(x) sum(x < 0)) / npsa, digits=2, nsmall=2)
  tableCePlane[13, ] <- format(apply(incBen, 2, function(x) sum(x > 0)) / npsa, digits=2, nsmall=2)
  tableCePlane[14, ] <- format(apply(inb, 2, function(x) sum(x > 0)) / npsa, digits=2, nsmall=2)
  #colnames(tableCePlane) <- colnames(costs)[-comp]
  tableCePlane
}

makeTableNetBenefit <- function(costs.int, effects.int, lambda, nInt) {
  
  tableNetBenefit <- matrix(NA, ncol= nInt, nrow = 8) 
  for (i in 1:nInt) {
    tableNetBenefit[1,i] <- format(mean(effects.int[,i]), digits=2, nsmall=4)
    tableNetBenefit[2,i] <- format(mean(costs.int[,i]), digits=2, nsmall=2)
    tableNetBenefit[3,i] <- format(mean(effects.int[,i] * lambda - costs.int[,i]), digits=2, nsmall=2)
    tableNetBenefit[4,i] <- format(quantile(effects.int[,i] * lambda - costs.int[,i], 0.025), digits=2, nsmall=2)
    tableNetBenefit[5,i] <- format(quantile(effects.int[,i] * lambda - costs.int[,i], 0.975), digits=2, nsmall=2) 
    tableNetBenefit[6,i] <- format(mean(effects.int[,i] - (costs.int[,i] / lambda)), digits=2, nsmall=4)
    tableNetBenefit[7,i] <- format(quantile(effects.int[,i] - (costs.int[,i] / lambda), 0.025), digits=2, nsmall=4)
    tableNetBenefit[8,i] <- format(quantile(effects.int[,i] - (costs.int[,i] / lambda), 0.975), digits=2, nsmall=4)
  }
  colnames(tableNetBenefit) <- colnames(costs.int)
  tableNetBenefit
}

# function for building up table of parameter sets for partial EVPI
buildSetStoreTable <- function(store, groupPartialEvpi, cache) {
  # maxRows <- max(unlist(lapply(store, length)))
  # tableRows <- lapply(store, function(x) c(x, rep("", maxRows - length(x))))
  groups <- sapply(store, function(x) {
    output <- paste(x, ", ", sep="", collapse="")
    output <- substr(output, 1, nchar(output) - 2)
    output})
  print(groups)
  print(df <- data.frame(groups, groupPartialEvpi))
  #Add and define extra columns
  df$indexed <- 0
  df$annualPrev <- 0
  df$horizon <- 0
  df1 <- data.matrix(df)
  df1[,4] <- df1[,2]/calcEvpi(cache$costs, cache$effects, cache$lambdaOverall)
  df1[,5] <- df1[,2]*cache$annualPrev
  df1[,6] <- df1[,2]*cache$annualPrev*cache$horizon      
  rownames(df) <- c(paste("Set", 1:(length(store))))
  colnames(df) <- c("Parameters", paste("Per Person EVPPI (", cache$currency, ")", sep=""), "Standard Error","Indexed to Overall EVPI = 1.00", 
                    paste("EVPPI for ", cache$jurisdiction, " Per Year (", cache$currency, ")", sep=""), 
                    paste("EVPPI for ", cache$jurisdiction, " over ", cache$horizon, " years (", cache$currency, ")", sep=""))
  df[,4] <- df1[,4]
  df[,5] <- df1[,5]
  df[,6] <- df1[,6]   
  df
}

bold.allrows <- function(x) {
  h <- paste('<strong>',x,'</strong>', sep ='')
  h
}
