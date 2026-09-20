library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_espacio is
    Port (
        clk                 : in  STD_LOGIC;                     -- Reloj 
        rst                 : in  STD_LOGIC;                     -- Reset del sistema
        ocupado             : in  STD_LOGIC;                     -- Sensor que indica si está ocupado (1) o si está libre (0)
        alarma              : out STD_LOGIC;                     -- Alarma por si la persona se pasa del tiempo (35 segundos)
        felicitacion        : out STD_LOGIC;                     -- Salida de la persona antes de los 35 segundos
        tiempo_35seg        : out STD_LOGIC_VECTOR(5 downto 0);  -- Tiempo consumido entre 0 y 35 segundos
        tiempo_facturacion  : out STD_LOGIC_VECTOR(7 downto 0)   -- Tiempo que se pasó la persona
    );
end control_espacio;

architecture control_espacio_arch of control_espacio is

    -- Declaración de señales, contadores y estados
    signal contador_35         : integer range 0 to 35 := 0;
    signal contador_segExtra   : integer range 0 to 255 := 0;
    signal estado_alarma       : STD_LOGIC := '0';
    signal estado_felicitacion : STD_LOGIC := '0';
begin

    -- Proceso secuencial síncrono por flanco de reloj
    process(clk, rst)
    begin
        if rst = '1' then
            contador_35         <= 0;
            contador_segExtra   <= 0;
            estado_alarma       <= '0';
            estado_felicitacion <= '0';
        elsif rising_edge(clk) then
            if ocupado = '1' then
                estado_felicitacion <= '0'; -- Apaga la felicitación mientras el espacio esté ocupado por una persona
                
                if contador_35    < 35 then
                    contador_35   <= contador_35 + 1;
                    estado_alarma <= '0';
                else
                    -- La persona excedió los 35 segundos 
                    estado_alarma     <= '1';
                    contador_segExtra <= contador_segExtra + 1;
                end if;
            else
                -- El espacio fue desocupado
                if contador_35 > 0 and contador_35 <= 35 and estado_alarma = '0' then
                    estado_felicitacion <= '1'; -- La persona salió dentro del tiempo permitido
                else
                    estado_felicitacion <= '0';
                end if;

                -- Reiniciar contadores para la siguiente persona
                contador_35       <= 0;
                contador_segExtra <= 0;
                estado_alarma     <= '0';
            end if;
        end if;
    end process;

    -- Asignaciones a los puertos de salida
    alarma             <= estado_alarma;
    felicitacion       <= estado_felicitacion;
    tiempo_35seg       <= std_logic_vector(to_unsigned(contador_35, 6));
    tiempo_facturacion <= std_logic_vector(to_unsigned(contador_segExtra, 8));

end architecture;