FUNCTION Z_TR_CAJA_OPER_DESCOM.
*"--------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(CTU) LIKE  APQI-PUTACTIVE DEFAULT 'X'
*"     VALUE(MODE) LIKE  APQI-PUTACTIVE DEFAULT 'N'
*"     VALUE(UPDATE) LIKE  APQI-PUTACTIVE DEFAULT 'L'
*"     VALUE(GROUP) LIKE  APQI-GROUPID OPTIONAL
*"     VALUE(USER) LIKE  APQI-USERID OPTIONAL
*"     VALUE(KEEP) LIKE  APQI-QERASE OPTIONAL
*"     VALUE(HOLDDATE) LIKE  APQI-STARTDATE OPTIONAL
*"     VALUE(NODATA) LIKE  APQI-PUTACTIVE DEFAULT '/'
*"     VALUE(AUGBL_001) LIKE  BDCDATA-FVAL DEFAULT '100232421'
*"     VALUE(BUKRS_002) LIKE  BDCDATA-FVAL DEFAULT 'TE00'
*"     VALUE(GJAHR_003) LIKE  BDCDATA-FVAL DEFAULT '2023'
*"     VALUE(STGRD_004) LIKE  BDCDATA-FVAL DEFAULT '01'
*"     VALUE(BUDAT_005) LIKE  BDCDATA-FVAL DEFAULT '01.11.2023'
*"     VALUE(MONAT_006) LIKE  BDCDATA-FVAL DEFAULT '11'
*"  EXPORTING
*"     VALUE(SUBRC) LIKE  SYST-SUBRC
*"  TABLES
*"      MESSTAB STRUCTURE  BDCMSGCOLL OPTIONAL
*"--------------------------------------------------------------------

subrc = 0.

perform bdc_nodata      using NODATA.

perform open_group      using GROUP USER KEEP HOLDDATE CTU.

perform bdc_dynpro      using 'SAPMF05R' '0100'.
perform bdc_field       using 'BDC_CURSOR'
                              'RF05R-AUGBL'.
perform bdc_field       using 'BDC_OKCODE'
                              '=RAGL'.
perform bdc_field       using 'RF05R-AUGBL'
                              AUGBL_001.
perform bdc_field       using 'RF05R-BUKRS'
                              BUKRS_002.
perform bdc_field       using 'RF05R-GJAHR'
                              GJAHR_003.
perform bdc_dynpro      using 'SAPLSPO2' '0100'.
perform bdc_field       using 'BDC_OKCODE'
                              '=OPT2'.
perform bdc_dynpro      using 'SAPMF05R' '0300'.
perform bdc_field       using 'BDC_CURSOR'
                              'RF05R-MONAT'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ENTR'.
perform bdc_field       using 'RF05R-STGRD'
                              STGRD_004.
perform bdc_field       using 'RF05R-BUDAT'
                              BUDAT_005.
perform bdc_field       using 'RF05R-MONAT'
                              MONAT_006.
perform bdc_dynpro      using 'SAPMF05R' '0100'.
perform bdc_field       using 'BDC_OKCODE'
                              '/EEEND'.
perform bdc_field       using 'BDC_CURSOR'
                              'RF05R-AUGBL'.
perform bdc_transaction tables messtab
using                         'FBRA'
                              CTU
                              MODE
                              UPDATE.
if sy-subrc <> 0.
  subrc = sy-subrc.
  exit.
endif.

perform close_group using     CTU.





ENDFUNCTION.
INCLUDE BDCRECXY .
