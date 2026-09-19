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
reg [0:n-1] CAX_Q = '0;
reg [0:n-1] CAX_QM = '0;
reg [0:n-1] CAY_Q = '0;
reg [0:n-1] CAY_QM = '0;

//logic of CA registors with OFC

always @(posedge clk or posedge reset) begin
    if (reset) begin
        Lx <= 2'b00;
    Ly <= 2'b00;
    CAX_Q <= '0;
    CAX_QM <= '0;
    CAY_Q <= '0;
    CAY_QM <= '0;
        
    end else begin

        Lx <= x ;
        Ly <= y;

          if(Lx > 2'b00)begin

            CAX_Q <= {CAX_Q[0:n-2] , 1} ;
            CAX_QM <= {CAX_Q[0:n-2] , 0};

          end else if(Lx == 2'b00) begin

            CAX_Q <= {CAX_Q[0:n-2] , 0};
            CAX_QM <= {CAX_QM [0:n-2] , 1};

          end else begin

            CAX_Q <= {CAX_QM[0:n-2] , 1};
            CAX_QM <= {CAX_QM[0:n-2] , 0};

          end


      
        if(Ly > 2'b00)begin

            CAY_Q <= {CAY_Q[0:n-2] , 1} ;
            CAY_QM <= {CAY_Q[0:n-2] , 0};

          end else if(Ly == 2'b00) begin

            CAY_Q <= {CAY_Q[0:n-2] , 0};
            CAY_QM <= {CAY_QM [0:n-2] , 1};

          end else begin

            CAY_Q <= {CAY_QM[0:n-2] , 1};
            CAY_QM <= {CAY_QM[0:n-2] , 0};

          end

    end

  
end


wire [0:n-1] In_add_x = '0 ;
wire [0:n-1] In_add_y = '0 ;

reg cx = 1'b0;
reg cy = 1'b0;



 always @(*) begin
    if(reset)begin
          In_add_x = '0 ;
 In_add_y = '0 ;
   = '0;

 cx = 1'b0;
 cy = 1'b0;

    end else begin
        if (Lx == 2'b01) begin
     In_add_x = CAX_Q;
     cx = 1'b0;

end
else if (Lx == 2'b11) begin
       In_add_x = ~CAX_Q;
    cx = 1'b1;             
end else begin
          In_add_x = '0;
        cx = 1'b0;
    end



if (Ly == 2'b01) begin
        In_add_y = CAY_Q;
         cy = 1'b0;
    end
    else if (Ly == 2'b11) begin
        In_add_y = ~CAY_Q;
        cy = 1'b1;
    end else begin
         In_add_y = '0;
        cy = 1'b0;
    end

    end
  
 end



 reg [0:n+1] V_sum = '0;
 reg [0:n+1] V_carry = '0;

 reg [0:n+1] Reg_WS = '0;
reg [0:n+1] Reg_WC = '0;

    reg carry_in = 1'b0;
    reg carry_out = 3'b0;
    reg  V_sum_at_i = 3'b0;
integer i;



always @(*) begin

    if(reset)begin
         V_sum = '0;
  V_carry = '0;

     carry_in = 1'b0;
     carry_out = 3'b0;
      V_sum_at_i = 3'b0;
      
    end

    else begin

        carry_in = 1'b0; 


for(i=n-1;i>=0;i--)begin
    
    V_sum_at_i  = In_add_y[i] +  In_add_x[i] +
    + Reg_WS[i+2]  + Reg_WC[i+2] +  carry_in  ;
    
   
    
    carry_out = V_sum_at_i >> 1;
    V_sum[i+2] = V_sum_at_i % 2;

    if(i==n-1)begin
        carry_out = carry_out + cx + cy ;
    end

    V_carry[i+2] = carry_out; 
    carry_in = carry_out ;
    
end

 V_sum_at_i = Reg_WS[1] + Reg_WC[1] + carry_in;
    carry_out  = V_sum_at_i >> 1;
    V_sum[1]   = V_sum_at_i % 2;
    V_carry[1] = carry_out;
    carry_in   = carry_out;

    V_sum_at_i  = Reg_WS[0] + Reg_WC[0] + carry_in;
    V_sum[0]  = V_sum_at_i % 2;
    V_carry[0]= V_sum_at_i >> 1;

    end
     
    
end



wire signed  [3:0] V_4bit = $signed(V_sum [0:3]) + $signed(V_carry[0:3]);
reg [0:n+1] Pout_Q = '0;
reg [0:n+1] Pout_QM = '0;


always @(posedge clk) begin
    if(V_4bit >= 4'sb0100 )begin

          Pout_Q <= {Pout_Q[0:n] , 1} ;
            Pout_QM <= {Pout_Q[0:n] , 0};
       
    end else if(V_4bit < 4'sb1100)begin

           Pout_QM <= {Pout_QM[0:n] , 1} ;
            Pout_QM <= {Pout_Q[0:n] , 0};
        
    end else begin

         Pout_Q <= {Pout_Q[0:n] , 0} ;
            Pout_QM <= {Pout_QM[0:n] , 1};

    end

   
end


reg [0:n+1] M_sum = '0;
reg [0:n+1] M_carry = '0;

always @(*) begin
    
        
        case(p)
            2'b00: begin  
                M_sum = V_sum;
                M_carry = V_carry;
            end
            2'b01: begin 
                M_sum = V_sum -1'b1;      
                M_carry = V_carry ;  
            end
            2'b11: begin  
                M_sum = V_sum + 1'b1;
                M_carry = V_carry ;
            end
            default: begin
                M_sum = V_sum;
                M_carry = V_carry;
            end
        endcase
    
end








always @(posedge clk or posedge reset) begin
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

