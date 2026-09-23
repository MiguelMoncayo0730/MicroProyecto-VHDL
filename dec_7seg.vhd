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
        seg_out <= "1111110" when "0000", -- Muestra 0
                   "0110000" when "0001", -- Muestra 1
                   "1101101" when "0010", -- Muestra 2
                   "1111001" when "0011", -- Muestra 3
                   "0110011" when "0100", -- Muestra 4
                   "1011011" when "0101", -- Muestra 5
                   "1011111" when "0110", -- Muestra 6
                   "1110000" when "0111", -- Muestra 7
                   "1111111" when "1000", -- Muestra 8
                   "1111011" when "1001", -- Muestra 9
                   "0000000" when others; -- apaga en otros casos
end architecture;