
### IMPORTS

library (jsonlite)
library (plyr)
library (reshape2)
library(WGCNA)

# TODO: ugh - cannot get this to work consistently across the web & desktop
# SHARED_FXN_DIR <- "web-app/HeimScripts/_shared_functions"
# source (paste(remoteScriptDir, "/Generic/utils.R", sep=""))


### CONSTANTS & DEFINES

# in development? FALSE, "web" or "r"
DEV = "web"

# maximum number of genes to allow
MAX_GENE_LIST_LEN <- 20

# how many components to display
MAX_DISPLAY_COMPONENTS <- 10


### CODE ###

## Utils:
# TODO: how we reliably source the shared components in R and web?

# a print with sane formatting
printf <- function(...) cat (sprintf(...))


# trim flanking whitespace
trim <- function (x) gsub("^\\s+|\\s+$", "", x)



## Main:

main <- function (dropMissingSubjects=FALSE, calcZScore=FALSE, aggregateProbes=FALSE) {
    # TODO: aggregate probes?

    ## Dev & debugging:
    ## Dev:
    if (DEV == 'web') {
        # if running through web, save the data
        save (loaded_variables, file="/homes/pagapow/SmartR/Pca/loaded_variables.Rda")
        save (fetch_params, file="/homes/pagapow/SmartR/Pca/fetch_params.Rda")
    }
    if (DEV == 'r') {
        # if running through r, load the data
        save (loaded_variables, file="/homes/pagapow/SmartR/Pca/loaded_variables.Rda")
        save (fetch_params, file="/homes/pagapow/SmartR/Pca/fetch_params.Rda")
    }
    if (DEV != FALSE) {
        print ("In development for pca/run.R")
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
    expr_data <- loaded_variables$highDimensional_n0_s1
    if (nrow (expr_data) == 0) {
        stop ("The input data is empty: either the specified subset
            has no matching data in the selected node, or the
            gene/pathway is not present.");
    }

    ## Main:
    # NOTE: at this point, the data columns are:
    # Row.Label, Bio.marker, [patients X1, X2, ...]

    initial_rows <- nrow (expr_data)

    # handle options:
    if (aggregateProbes) {
        expr_data <- pca_probe_aggregation (expr_data,
            collapse_method="MaxMean",
            select_fewest_missing=TRUE
        )
    }

    if (calcZScore) {
        expr_data <- convert_to_zscore (expr_data)
    }

    if (dropMissingSubjects) {
        # for poorly curated data, drop columns where there are one or more missing values
        expr_data <- subset (expr_data, select = colSums (is.na(expr_data))<1)
    }


    if (ncol (expr_data) == 0) {
        stop ("The selected cohort has incomplete data for each of your biomarkers.
            No data is left to plot a PCA with.");
    }

    # need purely numeric matrix for analysis
    rownames (expr_data) <- paste (expr_data$Row.Label, expr_data$Bio.marker, sep='_')
    expr_data$Row.Label <- NULL
    expr_data$Bio.marker <- NULL
    # remove columns that are all null
    print (which(apply(expr_data, 2, var)==0))
    print (expr_data)
    expr_data <- expr_data[, ! apply (expr_data, 2, var, na.rm=TRUE) %in% c(0.0, NA)]

    # actually do the analysis
    print ("Doing the actual analysis")
    print (expr_data)
    pca_results <- prcomp (expr_data, center=TRUE, scale=TRUE, na.action=na.omit)

    # extract useful info
    pca_summary <- summary (pca_results)
    importance <- pca_results$importance
    porp_var <- importance[2,]
    cum_var  <- importance[3,]

    # post-analysis:
    # get the number of components.
    numberOfComponents <- length (pca_results$sdev)
    print ("Number of components:")
    print (numberOfComponents)
    max_pcs_to_show <- min (MAX_DISPLAY_COMPONENTS, numberOfComponents)

    # trim number of genes
    gene_list_len <- min (MAX_GENE_LIST_LEN, length (pca_results$center))

    #Create a data frame with 1 row per component.
    #Create a table with Eigen Value and %Variation.
    component_summary <- data.frame (paste ("PC", 1:numberOfComponents, sep=""))
    component_summary$Eigenvalue <- round (pca_results$sdev[1:numberOfComponents]**2,5)
    component_summary$Percent_variance <- round (pca_results$sdev[1:numberOfComponents]**2 / sum(pca_results$sdev**2) * 100,5)
    colnames (component_summary) <- c('Component','Eigenvalue','Percent_variance')

    ## Postconditions & return:
    # create json and return
    # Note: can't JSONify the whole prcomp result
    output <- list(
        # NOTE: single numbers are always rendered as list, 'cos they're lists in R
        # Doesn't seem to be any way around this.
        params = list (
            analysisType = 'PCA',
            dataSource = fetch_params$ontologyTerms$highDimensional_n0$fullName,
            dropMissingSubjects=dropMissingSubjects,
            calcZScore=calcZScore,
            aggregateProbes=aggregateProbes,
            maximumGenes = MAX_GENE_LIST_LEN,
            initialRows = initial_rows,
            rowsWithData = nrow (expr_data)
        ),

        numberOfComponents = length (pca_results$sdev),
        componentSummary = component_summary,
        porpVariance = porp_var,
        cumVariance = cum_var,

        sdev = pca_results$sdev,
        pca_rotation = pca_results$rotation,
        pca_points = pca_results$x
    )

    return (toJSON (output))   	
}


convert_to_zscore <- function (expr_data) {
    # NOTE: original used median not mean, go figure

    ## Main:
    num_df <- subset (expr_data, select = -c(Bio.marker, Row.Label))

    # flip so can use scale() on it
    trans_df <- t (num_df)
    trans_df <- scale (trans_df, center=TRUE, scale=TRUE)

    # flip back and add back cols
    rev_df <- t (trans_df)
    rev_df$Bio.marker <- num_df$Bio.marker
    rev_df$Row.Label <- num_df$Row.Label

    ## Postconditions & return
    return (rev_df)
}

pca_probe_aggregation <- function (expr_data, collapse_method, select_fewest_missing) {

    # NOTE: at this point, the data columns are:
    # Row.Label, Bio.marker, [patients X1, X2, ...]

    # create a row grouping
    row_groups <- paste (expr_data$Bio.marker, expr_data$Row.Label, sep="_")
    row_ids = make.names (expr_data$GROUP, unique=TRUE)

    agg <- collapseRows (
        # get rid of non-numeric columns
        subset (expr_data, select = -c(Bio.marker, Row.Label)),
        rowGroup = row_groups,
        rowID = row_ids,
        method = collapse_method,
        connectivityBasedCollapsing = TRUE,
        methodFunction = NULL,
        connectivityPower = 1,
        selectFewestMissing = select_fewest_missing,
        thresholdCombine = NA
    )

    # reduce data to the selected rows
    agg_data <- expr_data[agg$selectedRow,]

    # NOTE: there was hideously complicated set of manipulations here that
    # seemed to be unnecessary if you just do things like above. I think.

    ## Postconditions & return:
    return (agg_data)
}


### END ###
