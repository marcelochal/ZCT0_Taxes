*&---------------------------------------------------------------------*
*&  Include           MZARI001DEF01
*&---------------------------------------------------------------------*


CLASS lcl_1100_event_handler_11 DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.

CLASS lcl_1100_event_handler_12 DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.

CLASS lcl_1100_event_handler_13 DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.

CLASS lcl_1100_event_handler_14 DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.

CLASS lcl_1100_event_handler_22 DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column,
      on_double_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.

CLASS lcl_1100_event_handler_31 DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.

CLASS lcl_1200_event_handler_11 DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.

CLASS lcl_1200_event_handler_12 DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.

CLASS lcl_1200_event_handler_13 DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.

CLASS lcl_1200_event_handler_14 DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.

CLASS lcl_1200_event_handler_22 DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column,
      on_double_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.

CLASS lcl_1200_event_handler_31 DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.

CLASS lcl_1100_event_handler_21 DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_clicked FOR EVENT clicked OF cl_dd_button_element
        IMPORTING sender.
ENDCLASS.                    "cl_my_event_handler DEFINITION

CLASS lcl_1200_event_handler_21 DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_clicked FOR EVENT clicked OF cl_dd_button_element
        IMPORTING sender.
ENDCLASS.                    "cl_my_event_handler DEFINITION

CLASS lcl_1300_event_handler_11 DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_clicked FOR EVENT clicked OF cl_dd_button_element
        IMPORTING sender.
ENDCLASS.                    "cl_my_event_handler DEFINITION

CLASS lcl_1300_event_handler_21 DEFINITION.

  PUBLIC SECTION.
    METHODS:
      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column,

      on_double_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row column.

ENDCLASS.                    "cl_my_event_handler DEFINITION

CLASS lcl_1400_event_handler_11 DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.

CLASS lcl_1400_event_handler_12 DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.

CLASS lcl_1400_event_handler_13 DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.

CLASS lcl_1400_event_handler_14 DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.

"Start    - Marcelo Alvares - MA004818 S4D MZARI001DEF01 ZCT0 - 24.10.2018 16:28

CLASS lcl_fi_doc_reader DEFINITION CREATE PRIVATE.

  PUBLIC SECTION.
    CLASS-METHODS:
      "! Read Table BKPF and return struct
      read_bkpf
        IMPORTING
          VALUE(im_v_bukrs) TYPE  bukrs
          VALUE(im_v_belnr) TYPE  belnr_d
          VALUE(im_v_gjahr) TYPE  gjahr
        EXPORTING
          VALUE(ex_s_bkpf)  TYPE  bkpf
        EXCEPTIONS
          key_incomplete                " Key is incomplete
          not_authorized                " No authorization
          not_found,                    " Data record not found
      "! Get doc status from BKPF
      get_doc_status
        IMPORTING
          VALUE(im_v_bukrs) TYPE  bukrs
          VALUE(im_v_belnr) TYPE  belnr_d
          VALUE(im_v_gjahr) TYPE  gjahr
        RETURNING
          VALUE(r_bstat)    TYPE bstat_d
        EXCEPTIONS
          key_incomplete                " Key is incomplete
          not_authorized                " No authorization
          not_found,                    " Data record not found
      "! Check if pre doc is status normal
      is_doc_normal_status
        IMPORTING
          VALUE(im_s_bkpf) TYPE ty_bkpf
        RETURNING
          VALUE(r_bool)    TYPE abap_bool.

ENDCLASS.

"END    - Marcelo Alvares - MA004818 S4D MZARI001DEF01 ZCT0 - 24.10.2018 16:28
