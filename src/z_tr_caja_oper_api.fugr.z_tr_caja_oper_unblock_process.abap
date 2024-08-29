FUNCTION Z_TR_CAJA_OPER_UNBLOCK_PROCESS.
*"----------------------------------------------------------------------
*"*"Interfase local
*"----------------------------------------------------------------------

  DATA: NUMBER type SY-TABIX,
        TENQ   type STANDARD TABLE OF SEQG3,
        wenq   type seqg3,
        subrc  type sy-subrc.

  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      GCLIENT               = SY-MANDT
      GNAME                 = 'ZTR_COPER_SPLIT'
*     GARG                  = ' '
      GUNAME                = ' '
*     LOCAL                 = ' '
*     FAST                  = ' '
*     GARGNOWC              = ' '
    IMPORTING
      NUMBER                = NUMBER
      SUBRC                 = SUBRC
    TABLES
      ENQ                   = TENQ
    EXCEPTIONS
      COMMUNICATION_FAILURE = 1
      SYSTEM_FAILURE        = 2
      OTHERS                = 3.

  call function 'ENQUE_DELETE'
    EXPORTING
      check_upd_requests = 1
    IMPORTING
      subrc              = subrc
    TABLES
      enq                = tenq.

ENDFUNCTION.
