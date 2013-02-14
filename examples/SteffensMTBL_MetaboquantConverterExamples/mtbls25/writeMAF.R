# This is a simple example file to demonstrate
# reading MetaboQuant output, and create
# an Metabolights MAF file
# 
# AUTHORS: Steffen Neumann 
#
# To install the requirements run 
# the following commands in R
# 
# 	source("http://bioconductor.org/biocLite.R")
#       biocLite("Risa")
# 
# To run the example, launch R from the root NMR-ML directory then
# run 
# 
# 	source("tools/R/reader.R")
# 


library(Risa)

## Use mtbls1 as template
#ISAmtbls1 <- readISAtab("../mtbls1")
#mtbls1.maf <- read.delim("../mtbls1/m_live_mtbl1_rms_metabolite profiling_NMR spectroscopy_v2_maf.tsv")
#nmr.maf.columns <- colnames(mtbls1.maf)[1:18]

nmr.maf.columns <- c("database_identifier", "chemical_formula",
                     "smiles", "inchi", "metabolite_identification",
                     "chemical_shift", "multiplicity", "taxid",
                     "species", "database", "database_version",
                     "reliability", "uri", "search_engine",
                     "search_engine_score",
                     "smallmolecule_abundance_sub",
                     "smallmolecule_abundance_stdev_sub",
                     "smallmolecule_abundance_std_error_sub" )

## Read mtbls25
ISAmtbls25 <- readISAtab()

assaynames <- ISAmtbls25@assayname.to.sample[[1]]$"NMR Assay Name"
a.filename <- ISAmtbls25["assay.filenames"][[1]]

## Read MetaboQuant output. comment.char is a bad hack to exclude
## the summary statistics at the end of MetaboQuant output
Latin_Square_Quantification <- t(read.table("Results_Latin_Square_Quantification_Results.txt",
                                          comment.char="z"))

## Todo: Now write m_Latin_Square_maf.tsv
maf <- cbind("database_identifier"="",
             "chemical_formula"="",
             "smiles"="",
             "inchi"="",
             "metabolite_identification"=rownames(Latin_Square_Quantification),
             "chemical_shift"="",
             "multiplicity"="",
             "taxid"="",
             "species"="",
             "database"="",
             "database_version"="",
             "reliability"="",
             "uri"="",
             "search_engine"="",
             "search_engine_score"="",
             "smallmolecule_abundance_sub"="",
             "smallmolecule_abundance_stdev_sub"="",
             "smallmolecule_abundance_std_error_sub"="",
             Latin_Square_Quantification)

colnames(maf) <- c(nmr.maf.columns, assaynames)

##
## Make sure maf table is quoted properly,
## and add to the ISAmtbls2 assay file.
##
maf_character <- apply(maf, 2, as.character)

maf.filename <- "m_urine latin square spike-in for testing metaboquant_metabolite profiling_NMR spectroscopy_maf.csv"
write.table(maf_character,
            file=maf.filename, 
            row.names=FALSE, 
            quote=TRUE, sep="\t", na="\"\"")

ISAmtbls25 <- updateAssayMetadata(ISAmtbls25, a.filename,
             "Metabolite Assignment File", maf.filename)

#write.assay.file(ISAmtbls25, a.filename)
