#' Example EDC data for form/table 'XX'
#'
#' This is an example data set to simulate raw EDC data from the fake form/table
#' 'XX'.
#'
#' @format ## 'edc_xx'
#' A data frame with 8 rows and 6 columns:
#' \describe{
#'  \item{STUDYID}{Study identifier}
#'  \item{USUBJID}{Subject identifier}
#'  \item{VISIT}{Visit name}
#'  \item{XXTESTCD}{Test name, coded}
#'  \item{XXORRES}{Test result}
#' }
"edc_xx"


#' Example SDTM domain table XX without meta data
#'
#' This data set is used to test the [assign_meta_data()] function and contains
#' a fake SDTM domain XX but without label or lengths assigned to the column
#' attributes.
#'
#' @format ## 'xx_no_meta_data'
#' A data frame with 10 rows and 11 columns:
#' \describe{
#'  \item{STUDYID}{Study identifier}
#'  \item{USUBJID}{Subject identifier}
#'  \item{XXSEQ}{Sequence number}
#'  \item{XXTESTCD}{Coded test name}
#'  \item{XXTEST}{Test name}
#'  \item{XXORRES}{Measurement in original units}
#'  \item{XXBLFL}{Baseline flag}
#'  \item{VISIT}{Visit name}
#'  \item{EPOCH}{EPOCH}
#'  \item{XXDTC}{Measurement date}
#'  \item{XXDY}{Measurement day of study}
#' }
"xx_no_meta_data"


#' Example EDC data for form/table 'VD'
#'
#' This is an example data set to simulate raw EDC data from the 'VD' form/table
#' which contains visit date information by subject.
#'
#' @format ## 'vd'
#' A data frame with 6 rows and 3 columns:
#' \describe{
#'  \item{USUBJID}{Subject identifier}
#'  \item{VISIT}{Visit name}
#'  \item{VISITDTC}{Visit date}
#' }
"vd"


#' Example SDTM Domain 'DM'
#'
#' This is an example data set to simulate a SDTM production domain 'DM' which
#' contains study start and end date information by subject. This can be used to
#' test [create_BLFL()], [create_EPOCH()], and [calc_DY()].
#'
#' @format ## 'dm'
#' A data frame with 2 rows and 4 columns:
#' \describe{
#'  \item{USUBJID}{Subject identifier}
#'  \item{RFSTDTC}{Study start date}
#'  \item{RFXSTDTC}{First exposure date}
#'  \item{RFXENDTC}{Last exposure date}
#' }
"dm"


#' Example 'Datasets' tab from a SDTM specification .xlsx file
#'
#' This table simulates an excerpt from a SDTM specification .xlsx file for the
#' 'Datasets' tab which provides the key variables for the fake domain XX. This
#' data set can be used to test the [get_key_vars()] function.
#'
#' @format ## 'spec_datasets'
#' A data frame with 1 row and 4 columns:
#' \describe{
#'  \item{Dataset}{The domain}
#'  \item{Description}{The domain description}
#'  \item{Structure}{Defines what qualifies as a unique record}
#'  \item{Key Variables}{The domain's key variables}
#' }
"spec_datasets"


#' Example domain specific tab from a SDTM specification .xlsx file
#'
#' This table simulates an excerpt from a SDTM specification .xlsx file for the
#' fake domain tab XX which provides the labels, data types, and lengths by
#' variable. This data set can be used to test the [get_data_spec()]
#' and [assign_meta_data()] functions.
#'
#' @format ## 'spec_XX'
#' A data frame with 12 rows and 5 columns:
#' \describe{
#'  \item{Order}{The order of the varibles in the data set}
#'  \item{Dataset}{The domain abbreviation}
#'  \item{Varible}{The domain's variables}
#'  \item{Label}{Variable labels}
#'  \item{Data Type}{Variable data types}
#'  \item{Length}{The maximum allowed length of an entry}
#' }
"spec_XX"


#' Example 'Codelists' tab from a SDTM specification .xlsx file
#'
#' This table simulates an excerpt from a SDTM specification .xlsx file for the
#' 'Codelists' tab which provides coded and decoded values from `XXTESTCD` and
#' `XXTEST` variables, respectively. This data set can be used to test the
#' [get_codelist()] function.
#'
#' @format ## 'spec_codelists'
#' A data frame with 3 rows and 3 columns:
#' \describe{
#'  \item{ID}{The variable identifier/name}
#'  \item{Term}{The coded term}
#'  \item{Decoded Value}{The corresponding decoded value for the coded term}
#' }
"spec_codelists"


#' Example 'valuelevel' tab from a SDTM specification .xlsx file
#'
#' This table simulates an excerpt from a SDTM specification .xlsx file for the
#' 'ValueLevel' tab. This data set can be used to test the [get_valuelevel()]
#' function.
#'
#' @format ## 'spec_valuelevel'
#' A data frame with 3 rows and 9 columns:
#' \describe{
#'  \item{Dataset}{The dataset/domain}
#'  \item{Variable}{The variable in dataset}
#'  \item{Where Clause}{Applicable cases, in psuedocode}
#'  \item{Description}{Label}
#'  \item{Codelist}{Relevant codelist entries}
#'  \item{Origin}{Where the data originated}
#'  \item{Pages}{aCRF reference pages}
#'  \item{Method}{Applicable methods}
#'  \item{Programming Notes}{Programming notes, in psuedocode}
#' }
"spec_valuelevel"













