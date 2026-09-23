library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity temporizador_1Boton is
    Port (
        clk     : in  STD_LOGIC;
        start   : in  STD_LOGIC;
        min     : out STD_LOGIC_VECTOR(6 downto 0);
        seg_dec : out STD_LOGIC_VECTOR(6 downto 0);
        seg_uni : out STD_LOGIC_VECTOR(6 downto 0)
    );
end entity;

architecture temporizador_1Boton_arch of temporizador_1Boton is
