prepDataSet <- function() {
        ## We expect a zip file of a certain name in working directory
        ## and return the resulting list
        ## Lenght of 0 for that list would indicate an error
        fileName <- "getdata-projectfiles-UCI HAR Dataset.zip"
        ds <- unzip(fileName)
        ds
}

chooseVariables <- function() {
        ## Do all the choosing and decorating of our columns here
        ## returns a data frame with 
        ## id - 1st column indexing into the source data
        ## measureName - 2nd column with suitable names to be used
        colFileName <- "UCI HAR Dataset/features.txt"
        colData <- read.table(colFileName, col.names=c("varId","varName"))
        requiredVariables <- sqldf('select * from colData where varName like "%-mean%" or varName like "%-std%"', stringsAsFactors=FALSE)
        requiredVariables
}

getActivityInfo <- function () {
        activityDataFileName <- "UCI HAR Dataset/activity_labels.txt"
        activityData <- read.table(activityDataFileName, col.names=c("actId", "actLabel"))
        data.table(activityData)
}


getData <- function(data_source) {
        ## read all the data for one set, i.e. data_source is test or train
        ## prepare it to be merged
        
        ## Merge labels about activity with actual activity records
        data_dir <- "UCI HAR Dataset/"
        y_data_file <- paste(c(data_dir, data_source, "/y_", data_source, ".txt"), sep="", collapse="")
        y_data <- data.table(read.table(y_data_file, col.names=c("actId")))
        setkey(y_data, actId)
        act_info <- getActivityInfo()
        setkey(act_info, actId)
        y_data_act_info <- merge(y_data, act_info)    
        
        # Get the data set
        X_data_file <- paste(c(data_dir, data_source, "/X_", data_source, ".txt"), sep="", collapse="")
        X_data <- data.table(read.table(X_data_file))
        ## Get column names required for our data set
        req_data_cols <- chooseVariables()
        # Select only the columns we are interested in
        X_data_subset <- X_data[, req_data_cols$varId, with = FALSE]
        
        subject_file <- paste(c(data_dir, data_source, "/subject_", data_source, ".txt"), sep="", collapse="")
        subject_data <- data.table(read.table(subject_file, col.names=c("subjectId")))
        
        # return a complete data set
        res_data <- data.table(subject_data, y_data_act_info$actLabel, X_data_subset)
        # set the column names
        setnames(res_data, c(colnames(subject_data), colnames(y_data_act_info)[2], as.character(req_data_cols$varName)))
}

run_analysis <- function() {
        
        # Unzip the file
        ds <- prepDataSet()
        
        # get test data
        test_data <- getData("test")
        
        # get train data
        train_data <- getData("train")
        
        # combine both sets
        all_data <- rbind(test_data, train_data)
        
        # Get the mean by person and activity
        all_data_grp <- group_by(all_data, subjectId, actLabel)
        all_data_grp_sum <- summarise_each(all_data_grp, funs(mean))
        
        # write the table
        write.table(all_data_grp_sum, "combined_activity_data.txt", row.name = FALSE)
        
        # return the data
        all_data_grp_sum
}