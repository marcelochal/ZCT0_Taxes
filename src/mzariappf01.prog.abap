*----------------------------------------------------------------------*
*                 P R O J E T O    T A E S A                           *
*----------------------------------------------------------------------*
* Consultoria .....: P E R C O S   C O N S U L T O R I A               *
* Res. ABAP........: Rafael Oliveira                                   *
* Res. Funcional...: Marcelo Forti                                     *
* Módulo...........: FI                                                *
* Programa.........: SAPMZARIAPP                                       *
* Transação........: ZARIAPP                                           *
* Tipo de Prg......: Module Pool                                       *
* Objetivo.........: Apuração e Recolhimento de Impostos               *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  EXIBIR_HELP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form EXIBIR_HELP USING P_ID TYPE DOKHL-ID
                       P_OBJECT TYPE DOKHL-OBJECT.
*** ID --> TX TEXTO GERAL/ TB TABELA
      call function 'DOCU_CALL'
        exporting
          displ      = 'X'
          displ_mode = 2
          id         = P_ID
          langu      = sy-langu
          object     = P_object
        exceptions
          wrong_name = 1.

endform.                    " EXIBIR_HELP




FORM CALL_SM37.


*submit SAPLBTCH using selection-screen '2170'.

perform bdc_dynpro      using 'SAPLBTCH' '2170'.
perform bdc_field       using 'BDC_CURSOR'
                              'BTCH2170-TO_DATE'.
perform bdc_field       using 'BDC_OKCODE'
                              '=DOIT'.
perform bdc_field       using 'BTCH2170-JOBNAME'
                              '*'.
perform bdc_field       using 'BTCH2170-USERNAME'
                              '*'.
perform bdc_field       using 'BTCH2170-SCHEDUL'
                              'X'.
perform bdc_field       using 'BTCH2170-READY'
                              'X'.
perform bdc_field       using 'BTCH2170-RUNNING'
                              'X'.
perform bdc_field       using 'BTCH2170-FINISHED'
                              'X'.
perform bdc_field       using 'BTCH2170-ABORTED'
                              'X'.
perform bdc_field       using 'BTCH2170-FROM_DATE'
                              '26.12.2006'.
perform bdc_field       using 'BTCH2170-TO_DATE'
                              '26.12.2006'.
call transaction 'SM37'  USING BDCDATA mode 'A'.
ENDFORM.


form bdc_field  using    FNAM FVAL.

    CLEAR BDCDATA.

    BDCDATA-FNAM = FNAM.

    BDCDATA-FVAL = FVAL.

    APPEND BDCDATA.

endform.                    " bdc_field



FORM BDC_DYNPRO USING PROGRAM DYNPRO.

  CLEAR BDCDATA.

  BDCDATA-PROGRAM  = PROGRAM.

  BDCDATA-DYNPRO   = DYNPRO.

  BDCDATA-DYNBEGIN = 'X'.

  APPEND BDCDATA.

ENDFORM.
