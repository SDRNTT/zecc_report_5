REPORT zsdr_salesorders_dashboard.

TABLES: vbak.
TYPES: BEGIN OF ty_vbak,
         vbeln TYPE vbeln_va,
         erdat TYPE erdat,
         ernam TYPE ernam,
         audat TYPE audat,
         auart TYPE auart,
         vkorg TYPE vkorg,
         vtweg TYPE vtweg,
         spart TYPE spart,
         kunnr TYPE kunnr,
       END OF ty_vbak.

TYPES: BEGIN OF ty_vbap,
         vbeln TYPE vbeln_va,
         netwr TYPE netwr,
       END OF ty_vbap.

TYPES: BEGIN OF ty_final,
         vbeln TYPE vbeln_va,
         audat TYPE audat,
         auart TYPE auart,
         vkorg TYPE vkorg,
         vtweg TYPE vtweg,
         spart TYPE spart,
         kunnr TYPE kunnr,
         netwr TYPE netwr,
         erdat TYPE erdat,
         ernam TYPE ernam,
       END OF ty_final.

DATA: lt_vbak      TYPE TABLE OF ty_vbak,
      ls_vbak      TYPE ty_vbak,
      lt_vbap      TYPE TABLE OF ty_vbap,
      ls_vbap      TYPE ty_vbap,
      lv_tot_price TYPE netwr,
      lt_final     TYPE TABLE OF ty_final,
      ls_final     TYPE ty_final,
      ls_fcat      TYPE slis_fieldcat_alv,
      lt_fcat      TYPE slis_t_fieldcat_alv,
      ls_layout    TYPE slis_layout_alv.

SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS   : s_vbeln FOR vbak-vbeln,
                   s_vkorg FOR vbak-vkorg.
SELECTION-SCREEN END OF BLOCK b1.

SELECT vbeln erdat ernam audat
       auart vkorg vtweg spart kunnr
FROM vbak INTO TABLE lt_vbak
WHERE vbeln IN s_vbeln
  AND vkorg IN s_vkorg.
IF sy-subrc = 0.
  SELECT vbeln netwr
  FROM vbap INTO TABLE lt_vbap
  FOR ALL ENTRIES IN lt_vbak
   WHERE vbeln = lt_vbak-vbeln.
ENDIF.

CLEAR: ls_vbap, lv_tot_price, ls_vbak, lt_final, ls_final.
LOOP AT lt_vbak INTO ls_vbak.
  LOOP AT lt_vbap INTO ls_vbap WHERE vbeln = ls_vbak-vbeln.
    lv_tot_price = ls_vbap-netwr + lv_tot_price.
    CLEAR ls_vbap.
  ENDLOOP.
  MOVE-CORRESPONDING ls_vbak TO ls_final.
  ls_final-netwr = lv_tot_price.
  APPEND ls_final TO lt_final.
  CLEAR: lv_tot_price, ls_vbak, ls_final.
ENDLOOP.

IF lt_final IS NOT INITIAL.
  CLEAR: ls_fcat, lt_fcat, ls_layout.
  ls_fcat-fieldname = 'VBELN'.
  ls_fcat-tabname = 'LT_FINAL'.
  ls_fcat-seltext_m = 'Sales Order'.
  ls_fcat-col_pos  = 1.
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.
  ls_fcat-fieldname = 'AUDAT'.
  ls_fcat-tabname = 'LT_FINAL'.
  ls_fcat-seltext_m = 'Order Date'.
  ls_fcat-col_pos  = 2.
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.
  ls_fcat-fieldname = 'AUART'.
  ls_fcat-tabname = 'LT_FINAL'.
  ls_fcat-seltext_m = 'Order Type'.
  ls_fcat-col_pos  = 3.
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.
  ls_fcat-fieldname = 'VKORG'.
  ls_fcat-tabname = 'LT_FINAL'.
  ls_fcat-seltext_m = 'Sales Org'.
  ls_fcat-col_pos  = 4.
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.
  ls_fcat-fieldname = 'VTWEG'.
  ls_fcat-tabname = 'LT_FINAL'.
  ls_fcat-seltext_m = 'Distribution'.
  ls_fcat-col_pos  = 5.
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.
  ls_fcat-fieldname = 'SPART'.
  ls_fcat-tabname = 'LT_FINAL'.
  ls_fcat-seltext_m = 'Division'.
  ls_fcat-col_pos  = 6.
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.
  ls_fcat-fieldname = 'KUNNR'.
  ls_fcat-tabname = 'LT_FINAL'.
  ls_fcat-seltext_m = 'Sold To Party'.
  ls_fcat-col_pos  = 7.
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.
  ls_fcat-fieldname = 'NETWR'.
  ls_fcat-tabname = 'LT_FINAL'.
  ls_fcat-seltext_m = 'Order Value'.
  ls_fcat-col_pos  = 8.
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.
  ls_fcat-fieldname = 'ERDAT'.
  ls_fcat-tabname = 'LT_FINAL'.
  ls_fcat-seltext_m = 'Created On'.
  ls_fcat-col_pos  = 9.
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.
  ls_fcat-fieldname = 'ERNAM'.
  ls_fcat-tabname = 'LT_FINAL'.
  ls_fcat-seltext_m = 'Created By'.
  ls_fcat-col_pos  = 10.
  APPEND ls_fcat TO lt_fcat.

  ls_layout-colwidth_optimize = abap_true.
  ls_layout-zebra = abap_true.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      is_layout          = ls_layout
      it_fieldcat        = lt_fcat
    TABLES
      t_outtab           = lt_final
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDIF.
