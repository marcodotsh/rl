-- Progetto di Reti Logiche Anno Accademico 2023/2024
-- Marco Zanzottera
-- Codice Persona: 10765812
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    port (
        i_clk   : in std_logic;
        i_rst   : in std_logic;
        i_start : in std_logic;
        i_add   : in std_logic_vector(15 downto 0);
        i_k     : in std_logic_vector(9 downto 0);
        
        o_done  : out std_logic;
        
        o_mem_addr  : out std_logic_vector(15 downto 0);
        i_mem_data  : in std_logic_vector(7 downto 0);
        o_mem_data  : out std_logic_vector(7 downto 0);
        o_mem_we    : out std_logic;
        o_mem_en    : out std_logic
   );     
end project_reti_logiche;

architecture structural of project_reti_logiche is
    component module_1_state_manager is
        port(
            i_clk       : in std_logic;
            i_rst       : in std_logic;
            i_start     : in std_logic;
    --Signal high when the current address is at the end of the sequence (i_add+i_k*2)
            i_finish    : in std_logic;
            
            i_memory_value_is_zero : in std_logic;
            
            i_current_value_is_zero : in std_logic;
            
            o_done      : out std_logic;
            o_mem_we    : out std_logic;
            o_mem_en    : out std_logic;
    --Signal to switch between writing a value or a credibility
            o_write_cred    : out std_logic;
    --Signal high when the next state requires the next address
            o_next_addr : out std_logic;
    --Signal high when modules storing value and credibility need to be activated
            o_eval_read : out std_logic
            
        );
    end component;

    component module_2_current_address is
        port (
            i_clk   : in std_logic;
            i_rst   : in std_logic;
            i_start : in std_logic;
            i_add   : in std_logic_vector(15 downto 0);
    --Signal high when the address needs to be incremented. Is obtained by module_1_state_manager
            i_next_addr : in std_logic;
    
            o_curr_addr : out std_logic_vector(15 downto 0)
        );
    end component;
    
    component module_3_current_value is
        port (
            i_clk       : in std_logic;
            i_rst       : in std_logic;
            i_start     : in std_logic;
            
            i_value     : in std_logic_vector(7 downto 0);
            i_memory_value_is_zero : in std_logic;
            
            i_eval   : in std_logic;
            
            o_value     : out std_logic_vector(7 downto 0)
        );
    end component;

    component module_4_current_credibility is
        port (
            i_clk       : in std_logic;
            i_rst       : in std_logic;
            i_start     : in std_logic;
            
            i_memory_value_is_zero   : in std_logic;
            
            i_eval            : in std_logic;
            
            o_credibility     : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component module_5_zero_evaluator is
        generic (
            N : integer := 8
        );
        port (
            i_value   : in std_logic_vector(N-1 downto 0);
            
            o_value_is_zero     : out std_logic
        );
    end component;

    component module_6_multiplexer is
        generic (
            N : integer := 8
        );
        port (
            i_0   : in std_logic_vector(N-1 downto 0);
            i_1   : in std_logic_vector(N-1 downto 0);
            i_ctrl  : in std_logic;
            
            o     : out std_logic_vector(N-1 downto 0)
        );
    end component;
    
    component module_7_end_address_computer is
        port (
            i_add   : in std_logic_vector(15 downto 0);
            i_k     : in std_logic_vector(9 downto 0);
            
            o_end_addr     : out std_logic_vector(15 downto 0)
        );
    end component;
    
    component module_8_end_evaluator is
        generic (
            N : integer := 16
        );
        port (
            i_0 : in std_logic_vector(N-1 downto 0);
            i_1 : in std_logic_vector(N-1 downto 0);
            
            o_greater_or_equal : out std_logic
        );
    end component;
    
    signal finish : std_logic;
    signal memory_value_is_zero : std_logic;
    signal write_cred : std_logic;
    signal next_addr : std_logic;
    signal eval_read : std_logic;
    signal curr_addr : std_logic_vector(15 downto 0);
    signal write_value : std_logic_vector(7 downto 0);
    signal write_credibility : std_logic_vector(7 downto 0);
    signal end_addr : std_logic_vector(15 downto 0);
    signal current_value_is_zero : std_logic;    
begin
    module_1 : module_1_state_manager
        port map(
            i_clk => i_clk,
            i_rst => i_rst,
            i_start => i_start,
            i_finish => finish,
            i_memory_value_is_zero => memory_value_is_zero,
            i_current_value_is_zero => current_value_is_zero,
            o_done => o_done,
            o_mem_we => o_mem_we,
            o_mem_en => o_mem_en,
            o_write_cred => write_cred,
            o_next_addr => next_addr,
            o_eval_read => eval_read
        );
        
    module_2 : module_2_current_address
        port map(
            i_clk => i_clk,
            i_rst => i_rst,
            i_start => i_start,
            i_add => i_add,
            i_next_addr => next_addr,
            o_curr_addr => curr_addr
        );
        
    module_3 : module_3_current_value
        port map(
            i_clk => i_clk,
            i_rst => i_rst,
            i_start => i_start,
            i_value => i_mem_data,
            i_memory_value_is_zero => memory_value_is_zero,
            i_eval => eval_read,
            o_value => write_value
        );
        
    module_4 : module_4_current_credibility
        port map(
            i_clk => i_clk,
            i_rst => i_rst,
            i_start => i_start,
            i_memory_value_is_zero => memory_value_is_zero,
            i_eval => eval_read,
            o_credibility => write_credibility
        );
        
    module_5A : module_5_zero_evaluator
        generic map(N => 8)
        port map(
            i_value =>i_mem_data,
            o_value_is_zero => memory_value_is_zero
        );
        
    module_5B : module_5_zero_evaluator
        generic map(N => 8)
        port map(
            i_value =>write_value,
            o_value_is_zero => current_value_is_zero
        );
        
    module_6 : module_6_multiplexer
        generic map(N => 8)
        port map(
            i_0 => write_value,
            i_1 => write_credibility,
            i_ctrl => write_cred,
            o => o_mem_data
        );
        
    module_7 : module_7_end_address_computer
        port map(
            i_add => i_add,
            i_k => i_k,
            o_end_addr => end_addr
        );
        
    module_8 : module_8_end_evaluator
        generic map(N => 16)
        port map(
            i_0 => curr_addr,
            i_1 => end_addr,
            o_greater_or_equal => finish
        );

    o_mem_addr <=  curr_addr;
end structural;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity module_1_state_manager is
    port(
        i_clk       : in std_logic;
        i_rst       : in std_logic;
        i_start     : in std_logic;
--Signal high when the current address is at the end of the sequence (i_add+i_k*2)
        i_finish    : in std_logic;
        
        i_memory_value_is_zero : in std_logic;
        
        i_current_value_is_zero : in std_logic;
        
        o_done      : out std_logic;
        o_mem_we    : out std_logic;
        o_mem_en    : out std_logic;
--Signal to switch between writing a value or a credibility
        o_write_cred    : out std_logic;
--Signal high when the next state requires the next address
        o_next_addr : out std_logic;
--Signal high when modules storing value and credibility need to be activated
        o_eval_read : out std_logic
        
    );
end module_1_state_manager;

architecture behavioral of module_1_state_manager is
    type state_type is (IDLE_STATE, READ_STATE, EVALREAD_STATE, WRITEVALUE_STATE, WRITECREDIBILITY_STATE, DONE_STATE);
    signal current_state, next_state: state_type;
begin
    state_reg : process(i_clk, i_rst)
    begin
        if i_rst='1' then current_state <= IDLE_STATE;
        elsif rising_edge(i_clk) then
            current_state <= next_state;
        end if;
    end process;
    
    lambda : process(current_state, i_start, i_finish, i_memory_value_is_zero, i_current_value_is_zero)
    begin
        case current_state is
            when IDLE_STATE =>
                if i_start='1' then
                    next_state <= READ_STATE;
                else
                    next_state <= IDLE_STATE;
                end if;
            when READ_STATE =>
                if i_finish='1' then
                    next_state <= DONE_STATE;
                else
                    next_state <= EVALREAD_STATE;
                end if;
            when EVALREAD_STATE =>
                if i_memory_value_is_zero='1' and i_current_value_is_zero='0' then
                    next_state <= WRITEVALUE_STATE;
                else
                    next_state <= WRITECREDIBILITY_STATE;
                end if;
            when WRITEVALUE_STATE =>
                next_state <= WRITECREDIBILITY_STATE;
            when WRITECREDIBILITY_STATE =>       
                next_state <= READ_STATE;
            when DONE_STATE =>
                if i_start='0' then
                    next_state <= IDLE_STATE;
                else
                    next_state <= DONE_STATE;
                end if;
        end case; 
    end process;
    
    delta : process(current_state, i_memory_value_is_zero, i_current_value_is_zero)
    begin
        case current_state is
            when IDLE_STATE =>
                o_done <= '0';
                o_mem_we <= '-';
                o_mem_en <= '0';
                o_write_cred <= '-';
                o_next_addr <= '0';
                o_eval_read <= '0';
            when READ_STATE =>
                o_done <= '0';
                o_mem_we <= '0';
                o_mem_en <= '1';
                o_write_cred <= '-';
                o_next_addr <= '0';
                o_eval_read <= '0';
            when EVALREAD_STATE =>
                o_done <= '0';
                o_mem_we <= '-';
                o_mem_en <= '0';
                o_write_cred <= '-';
                if i_memory_value_is_zero='1' and i_current_value_is_zero='0' then
                    o_next_addr <= '0';
                else
                    o_next_addr <= '1';
                end if;
                o_eval_read <= '1';
            when WRITEVALUE_STATE =>
                o_done <= '0';
                o_mem_we <= '1';
                o_mem_en <= '1';
                o_write_cred <= '0';
                o_next_addr <= '1';
                o_eval_read <= '0';
            when WRITECREDIBILITY_STATE =>
                o_done <= '0';
                o_mem_we <= '1';
                o_mem_en <= '1';
                o_write_cred <= '1';
                o_next_addr <= '1';
                o_eval_read <= '0';
            when DONE_STATE =>
                o_done <= '1';
                o_mem_we <= '-';
                o_mem_en <= '0';
                o_write_cred <= '-';
                o_next_addr <= '0';
                o_eval_read <= '0';
            
        end case;
    end process;
end behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity module_2_current_address is
    port (
        i_clk   : in std_logic;
        i_rst   : in std_logic;
        i_start : in std_logic;
        i_add   : in std_logic_vector(15 downto 0);
--Signal high when the address needs to be incremented. Is obtained by module_1_state_manager
        i_next_addr : in std_logic;

        o_curr_addr : out std_logic_vector(15 downto 0)
    );
end module_2_current_address;

architecture behavioral of module_2_current_address is
    type state_type is (IDLE_STATE, STORE_STATE);
    signal current_state, next_state : state_type;
    signal curr_addr, next_addr : std_logic_vector(15 downto 0);
begin
    o_curr_addr <= curr_addr;
--Everything in a process because the update of the address is done on clock rising edge
    state_reg : process(i_clk, i_rst)
    begin
        if i_rst='1' then
            current_state <= IDLE_STATE;
            curr_addr <= (OTHERS => '0');
        elsif rising_edge(i_clk) then
            current_state <= next_state;
            curr_addr <= next_addr;
        end if;
    end process;
    
    lambda : process(current_state, curr_addr, i_next_addr, i_start, i_add)
    begin
        case current_state is
        when IDLE_STATE =>
            if i_start='1' then
                next_state <= STORE_STATE;
                next_addr <= i_add;
            else
                next_state <= IDLE_STATE;
                next_addr <= (OTHERS => '0');
            end if;
        when STORE_STATE =>
            if i_start='0' then
                next_state <= IDLE_STATE;
                next_addr <= (OTHERS => '0');
            else
                next_state <= STORE_STATE;
                if i_next_addr='1' then
                    next_addr <= std_logic_vector(unsigned(curr_addr)+1);
                else
                    next_addr <= curr_addr;
                end if;
            end if;
        end case; 
    end process;
end behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity module_3_current_value is
    port (
        i_clk       : in std_logic;
        i_rst       : in std_logic;
        i_start     : in std_logic;
        
        i_value     : in std_logic_vector(7 downto 0);
        i_memory_value_is_zero : in std_logic;
        
        i_eval   : in std_logic;
        
        o_value     : out std_logic_vector(7 downto 0)
    );
end module_3_current_value;

architecture behavioral of module_3_current_value is
    signal current_value, next_value    : std_logic_vector(7 downto 0);
begin
    o_value <= current_value;

    state_reg : process(i_clk, i_rst)
    begin
        if i_rst='1' then
            current_value <= (OTHERS => '0');
        elsif rising_edge(i_clk) then
            current_value <= next_value;
        end if;
    end process;
    
    lambda : process(current_value, i_start, i_value, i_memory_value_is_zero, i_eval)
    begin
        if i_start='1' then
            if i_memory_value_is_zero='0' and i_eval='1' then
                next_value <= i_value;
            else
                next_value <= current_value;
            end if;
        else
            next_value <= (OTHERS => '0');
        end if;
    end process;
end behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity module_4_current_credibility is
    port (
        i_clk       : in std_logic;
        i_rst       : in std_logic;
        i_start     : in std_logic;
        
        i_memory_value_is_zero   : in std_logic;
        
        i_eval            : in std_logic;
        
        o_credibility     : out std_logic_vector(7 downto 0)
    );
end module_4_current_credibility;

architecture behavioral of module_4_current_credibility is
    signal current_credibility, next_credibility    : std_logic_vector(7 downto 0);
begin
    o_credibility <= current_credibility;

    state_reg : process(i_clk, i_rst)
    begin
        if i_rst='1' then
            current_credibility <= (OTHERS => '0');
        elsif rising_edge(i_clk) then
            current_credibility <= next_credibility;
        end if;
    end process;
    
    lambda : process(current_credibility, i_start, i_memory_value_is_zero, i_eval)
    begin
        if i_start='1' then
            if i_eval='1' then
                if i_memory_value_is_zero='1' then
                    if unsigned(current_credibility)>0 then
                        next_credibility <= std_logic_vector(unsigned(current_credibility)-1);
                    else
                        --remains zero
                        next_credibility <= current_credibility;
                    end if;
                else
                    --set to 31
                    next_credibility <= (7 downto 5 => '0', 4 downto 0 => '1');
                end if;
            else
                next_credibility <= current_credibility;
            end if;
        else
            next_credibility <= (OTHERS => '0');
        end if;
    end process;
end behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_MISC.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity module_5_zero_evaluator is
    generic (
        N : integer := 8
    );
    port (
        i_value   : in std_logic_vector(N-1 downto 0);
        
        o_value_is_zero     : out std_logic
    );
end module_5_zero_evaluator;

architecture dataflow of module_5_zero_evaluator is
begin
    o_value_is_zero <= not or_reduce(i_value);
end dataflow;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity module_6_multiplexer is
    generic (
        N : integer := 8
    );
    port (
        i_0   : in std_logic_vector(N-1 downto 0);
        i_1   : in std_logic_vector(N-1 downto 0);
        i_ctrl  : in std_logic;
        
        o     : out std_logic_vector(N-1 downto 0)
    );
end module_6_multiplexer;

architecture dataflow of module_6_multiplexer is
begin
    with i_ctrl select
        o <= i_0 when '0',
             i_1 when others;
end dataflow;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity module_7_end_address_computer is
    port (
        i_add   : in std_logic_vector(15 downto 0);
        i_k     : in std_logic_vector(9 downto 0);
        
        o_end_addr     : out std_logic_vector(15 downto 0)
    );
end module_7_end_address_computer;

architecture dataflow of module_7_end_address_computer is
begin
    o_end_addr <= std_logic_vector(unsigned(i_add)+unsigned("00000" & i_k & "0"));
end dataflow;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity module_8_end_evaluator is
    generic (
        N : integer := 16
    );
    port (
        i_0 : in std_logic_vector(N-1 downto 0);
        i_1 : in std_logic_vector(N-1 downto 0);
        
        o_greater_or_equal : out std_logic
    );
end module_8_end_evaluator;

architecture dataflow of module_8_end_evaluator is
    signal tmp : std_logic_vector(N-1 downto 0);
begin
    tmp <= std_logic_vector(unsigned(i_0) - unsigned(i_1));
    o_greater_or_equal <= not tmp(N-1);
end dataflow;
