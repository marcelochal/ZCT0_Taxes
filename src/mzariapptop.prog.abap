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

PROGRAM  sapmzjvapp MESSAGE-ID 00.

DATA: BDCDATA TYPE TABLE OF BDCDATA WITH HEADER LINE.
DATA: ITAB TYPE TABLE OF BDCMSGCOLL.
DATA: PROGRAM LIKE SY-REPID.
