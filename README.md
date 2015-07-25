# Tidy Data Project

Only one script required: run_analysis.R

The script mostly follows the order of the assignment:

     1. Merges the training and the test sets to create one data set.
     
     2. Extracts only the measurements on the mean and standard deviation for each measurement. 
     
     3. Uses descriptive activity names to name the activities in the data set
     
     4. Appropriately labels the data set with descriptive variable names. 
     
     5. From the data set in step 4, creates a second, independent tidy data set with the average of each  
        variable for each activity and each subject.

#Part one

First, reads into R the column names and activity key. Then it reads all of the data from the test and train folders and renames the columns. This is the only part of the script done out of order: this effectively completes parts 1 and 4 at the same time. 

X_test and X_train contain the actual data, and subject_test/train and Y_test/train contain identifiers for the subjects and activities, respectively. Build the tables with appropriate column names and then combine them with an rbind() and parts 1 and 4 are done.

#Part two

Utilizes grep() function. From R documentation: grep search[es] for matches to argument pattern within each element of a character vector. 

Calling grep("mean",names(df.combinedSample)) will go through all of the column names and find the index values of any that have a match with the string "mean"; this lets you pull only the columns associated with means. Similarly, calling the same function but with "std" will pull all of the columns representing standard deviations. Finally, combine the tables and keep the two indexes for subject and activity from the original table. I also went ahead and scrubbed some of the old tables out to make sure memory doesn't become an issue later on.

This methodology was chosen because after inspecting the column names, it was clear that all of the means and standard deviations contained the string "mean" and "std". There are other column names that contain the string "Mean", and these were intentionally excluded because those columns represent angle measurements and do not appear to be actual means themselves but rather take as inputs the mean direction of gravity.

#Part three

Uses the match() function to match activity ID numbers originally contained in Y_test.txt and Y_train.txt to the corresponding strings that can be found in activity_labels.txt. This searches for the locations of matches between the value in the ActivityIndex column in the big table and their corresponding string values in the activity_labels table and replaces the numeric IDs with those strings.

#Part four

As mentioned above, this was completed during step 1 by defining colNames = ... in the data.frame() function calls in that step.

#Part five

Uses reshape and plyr packages to generate a long form of output table. melt() from reshape takes the current output table with lots of columns and restructures it such that there is a new row for every subject/activity/variable observation where variable corresponds to the non-subject/activity column names (e.g. tBodyAcc.mean...X as the recorded mean x-axis body acceleration in the time domain). 

If it helps, note that the table created from steps 1 through 4 has 10299 observations of 81 variables. The melt.output table has 813621 observations of 4 variables; it is not a coincidence that 10299 * 81 = 813621. 

The advantage of restructuring the table in this way is it makes for a simple ddply() call; this function takes the averages (mean and median) of all observations that share the same subject/activity/variable and thus the output of this ddply call will have one row for each unique set of subject/activity/variable and each row will contain those three along with the mean and median across all observations that share all three of those in common.


