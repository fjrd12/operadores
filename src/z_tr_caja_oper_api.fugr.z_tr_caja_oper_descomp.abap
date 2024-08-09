FUNCTION Z_TR_CAJA_OPER_DESCOMP.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(AUGBL) TYPE  AUGBL DEFAULT '100232421'
*"     VALUE(BUKRS) TYPE  BUKRS DEFAULT 'TE00'
*"     VALUE(GJAHR) TYPE  GJAHR DEFAULT '2023'
*"     VALUE(STGRD) TYPE  STGRD DEFAULT '01'
*"     VALUE(BUDAT) TYPE  ZDADES DEFAULT '01.11.2023'
*"     VALUE(MONAT) TYPE  MONAT DEFAULT '11'
*"  EXPORTING
*"     VALUE(SUBRC) LIKE  SYST-SUBRC
*"  TABLES
*"      MESSTAB STRUCTURE  BDCMSGCOLL OPTIONAL
*"----------------------------------------------------------------------

*DATA: CTU TYPE APQI-PUTACTIVE VALUE 'X',
*      MODE TYPE APQI-PUTACTIVE VALUE 'N',
*      UPDATE TYPE APQI-PUTACTIVE VALUE 'L',
*      GROUP TYPE APQI-GROUPID,
*      USER TYPE APQI-USERID,
*      KEEP TYPE APQI-QERASE,
*      HOLDDATE TYPE APQI-STARTDATE,
*      NODATA TYPE APQI-PUTACTIVE VALUE '/',
*      AUGBL_001 TYPE BDCDATA-FVAL,
*      BUKRS_002 TYPE BDCDATA-FVAL,
*      GJAHR_003 TYPE BDCDATA-FVAL,
*      STGRD_004 TYPE BDCDATA-FVAL,
*      BUDAT_005 TYPE BDCDATA-FVAL,
*      MONAT_006 TYPE BDCDATA-FVAL.
*
*AUGBL_001 = AUGBL.
*BUKRS_002 = BUKRS.
*GJAHR_003 = GJAHR.
*STGRD_004 = STGRD.
*BUDAT_005 = BUDAT.
*MONAT_006 = MONAT.
*
*subrc = 0.
*
*perform bdc_nodata      using NODATA.
*
*perform open_group      using GROUP USER KEEP HOLDDATE CTU.
*
*perform bdc_dynpro      using 'SAPMF05R' '0100'.
*perform bdc_field       using 'BDC_CURSOR'
*                              'RF05R-AUGBL'.
*perform bdc_field       using 'BDC_OKCODE'
*                              '=RAGL'.
*perform bdc_field       using 'RF05R-AUGBL'
*                              AUGBL_001.
*perform bdc_field       using 'RF05R-BUKRS'
*                              BUKRS_002.
*perform bdc_field       using 'RF05R-GJAHR'
*                              GJAHR_003.
*perform bdc_dynpro      using 'SAPLSPO2' '0100'.
*perform bdc_field       using 'BDC_OKCODE'
*                              '=OPT2'.
*perform bdc_dynpro      using 'SAPMF05R' '0300'.
*perform bdc_field       using 'BDC_CURSOR'
*                              'RF05R-MONAT'.
*perform bdc_field       using 'BDC_OKCODE'
*                              '=ENTR'.
*perform bdc_field       using 'RF05R-STGRD'
*                              STGRD_004.
*perform bdc_field       using 'RF05R-BUDAT'
*                              BUDAT_005.
*perform bdc_field       using 'RF05R-MONAT'
*                              MONAT_006.
*perform bdc_dynpro      using 'SAPMF05R' '0100'.
*perform bdc_field       using 'BDC_OKCODE'
*                              '/EEEND'.
*perform bdc_field       using 'BDC_CURSOR'
*                              'RF05R-AUGBL'.
*
**perform bdc_transaction tables messtab
**using                         'FBRA'
**                             CTU
**                             MODE
**                             UPDATE.
*
** Custom CALL TRANSACTION
*TABLES: CTU_PARAMS.
*
*CTU_PARAMS-DISMODE  = 'N'.
*CTU_PARAMS-UPDMODE  = 'S'.
*CTU_PARAMS-CATTMODE = ''.
*CTU_PARAMS-DEFSIZE  = 'X'.
*CTU_PARAMS-RACOMMIT = 'X'.
*CTU_PARAMS-NOBINPT  = 'X'.
*CTU_PARAMS-NOBIEND  = ''.
*
*CALL TRANSACTION 'FBRA' USING BDCDATA
*                        OPTIONS FROM CTU_PARAMS
*                        MESSAGES INTO MESSTAB.
*REFRESH BDCDATA.
*
*if sy-subrc <> 0.
*  subrc = sy-subrc.
*  exit.
*endif.
*
*perform close_group using     CTU.
*




ENDFUNCTION.
