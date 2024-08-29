FUNCTION Z_TR_CAJA_OPER_BLOCK_PROCESS.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(THRESHOLD) TYPE  SY-TABIX DEFAULT 30
*"----------------------------------------------------------------------
  DATA: NUMBER  type SY-TABIX,
        TENQ    type STANDARD TABLE OF SEQG3,
        wenq    type seqg3,
        subrc   type sy-subrc,
        SECONDS TYPE INT4.
  do.

    CALL FUNCTION 'ENQUEUE_EZTR_COPER_SPLIT'
      EXPORTING
*       MODE_ZTR_COPER_SPLIT = 'E'
        PROCESS        = 'OPERADORES'
*       X_PROCESS      = 'X'
*       _SCOPE         = '2'
*       _WAIT          = ' '
*       _COLLECT       = 'X'
      EXCEPTIONS
        FOREIGN_LOCK   = 1
        SYSTEM_FAILURE = 2
        OTHERS         = 3.

    IF SY-SUBRC <> 0.
      clear tenq.
* Implement suitable error handling here
      CALL FUNCTION 'ENQUEUE_READ'
        EXPORTING
          GCLIENT               = SY-MANDT
          GNAME                 = 'ZTR_COPER_SPLIT'
*         GARG                  = ' '
          GUNAME                = ' '
*         LOCAL                 = ' '
*         FAST                  = ' '
*         GARGNOWC              = ' '
        IMPORTING
          NUMBER                = NUMBER
          SUBRC                 = SUBRC
        TABLES
          ENQ                   = TENQ
        EXCEPTIONS
          COMMUNICATION_FAILURE = 1
          SYSTEM_FAILURE        = 2
          OTHERS                = 3.

      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      else.
        read table tenq into wenq index 1.
        if sy-subrc = 0.

          CALL FUNCTION 'SALP_SM_CALC_TIME_DIFFERENCE'
            EXPORTING
              DATE_1  = wenq-GTDATE
              TIME_1  = wenq-GTTIME
              DATE_2  = SY-DATUM
              TIME_2  = SY-UZEIT
            IMPORTING
              SECONDS = seconds.
          if seconds > threshold.
            leave PROGRAM.
          endif.

        endif.

      ENDIF.
    else.
      exit.
    ENDIF.
  enddo.
ENDFUNCTION.
