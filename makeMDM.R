# NOTE: not sure if this header is appropriate. RFX=0 is particularly troubling,
  # and NrOfStudies surely has to change.
require(magrittr)

makeMDM = function(conditionsFile) {
  
  suffix = strsplit(conditionsFile, "-")[[1]][2]
  suffix = strsplit(suffix, "\\.")[[1]][1]
  
  
  # List of all subjects and bolds
  subList = c("WIT001", "WIT002", "WIT003", "WIT004", "WIT005", "WIT006", "WIT007", "WIT008",
              "WIT009", "WIT010", "WIT011", "WIT012", "WIT013", "WIT014", "WIT015", "WIT016",
              "WIT017", "WIT018",
              #"WIT101", # Subject 101 was non-white, maybe his behavior is weird (really loves gun button, at least)
              "WIT102", "WIT103", "WIT104", "WIT105", "WIT106", "WIT107", "WIT108",
              "WIT109", "WIT110", "WIT111", "WIT112", "WIT113", "WIT114", "WIT115", "WIT116",
              "WIT117", "WIT118", "WIT119", "WIT120", "WIT121", "WIT123")
  boldList = c("b1", "b2", "b3", "b4", "b5", "b6")
  # read in spreadsheet of bad subject-BOLDs
  bad = read.table(file="list_of_bad_BOLDS.txt") # bad behavior bolds (e.g. accuracy, nonresponse)
  # ^^ Maybe I should stop dropping people for excess too-slow now that I model that as a confound.
#   badBold = 
#     paste("badBolds_", suffix, ".txt", 
#           sep = "") %>%
#     read.table
  badMotion = 
    paste("badMotion_", suffix, ".txt",
          sep = "") %>%
    read.delim
  badSubject = 
    paste("badSubs_", suffix, ".txt",
          sep = "") %>%
    read.delim
  
  
  # UPDATE THIS PROCESS TO MAKE IT AUTOMATIC, ABSTRACT INTO FUNCTION
  vtcList = c(); sdmList = c()
  for (sub in subList) {
    for (bold in boldList) {
      subno = as.numeric(substr(sub, 4, 6)); boldno = as.numeric(substr(bold, 2, 2))
      # these unweildly if() statements are actually necessary to get appropriate pairwise ANDs.
      if (length(bad$Subject[bad$Subject == subno & bad$Session == boldno]) >0) next
      if (subno %in% badSubject$Subject) next
      if (length(badMotion$subject[badMotion$subject == subno & badMotion$bold == boldno]) >0) next
      vtcFile = paste("\"/data/BartholowLab/JH_racebias/analysis/",
                      sub, "/",
                      sub, "_", bold, "_SCCAI2_3DMCTS_SD3DSS4.00mm_TAL.vtc\"",
                      sep="")
      sdmFile = paste("\"/data/BartholowLab/JH_racebias/analysis/SDMs_",
                      suffix,
                      "/",
                      sub, "_", bold, ".sdm\"",
                      sep="")
      vtcList = c(vtcList, vtcFile)
      sdmList = c(sdmList, sdmFile)
    }
  }
  
  mdm = matrix(c(vtcList, sdmList), ncol=2, nrow=length(vtcList))
  
  # change header NrOfStudies to length(vtcList)
  NrOfStudies = length(vtcList)
  header = "
FileVersion:          3
TypeOfFunctionalData: VTC

RFX-GLM:              0

PSCTransformation:    0
zTransformation:      1
SeparatePredictors:   0

NrOfStudies:"
  
  # Write that bitch
  mdmName = paste(suffix, "_", NrOfStudies, ".mdm", sep="")
  cat(header, "\t", NrOfStudies, "\n", file=mdmName)
  write(t(mdm), file=mdmName, append=T)
}
