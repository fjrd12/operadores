FUNCTION Z_TR_CAJA_OPER_MERGE_PARAMETER.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  EXPORTING
*"     REFERENCE(PARAMETRO_COMMA) TYPE  STRING
*"  TABLES
*"      PARAMETROS STRUCTURE  RSPARAMS
*"  EXCEPTIONS
*"      NO_CONTENT
*"----------------------------------------------------------------------
  data: tabix     type sy-tabix,
        longi     type sy-tabix,
        wrsparams type rsparams,
        parametre type char20.

  if parametros[] is INITIAL.
    raise no_content.
  endif.

  describe table parametros lines longi.

  if longi = 1.
    read  table parametros into WRSPARAMS index 1.
    PARAMETRO_COMMA = wrsparams-low.
  else.

    loop at parametros into wrsparams.
      tabix = sy-tabix.
      if tabix = 1.
        PARAMETRO_COMMA = WRSPARAMS-LOW.
      else.
        concatenate PARAMETRO_COMMA wrsparams-low into PARAMETRO_COMMA separated by ','.
      endif.
    endloop.

  endif.

ENDFUNCTION.
