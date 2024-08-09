FUNCTION Z_TR_CAJA_OPER_DERIVE_VIA.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(LIFNR) TYPE  LIFNR
*"  EXPORTING
*"     REFERENCE(PYMT_METH) TYPE  ACPI_ZLSCH
*"  TABLES
*"      RETURN STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      ACCOUNT_NOT_FOUND
*"----------------------------------------------------------------------

  DATA: BUSINESSPARTNER TYPE  BAPIBUS1006_HEAD-BPARTNER,
        TBANKDETAILS    TYPE STANDARD TABLE OF BAPIBUS1006_BANKDETAILS,
        WBANKDETAILS    TYPE BAPIBUS1006_BANKDETAILS.

  CALL FUNCTION 'BAPI_BUPA_BANKDETAILS_GET'
    EXPORTING
      BUSINESSPARTNER = LIFNR
      VALID_DATE      = SY-DATLO
    TABLES
      BANKDETAILS     = TBANKDETAILS
      RETURN          = RETURN.

  delete TBANKDETAILS where BANKDETAILVALIDFROM > SY-DATLO or BANKDETAILVALIDTO < sy-datlo.
  if TBANKDETAILS is INITIAL.
    raise account_not_found.
  else.
    read table TBANKDETAILS into WBANKDETAILS index  1.
    case WBANKDETAILS-BANK_KEY.
      when '072'.
        PYMT_METH = '9'.
      when '014'.
        PYMT_METH = '8'.
    endcase.
  endif.

ENDFUNCTION.
