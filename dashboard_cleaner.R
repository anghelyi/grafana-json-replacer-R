library(jsonlite)
library(stringr)
library(svDialogs)

filename <- file.choose()
result <- fromJSON(filename)

namespace <- dlg_input("Mi a namespace a dashboardon?")$res
interval <- dlg_input("Mi legyen a beállított felbontás?")$res

df_targets <-result[["panels"]][["targets"]]
df_title <-result[["panels"]][["title"]]
uri_values<-(result[["panels"]][["scopedVars"]][["http_uri"]][["value"]])
uri_values[is.na(uri_values)] <-""

for (i in 1:length(uri_values)){
  df_targets[[i]][["expr"]]<-str_replace_all(df_targets[[i]][["expr"]],"\\$http_uri",uri_values[i])
  df_targets[[i]][["expr"]]<-str_replace_all(df_targets[[i]][["expr"]],"\\$namespaces",namespace)
  df_targets[[i]][["expr"]]<-str_replace_all(df_targets[[i]][["expr"]],"\\$interval",interval)
  df_title[i]<-str_replace(df_title[i],"\\$http_uri",uri_values[i])
}

result[["templating"]][["list"]][["hide"]][1:length(result[["templating"]][["list"]][["hide"]])] <-2 #ez elrejti a template változókat a dashboardról

result[["panels"]][["title"]] <- df_title
result[["panels"]][["targets"]] <- df_targets
result[["title"]] <- namespace
result[["panels"]][["repeat"]][[14]] <- NA
result[["panels"]][["repeatPanelId"]] <- NA
result[["panels"]][["repeatIteration"]] <- NA
result[["uid"]] <- NA
result[["version"]] <-NA

export_JSON <- toJSON(result,pretty = TRUE,auto_unbox = TRUE)
new_filename <-str_replace(filename,".json","_modified.json")
write(export_JSON, new_filename)

