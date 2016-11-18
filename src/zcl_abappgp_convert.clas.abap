class ZCL_ABAPPGP_CONVERT definition
  public
  final
  create public .

public section.

  class-methods BASE64_DECODE
    importing
      !IV_ENCODED type STRING
    returning
      value(RV_BIN) type XSTRING .
  class-methods BITS_TO_BIG_INTEGER
    importing
      !IV_BITS type STRING
    returning
      value(RO_INTEGER) type ref to ZCL_ABAPPGP_INTEGER .
  class-methods BITS_TO_INTEGER
    importing
      !IV_BITS type STRING
    returning
      value(RV_INT) type I .
  class-methods TO_BITS
    importing
      !IV_DATA type XSEQUENCE
    returning
      value(RV_BITS) type STRING .
  class-methods READ_MPI
    importing
      !IO_STREAM type ref to ZCL_ABAPPGP_STREAM
    returning
      value(RO_INTEGER) type ref to ZCL_ABAPPGP_INTEGER .
protected section.
ENDCLASS.



CLASS ZCL_ABAPPGP_CONVERT IMPLEMENTATION.


  METHOD base64_decode.

    CALL FUNCTION 'SSFC_BASE64_DECODE'
      EXPORTING
        b64data                  = iv_encoded
      IMPORTING
        bindata                  = rv_bin
      EXCEPTIONS
        ssf_krn_error            = 1
        ssf_krn_noop             = 2
        ssf_krn_nomemory         = 3
        ssf_krn_opinv            = 4
        ssf_krn_input_data_error = 5
        ssf_krn_invalid_par      = 6
        ssf_krn_invalid_parlen   = 7
        OTHERS                   = 8.
    IF sy-subrc <> 0.
      BREAK-POINT.
    ENDIF.

  ENDMETHOD.


  METHOD bits_to_big_integer.

    DATA: lv_bits  TYPE string,
          lo_multi TYPE REF TO zcl_abappgp_integer.


    CREATE OBJECT lo_multi
      EXPORTING
        iv_integer = 1.

    CREATE OBJECT ro_integer
      EXPORTING
        iv_integer = 0.

    lv_bits = reverse( iv_bits ).

    WHILE strlen( lv_bits ) > 0.
      CASE lv_bits(1).
        WHEN '0'.
        WHEN '1'.
          ro_integer = ro_integer->add( lo_multi ).
        WHEN OTHERS.
          ASSERT 0 = 1.
      ENDCASE.
      lv_bits = lv_bits+1.
      lo_multi = lo_multi->multiply_int( 2 ).
    ENDWHILE.

  ENDMETHOD.


  METHOD bits_to_integer.

    DATA: lv_bits  TYPE string,
          lv_multi TYPE i VALUE 1.


    lv_bits = reverse( iv_bits ).

    WHILE strlen( lv_bits ) > 0.
      CASE lv_bits(1).
        WHEN '0'.
        WHEN '1'.
          rv_int = rv_int + lv_multi.
        WHEN OTHERS.
          ASSERT 0 = 1.
      ENDCASE.
      lv_bits = lv_bits+1.
      lv_multi = lv_multi * 2.
    ENDWHILE.

  ENDMETHOD.


  METHOD read_mpi.

* todo, move this method to somewhere else?

    DATA: lv_length TYPE i,
          lv_octets TYPE i.


    lv_length = bits_to_integer(
      to_bits(
      io_stream->eat_octets( 2 ) ) ).

    lv_octets = lv_length DIV 8.
    IF lv_length MOD 8 <> 0.
      lv_octets = lv_octets + 1.
    ENDIF.

    ro_integer = bits_to_big_integer(
      to_bits(
      io_stream->eat_octets( lv_octets ) ) ).

  ENDMETHOD.


  METHOD to_bits.

    DATA: lv_char   TYPE c LENGTH 1,
          lv_length TYPE i.


    lv_length = xstrlen( iv_data ) * 8.

    DO lv_length TIMES.
      GET BIT sy-index OF iv_data INTO lv_char.
      CONCATENATE rv_bits lv_char INTO rv_bits.
    ENDDO.

  ENDMETHOD.
ENDCLASS.