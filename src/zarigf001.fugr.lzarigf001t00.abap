*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 30.08.2018 at 13:50:22
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZARIV_COD_IMP...................................*
TABLES: ZARIV_COD_IMP, *ZARIV_COD_IMP. "view work areas
CONTROLS: TCTRL_ZARIV_COD_IMP
TYPE TABLEVIEW USING SCREEN '0005'.
DATA: BEGIN OF STATUS_ZARIV_COD_IMP. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZARIV_COD_IMP.
* Table for entries selected to show on screen
DATA: BEGIN OF ZARIV_COD_IMP_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZARIV_COD_IMP.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZARIV_COD_IMP_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZARIV_COD_IMP_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZARIV_COD_IMP.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZARIV_COD_IMP_TOTAL.

*...processing: ZARIV_EMPRESA...................................*
TABLES: ZARIV_EMPRESA, *ZARIV_EMPRESA. "view work areas
CONTROLS: TCTRL_ZARIV_EMPRESA
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZARIV_EMPRESA. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZARIV_EMPRESA.
* Table for entries selected to show on screen
DATA: BEGIN OF ZARIV_EMPRESA_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZARIV_EMPRESA.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZARIV_EMPRESA_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZARIV_EMPRESA_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZARIV_EMPRESA.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZARIV_EMPRESA_TOTAL.

*...processing: ZARIV_INTERVALO.................................*
TABLES: ZARIV_INTERVALO, *ZARIV_INTERVALO. "view work areas
CONTROLS: TCTRL_ZARIV_INTERVALO
TYPE TABLEVIEW USING SCREEN '0003'.
DATA: BEGIN OF STATUS_ZARIV_INTERVALO. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZARIV_INTERVALO.
* Table for entries selected to show on screen
DATA: BEGIN OF ZARIV_INTERVALO_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZARIV_INTERVALO.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZARIV_INTERVALO_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZARIV_INTERVALO_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZARIV_INTERVALO.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZARIV_INTERVALO_TOTAL.

*...processing: ZARIV_JUROS_MULT................................*
TABLES: ZARIV_JUROS_MULT, *ZARIV_JUROS_MULT. "view work areas
CONTROLS: TCTRL_ZARIV_JUROS_MULT
TYPE TABLEVIEW USING SCREEN '0004'.
DATA: BEGIN OF STATUS_ZARIV_JUROS_MULT. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZARIV_JUROS_MULT.
* Table for entries selected to show on screen
DATA: BEGIN OF ZARIV_JUROS_MULT_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZARIV_JUROS_MULT.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZARIV_JUROS_MULT_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZARIV_JUROS_MULT_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZARIV_JUROS_MULT.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZARIV_JUROS_MULT_TOTAL.

*...processing: ZARIV_RESP......................................*
TABLES: ZARIV_RESP, *ZARIV_RESP. "view work areas
CONTROLS: TCTRL_ZARIV_RESP
TYPE TABLEVIEW USING SCREEN '0006'.
DATA: BEGIN OF STATUS_ZARIV_RESP. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZARIV_RESP.
* Table for entries selected to show on screen
DATA: BEGIN OF ZARIV_RESP_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZARIV_RESP.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZARIV_RESP_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZARIV_RESP_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZARIV_RESP.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZARIV_RESP_TOTAL.

*...processing: ZARIV_TP_IMPOSTO................................*
TABLES: ZARIV_TP_IMPOSTO, *ZARIV_TP_IMPOSTO. "view work areas
CONTROLS: TCTRL_ZARIV_TP_IMPOSTO
TYPE TABLEVIEW USING SCREEN '0002'.
DATA: BEGIN OF STATUS_ZARIV_TP_IMPOSTO. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZARIV_TP_IMPOSTO.
* Table for entries selected to show on screen
DATA: BEGIN OF ZARIV_TP_IMPOSTO_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZARIV_TP_IMPOSTO.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZARIV_TP_IMPOSTO_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZARIV_TP_IMPOSTO_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZARIV_TP_IMPOSTO.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZARIV_TP_IMPOSTO_TOTAL.

*.........table declarations:.................................*
TABLES: ZARI_COD_IMPOSTO               .
TABLES: ZARI_EMPRESA                   .
TABLES: ZARI_INTERV_NUM                .
TABLES: ZARI_JUROS_MULTA               .
TABLES: ZARI_RESPONSAVEL               .
TABLES: ZARI_TP_IMPOSTO                .
