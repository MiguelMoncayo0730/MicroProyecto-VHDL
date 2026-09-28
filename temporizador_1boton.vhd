library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity temporizador_1boton is
    Port (  clk, btn_control      : in  STD_LOGIC;
            min, seg_dec, seg_uni : out STD_LOGIC_VECTOR(6 downto 0);
		      dp_min                : out STD_LOGIC;
          );
end entity;

architecture temporizador_1boton_arch of temporizador_1boton is

    -- llamada al componente de bcd a 7 segmentos
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

    -- Contadores y banderas para el botón único
    signal contador_btn  : integer range 0 to 99_999_999 := 0;
    signal btn_prev      : STD_LOGIC := '1';
    signal reset_interno : STD_LOGIC := '0';
    signal alternar_run  : STD_LOGIC := '0';

    signal bcd_sec_u : STD_LOGIC_VECTOR(3 downto 0);
    signal bcd_sec_d : STD_LOGIC_VECTOR(3 downto 0);
    signal bcd_min_u : STD_LOGIC_VECTOR(3 downto 0);

begin
	 dp_min <= '0';
	 
    -- Divisor de 50 MHz a 1 Hz
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_interno = '1' then 
                contador_clk <= 0;
                pulso_1hz <= '0';
            else
                if contador_clk = 49_999_999 then
                    contador_clk <= 0;
                    pulso_1hz <= '1';
                else
                    contador_clk <= contador_clk + 1;
                    pulso_1hz <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Detección de Start, Stop y Reset
    process(clk)
    begin
        if rising_edge(clk) then
            btn_prev <= btn_control;
            
            -- Estp es para indicar que las banderas duran solo un ciclo de reloj
            alternar_run <= '0';
            reset_interno <= '0';

            if btn_control = '0' then -- Botón presionado
                if contador_btn < 99_999_999 then
                    contador_btn <= contador_btn + 1;
                end if;

                -- Si se mantiene presionado 2 segundos exactos
                if contador_btn = 99_999_998 then
                    reset_interno <= '1';
                end if;
                
            else
                -- Detección del instante de soltar
                if btn_prev = '0' then
                    -- Si se soltó antes de llegar a los 2 segundos
                    if contador_btn < 99_999_998 then
                        alternar_run <= '1'; -- Se genera un pulso para alternar
                    end if;
                end if;
                
                contador_btn <= 0; -- Se reinicia el medidor del botón
            end if;
        end if;
    end process;

    -- Único proceso para controlar el conteo y la variable "running"
    process(clk)
    begin
        if rising_edge(clk) then
            -- Reset por botón prolongado
            if reset_interno = '1' then
                sec_u   <= 0;
                sec_d   <= 0;
                min_u   <= 0;
                running <= '0';
            
            -- Alternar Start/Stop por toque corto
            elsif alternar_run = '1' then
                running <= not running;
            
            -- Avanza el reloj
            elsif pulso_1hz = '1' and running = '1' then
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
                            running <= '0'; -- Auto-stop a los 9:59
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

    -- Llamada de los Displays
    display_unidades : dec_7seg port map (bcd => bcd_sec_u, seg_out => seg_uni);
    display_decenas  : dec_7seg port map (bcd => bcd_sec_d, seg_out => seg_dec);
    display_minutos  : dec_7seg port map (bcd => bcd_min_u, seg_out => min);

end architecture;