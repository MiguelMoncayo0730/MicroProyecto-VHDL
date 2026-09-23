library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity temporizador_3botones is
    Port (
        clk           : in  STD_LOGIC;                      -- Reloj
        start         : in  STD_LOGIC;                      -- Inicio
        stop          : in  STD_LOGIC;                      -- Parada
        reset         : in  STD_LOGIC;                      -- Reinicio
		  disp_min      : out STD_LOGIC_VECTOR(6 downto 0);   -- Display de los minutos
        disp_sec_tens : out STD_LOGIC_VECTOR(6 downto 0);   -- Display de decenas de los segundos 
        disp_sec_units: out STD_LOGIC_VECTOR(6 downto 0));  -- Display unidades de los segundos
		  
end entity;

architecture temporizador_3botones_arch of temporizador_3botones is

    -- Aquí se hace la declaración del componente decodificador 7 segmentos para el Port Mapping
    component dec_7seg is
        Port (
            bcd     : in  STD_LOGIC_VECTOR(3 downto 0);
            seg_out : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    -- Señales internas de conteo
    signal sec_u   : integer range 0 to 9 := 0;  -- Unidades de los segundos
    signal sec_d   : integer range 0 to 5 := 0;  -- Decenas de los segundos
    signal min_u   : integer range 0 to 9 := 0;  -- Minutos
    signal running : STD_LOGIC := '0';           -- Estado de running y de detenido

    -- Señales en formato vector BCD para conectar a los componentes
    signal bcd_sec_u : STD_LOGIC_VECTOR(3 downto 0);
    signal bcd_sec_d : STD_LOGIC_VECTOR(3 downto 0);
    signal bcd_min_u : STD_LOGIC_VECTOR(3 downto 0);

begin

    -- Lógica Secuencial de Control y Conteo
    process(clk, reset)
    begin
        if reset = '1' then
            sec_u   <= 0;
            sec_d   <= 0;
            min_u   <= 0;
            running <= '0';
        elsif rising_edge(clk) then
            -- Evaluación de botones de arranque y parada
            if start = '1' then
                running <= '1';
            elsif stop = '1' then
                running <= '0';
            end if;

            -- Lógica de incremento del contador cuando está en marcha
            if running = '1' then
                if sec_u < 9 then
                    sec_u <= sec_u + 1;
                else
                    sec_u <= 0;
                    if sec_d < 5 then
                        sec_d <= sec_d + 1;
                    else
                        sec_d <= 0;
                        if min_u < 9 then
                            min_u <= min_u + 1;
                        else
                            -- Al alcanzar 9:59 se detiene automáticamente
                            running <= '0';
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Conversión de los contadores internos a BCD de 4 bits
    bcd_sec_u <= std_logic_vector(to_unsigned(sec_u, 4));
    bcd_sec_d <= std_logic_vector(to_unsigned(sec_d, 4));
    bcd_min_u <= std_logic_vector(to_unsigned(min_u, 4));

    -- Instanciación de componentes mediante portmapping
    U_UNIDADES_SEG : dec_7seg port map (bcd => bcd_sec_u, seg_out => disp_sec_units);
    U_DECENAS_SEG  : dec_7seg port map (bcd => bcd_sec_d, seg_out => disp_sec_tens);
    U_MINUTOS      : dec_7seg port map (bcd => bcd_min_u, seg_out => disp_min);

end architecture;