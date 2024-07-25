FUNCTION Z_TR_CAJA_OPER_EXIT_PAY.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(REGUH_DATA) LIKE  REGUH STRUCTURE  REGUH
*"  EXCEPTIONS
*"      PROC_ERROR
*"      ERROR_IN_IDOC_CONTROL
*"      ERROR_WRITING_IDOC_STATUS
*"      ERROR_IN_IDOC_DATA
*"      SENDING_LOGICAL_SYSTEM_UNKNOWN
*"      OTHERS
*"----------------------------------------------------------------------

  data: laufd                type laufd,
        laufi                type laufi,
        wreguh               type reguh,
        scenario             type char10,
        ZBNKHEADER           type ZBNKHEADER,
        TZTRPAYH             type STANDARD TABLE OF ZTRPAYH,
        TZTRPAYP             type STANDARD TABLE OF ZTRPAYP,
        TZTRPAY_META         type STANDARD TABLE OF ZTRPAY_META,
        it_bapiret2          type STANDARD TABLE OF bapiret2,
        EDIDC                type EDIDC,
        EDIDD                type EDIDD,
        WZTR_COPER_PROP_LIST type ZTR_COPER_PROP_LIST.

   CALL FUNCTION 'Z_TR_CAJA_OPER_DEBUG'
    EXPORTING
      NAME = 'Z_DEBUG2'.
  read table TZTR_COPER_PROP_LIST into WZTR_COPER_PROP_LIST
  WITH key laufd = REGUH_DATA-laufd laufi = REGUH_DATA-laufi.

  if sy-subrc ne 0.

    WZTR_COPER_PROP_LIST-laufd = REGUH_DATA-laufd.
    WZTR_COPER_PROP_LIST-laufi = REGUH_DATA-laufi.
    append WZTR_COPER_PROP_LIST to TZTR_COPER_PROP_LIST.

    CALL FUNCTION 'Z_TR_CAJA_OPER_SCENARIO_ORIG'
      EXPORTING
        LAUFD     = reguh_data-laufd
        LAUFI     = reguh_data-laufi
      IMPORTING
        SCENARIO  = SCENARIO
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.

    case SCENARIO.
      when 'OPERADORES'.
        case reguh_data-hbkid(3).
          when 'SNT'.
            ZBNKHEADER-BANK = 'SANTANDER'.
          when 'BNT'.
            ZBNKHEADER-BANK = 'BANORTE'.
          when 'HSB'.
            ZBNKHEADER-BANK = 'HSBC'.
        endcase.

        ZBNKHEADER-CORREL_ID = cl_system_uuid=>if_system_uuid_rfc4122_static~create_uuid_c36_by_version( version = 4 )..
        ZBNKHEADER-TRANS_IP = cl_system_uuid=>if_system_uuid_rfc4122_static~create_uuid_c36_by_version( version = 4 )..
        ZBNKHEADER-PROCESS = 'OPERD'.

        CALL FUNCTION 'ZTR_PAY_GENERATE_IDOC_FUNC'
          EXPORTING
            ZBNKHEADER                     = ZBNKHEADER
            LAUFD                          = reguh_data-LAUFD
            LAUFI                          = reguh_data-LAUFI
          TABLES
            ZTRPAYH                        = TZTRPAYH
            ZTRPAYP                        = TZTRPAYP
            ZTRPAY_META                    = TZTRPAY_META
            IT_BAPIRET2                    = it_bapiret2
          CHANGING
            MASTER_IDOC_CONTROL            = EDIDC
          EXCEPTIONS
            ERROR_IN_IDOC_CONTROL          = 1
            ERROR_WRITING_IDOC_STATUS      = 2
            ERROR_IN_IDOC_DATA             = 3
            SENDING_LOGICAL_SYSTEM_UNKNOWN = 4
            OTHERS                         = 5.

        CASE SY-SUBRC.
          WHEN 1.
            RAISE ERROR_IN_IDOC_CONTROL.
          WHEN 2.
            RAISE ERROR_WRITING_IDOC_STATUS.
          WHEN 3.
            RAISE ERROR_IN_IDOC_DATA.
          WHEN 4.
            raise SENDING_LOGICAL_SYSTEM_UNKNOWN.
          WHEN 5.
            RAISE OTHERS.
        endcase.
    endcase.

  endif.

ENDFUNCTION.
