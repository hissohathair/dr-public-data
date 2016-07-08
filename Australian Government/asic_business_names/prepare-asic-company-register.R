
setwd("~/Dropbox (Data Republic)/Personal folders/Dan/Data Loading/Australian Government/asic_business_names/raw")
if ( !exists("csvFile")) {
  csvFile <- read.csv("BUSINESS_NAMES_201606.csv", sep = "\t", quote = "", 
                      colClasses = c(rep("character",5)),
                      fill = TRUE, blank.lines.skip = TRUE, strip.white = TRUE,
                      fileEncoding = "iso-8859-1")
}
print("Done reading.")
dim(csvFile)
#summary(csvFile)

write.table(csvFile, file = "BUSINESS_NAMES_DATASET_201606_fixed_byR.csv", quote = TRUE,
            sep = ",", col.names = FALSE, row.names = FALSE, na = "",
            qmethod = "double", fileEncoding = "utf8")
print ("Done writing.")

remove(csvFile)
