# Getting and Cleaning data Course Project
*Technical Notes on how the tidy data set was processed and prepared*

## Environment
All processing was done on 3.1 Ghz Core i7 iMAC running OS X Yosemite 10.10.1

## Packages used
data.table, dplyr, sqldf

## Source of data
The script **run_analysis.R** expects the initial data file **getdata-projectfiles-UCI HAR Dataset.zip** to be present in the working directory.

The specific version of the file that was used to generate the output tidy data set was downloaded from [here][1] on January 15, 2015 at 20:45 EST using *download.file()* function.


## Steps to generate the final data set

1. *prepDataSet()* unzips the source file creating a set of files and directories to be processed and returning a list of the resulting files. 28 files are expected in total.

2. *chooseVariables()* uses *features.txt* to generate the column names for the final set of data given we need only extract **mean** and **standard deviation** variables. It uses **sqldf** package to search for the required variables.

3. *getData()* is the main worker function that for each set of train and test set of data loads and joins the data components such that the resulting data set has subject identification, activity name and all the relevant columns of **mean** and **standard deviation** variables

4. *run_analysis()* is the main driver function that calls *getData()* on each set, then combines the two results set and finally applies the summarization criteria - which is to group by subject and activity and calculate **mean**. The function returns a data table and also writes the results into **combined_activity_data.txt** file in current working directory. This is the file that will be submitted for grading. *write.table()* is used to create the output file.

[1]: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip