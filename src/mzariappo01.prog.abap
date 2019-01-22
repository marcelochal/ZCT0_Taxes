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
*&      Module  SET_SCREEN;  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_screen OUTPUT.
  SET TITLEBAR sy-dynnr.
  SET PF-STATUS '0001'.
ENDMODULE.                 " SET_SCREEN;  OUTPUT
