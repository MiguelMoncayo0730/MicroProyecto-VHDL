library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_espacio is
    Port (
        clk                 : in  STD_LOGIC;
        rst                 : in  STD_LOGIC;
        ocupado             : in  STD_LOGIC; 
        alarma              : out STD_LOGIC; 
        felicitacion        : out STD_LOGIC; 
        display_35_decenas  : out STD_LOGIC_VECTOR(6 downto 0);
        display_35_unidades : out STD_LOGIC_VECTOR(6 downto 0)
    );
end control_espacio;

architecture control_espacio_arch of control_espacio is

    -- Divisor de reloj (50 MHz a 1 Hz)
    signal contador_50mhz : integer range 0 to 49_999_999 := 0;
    signal pulso_1hz      : STD_LOGIC := '0';
    
    -- Variables de tiempo
    signal contador_35 : integer range 0 to 99 := 0;
    signal dec : integer range 0 to 9 := 0;
    signal uni : integer range 0 to 9 := 0;

    signal alarma_activa       : std_logic := '0';
    signal felicitacion_activa : std_logic := '0';
    signal persona_prev        : std_logic := '0';

    -- Declaración del componente dec_7seg
    component dec_7seg is
        Port (
            bcd     : in  STD_LOGIC_VECTOR(3 downto 0);
            seg_out : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    -- Señales auxiliares para conectar los integers decenas/unidades al puerto BCD del componente
    signal bcd_dec : std_logic_vector(3 downto 0);
    signal bcd_uni : std_logic_vector(3 downto 0);

begin

    -- Divisor de frecuencia (50 MHz -> 1 Hz)
    process(clk, rst)
    begin
        if rst = '0' then
            contador_50mhz <= 0;
            pulso_1hz <= '0';
        elsif rising_edge(clk) then
            if contador_50mhz = 49_999_999 then
                contador_50mhz <= 0;
                pulso_1hz <= '1';
            else
                contador_50mhz <= contador_50mhz + 1;
                pulso_1hz <= '0';
            end if;
        end if;
    end process;

    -- Lógica principal usando condicionales If-Else y detección de cambios
    process(clk, rst)
    begin
        if rst = '0' then
            contador_35 <= 0;
            alarma_activa <= '0';
            felicitacion_activa <= '0';
            persona_anterior <= '0';

        elsif rising_edge(clk) then
            
            -- Se guarda el valor actual para detectar cambios en el siguiente ciclo
            persona_anterior <= ocupado;

            -- Flanco de subida, es decir que el espacio acaba de ser ocupado (0 -> 1)
            if ocupado = '1' and persona_anterior = '0' then
                contador_35 <= 0;
                alarma_activa <= '0';
                felicitacion_activa <= '0';
            
            -- Flanco de bajada, es decir que el espacio acaba de ser desocupado (1 -> 0)
            elsif ocupado = '0' and persona_anterior = '1' then
                contador_35 <= 0; 
                if alarma_activa = '0' then
                    -- Si la persona desocupó antes de que sonara la alarma se le felicita
                    felicitacion_activa <= '1';
                else
                    -- Si ya estaba la alarma simplemente se apaga al salir
                    alarma_activa <= '0';
                end if;

            -- Si el espacio sigue ocupado (1 y 1)
            elsif ocupado = '1' then
                if pulso_1hz = '1' then
                    if alarma_activa = '0' then
                        -- Conteo normal hasta 35 segundos
                        if contador_35 >= 35 then
                            alarma_activa <= '1'; -- Se activa la alarma por exceso de tiempo
                            contador_35 <= 0;     -- Reinicia para contar el exceso
                        else
                            contador_35 <= contador_35 + 1;
                        end if;
                    else
                        -- Conteo del exceso de tiempo con alarma activada
                        if contador_35 < 99 then
                            contador_35 <= contador_35 + 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Asignación de las banderas lógicas a las salidas físicas
    alarma       <= alarma_activa;
    felicitacion <= felicitacion_activa;

    -- Conversión a decenas y unidades para los displays
    dec <= contador_35 / 10;
    uni <= contador_35 rem 10;

    -- Conversión de integer a std_logic_vector(3 downto 0)
    bcd_dec <= std_logic_vector(to_unsigned(dec, 4));
    bcd_uni <= std_logic_vector(to_unsigned(uni, 4));

    -- Llamada del componente para las decenas
    inst_decenas: dec_7seg
        port map (
            bcd     => bcd_dec,
            seg_out => display_35_decenas
        );

    -- Llamada del componente para las unidades
    inst_unidades: dec_7seg
        port map (
            bcd     => bcd_uni,
            seg_out => display_35_unidades
        );

end control_espacio_arch;