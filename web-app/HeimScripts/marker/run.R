
### IMPORTS

library (jsonlite)


### CONSTANTS & DEFINES

# in development? FALSE, "web" or "r"
DEV = "web"


### CODE ###

## Main:

main <- function (includeTable=FALSE) {

    ## Dev & debugging:
    ## Dev:
    if (DEV == 'web') {
        # if running through web, save the data
        save (loaded_variables, file="/homes/pagapow/SmartR/Marker/loaded_variables.Rda")
        save (fetch_params, file="/homes/pagapow/SmartR/Marker/fetch_params.Rda")
    }
    if (DEV == 'r') {
        # if running through r, load the data
        save (loaded_variables, file="/homes/pagapow/SmartR/Marker/loaded_variables.Rda")
        save (fetch_params, file="/homes/pagapow/SmartR/Marker/fetch_params.Rda")
    }
    if (DEV != FALSE) {
        print ("In development for marker/run.R")
        print ("Working directory:")
        print (getwd())
        print ("Files:")
        print (list.files())
        print ("Fxn call:")
        print (print (match.call()))
        print ("Params:")
        print (head (loaded_variables))
        print (fetch_params)
    }


    ## Preconditions & preparation:
    # get the names of the variables
    ont_terms <- fetch_params$ontologyTerms
    var_names <- sapply (names (ont_terms), function (x) { ont_terms[[x]]$name },
        USE.NAMES=FALSE)

    # get list of value lists
    vals <- sapply (loaded_variables, function (x) { x[2] }, USE.NAMES=FALSE )

    ## Main:
    # calc the quantiles
    intervals <- seq (0, 1, 0.05)
    # TODO: allow user to set intervals?
    res <- lapply (vals,
        function (x) { quantile (x, probs=intervals, na.rm=TRUE, names=FALSE ) } )

    # tidy into nice dataframe
    res_df <- data.frame (res)
    colnames (res_df) <- var_names
    rownames (res_df) <- intervals

    ## Postconditions & return:
    # create json and return
    # Note: can't JSONify the whole prcomp result
    output <- list(
        # NOTE: single numbers are always rendered as list, 'cos they're lists in R
        # Doesn't seem to be any way around this.
        params = list (
            analysisType = 'Marker plot',
            includeTable=includeTable
        ),

        results = res_df,
        variables = var_names
    )

    return (toJSON (output))   	
}



### END ###
