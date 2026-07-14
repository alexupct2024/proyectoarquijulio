library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity parity_unit is
    Port (
        data_in : in  std_logic_vector(7 downto 0);
        Y       : out std_logic_vector(7 downto 0)
    );
end parity_unit;

architecture Behavioral of parity_unit is
    signal parity_bit : std_logic;
begin

    parity_bit <= data_in(0) xor data_in(1) xor data_in(2) xor data_in(3) xor
                  data_in(4) xor data_in(5) xor data_in(6) xor data_in(7);

    Y <= "0000000" & parity_bit;

end Behavioral;