library(reshape2)
#if the Samsung data is not in your working directory
#downlaod and unzip
if(!file.exists('UCI HAR Dataset')){
  #download file
  download.file('https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip', 'rawdata.zip')
  #unzip file
  unzip('rawdata.zip')
}

#load raw dataframe
features      = read.table('UCI HAR Dataset/features.txt',header=FALSE)
activityType  = read.table('UCI HAR Dataset/activity_labels.txt',header=FALSE)
subjectTrain  = read.table('UCI HAR Dataset/train/subject_train.txt',header=FALSE)
xTrain        = read.table('UCI HAR Dataset/train/x_train.txt',header=FALSE)
yTrain        = read.table('UCI HAR Dataset/train/y_train.txt',header=FALSE)
subjectTest   = read.table('UCI HAR Dataset/test/subject_test.txt',header=FALSE)
xTest         = read.table('UCI HAR Dataset/test/x_test.txt',header=FALSE)
yTest         = read.table('UCI HAR Dataset/test/y_test.txt',header=FALSE)

#assign column names
names(xTrain) <- features$V2
names(subjectTrain) <- c('subjectId')
names(yTrain) <- c('activityId')
names(xTest) <- features$V2
names(subjectTest) <- c('subjectId')
names(yTest) <- c('activityId')

#combine columns
trainingData = cbind(subjectTrain, yTrain, xTrain)
testData = cbind(subjectTest, yTest, xTest)

#merges the training and the test sets to create one data set
df = rbind(trainingData,testData)
#write.table(df, file='refined.tab', quote = FALSE, sep = '\t', row.names = FALSE)

#extracts only the measurements on the mean and standard deviation for each measurement.
#build features to be extracted
toExtract <- c('subjectId', 'activityId')
extract <- c(toExtract, names(df)[grepl('.*mean.*|.*std.*', names(df))])

#refine
tidydf <- df[,extract]
names(tidydf) = gsub('-mean', 'Mean', names(tidydf))
names(tidydf) = gsub('-std', 'Std', names(tidydf))
names(tidydf) <- gsub('[-()]', '', names(tidydf))
tidydf$subjectId <- as.factor(tidydf$subjectId)
tidydf$activityId <- factor(tidydf$activityId, levels=activityType$V1, labels=activityType$V2)

tmpdf <- melt(tidydf, id = c("subjectId", "activityId"))
tidyMean <- dcast(tmpdf, subjectId + activityId ~ variable, mean)

#save
write.table(tidyMean, file='tidy.txt', quote = FALSE, sep = '\t', row.names = FALSE)
