package Types is

    type Byte is mod 2**8;
    type Bytes is array (Natural range <>) of Byte;

    procedure Bytes_Put (Buffer : in Bytes);

    generic
        type UXX is mod <>;
    function Convert_To (Buffer : Bytes) return UXX
        with Depends => (Convert_To'Result => Buffer),
             Pre => UXX'Size rem 8 = 0 and then Buffer'Length = UXX'Size / 8;

end Types;
