library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_disp is
    Port (
        pixel_x : in STD_LOGIC_VECTOR (9 downto 0);
        pixel_y : in STD_LOGIC_VECTOR (9 downto 0);
        hit_cnt: in STD_LOGIC_VECTOR (2 downto 0);
        life_cnt: in STD_LOGIC_VECTOR (1 downto 0);
        sq_hit_cnter_on_output: out std_logic;
        sq_life_cnter_on_output: out std_logic;
        graph_rgb: out std_logic_vector(2 downto 0)
    );
end counter_disp;

architecture Behavioral of counter_disp is
    -- x, y coordinates (0,0 to (639, 479)
    signal pix_x, pix_y: unsigned(9 downto 0);
    -- signal that stores the unsigned 'hit_cnt' value
    signal hit_cnter: unsigned(2 downto 0);
    -- Square cnter size and boundaries
    constant CNT_SIZE: integer := 16;
    constant HIT_CNT_X_L: integer := 610;
    constant HIT_CNT_X_R: integer:= HIT_CNT_X_L + CNT_SIZE - 1;
    constant HIT_CNT_Y_T: integer := 80;
    constant HIT_CNT_Y_B: integer:= HIT_CNT_Y_T + CNT_SIZE - 1;
    -- new data type to store the 16x16 rom images of counter values 0-7
    type counter_type is array(0 to 15) of std_logic_vector(15 downto 0);
    -- signal that stores the rom image of the current cnter value
    signal cnter_rom_current: counter_type;
    -- constant rom images for 0-7
    constant CNTER_ROM_0: counter_type:= (
    "0000101111110000",
    "0001111111111100",
    "0111000000001111",
    "0110000000000011",
    "1110000000000011",
    "1110000000000011",
    "1110000000000011",
    "1110000000000011",
    "1110000000000011",
    "1110000000000011",
    "1110000000000011",
    "1110000000000011",
    "1110000010000111",
    "0111000000011110",
    "0011111111111100",
    "0000111111111000");

    --- Write your own VHDL code below:
    --- Initialize images for other CNTER_ROM VALUES (1-7)

    constant CNTER_ROM_1: counter_type:= (
    "0000001110000000",
    "0000001110000000",
    "0000001110000000",
    "0000001110000000",
    "0000001110000000",
    "0000001110000000",
    "0000001110000000",
    "0000001110000000",
    "0000001110000000",
    "0000001110000000",
    "0000001110000000",
    "0000001110000000",
    "0000001110000000",
    "0000001110000000",
    "0000001110000000",
    "0000001110000000");

    constant CNTER_ROM_2: counter_type:= (
    "1111111111111111",
    "1111111111111111",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1111111111111111",
    "1111111111111111",
    "0000000000000111",
    "0000000000000111",
    "0000000000000111",
    "0000000000000111",
    "0000000000000111",
    "1111111111111111",
    "1111111111111111");

    constant CNTER_ROM_3: counter_type:= (
    "1111111111111111",
    "1111111111111111",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1111111111111111",
    "1111111111111111",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1111111111111111",
    "1111111111111111");

    constant CNTER_ROM_4: counter_type:= (
    "1110000000000111",
    "1110000000000111",
    "1110000000000111",
    "1110000000000111",
    "1110000000000111",
    "1110000000000111",
    "1110000000000111",
    "1111111111111111",
    "1111111111111111",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000");

    constant CNTER_ROM_5: counter_type:= (
    "1111111111111111",
    "1111111111111111",
    "0000000000000111",
    "0000000000000111",
    "0000000000000111",
    "0000000000000111",
    "0000000000000111",
    "1111111111111111",
    "1111111111111111",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1111111111111111",
    "1111111111111111");

    constant CNTER_ROM_6: counter_type:= (
    "1111111111111111",
    "1111111111111111",
    "0000000000000111",
    "0000000000000111",
    "0000000000000111",
    "0000000000000111",
    "0000000000000111",
    "1111111111111111",
    "1111111111111111",
    "1110000000000111",
    "1110000000000111",
    "1110000000000111",
    "1110000000000111",
    "1110000000000111",
    "1111111111111111",
    "1111111111111111");

    constant CNTER_ROM_7: counter_type:= (
    "1111111111111111",
    "1111111111111111",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000",
    "1110000000000000");

    -- signals to store the row and column indexes of the current cnter rom
    signal rom_addr_cnter, rom_col_cnter: unsigned(3 downto 0);
    -- signals to store the row data and the rom_bit
    signal rom_data_cnter: std_logic_vector(15 downto 0);
    signal rom_bit_cnter: std_logic;
    -- signal to indicate if scan coord is within the square area of
    --- the counter
    signal sq_hit_cnter_on: std_logic;
    -- signals to indicate if the image of current cnter value is
    --- displayed
    signal hit_cnter_cur_val_on: std_logic;
    -- hit cnter value color
    signal hit_cnter_rgb:std_logic_vector(2 downto 0);
    -- signals that store unsigned values of the square counter boundaries
    signal hit_cnt_y_t_u: unsigned(9 downto 0);
    signal hit_cnt_x_l_u: unsigned(9 downto 0);

    -- signal that stores the unsigned life_cnt value
    signal life_cnter: unsigned (1 downto 0);

    constant LIFE_SIZE: integer := 16;

    constant LIFE_CNT_1_X_L: integer := 550;
    constant LIFE_CNT_1_X_R: integer:= LIFE_CNT_1_X_L + LIFE_SIZE - 1;
    constant LIFE_CNT_1_Y_T: integer := 55;
    constant LIFE_CNT_1_Y_B: integer:= LIFE_CNT_1_Y_T + LIFE_SIZE - 1;

    constant LIFE_CNT_2_X_L: integer := 580;
    constant LIFE_CNT_2_X_R: integer:= LIFE_CNT_2_X_L + LIFE_SIZE - 1;
    constant LIFE_CNT_2_Y_T: integer := 55;
    constant LIFE_CNT_2_Y_B: integer:= LIFE_CNT_2_Y_T + LIFE_SIZE - 1;

    constant LIFE_CNT_3_X_L: integer := 610;
    constant LIFE_CNT_3_X_R: integer:= LIFE_CNT_3_X_L + LIFE_SIZE - 1;
    constant LIFE_CNT_3_Y_T: integer := 55;
    constant LIFE_CNT_3_Y_B: integer:= LIFE_CNT_3_Y_T + LIFE_SIZE - 1;

    type life_type is array (0 to 15) of std_logic_vector (0 to 15);
    constant LIFE_ROM_1: life_type := (
        "0000110001100000",
        "0001111101111000",
        "0011111111111100",
        "0111111111111110",
        "1111111111111110",
        "1111111111111110",
        "1111111111111110",
        "0111111111111100",
        "0011111111111000",
        "0001111111110000",
        "0000111111100000",
        "0000011111000000",
        "0000001110000000",
        "0000001100000000",
        "0000000100000000",
        "0000000000000000"
    );

    constant LIFE_ROM_2: life_type := (
        "0000110001100000",
        "0001111101111000",
        "0011111111111100",
        "0111111111111110",
        "1111111111111110",
        "1111111111111110",
        "1111111111111110",
        "0111111111111100",
        "0011111111111000",
        "0001111111110000",
        "0000111111100000",
        "0000011111000000",
        "0000001110000000",
        "0000001100000000",
        "0000000100000000",
        "0000000000000000"
    );

    constant LIFE_ROM_3: life_type := (
        "0000110001100000",
        "0001111101111000",
        "0011111111111100",
        "0111111111111110",
        "1111111111111110",
        "1111111111111110",
        "1111111111111110",
        "0111111111111100",
        "0011111111111000",
        "0001111111110000",
        "0000111111100000",
        "0000011111000000",
        "0000001110000000",
        "0000001100000000",
        "0000000100000000",
        "0000000000000000"
    );

    signal life_cnter_rgb: std_logic_vector(2 downto 0);

    signal rom_addr_life_cnter_1, rom_col_life_cnter_1: unsigned(3 downto 0);
    signal rom_data_life_cnter_1: std_logic_vector(15 downto 0);
    signal rom_bit_life_cnter_1: std_logic;
    signal sq_life_cnter_1_on: std_logic;
    signal life_cnter_1_cur_val_on: std_logic;
    signal life_cnt_1_y_t_u: unsigned(9 downto 0);
    signal life_cnt_1_x_l_u: unsigned(9 downto 0);

    signal rom_addr_life_cnter_2, rom_col_life_cnter_2: unsigned(3 downto 0);
    signal rom_data_life_cnter_2: std_logic_vector(15 downto 0);
    signal rom_bit_life_cnter_2: std_logic;
    signal sq_life_cnter_2_on: std_logic;
    signal life_cnter_2_cur_val_on: std_logic;
    signal life_cnt_2_y_t_u: unsigned(9 downto 0);
    signal life_cnt_2_x_l_u: unsigned(9 downto 0);

    signal rom_addr_life_cnter_3, rom_col_life_cnter_3: unsigned(3 downto 0);
    signal rom_data_life_cnter_3: std_logic_vector(15 downto 0);
    signal rom_bit_life_cnter_3: std_logic;
    signal sq_life_cnter_3_on: std_logic;
    signal life_cnter_3_cur_val_on: std_logic;
    signal life_cnt_3_y_t_u: unsigned(9 downto 0);
    signal life_cnt_3_x_l_u: unsigned(9 downto 0);

begin
    pix_x <= unsigned(pixel_x);
    pix_y <= unsigned(pixel_y);
    hit_cnter <= unsigned(hit_cnt);
    life_cnter <= unsigned(life_cnt);

    -- Write your VHDL code below:
    -- Assert ‘sq_hit_cnter_on’ by checking if the pixel is within the area
    --- of the square hit_counter;
    -- Note: the square area is a fixed area shared by 8 counter values

    sq_hit_cnter_on <= '1' when (HIT_CNT_X_L <= pix_x) and (pix_x <= HIT_CNT_X_R) and (HIT_CNT_Y_T <= pix_y) and (pix_y <= HIT_CNT_Y_B) else '0';
        
    sq_life_cnter_1_on <= '1' when (LIFE_CNT_1_X_L <= pix_x) and (pix_x <= LIFE_CNT_1_X_R) and (LIFE_CNT_1_Y_T <= pix_y) and (pix_y <= LIFE_CNT_1_Y_B) else '0';
    sq_life_cnter_2_on <= '1' when (LIFE_CNT_2_X_L <= pix_x) and (pix_x <= LIFE_CNT_2_X_R) and (LIFE_CNT_2_Y_T <= pix_y) and (pix_y <= LIFE_CNT_2_Y_B) else '0';
    sq_life_cnter_3_on <= '1' when (LIFE_CNT_3_X_L <= pix_x) and (pix_x <= LIFE_CNT_3_X_R) and (LIFE_CNT_3_Y_T <= pix_y) and (pix_y <= LIFE_CNT_3_Y_B) else '0';

    --- Write your VHDL code: complete “with select�? statement below:
    --- Here we use a signal ‘cnter_rom_current’ to store the actual
    --- ROM image to be displayed which depends on the current cnter value.
    -- Assign the corresponding ROM image constant to ‘cnter_rom_current’
    --- depending on the value of ‘hit_cnter’
    with to_integer(hit_cnter) select
        cnter_rom_current <= CNTER_ROM_0 when 0, 
                            CNTER_ROM_1 when 1,
                            CNTER_ROM_2 when 2,
                            CNTER_ROM_3 when 3,
                            CNTER_ROM_4 when 4,
                            CNTER_ROM_5 when 5,
                            CNTER_ROM_6 when 6, 
                            CNTER_ROM_7 when others;
    --- Complete the above “with-select�? statement

    -- type conversion to unsigned values
    hit_cnt_y_t_u <= to_unsigned(HIT_CNT_Y_T, 10);
    hit_cnt_x_l_u <= to_unsigned(HIT_CNT_X_L, 10);
    -- Obtain row and col indexes
    rom_addr_cnter <= pix_y(3 downto 0) - hit_cnt_y_t_u(3 downto 0);
    rom_col_cnter <= pix_x(3 downto 0) - hit_cnt_x_l_u(3 downto 0);
    -- map scan coord to rom_bit using addr/col for current cnter value;
    rom_data_cnter <= cnter_rom_current(to_integer(rom_addr_cnter));
    rom_bit_cnter <= rom_data_cnter(to_integer(rom_col_cnter));
    
    -- =======================================================================

    life_cnt_1_y_t_u <= to_unsigned(life_CNT_1_Y_T, 10);
    life_cnt_1_x_l_u <= to_unsigned(life_CNT_1_X_L, 10);
    rom_addr_life_cnter_1 <= pix_y(3 downto 0) - life_cnt_1_y_t_u(3 downto 0);
    rom_col_life_cnter_1 <= pix_x(3 downto 0) - life_cnt_1_x_l_u(3 downto 0);
    rom_data_life_cnter_1 <= LIFE_ROM_1(to_integer(rom_addr_life_cnter_1));
    rom_bit_life_cnter_1 <= rom_data_life_cnter_1(to_integer(rom_col_life_cnter_1));

    life_cnt_2_y_t_u <= to_unsigned(life_CNT_2_Y_T, 10);
    life_cnt_2_x_l_u <= to_unsigned(life_CNT_2_X_L, 10);
    rom_addr_life_cnter_2 <= pix_y(3 downto 0) - life_cnt_2_y_t_u(3 downto 0);
    rom_col_life_cnter_2 <= pix_x(3 downto 0) - life_cnt_2_x_l_u(3 downto 0);
    rom_data_life_cnter_2 <= LIFE_ROM_2(to_integer(rom_addr_life_cnter_2));
    rom_bit_life_cnter_2 <= rom_data_life_cnter_2(to_integer(rom_col_life_cnter_2));

    life_cnt_3_y_t_u <= to_unsigned(life_CNT_3_Y_T, 10);
    life_cnt_3_x_l_u <= to_unsigned(life_CNT_3_X_L, 10);
    rom_addr_life_cnter_3 <= pix_y(3 downto 0) - life_cnt_3_y_t_u(3 downto 0);
    rom_col_life_cnter_3 <= pix_x(3 downto 0) - life_cnt_3_x_l_u(3 downto 0);
    rom_data_life_cnter_3 <= LIFE_ROM_3(to_integer(rom_addr_life_cnter_3));
    rom_bit_life_cnter_3 <= rom_data_life_cnter_3(to_integer(rom_col_life_cnter_3));

    --- Write your VHDL code below:
    -- assert ‘hit_cnter_cur_val_on’ by checking
    --- ‘sq_hit_cnter_on’ and ‘rom_bit_cnter’

    hit_cnter_cur_val_on <= '1' when (sq_hit_cnter_on = '1') and (rom_bit_cnter = '1') else '0';

    life_cnter_1_cur_val_on <= '1' when (sq_life_cnter_1_on = '1') and (rom_bit_life_cnter_1 = '1') and (life_cnter >= "11") else '0';
    life_cnter_2_cur_val_on <= '1' when (sq_life_cnter_2_on = '1') and (rom_bit_life_cnter_2 = '1') and (life_cnter >= "10") else '0';
    life_cnter_3_cur_val_on <= '1' when (sq_life_cnter_3_on = '1') and (rom_bit_life_cnter_3 = '1') and (life_cnter >= "01") else '0';

    -- set the cnter value color
    hit_cnter_rgb <= "010";
    life_cnter_rgb <= "100";

    --- Write your VHDL code below:
    -- set graph_rgb

    graph_rgb <= hit_cnter_rgb when hit_cnter_cur_val_on = '1' else 
            life_cnter_rgb when life_cnter_1_cur_val_on = '1' else
            life_cnter_rgb when life_cnter_2_cur_val_on = '1' else
            life_cnter_rgb when life_cnter_3_cur_val_on = '1' else
            "000";

    -- assign output sq_hit_cnter_on_output
    sq_hit_cnter_on_output <= sq_hit_cnter_on;
    sq_life_cnter_on_output <= sq_life_cnter_1_on or sq_life_cnter_2_on or sq_life_cnter_3_on;
    end Behavioral;
    