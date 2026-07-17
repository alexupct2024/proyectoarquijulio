------------------------------------------------------------------------------------
--
-- Definition of an 8-bit not process
-- Operation
--
-- The input operand is applied a not
--
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mask is
    Port (operand : in std_logic_vector(7 downto 0);
          Y : out std_logic_vector(7 downto 0);
          clk : in std_logic);
end mask;
--
architecture low_level_definition of mask is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            Y(7 downto 4) <= (others => '0');      -- 4 bits MSB a 0
            Y(3 downto 0) <= operand(3 downto 0); -- 4 bits LSB iguales
        end if;
    end process;
end low_level_definition;
