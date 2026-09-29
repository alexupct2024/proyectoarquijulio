------------------------------------------------------------------------------------
--
-- Testbench del sistema completo (toplevel): PicoBlaze + ROM MASK_PARIDAD +
-- periferico de paridad.
--
-- Envia caracteres por rx (RS-232, 115200bps, 8N1), decodifica la respuesta
-- que sale por tx y comprueba que sea '0' si el nibble bajo del caracter
-- (resultado de MASK) tiene paridad par y '1' si es impar.
--
------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_toplevel is
end tb_toplevel;

architecture sim of tb_toplevel is

  component toplevel
    Port (      port_id : out std_logic_vector(7 downto 0);
           write_strobe : out std_logic;
            read_strobe : out std_logic;
               out_port : out std_logic_vector(7 downto 0);
                in_port : out std_logic_vector(7 downto 0);
                  reset : in std_logic;
                    clk : in std_logic;
                     rx : in std_logic;
                     tx : out std_logic;
                    LED : out std_logic);
  end component;

  constant CLK_PERIOD : time := 20 ns;      -- 50 MHz
  constant BIT_TIME   : time := 8680 ns;    -- 115200 bps

  signal clk     : std_logic := '0';
  signal reset   : std_logic := '1';
  signal rx      : std_logic := '1';
  signal tx      : std_logic;
  signal LED     : std_logic;
  signal port_id, out_port, in_port : std_logic_vector(7 downto 0);
  signal write_strobe, read_strobe  : std_logic;

  type char_array is array (natural range <>) of std_logic_vector(7 downto 0);
  constant test_chars : char_array := (
    x"41",   -- 'A' -> MASK 01 -> impar -> '1'
    x"43",   -- 'C' -> MASK 03 -> par   -> '0'
    x"37",   -- '7' -> MASK 07 -> impar -> '1'
    x"4F",   -- 'O' -> MASK 0F -> par   -> '0'
    x"F0",   --        MASK 00 -> par   -> '0'
    x"8E"    --        MASK 0E -> impar -> '1'
  );

  -- paridad esperada del nibble bajo en ASCII ('0' = 30h, '1' = 31h)
  function expected(c : std_logic_vector(7 downto 0)) return std_logic_vector is
    variable p : std_logic;
  begin
    p := c(0) xor c(1) xor c(2) xor c(3);
    if p = '1' then
      return x"31";
    else
      return x"30";
    end if;
  end function;

  function to_hex(v : std_logic_vector(7 downto 0)) return string is
    constant digits : string(1 to 16) := "0123456789ABCDEF";
    variable hi, lo : integer := 0;
  begin
    for i in 7 downto 4 loop
      hi := hi * 2;
      if v(i) = '1' then hi := hi + 1; end if;
    end loop;
    for i in 3 downto 0 loop
      lo := lo * 2;
      if v(i) = '1' then lo := lo + 1; end if;
    end loop;
    return digits(hi + 1) & digits(lo + 1);
  end function;

begin

  uut: toplevel
    port map(      port_id => port_id,
              write_strobe => write_strobe,
               read_strobe => read_strobe,
                  out_port => out_port,
                   in_port => in_port,
                     reset => reset,
                       clk => clk,
                        rx => rx,
                        tx => tx,
                       LED => LED);

  clk <= not clk after CLK_PERIOD / 2;

  stimulus: process
    variable rx_byte : std_logic_vector(7 downto 0);
    variable errors  : integer := 0;
  begin
    reset <= '1';
    wait for 200 ns;
    reset <= '0';
    wait for 20 us;

    for n in test_chars'range loop
      -- envia el caracter por rx: start, 8 bits (LSB primero), stop
      rx <= '0';
      wait for BIT_TIME;
      for i in 0 to 7 loop
        rx <= test_chars(n)(i);
        wait for BIT_TIME;
      end loop;
      -- bit de parada: el PicoBlaze lo muestrea a mitad de bit y empieza a
      -- responder enseguida, asi que se vigila tx sin esperar el bit completo
      rx <= '1';

      -- recibe la respuesta por tx, muestreando en mitad de cada bit
      wait until tx = '0' for 500 us;
      assert tx = '0'
        report "Timeout esperando respuesta para " & to_hex(test_chars(n))
        severity failure;
      wait for BIT_TIME / 2;
      for i in 0 to 7 loop
        wait for BIT_TIME;
        rx_byte(i) := tx;
      end loop;
      wait for BIT_TIME;
      assert tx = '1' report "Bit de parada incorrecto" severity error;

      if rx_byte = expected(test_chars(n)) then
        report "OK   enviado " & to_hex(test_chars(n)) &
               " -> recibido " & to_hex(rx_byte);
      else
        report "FAIL enviado " & to_hex(test_chars(n)) &
               " -> recibido " & to_hex(rx_byte) &
               " (esperado " & to_hex(expected(test_chars(n))) & ")"
          severity error;
        errors := errors + 1;
      end if;
      wait for 3 * BIT_TIME;
    end loop;

    if errors = 0 then
      report "SIMULACION CORRECTA: todas las pruebas pasan";
    else
      report "SIMULACION CON " & integer'image(errors) & " ERRORES" severity error;
    end if;
    wait;
  end process;

end sim;
