####################################################
#
#     This script:
#     
#     1. Merges the training and the test sets to create one data set.
#     2. Extracts only the measurements on the mean and standard deviation for each measurement. 
#     3. Uses descriptive activity names to name the activities in the data set
#     4. Appropriately labels the data set with descriptive variable names. 
#     5. From the data set in step 4, creates a second, independent tidy data set with the average of each  
#        variable for each activity and each subject.
#

#############################################################
#     Step 1: Merge the two data sets.
#     

homeDirectory = getwd()

#     We are going to need "features" to assign column names to the 561-variable X_test and X_train
#     tables. "activity_labels" contains only 6 rows and is used to decrypt the 
#     Y_test and Y_train tables into the associated activities they represent.

features <- read.table(paste(homeDirectory, "/UCI HAR Dataset/features.txt", sep=""), 
                       col.names = c("Index", "Feature"))
activity_labels <- read.table(paste(homeDirectory, "/UCI HAR Dataset/activity_labels.txt", sep=""), 
                              col.names = c("Index", "Activity"))

#     Build the tables from the .txt files
#     Grab the raw data and subject/activity index data from the test folder
#     Column names are assigned using the features table from above
#     This is actually taking care of step 4 a little early, but it is easiest to just go ahead 
#     and get it done up front.

subject_test <- read.table(paste(homeDirectory, "/UCI HAR Dataset/test/subject_test.txt", sep=""), 
                           col.names = c("Subject"))
X_test <- read.table(paste(homeDirectory, "/UCI HAR Dataset/test/X_test.txt", sep=""), 
                     col.names = features$Feature)
Y_test <- read.table(paste(homeDirectory, "/UCI HAR Dataset/test/Y_test.txt", sep=""),
                     col.names = c("ActivityIndex"))

#     Combine them into single data frame.
df.test <- data.frame(subject = subject_test,
                     Activity = Y_test,
                     X_test)

#     Repeat the above for the data in the "train" folder
subject_train <- read.table(paste(homeDirectory, "/UCI HAR Dataset/train/subject_train.txt", sep=""), 
                           col.names = c("Subject"))
X_train <- read.table(paste(homeDirectory, "/UCI HAR Dataset/train/X_train.txt", sep=""), 
                     col.names = features$Feature)
Y_train <- read.table(paste(homeDirectory, "/UCI HAR Dataset/train/Y_train.txt", sep=""),
                     col.names = c("ActivityIndex"))

df.train <- data.frame(subject = subject_train,
                     Activity = Y_train,
                     X_train)

#     Last step is simply to combine them using an rbind() call. They were constructed to
#     have matching column dimensions and matching column names. This completed part
#     1 of this script.
df.combinedSample <- rbind(df.test, df.train)

###################################################################
#     Part 2:
#     Extract only the measurements on the mean and standard deviation for each measurement.
#
#     To accomplish this, notice that the column names provided have the form "tBodyAcc.mean...X"
#     or "fBodyBodyGyroMag.std..". All of the means include the string "mean" and all of the standard
#     deviations include the string "std".
#     
#     The following code will search for partial matches on "mean" or "std" within the column name strings
#     and keep only the columns with matches
#
#     NOTE: specifically did NOT include partial match for "Mean". The upper case "Mean" only occurs
#     in association with angle measures at the very end of the table, and these are gravity angles and thus 
#     not means or standard deviations, so they were not included.

df.combinedSample.means <- df.combinedSample[,grep("mean",names(df.combinedSample))]
df.combinedSample.std <- df.combinedSample[,grep("std",names(df.combinedSample))]

df.output <- data.frame(df.combinedSample[,1:2], df.combinedSample.means, df.combinedSample.std)

#     Do a little bit of house keeping to keep the memory load down
rm(df.combinedSample, X_test, X_train, Y_train, Y_test, features,
   df.test, df.train, subject_test, subject_train,
   df.combinedSample.std, df.combinedSample.means)

############################################################################
#     Part 3:
#     Uses descriptive activity names to name the activities in the data set
#
#     This requires using the activity_labels object created at the beginning of the script.
#     Need to match column ActivityIndex from df.output to Index from activity_labels and
#     replace ActivityIndex values with descriptive strings

df.output$ActivityIndex <- activity_labels[match(df.output$ActivityIndex, activity_labels$Index),2]
names(df.output)[2] <- "Activity"

#####################################################################################
#     Part 4:
#     Appropriately labels the data set with descriptive variable names
#
#     This was completed during part 1 as that seemed to be the easiest time to do it.

#####################################################################################
#     Part 5:
#     From the data set in step 4, creates a second, independent tidy data set with the average of each  
#     variable for each activity and each subject.
#
#     Most easily accomplished using melt from reshape package with ddply from plyr package
#     NOTE: Asking for the average is a bit ambiguous, so both the mean and median were included.
#     Mode was not included because data are near enough to continuous that repeats are unlikely.

melt.output <- melt(df.output, id.vars=c("Subject", "Activity"))
df.averages <- ddply(melt.output, .(Subject, Activity, variable), summarize, mean=mean(value), median=median(value))

#     Last bit of house keeping
rm(melt.output, activity_labels)
