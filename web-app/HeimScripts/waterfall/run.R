
### IMPORTS


### CONSTANTS & DEFINES

# in development? FALSE, "web" or "r"
DEV = "web"


### CODE ###

## Utils:

# If 'blank/empty' return null, else convert to number
toNullOrNumber <- function (x) {
    # NOTE: can't check for NULL in list
    if (is.null (x) || (x %in% c(NA, NULL, '', ""))) {
        return (NULL)
    } else {
        return (as.numeric (x))
    }
}


## Main:

main <- function (lowRangeValue=NULL, highRangeValue=NULL) {

    ## Dev:
    if (DEV == 'web') {
        # if running through web, save the data
        save (loaded_variables, file="/homes/pagapow/SmartR/Waterfall/loaded_variables.Rda")
        save (fetch_params, file="/homes/pagapow/SmartR/Waterfall/fetch_params.Rda")
    }
    if (DEV == 'r') {
        # if running through r, load the data
        save (loaded_variables, file="/homes/pagapow/SmartR/Waterfall/loaded_variables.Rda")
        save (fetch_params, file="/homes/pagapow/SmartR/Waterfall/fetch_params.Rda")
    }
    if (DEV != FALSE) {
        print ("----")
        print ("In development for waterfall/run.R")
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
    # check parameters
    lowRangeValue <- toNullOrNumber (lowRangeValue)
    highRangeValue <- toNullOrNumber (highRangeValue)

    if ((! is.null (lowRangeValue)) &&
        (! is.null (highRangeValue)) &&
        (highRangeValue <= lowRangeValue)) {
        stop ("low range must be less than high range")
    }

    numData <- loaded_variables$numData_n0_s1

    ## Main:
    # remove the rows with NA values
    initial_row_cnt <- nrow (numData)
    numData <- numData[complete.cases(numData),]
    result_row_cnt <- nrow (numData)

    # order by data and then row id
    numData <- numData[order(numData[2], numData[1]),]

    # name cols on output
    colnames(numData) <- c("Patient ID", "Value")

    # set display params
    displayLow <- if (is.null (lowRangeValue)) min (numData$Value) - 1 else lowRangeValue
    displayHigh <- if (is.null (highRangeValue)) max (numData$Value) + 1 else highRangeValue

    # classify data
    valType <- sapply (numData$Value,
        function (x) {
            if (x <= displayLow) {
                return (-1)
            } else if (displayHigh <= x) {
                return (1)
            } else {
                return (0)
            }
        },
        USE.NAMES=FALSE
    )
    numData$valueClass <- valType

    ## Postconditions & return:
    output <- list(
        # NOTE: single numbers are always rendered as list, 'cos they're lists in R
        # Doesn't seem to be any way around this.
        params = list (
            analysisType = 'waterfall',
            dataSource = fetch_params$ontologyTerms$numData_n0$fullName,
            lowRangeValue = lowRangeValue,
            highRangeValue = highRangeValue,
            initialRows = initial_row_cnt,
            rowsWithData = result_row_cnt
        ),

        displayLow = displayLow,
        displayHigh = displayHigh,

        points = numData
    )

    return (toJSON(output))
}

