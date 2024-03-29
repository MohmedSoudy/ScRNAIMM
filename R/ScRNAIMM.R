#' Performs a distribution check for the data
#'
#' @usage scRNA_MMI(scRNA_dataset)
#'
#' @param scRNA_dataset ScRNA-seq data set
#'
#' @export
#'
#' @author Mohamed Soudy \email{Mohmedsoudy2009@gmail.com}
#'
#' @returns ScRNA-Seq Imputed data set
#'
scRNA_MMI <- function(scRNA_dataset)
{
  for (i in 1:dim(scRNA_dataset)[2])
  {
    #Check if there is NAs in columns
    if (!any(is.na(scRNA_dataset[,i])))
      next
    pval <- tryCatch({
      ad.test(scRNA_dataset[,i])$p.value
    },
    error=function(cond){
      0.1
    })
    if (pval < 0.05)
    {
      #median Imputation
      scRNA_dataset[,i][is.na(scRNA_dataset[,i])] <- median(scRNA_dataset[,i], na.rm = T)
    }else{
      scRNA_dataset[,i][is.na(scRNA_dataset[,i])] <- mean(scRNA_dataset[,i], na.rm = T)
    }
  }
  return(scRNA_dataset)
}

#' Perform ScRNA-seq imputation using mean/Median
#'
#' @usage ScRNA_imp_MM(ScRNA_filtered, cluster_labels = NULL, cells = TRUE, genes = FALSE)
#'
#' @param ScRNA_filtered ScRNA-seq data set generated by prepare_dataset function
#'
#' @param cluster_labels Cluster labels generated by cluster_cells function or user-defined
#'
#' @param cells Boolean whether to do the imputation based on cell clustering or not
#'
#' @param genes Boolean whether to do the imputation based on genes or not
#'
#' @export
#'
#' @author Mohamed Soudy \email{Mohmedsoudy2009@gmail.com}
#'
#' @returns a data frame with the imputed values
#'
ScRNA_imp_MM <- function(ScRNA_filtered, cluster_labels = NULL, cells = TRUE, genes = FALSE)
{
  message("Imputation started!")
  if (is.null(cluster_labels))
  {
    #perform the imputation for all cells
    if (cells)
    {
      imputed_mm <- scRNA_MMI(ScRNA_filtered)
      message("Imputation finished!")
      return(imputed_mm)
    }
  }else{
    #impute based on each cell
    imputed_list <- list()
    labels_unique <- unique(cluster_labels)
    i <- 1
    for (label in labels_unique)
    {
      message(paste0("Imputation started for cluster: ", label))
      population_columns <- colnames(ScRNA_filtered)[sapply(strsplit(colnames(ScRNA_filtered), ";"), "[", 2) == label]
      cell_population <- ScRNA_filtered %>% select(all_of(population_columns))

      if(genes)
      {
        imputed_cell_pop <- t(scRNA_MMI(t(cell_population)))
      }else{
        imputed_cell_pop <- scRNA_MMI(cell_population)
      }

      imputed_list[[i]] <- imputed_cell_pop
      i <- i + 1
      message(paste0("Imputation finished for clsuter: ", label))
    }
    imputed_MMI <- do.call(cbind, imputed_list)
    message("Imputation finished!!")
    return(imputed_MMI)
  }
}
#' Run the main pipeline for ScRNAIMM 
#'
#' @usage run_pipeline(ScRNA,label=NULL,k=NULL,cells=TRUE,genes=TRUE,outdir=NULL,dataset=NULL)
#'
#' @param ScRNA ScRNA-seq data set generated by prepare_dataset function
#'
#' @param label Prior knowledge about cluster labels if NULL, will use our clustering function
#'
#' @param k Prior knowledge about number of clusters if NULL, will use our clustering function
#'
#' @param cells Boolean whether to do the imputation based on cell clustering or not
#'
#' @param genes Boolean whether to do the imputation based on genes or not
#' 
#' @param outdir Path to output directory to write the imputed data 
#' 
#' @param dataset Name of the data set to be the name of the output directory
#'
#' @export
#'
#' @author Mohamed Soudy \email{Mohmedsoudy2009@gmail.com}
#'
#' @returns a data frame with the imputed values
#'
run_pipeline <- function(ScRNA,label=NULL,k=NULL,cells=TRUE,genes=TRUE,outdir=NULL,dataset=NULL)
{
  filtered_ScRNA_seq <- filter_ScRNA(ScRNA)
  if (is.null(label)){
    if (!is.null(k)){
      #perform the clustering step needed for the imputation 
      cluster_lbl <- cluster_cells(ScRNA_filtered = filtered_ScRNA_seq, k = k)
    }else{
      cluster_lbl <- cluster_cells(ScRNA_filtered = filtered_ScRNA_seq)
    }
  }else{
    cluster_lbl <- label
  }
  #prepare the data set for imputation 
  filtered_ScRNA_prep <- prepare_dataset(filtered_ScRNA_seq, cluster_lbl)
  #perform the Imputation 
  scRNA_IMM <- ScRNA_imp_MM(filtered_ScRNA_prep, cluster_labels = cluster_lbl, cells = cells, genes = genes)
  colnames(scRNA_IMM) <- sapply(strsplit(colnames(scRNA_IMM), ";"), "[", 1)
  Imputed_IMM <- scRNA_IMM[,colnames(ScRNA)]
  if (!is.null(outdir)){
    if(!is.null(dataset)){
      write.csv(x = Imputed_IMM, file = paste0(outdir, dataset, "_IMM_Imputed.csv"))
    }else{
      write.csv(x = Imputed_IMM, file = paste0(outdir, "_IMM_Imputed.csv"))
    }
  }
  return(Imputed_IMM)
}