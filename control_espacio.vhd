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
		  
		  --En este caso usé la IA para implementar el bcd a 7 segmentos en el código que ya tenía
		  display_35_decenas      : out STD_LOGIC_VECTOR(6 downto 0);
        display_35_unidades     : out STD_LOGIC_VECTOR(6 downto 0);
        display_fact_decenas    : out STD_LOGIC_VECTOR(6 downto 0);
        display_fact_unidades   : out STD_LOGIC_VECTOR(6 downto 0)
		  );
		  
end control_espacio;

architecture control_espacio_arch of control_espacio is

    signal contador_35         : integer range 0 to 35 := 0;
    signal contador_segExtra   : integer range 0 to 255 := 0;
    signal estado_alarma       : STD_LOGIC := '0';
    signal estado_felicitacion : STD_LOGIC := '0';
    signal contador_50mhz      : integer range 0 to 49_999_999 := 0;
    signal pulso_1hz           : STD_LOGIC := '0';
	 
	 --Implementación de la función para el bcd a 7seg
    function digito_7seg(digito : integer)
        return STD_LOGIC_VECTOR is

        variable segmentos : STD_LOGIC_VECTOR(6 downto 0);
	 begin
        case digito is
            when 0 =>
                segmentos := "1000000";
            when 1 =>
                segmentos := "1111001";
            when 2 =>
                segmentos := "0100100";
            when 3 =>
                segmentos := "0110000";
            when 4 =>
                segmentos := "0011001";
            when 5 =>
                segmentos := "0010010";
            when 6 =>
                segmentos := "0000010";
            when 7 =>
                segmentos := "1111000";
            when 8 =>
                segmentos := "0000000";
            when 9 =>
                segmentos := "0010000";
            when others =>
                segmentos := "1111111";
        end case;

        return segmentos;

    end function;

begin
    -- Divisor de frecuencia (en este caso usé la IA para este process)
    process(clk)
    begin
        if rising_edge(clk) then
            if contador_50mhz = 49_999_999 then
                contador_50mhz <= 0;
                pulso_1hz      <= '1';
            else
                contador_50mhz <= contador_50mhz + 1;
                pulso_1hz      <= '0';
            end if;
        end if;
    end process;
    
	 
    -- Apartir de aquí se basa todo en la lógica principal
    process(clk, rst)
    begin
        if rst = '0' then
            contador_35         <= 0;
            contador_segExtra   <= 0;
            estado_alarma       <= '0';
            estado_felicitacion <= '0';
                
        elsif rising_edge(clk) then
            
            if ocupado = '1' then
                -- Se apaga la felicitación en cuanto una nueva persona ingresa
                estado_felicitacion <= '0';
                
                -- Los temporizadores de 35 segundos y la facturación extra van contando solo con el pulso de 1 Hz
                if pulso_1hz = '1' then
                    if contador_35 < 35 then
                        contador_35   <= contador_35 + 1;
                        estado_alarma <= '0';
                    else
                        estado_alarma     <= '1';
                        if contador_segExtra < 255 then
                            contador_segExtra <= contador_segExtra + 1;
                        end if;    
                    end if;
                end if;
                
            else
                -- Si el espacio se desocupa se evalua si salió dentro del tiempo para dar la felicitación
                if contador_35 > 0 and estado_alarma = '0' then
                    estado_felicitacion <= '1';
                end if;

                -- Se detienen y reinician los temporizadores y la alarma si la persona sale a tiempo
                contador_35       <= 0;
                contador_segExtra <= 0;
                estado_alarma     <= '0';
            end if;
            
        end if;
    end process;

    -- Asignación de señales a los puertos de salida
    alarma             <= estado_alarma;
    felicitacion       <= estado_felicitacion;
    
	 --Este es el display de los 35 segundos
	 display_35_decenas <=
        digito_7seg(contador_35 / 10);

    display_35_unidades <=
        digito_7seg(contador_35 mod 10);
		  
	 --Este es el display de la facturación

    display_fact_decenas <=
        digito_7seg((contador_segExtra / 10) mod 10);

    display_fact_unidades <=
        digito_7seg(contador_segExtra mod 10);


end architecture;