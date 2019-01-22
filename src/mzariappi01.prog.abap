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
*&      Module  USER_COMMAND_0001  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0001 INPUT.
***  CASE sy-ucomm.
***    WHEN 'INTERVALO'.
***      CALL SCREEN '0002'.
***    WHEN 'TIPOIMPOSTO'.
***      CALL SCREEN '0003'.
***    WHEN 'JUROSMULTA'.
***      CALL SCREEN '0004'.
***    WHEN 'CODIMPOSTO'.
***      CALL SCREEN '0005'.
***    WHEN 'EMPRESAS'.
***
***    WHEN 'RESPONSAVEIS'.
***  ENDCASE.

  CASE sy-ucomm.
    WHEN 'INTERVALO'.    CALL TRANSACTION 'ZARI_INTERV_NUM'.
    WHEN 'TIPOIMPOSTO'.  CALL TRANSACTION 'ZARI_TIPO_IMPOSTO'.
    WHEN 'JUROSMULTA'.   CALL TRANSACTION 'ZARI_JUROS_MULTA'.
    WHEN 'CODIMPOSTO'.   CALL TRANSACTION 'ZARI_COD_IMPOSTO'.
    WHEN 'EMPRESAS'.     CALL TRANSACTION 'ZARI_EMPRESA'.
    WHEN 'RESPONSAV'.    CALL TRANSACTION 'ZARI_RESPONSAVEL'.
    WHEN 'JOB'.          PERFORM CALL_SM37. "CALL TRANSACTION 'SM37'.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0001  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0002 INPUT.
  CASE sy-ucomm.
    WHEN 'APPDET'.  CALL TRANSACTION 'ZJVAPPDET'.
    WHEN 'APPFIPP'. CALL TRANSACTION 'ZJVAPPFIPP'.
    WHEN 'APPRULE'. CALL TRANSACTION 'ZJVAPPROLE'.
    WHEN 'APPSTEP'. CALL TRANSACTION 'ZJVAPPSTEP'.
    WHEN 'APPTYPE'. CALL TRANSACTION 'ZJVAPPTYPE'.
    WHEN 'APPSTAT'. CALL TRANSACTION 'ZJVAPPSTATION'.
    WHEN 'APPCOND'. CALL TRANSACTION 'ZJVAPPCOND'.
    WHEN 'HELP1'. PERFORM exibir_help USING 'TB' 'ZJVAPPDET'.
    WHEN 'HELP2'. PERFORM exibir_help USING 'TB' 'ZJVAPPFIPP'.
    WHEN 'HELP3'. PERFORM exibir_help USING 'TB' 'ZJVAPPROLE'.
    WHEN 'HELP4'. PERFORM exibir_help USING 'TB' 'ZJVAPPSTEP'.
    WHEN 'HELP5'. PERFORM exibir_help USING 'TB' 'ZJVAPPTYPE'.
    WHEN 'HELP6'. PERFORM exibir_help USING 'TB' 'ZJVAPPSTATION'.
    WHEN 'HELP7'. PERFORM exibir_help USING 'TB' 'ZJVAPPCONDI'.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0002  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_exit INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " USER_COMMAND_EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0003  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0003 INPUT.
  CASE sy-ucomm.
    WHEN 'APPTYPE'. CALL TRANSACTION 'ZJVAPPTYPE'.
    WHEN 'APPSTAT'. CALL TRANSACTION 'ZJVAPPSTATION'.
    WHEN 'HELP1'. PERFORM exibir_help USING 'TB' 'ZJVAPPDET'.
    WHEN 'HELP2'. PERFORM exibir_help USING 'TB' 'ZJVAPPFIPP'.
    WHEN 'HELP3'. PERFORM exibir_help USING 'TB' 'ZJVAPPROLE'.
    WHEN 'HELP4'. PERFORM exibir_help USING 'TB' 'ZJVAPPSTEP'.
    WHEN 'HELP5'. PERFORM exibir_help USING 'TB' 'ZJVAPPTYPE'.
    WHEN 'HELP6'. PERFORM exibir_help USING 'TB' 'ZJVAPPSTATION'.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0003  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0004  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0004 INPUT.
  CASE sy-ucomm.
    WHEN 'OBWA'.   CALL TRANSACTION 'OBWA'.
    WHEN 'OBWJ'.   CALL TRANSACTION 'OBWJ'.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0004  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0005  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0005 INPUT.
  CASE sy-ucomm.
    WHEN 'SWI1_RULE'.   CALL TRANSACTION 'SWI1_RULE'.
    WHEN 'SWI2_ADM1'.   CALL TRANSACTION 'SWI2_ADM1'.
    WHEN 'SWIA'.        CALL TRANSACTION 'SWIA'.
    WHEN 'SWUS'.
      SET PARAMETER ID 'TSK' FIELD 'WS80000013'.
      CALL TRANSACTION 'SWUS'.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0005  INPUT
