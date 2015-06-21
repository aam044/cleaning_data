if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

# Load features
features <- read.table("./features.txt", col.names=c("feature.id","feature.name"))

# Get features that has mean() or std() in the name
mean_std <- grepl("(mean|std)\\(\\)", features$feature.name)

# Setting user friendly column names
columns_name <- features$feature.name

l_name_patterns <- c("^t{1}","^f{1}","*BodyBody*","*Body*","*Acc*", "*Gravity*","*Gyro*", "*Mag*", "*Jerk*", "-mean\\(\\)", "-std\\(\\)", "-X", "-Y", "-Z")
l_repl_patterns <- c("Time ", "Frequency ","Body","Body ","Accelerator ", "Gravity ", "Gyroscope ","Magnitude ", "Jerk ", "the mean ", "standard deviation ", "of X", "of Y", "of Z")
for ( i in 1:length(l_name_patterns) )
{
  columns_name <- gsub( pattern  = l_name_patterns[i]
                                 , replacement = l_repl_patterns[i]
                                 , x           = columns_name
  )
}

# Load Train related data
train.set <- read.table("./train/X_train.txt", col.names=columns_name)
train.labels <- read.table("./train/y_train.txt", col.names=c("activity.id"))
train.subject <- read.table("./train/subject_train.txt", col.names=c("subject.id"))

# Load Test related data
test.set <- read.table("./test/X_test.txt", col.names=columns_name)
test.labels <- read.table("./test/y_test.txt", col.names=c("activity.id"))
test.subject <- read.table("./test/subject_test.txt", col.names=c("subject.id"))

# Extracts only the measurements on the mean and standard deviation for each measurement.
train.subset <- train.set[mean_std]
test.subset <- test.set[mean_std]

# Add New variables
# Adding activity.id to subsets
train.subset$activity.id <- train.labels$activity.id
test.subset$activity.id <- test.labels$activity.id

# Add Subject Id
train.subset$subject.id <- train.subject$subject.id
test.subset$subject.id <- test.subject$subject.id

# Source of data - just in case we need it
train.subset$origin <- "train"
test.subset$origin <- "test"

# Join two datasets
combo.sets <- rbind(train.subset,test.subset)

# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive activity names.

# Load activity labels 
activity.labels <- read.table("./activity_labels.txt", col.names=c("activity.id","activity.label"))
combo.sets <- merge(combo.sets,activity.labels, by="activity.id")

# Creates a second, independent tidy data set with the average of each variable for each activity and each subject
library(reshape2)
measure.names <- colnames(combo.sets)[!(colnames(combo.sets) %in% c("activity.id","subject.id","origin","activity.label"))]

combo.melt <- melt(combo.sets, id=c("subject.id","activity.label"), measure.vars=measure.names)

combo.tidy <- dcast(combo.melt, subject.id+activity.label ~ variable, mean)

# Save the tidy dataset
write.table(combo.tidy,"tidy.txt", row.name=FALSE)
