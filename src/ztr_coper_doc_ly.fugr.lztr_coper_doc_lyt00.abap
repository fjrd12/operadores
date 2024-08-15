*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTR_COPER_DOC_LY................................*
DATA:  BEGIN OF STATUS_ZTR_COPER_DOC_LY              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTR_COPER_DOC_LY              .
CONTROLS: TCTRL_ZTR_COPER_DOC_LY
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZTR_COPER_DOC_LY              .
TABLES: ZTR_COPER_DOC_LY               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
