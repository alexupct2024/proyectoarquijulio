------------------------------------------------------------------------------------
--
-- Definition of an 8-bit SWAP process
--
-- The upper and lower nibbles of the operand are exchanged.
--
-- Example:
-- operand = 1010 1011 (AB)
-- Y       = 1011 1010 (BA)
--
------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity swap is
    Port (
        operand : in  std_logic_vector(7 downto 0);
        Y       : out std_logic_vector(7 downto 0);
        clk     : in  std_logic
    );
end swap;

architecture low_level_definition of swap is
begin

    process(clk)
    begin
        if clk'event and clk = '1' then
            Y(7 downto 4) <= operand(3 downto 0);
            Y(3 downto 0) <= operand(7 downto 4);
        end if;
    end process;

end low_level_definition;