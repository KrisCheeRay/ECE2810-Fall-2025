
LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;

ENTITY top IS
   PORT (
      clk      : IN STD_LOGIC;
      rstn     : IN STD_LOGIC;
      load     : IN STD_LOGIC;
      clk_1hz  : OUT STD_LOGIC;
      clk_2hz  : OUT STD_LOGIC;
      clk_4hz  : OUT STD_LOGIC;
      clk_8hz  : OUT STD_LOGIC;
      sw_in    : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      led      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      seg      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
      dn       : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
   );
END top;

ARCHITECTURE trans OF top IS
   COMPONENT blink_led IS
      PORT (
         clk      : IN STD_LOGIC;
         rstn     : IN STD_LOGIC;
         clk_1hz  : OUT STD_LOGIC;
         clk_2hz  : OUT STD_LOGIC;
         clk_4hz  : OUT STD_LOGIC;
         clk_8hz  : OUT STD_LOGIC
      );
   END COMPONENT;
   
   
   SIGNAL sw            : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL tens          : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL ones          : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL cnt1          : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL clk_div       : STD_LOGIC;
   SIGNAL seg0          : STD_LOGIC_VECTOR(6 DOWNTO 0);
   SIGNAL seg1          : STD_LOGIC_VECTOR(6 DOWNTO 0);
   
   SIGNAL tens_r        : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL ones_r        : STD_LOGIC_VECTOR(3 DOWNTO 0);
   
   SIGNAL clk_1hz_tmp0 : STD_LOGIC;
   SIGNAL clk_2hz_tmp1 : STD_LOGIC;
   SIGNAL clk_4hz_tmp2 : STD_LOGIC;
   SIGNAL clk_8hz_tmp3 : STD_LOGIC;
