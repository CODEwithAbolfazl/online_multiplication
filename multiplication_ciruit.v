module  online_multiplier #(
    parameter n = 8 
)(
    input wire clk,
    input wire reset ,
    input wire [1:0] x,
    input wire [1:0] y , 
    output reg [1:0] p 
);

reg [1:0] Lx = 2'b00;
reg [1:0] Ly = 2'b00;
reg [0:n-1] CAX_sum = '0;
reg [0:n-1] CAX_carry = '0;
reg [0:n-1] CAY_sum = '0;
reg [0:n-1] CAY_carry = '0;

always @(posedge clk or negedge reset) begin
    if (reset) begin
        Lx <= 2'b00;
    Ly <= 2'b00;
    CAX_sum <= '0;
    CAX_carry <= '0;
    CAY_sum <= '0;
    CAY_carry <= '0;
        
    end else begin
          Lx <= x;
    Ly <= y ;
    CAX_sum <= {CAX_sum [0:n-2], Lx[1]}; 
    CAX_carry <= {CAX_carry [0:n-2], Lx[0]}; 
    CAY_sum   <= {CAY_sum [0:n-2], Ly[1]};    
    CAY_carry <= {CAY_carry [0:n-2], Ly[0]};
    end

  
end


reg [0:n-1] In_add_x_sum = '0 ;
reg  [0:n-1] In_add_x_carry = '0;
reg [0:n-1] In_add_y_sum = '0 ;
reg  [0:n-1] In_add_y_carry = '0;

reg cx = 1'b0;
reg cy = 1'b0;



 always @(*) begin
    if(reset)begin
         In_add_x_sum = '0 ;
 In_add_x_carry = '0;
 In_add_y_sum = '0 ;
 In_add_y_carry = '0;

 cx = 1'b0;
 cy = 1'b0;

    end else begin
        if (Lx == 2'b01) begin
    In_add_x_sum = CAX_sum;
    In_add_x_carry =CAX_carry;
     cx = 1'b0;

end
else if (Lx == 2'b11) begin
      In_add_x_sum = ~CAX_sum;
    In_add_x_carry = ~CAX_carry;  
    cx = 1'b1;             
end else begin
         In_add_x_sum = '0;
        In_add_x_carry = '0;
        cx = 1'b0;
    end



if (Ly == 2'b01) begin
        In_add_y_sum = CAY_sum;
        In_add_y_carry = CAY_carry;
         cy = 1'b0;
    end
    else if (Ly == 2'b11) begin
        In_add_y_sum = ~CAY_sum;
        In_add_y_carry = ~CAY_carry;
        cy = 1'b1;
    end else begin
         In_add_y_sum = '0;
        In_add_y_carry = '0;
        cy = 1'b0;
    end

    end
  
 end



 reg [0:n+1] V_sum = '0;
 reg [0:n+1] V_carry = '0;

    reg carry_in = 1'b0;
    reg carry_out = 3'b0;
    reg  V_sum_at_i = 3'b0;
integer i;



always @(posedge clk) begin

    if(reset)begin
         V_sum <= '0;
  V_carry <= '0;

     carry_in <= 1'b0;
     carry_out <= 3'b0;
      V_sum_at_i <= 3'b0;
      
    end

    else begin
        carry_in <= 1'b0; 


for(i=n-1;i>=0;i--)begin
    
    V_sum_at_i  <= In_add_y_sum[i] + In_add_x_sum[i] +
    In_add_y_carry[i] + In_add_x_carry[i] +
    + Reg_WS[i+2]     + Reg_WC[i+2] +  carry_in  ;
    
    
    carry_out <= V_sum_at_i >> 1;
    V_sum[i] <= V_sum_at_i % 2;

    if(i==n-1)begin
        carry_out <= carry_out + cx + cy ;
    end

    V_carry[i] <= carry_out; 
    carry_in <= carry_out ;
    
end

 V_sum_at_i <= Reg_WS[1] + Reg_WC[1] + carry_in;
    carry_out  <= V_sum_at_i >> 1;
    V_sum[n]   <= V_sum_at_i % 2;
    V_carry[n] <= carry_out;
    carry_in   <= carry_out;

    V_sum_at_i  <= Reg_WS[0] + Reg_WC[0] + carry_in;
    V_sum[n+1]  <= V_sum_at_i % 2;
    V_carry[n+1]<= V_sum_at_i >> 1;

    end
     
    
end



wire signed  [3:0] V_4bit = V_sum [0:3];
reg [0:1] Pout = '0;



always @(posedge clk) begin
    if(V_4bit >= 4'b0100 )begin
        Pout <= 2'b01;
    end else if(V_4bit < 4'b1100)begin
        Pout <= 2'b11;
    end else begin
        Pout <= 2'b00;
    end
    p <= Pout;
end


reg [0:n+1] M_sum = '0;
reg [0:n+1] M_carry = '0;

always @(posedge clk) begin
    
        
        case(p)
            2'b00: begin  
                M_sum <= V_sum;
                M_carry <= V_carry;
            end
            2'b01: begin 
                M_sum <= V_sum -1;      
                M_carry <= V_carry ;  
            end
            2'b11: begin  
                M_sum <= V_sum + 1;
                M_carry <= V_carry ;
            end
            default: begin
                M_sum <= V_sum;
                M_carry <= V_carry;
            end
        endcase
    
end






reg [0:n+1] Reg_WS = '0;
reg [0:n+1] Reg_WC = '0;

always @(posedge clk or negedge reset) begin
    if (reset) begin
        Reg_WS <= '0;
        Reg_WC <= '0;
    end
    else begin
        Reg_WS <= {M_sum[1:n+1], 1'b0};   
        Reg_WC <= {M_carry[1:n+1], 1'b0}; 
    end
end







endmodule 

