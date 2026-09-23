library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dec_7seg is
    Port (
        bcd     : in  STD_LOGIC_VECTOR(3 downto 0); -- Entrada en código BCD
        seg_out : out STD_LOGIC_VECTOR(6 downto 0)  -- Salida
    );
end dec_7seg;

architecture dec_7seg_arch of dec_7seg is
begin
    -- Asignación con with-select y mapeo
    with bcd select
        seg_out <= "1111110" when "0000", -- 0
                   "0110000" when "0001", -- 1
                   "1101101" when "0010", -- 2
                   "1111001" when "0011", -- 3
                   "0110011" when "0100", -- 4
                   "1011011" when "0101", -- 5
                   "1011111" when "0110", -- 6
                   "1110000" when "0111", -- 7
                   "1111111" when "1000", -- 8
                   "1111011" when "1001", -- 9
                   "0000000" when others; -- apaga en otros casos
end architecture;