BEGIN

   clk_1hz <= clk_1hz_tmp0;
   clk_2hz <= clk_2hz_tmp1;
   clk_4hz <= clk_4hz_tmp2;
   clk_8hz <= clk_8hz_tmp3;
   
   
   blink_led_ins : blink_led
      PORT MAP (
         clk      => clk,
         rstn     => rstn,
         clk_1hz  => clk_1hz_tmp0,
         clk_2hz  => clk_2hz_tmp1,
         clk_4hz  => clk_4hz_tmp2,
         clk_8hz  => clk_8hz_tmp3
      );
   PROCESS (clk, rstn)
   BEGIN
      IF (rstn = '0') THEN
         sw <= "00000000";
      ELSIF (clk'EVENT AND clk = '1') THEN
         IF (load = '1') THEN
            sw <= sw_in;
         ELSE
            sw <= sw;
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (sw) 
   BEGIN
      IF (sw(7 DOWNTO 4) > "1001") THEN
         tens <= "1001";
      ELSE
         tens <= sw(7 DOWNTO 4);
      END IF;
   END PROCESS;
   
   PROCESS (sw)
   BEGIN
      IF (sw(3 DOWNTO 0) > "1001") THEN
         ones <= "1001";
      ELSE
         ones <= sw(3 DOWNTO 0);
      END IF;
   END PROCESS;
   
   led <= (tens & ones);
   
   PROCESS (clk_1hz_tmp0, rstn)
   BEGIN
      IF (rstn = '0') THEN
         tens_r <= "0000";
      ELSIF (clk_1hz_tmp0'EVENT AND clk_1hz_tmp0 = '1') THEN
         IF (load = '1') THEN
            tens_r <= tens;
         ELSIF (tens_r = "0000") THEN
            tens_r <= "0000";
         ELSIF (ones_r = "0000") THEN
            tens_r <= tens_r - "0001";
         ELSE
            tens_r <= tens_r;
         END IF;
      END IF;
   END PROCESS;
   
   
   PROCESS (clk_1hz_tmp0, rstn)
   BEGIN
      IF (rstn = '0') THEN
         ones_r <= "0000";
      ELSIF (clk_1hz_tmp0'EVENT AND clk_1hz_tmp0 = '1') THEN
         IF (load = '1') THEN
            ones_r <= ones;
         ELSIF (ones_r = "0000") THEN
            IF (tens_r = "0000") THEN
               ones_r <= "0000";
            ELSE
               ones_r <= "1001";
            END IF;
         ELSE
            ones_r <= ones_r - "0001";
         END IF;
      END IF;
   END PROCESS;
   
   
   PROCESS (clk, rstn)
   BEGIN
      IF (rstn = '0') THEN
         cnt1 <= "00000000000000000000000000000000";
      ELSIF (clk'EVENT AND clk = '1') THEN
         IF (cnt1 = "00000000000000111101000010001111") THEN
            cnt1 <= "00000000000000000000000000000000";
         ELSE
            cnt1 <= cnt1 + "00000000000000000000000000000001";
         END IF;
      END IF;
   END PROCESS;
   
   
   PROCESS (clk, rstn)
   BEGIN
      IF (rstn = '0') THEN
         clk_div <= '0';
      ELSIF (clk'EVENT AND clk = '1') THEN
         IF (cnt1 = "00000000000000111101000010001111") THEN
            clk_div <= NOT(clk_div);
         ELSE
            clk_div <= clk_div;
         END IF;
      END IF;
   END PROCESS;
   
   
   PROCESS (tens_r)
   BEGIN
      CASE tens_r IS
         WHEN "0000" =>
            seg1 <= "0000000";
         WHEN "0001" =>
            seg1 <= "0010010";
         WHEN "0010" =>
            seg1 <= "1011101";
         WHEN "0011" =>
            seg1 <= "1011011";
         WHEN "0100" =>
            seg1 <= "0111010";
         WHEN "0101" =>
            seg1 <= "1101011";
         WHEN "0110" =>
            seg1 <= "1101111";
         WHEN "0111" =>
            seg1 <= "1010010";
         WHEN "1000" =>
            seg1 <= "1111111";
         WHEN "1001" =>
            seg1 <= "1111011";
         WHEN OTHERS =>
            seg1 <= "0000000";
      END CASE;
   END PROCESS;
   
   
   PROCESS (ones_r)
   BEGIN
      CASE ones_r IS
         WHEN "0000" =>
            seg0 <= "1110111";
         WHEN "0001" =>
            seg0 <= "0010010";
         WHEN "0010" =>
            seg0 <= "1011101";
         WHEN "0011" =>
            seg0 <= "1011011";
         WHEN "0100" =>
            seg0 <= "0111010";
         WHEN "0101" =>
            seg0 <= "1101011";
         WHEN "0110" =>
            seg0 <= "1101111";
         WHEN "0111" =>
            seg0 <= "1010010";
         WHEN "1000" =>
            seg0 <= "1111111";
         WHEN "1001" =>
            seg0 <= "1111011";
         WHEN OTHERS =>
            seg0 <= "0000000";
      END CASE;
   END PROCESS;
   
   
   dn <= "10" WHEN (clk_div = '1') ELSE
         "01";
   seg <= seg1 WHEN (clk_div = '1') ELSE
          seg0;
   
END trans;


LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;

ENTITY blink_led IS
   PORT (
      clk      : IN STD_LOGIC;
      rstn     : IN STD_LOGIC;
      clk_1hz  : OUT STD_LOGIC;
      clk_2hz  : OUT STD_LOGIC;
      clk_4hz  : OUT STD_LOGIC;
      clk_8hz  : OUT STD_LOGIC
   );
END blink_led;

ARCHITECTURE trans OF blink_led IS
   SIGNAL cnt           : STD_LOGIC_VECTOR(31 DOWNTO 0);
   
   SIGNAL clk_1hz_tmp0 : STD_LOGIC;
   SIGNAL clk_2hz_tmp1 : STD_LOGIC;
   SIGNAL clk_4hz_tmp2 : STD_LOGIC;
   SIGNAL clk_8hz_tmp3 : STD_LOGIC;
BEGIN

   clk_1hz <= clk_1hz_tmp0;
   clk_2hz <= clk_2hz_tmp1;
   clk_4hz <= clk_4hz_tmp2;
   clk_8hz <= clk_8hz_tmp3;
   PROCESS (clk, rstn)
   BEGIN
      IF (rstn = '0') THEN
         cnt <= "00000000000000000000000000000000";
      ELSIF (clk'EVENT AND clk = '1') THEN
         IF (cnt = "00000000010111110101111000001111") THEN
         -- IF (cnt = "00000000000000000001100001101001") THEN
            cnt <= "00000000000000000000000000000000";
         ELSE
            cnt <= cnt + "00000000000000000000000000000001";
         END IF;
      END IF;
   END PROCESS;
   
   
   PROCESS (clk, rstn)
   BEGIN
      IF (rstn = '0') THEN
         clk_8hz_tmp3 <= '0';
      ELSIF (clk'EVENT AND clk = '1') THEN
         IF (cnt = "00000000010111110101111000001111") THEN
         -- IF (cnt = "00000000000000000001100001101001") THEN
            clk_8hz_tmp3 <= NOT(clk_8hz_tmp3);
         ELSE
            clk_8hz_tmp3 <= clk_8hz_tmp3;
         END IF;
      END IF;
   END PROCESS;
   
   
   PROCESS (clk_8hz_tmp3, rstn)
   BEGIN
      IF (rstn = '0') THEN
         clk_4hz_tmp2 <= '0';
      ELSIF (clk_8hz_tmp3'EVENT AND clk_8hz_tmp3 = '1') THEN
         clk_4hz_tmp2 <= NOT(clk_4hz_tmp2);
      END IF;
   END PROCESS;
   
   
   PROCESS (clk_4hz_tmp2, rstn)
   BEGIN
      IF (rstn = '0') THEN
         clk_2hz_tmp1 <= '0';
      ELSIF (clk_4hz_tmp2'EVENT AND clk_4hz_tmp2 = '1') THEN
         clk_2hz_tmp1 <= NOT(clk_2hz_tmp1);
      END IF;
   END PROCESS;
   
   
   PROCESS (clk_2hz_tmp1, rstn)
   BEGIN
      IF (rstn = '0') THEN
         clk_1hz_tmp0 <= '0';
      ELSIF (clk_2hz_tmp1'EVENT AND clk_2hz_tmp1 = '1') THEN
         clk_1hz_tmp0 <= NOT(clk_1hz_tmp0);
      END IF;
   END PROCESS;
   
   
END trans;
