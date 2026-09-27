library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity temporizador_3botones is
    Port (
        clk     : in  STD_LOGIC;
        start   : in  STD_LOGIC;
        stop    : in  STD_LOGIC;
        reset   : in  STD_LOGIC;
        min     : out STD_LOGIC_VECTOR(6 downto 0);
        seg_dec : out STD_LOGIC_VECTOR(6 downto 0);
        seg_uni : out STD_LOGIC_VECTOR(6 downto 0)
    );
end entity;

architecture temporizador_3botones_arch of temporizador_3botones is

    component dec_7seg is
        Port (
            bcd     : in  STD_LOGIC_VECTOR(3 downto 0);
            seg_out : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    signal sec_u   : integer range 0 to 9 := 0;
    signal sec_d   : integer range 0 to 5 := 0;
    signal min_u   : integer range 0 to 9 := 0;
    signal running : STD_LOGIC := '0';

    signal contador_clk : integer range 0 to 49_999_999 := 0;
    signal pulso_1hz    : STD_LOGIC := '0';

    signal bcd_sec_u : STD_LOGIC_VECTOR(3 downto 0);
    signal bcd_sec_d : STD_LOGIC_VECTOR(3 downto 0);
    signal bcd_min_u : STD_LOGIC_VECTOR(3 downto 0);

begin

    -- Divisor de 50 MHz a 1 Hz
    process(clk, reset)
    begin
        if reset = '0' then 
            contador_clk <= 0;
            pulso_1hz <= '0';
        elsif rising_edge(clk) then
            if contador_clk = 49_999_999 then
                contador_clk <= 0;
                pulso_1hz <= '1';
            else
                contador_clk <= contador_clk + 1;
                pulso_1hz <= '0';
            end if;
        end if;
    end process;

    -- Control de botones y conteo
    process(clk, reset)
    begin
        -- Reset asíncrono al detectar '0'
        if reset = '0' then
            sec_u <= 0;
            sec_d <= 0;
            min_u <= 0;
            running <= '0';
            
        elsif rising_edge(clk) then
            
            -- Start / Stop con lógica de botones en bajo ('0')
            if start = '0' then
                running <= '1';
            elsif stop = '0' then
                running <= '0';
            end if;

            -- Conteo del temporizador a 1 Hz
            if pulso_1hz = '1' and running = '1' then
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
                            running <= '0'; -- Se detiene al llegar a 9:59
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Conversión a BCD
    bcd_sec_u <= std_logic_vector(to_unsigned(sec_u, 4));
    bcd_sec_d <= std_logic_vector(to_unsigned(sec_d, 4));
    bcd_min_u <= std_logic_vector(to_unsigned(min_u, 4));

    -- Instanciación de los Displays
    display_unidades : dec_7seg
        port map (
            bcd     => bcd_sec_u,
            seg_out => seg_uni
        );

    display_decenas : dec_7seg
        port map (
            bcd     => bcd_sec_d,
            seg_out => seg_dec
        );

    display_minutos : dec_7seg
        port map (
            bcd     => bcd_min_u,
				
            seg_out => min
        );

end architecture;