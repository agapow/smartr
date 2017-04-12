
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

main <- function (nodeAsVar=FALSE, calcZScore=FALSE, aggregateProbes=FALSE) {
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

    print (nodeAsVar)
    print (mode(nodeAsVar))

    ## Preconditions & preparation:
    exprData <- loaded_variables$highDimensional_n0_s1
    if (nrow (exprData) == 0) {
        stop ("The input data is empty: either the specified subset
            has no matching data in the selected node, or the
            gene/pathway is not present.");
    }

    ## Main:
    # NOTE: at this point, the data columns are:
    # Row.Label, Bio.marker, [patients X1, X2, ...]

    # handle options:
    if (aggregateProbes) {
        exprData <- pca_probe_aggregation (exprData,
            collapseRow.method = "MaxMean",
            collapseRow.selectFewestMissing=TRUE
        )
    }

    if (calcZScore) {
        # TODO: check for other headers / id columns or consistent in SmartR?

        # need to move into a more useful format:
        # Row.Label, Bio.marker, PatientID, Value
        exprData <- melt (rna_data, c('Row.Label', 'Bio.marker'),
            variable.name="PatientID", value.name="Value")

        exprData <- ddply (exprData, "Row.Label", transform, probe.md=median (Value, na.rm = TRUE))
        exprData <- ddply (exprData, "Row.Label", transform, probe.sd=sd (Value, na.rm = TRUE))

        exprData$Value = with (exprData, ifelse (probe.sd == 0, 0,
            (exprData$Value - exprData$probe.md) / exprData$probe.sd))
            exprData$Value = with (exprData,
                ifelse (Value > 2.5, 2.5,
                ifelse (Value < -2.5, -2.5, Value)
            )
        )
        exprData$Value = round (exprData$Value, 9)
        exprData$probe.md = NULL
        exprData$probe.sd = NULL
    }

    # for poorly curated data, drop columns where there are one or more missing values
    exprData <- subset (exprData, select = colSums (is.na(exprData))<1)
    printf ("rows %d cols %d NA columns dropped", nrow(exprData), ncol(exprData))
    if (ncol (exprData) == 0) {
        stop ("The selected cohort has incomplete data for each of your biomarkers.
            No data is left to plot a PCA with.");
    }

    # actually do the analysis, need purely numeric matrix
    rownames (exprData) <- paste (exprData$Row.Label, exprData$Bio.marker, sep='_')
    exprData$Row.Label <- NULL
    exprData$Bio.marker <- NULL
    print ("Doing the actual analysis")
    print (exprData)
    pca_results <- prcomp (exprData, center=TRUE, scale=TRUE)

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
        analysis = 'pca',
        data_name = fetch_params$ontologyTerms$highDimensional_n0$name,
        data_fullname = fetch_params$ontologyTerms$highDimensional_n0$fullName,

        max_gene_list_len = MAX_GENE_LIST_LEN,
        component_summary = component_summary,
        max_pcs_to_show = max_pcs_to_show,
        sdev = pca_results$sdev,
        numberOfComponents = length (pca_results$sdev),
        rotation = pca_results$rotation,
        sdev = pca_results$sdev
    )

    return (toJSON (output))   	
}


pca_probe_aggregation <- function (exprData, collapseRow.method,
        collapseRow.selectFewestMissing, output.file="aggregated_data.txt") {

    #Create a unique identifier column and row names
    castedData$UNIQUE_ID <- paste (castedData$Bio.marker, castedData$Row.Label, sep="_")
    rownames (castedData) = castedData$UNIQUE_ID

    #Run the collapse on a subset of the data by removing some columns.
    finalData <- collapseRows (
        subset (castedData, select = -c(Bio.marker, Row.Label, UNIQUE_ID)),
        rowGroup = castedData$Bio.marker,
        rowID = castedData$UNIQUE_ID,
        method = collapseRow.method,
        connectivityBasedCollapsing = TRUE,
        methodFunction = NULL,
        connectivityPower = 1,
        selectFewestMissing = collapseRow.selectFewestMissing,
        thresholdCombine = NA
    )

    #Coerce the data into a data frame.
    finalData <- data.frame (finalData$group2row, finalData$datETcollapsed)

    # rename the columns back to original form
    colnames(finalData)[2] <- 'UNIQUE_ID'
    finalData <- merge(finalData,castedData[c('UNIQUE_ID','Row.Label')],by=c('UNIQUE_ID'))
    finalData <- subset(finalData, select = -c(UNIQUE_ID))

    # set the column names again.
    colnames (finalData)[1] <- "Bio.marker"

    return (finalData)
}


### END ###
