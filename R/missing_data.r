#' Dropout Missing Data
#' 
#' Function that inputs simulated data and returns data frame with
#' new response variable that includes missing data. This function
#' does dropout missing data, that is missing data dependent on time.
#' Likely most appropriate for longitudinal data.
#' 
#' The function returns two new variables to the original data frame.
#' The first is a dichotomous variable representing whether the response
#' variable would be marked as NA (1) or not (0). The second is a 
#' re-representation of the response variable with the values coded as 
#' NA named 'sim.data2'.
#' 
#' @param sim_data Simulated data frame
#' @param resp_var Response variable to add missing data to
#' @param clust_var Cluster variable used for the grouping.
#' @param miss_prop Proportion of missing data overall or a vector
#'           the same length as the number of clusters representing the
#'           percentage of missing data for each cluster
#' @import dplyr
#' @export 
dropout_miss <- function(sim_data, resp_var = 'sim.data', 
                        clust_var = 'clustID', miss_prop) {
  
  if(resp_var %ni% names(sim_data)) {
    stop(paste(resp_var, 'not found in variables of data supplied'))
  }
  if(clust_var %ni% names(sim_data)) {
    stop(paste(clust_var, 'not found in variables of data supplied'))
  }
  
  len_groups <- with(sim_data, tapply(eval(parse(text = resp_var)), 
                                  eval(parse(text = clust_var)),
                                  length))
  num_obs <- nrow(sim_data)
  
  if(length(miss_prop) == 1) {
    if(miss_prop > 1) {
      miss_prop <- miss_prop / 100
    }
    total_missing <- num_obs * miss_prop
    missing_range <- round((total_missing *.98):(total_missing * 1.02))
    n_groups <- with(sim_data, length(unique(eval(parse(text = clust_var)))))
    
    lim <- prop_limits(miss_prop)
    
    num_missing <- 0
    while(sum(num_missing) %ni% missing_range) {
      num_missing <- round(len_groups * round(runif(n_groups, lim[1], lim[2]), 2))
    }
    
  } else {
    num_missing <- round(len_groups * miss_prop, 0)
  }
    
  missing_obs <- lapply(1:length(num_missing), function(xx) 
    (len_groups[xx] - num_missing[xx] + 1):len_groups[xx])
  
  data_split <- with(sim_data, split(sim_data, eval(parse(text = clust_var))))
  
  sim_data$missing <- do.call("c", lapply(1:length(missing_obs), function(xx)
    ifelse(data_split[[xx]]$withinID %in% missing_obs[[xx]], 1, 0)))
  
  sim_data$sim.data2 <- with(sim_data, ifelse(missing == 1, NA, eval(parse(text = resp_var))))
  
  sim_data
}


#' Random Missing Data
#' 
#' Function that inputs simulated data and returns data frame with
#' new response variable that includes missing data. This function 
#' simulates data that is randomly missing or missing completely at
#' random.
#' 
#' The function returns two new variables to the original data frame.
#' The first is a dichotomous variable representing whether the response
#' variable would be marked as NA (1) or not (0). The second is a 
#' re-representation of the response variable with the values coded as 
#' NA named 'sim.data2'.
#' 
#' @param sim_data Simulated data frame
#' @param resp_var Response variable to add missing data to
#' @param clust_var Cluster variable used for the grouping.
#' @param miss_prop Proportion of missing data overall or a vector
#'           the same length as the number of clusters representing the
#'           percentage of missing data for each cluster
#' @import dplyr
#' @export 
random_missing <- function(sim_data, resp_var = 'sim.data',
                           clust_var = 'clustID', miss_prop) {
  
  if(resp_var %ni% names(sim_data)) {
    stop(paste(resp_var, 'not found in variables of data supplied'))
  }
  if(clust_var %ni% names(sim_data)) {
    stop(paste(clust_var, 'not found in variables of data supplied'))
  }
  
  len_groups <- with(sim_data, tapply(eval(parse(text = resp_var)), 
                                      eval(parse(text = clust_var)),
                                      length))
  
  n_obs <- nrow(sim_data)
  
  if(length(miss_prop) == 1) {
    if(miss_prop > 1) {
      miss_prop <- miss_prop / 100
    }
    total_missing <- num_obs * miss_prop
    missing_range <- round((total_missing *.98):(total_missing * 1.02))
    n_groups <- with(sim_data, length(unique(eval(parse(text = clust_var)))))
    
    lim <- prop_limits(miss_prop)
    
    num_missing <- 0
    while(sum(num_missing) %ni% missing_range) {
      num_missing <- round(len_groups * round(runif(n_groups, lim[1], lim[2]), 2))
    }
    
  } else {
    num_missing <- round(len_groups * miss_prop, 0)
  }
  
  missing_obs <- lapply(1:length(num_missing), function(xx) 
    sample(1:len_groups[xx], num_missing[xx]))
  
  data_split <- with(sim_data, split(sim_data, eval(parse(text = clust_var))))
  
  sim_data$missing <- do.call("c", lapply(1:length(missing_obs), function(xx)
    ifelse(data_split[[xx]]$withinID %in% missing_obs[[xx]], 1, 0)))
  
  sim_data$sim.data2 <- with(sim_data, ifelse(missing == 1, NA, eval(parse(text = resp_var))))
  
  sim_data
}
