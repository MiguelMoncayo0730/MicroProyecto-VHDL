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

    -- Banderas lógicas que reemplazan la máquina de estados
    signal alarma_activa       : std_logic := '0';
    signal felicitacion_activa : std_logic := '0';
    signal persona_prev        : std_logic := '0';

    -- Decodificador BCD a 7 Segmentos usando CASE
    function digito_7seg(digito : integer) return STD_LOGIC_VECTOR is
    begin
        case digito is
            when 0 => return "1000000"; -- 0
            when 1 => return "1111001"; -- 1
            when 2 => return "0100100"; -- 2
            when 3 => return "0110000"; -- 3
            when 4 => return "0011001"; -- 4
            when 5 => return "0010010"; -- 5
            when 6 => return "0000010"; -- 6
            when 7 => return "1111000"; -- 7
            when 8 => return "0000000"; -- 8
            when 9 => return "0010000"; -- 9
            when others => return "1111111"; -- Apagado
        end case;
    end function;

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

    -- Lógica principal usando condicionales (If-Else) y detección de flancos
    process(clk, rst)
    begin
        if rst = '0' then
            contador_35 <= 0;
            alarma_activa <= '0';
            felicitacion_activa <= '0';
            persona_prev <= '0';

        elsif rising_edge(clk) then
            
            -- Guardamos el valor actual para detectar cambios (flancos) en el siguiente ciclo
            persona_prev <= ocupado;

            -- 1. Flanco de subida: El espacio acaba de ser OCUPADO (0 -> 1)
            if ocupado = '1' and persona_prev = '0' then
                contador_35 <= 0;
                alarma_activa <= '0';
                felicitacion_activa <= '0';
            
            -- 2. Flanco de bajada: El espacio acaba de ser DESOCUPADO (1 -> 0)
            elsif ocupado = '0' and persona_prev = '1' then
                contador_35 <= 0; 
                if alarma_activa = '0' then
                    -- Si se desocupó antes de que sonara la alarma, lo felicitamos
                    felicitacion_activa <= '1';
                else
                    -- Si ya estaba la alarma, simplemente la apagamos al salir
                    alarma_activa <= '0';
                end if;

            -- 3. Nivel alto continuo: El espacio sigue OCUPADO (1 y 1)
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

    display_35_decenas  <= digito_7seg(dec);
    display_35_unidades <= digito_7seg(uni);

end control_espacio_arch;