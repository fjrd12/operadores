FUNCTION Z_TR_CAJA_OPER_DEBUG.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(NAME) TYPE  RVARI_VNAM
*"----------------------------------------------------------------------

  data: V_DEBUG type tvarvc-low.

  SELECT SINGLE LOW
    FROM TVARVC
    INTO V_DEBUG
    WHERE NAME = NAME.

  IF SY-SUBRC EQ 0 and V_DEBUG is NOT INITIAL.
    clear V_DEBUG.
    DO.
      IF V_DEBUG IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDDO.
  ENDIF.


ENDFUNCTION.
