FUNCTION Z_TR_CAJA_OPER_DISPLAY_LOG.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(UUID) TYPE  CHAR128
*"  EXCEPTIONS
*"      LOG_NOT_FOUND
*"----------------------------------------------------------------------
  data: I_S_LOG_FILTER      TYPE  BAL_S_LFIL,
        TEXTNUMBER          TYPE  BAL_R_EXTN,
        WEXTNUMBER          TYPE  BAL_S_EXTN,
        g_t_log_handle      TYPE  BAL_T_LOGH,
        G_S_DISPLAY_PROFILE TYPE  BAL_S_PROF,
        I_T_LOGNUMBER       TYPE  BAL_T_LOGN,
        I_W_LOGNUMBER       TYPE  BALOGNR,
        E_T_LOG_HEADER      TYPE  BALHDR_T,
        E_W_LOG_HEADER      TYPE  BALHDR,
        E_T_MSG_HANDLE      TYPE  BAL_T_MSGH,
        E_T_LOCKED          TYPE  BALHDR_T.

  WEXTNUMBER-SIGN = 'I'.
  WEXTNUMBER-OPTION = 'EQ'.
  WEXTNUMBER-LOW = uuid.
  clear WEXTNUMBER-HIGH.
  append WEXTNUMBER to TEXTNUMBER.


  I_S_LOG_FILTER-EXTNUMBER = TEXTNUMBER.


  CALL FUNCTION 'BAL_DB_SEARCH'
    EXPORTING
*     I_CLIENT           = SY-MANDT
      I_S_LOG_FILTER     = I_S_LOG_FILTER
*     I_T_SEL_FIELD      =
*     I_TZONE            =
    IMPORTING
      E_T_LOG_HEADER     = E_T_LOG_HEADER
    EXCEPTIONS
      LOG_NOT_FOUND      = 1
      NO_FILTER_CRITERIA = 2
      OTHERS             = 3.
  if sy-subrc ne 0.
    RAISE LOG_NOT_FOUND.
  else.
    read table E_T_LOG_HEADER into E_W_LOG_HEADER index 1.
    I_W_LOGNUMBER = E_W_LOG_HEADER-LOGNUMBER.
    append I_W_LOGNUMBER to I_T_LOGNUMBER.

    CALL FUNCTION 'BAL_DB_LOAD'
      EXPORTING
*       I_T_LOG_HEADER     =
*       I_T_LOG_HANDLE     =
        I_T_LOGNUMBER      = I_T_LOGNUMBER
*       I_CLIENT           = SY-MANDT
*       I_DO_NOT_LOAD_MESSAGES              = ' '
*       I_EXCEPTION_IF_ALREADY_LOADED       =
*       I_LOCK_HANDLING    = 2
      IMPORTING
        E_T_LOG_HANDLE     = g_t_log_handle
        E_T_MSG_HANDLE     = E_T_MSG_HANDLE
        E_T_LOCKED         = E_T_LOCKED
      EXCEPTIONS
        NO_LOGS_SPECIFIED  = 1
        LOG_NOT_FOUND      = 2
        LOG_ALREADY_LOADED = 3
        OTHERS             = 4.

    case SY-SUBRC.
      when 0.

        g_s_display_profile-show_all = 'X'.
        g_s_display_profile-use_grid = 'X'.
        g_s_display_profile-disvariant-report = sy-repid.
        g_s_display_profile-disvariant-handle = 'LOG'.

        CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
          EXPORTING
            i_t_log_handle      = g_t_log_handle
            i_s_display_profile = g_s_display_profile
          EXCEPTIONS
            OTHERS              = 1.
        IF sy-subrc <> 0.
          RAISE LOG_NOT_FOUND.
        ENDIF.

      when 1.
        RAISE LOG_NOT_FOUND.
      when 2.
        RAISE OTHERS.
    ENDCASE.

  endif.

ENDFUNCTION.
