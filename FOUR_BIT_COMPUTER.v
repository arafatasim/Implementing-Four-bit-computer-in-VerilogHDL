module FOUR_BIT_COMPUTER(Clk,init_A, init_B, address_location, byte_in, carry_in, port_in, 
					port_out, A,B,C,carry_out,ADDRESS_H, ADDRESS_L, stack_H, stack_L,ZF);
	
	input Clk, carry_in;
	input [3:0] init_A, init_B, address_location, byte_in;
	input [3:0] port_in;
	output reg [3:0] port_out;
	output reg  [3:0] A, B;
	output reg [3:0] C;
	output reg carry_out;
	output reg [3:0]  ADDRESS_H, ADDRESS_L, stack_H, stack_L;
	output reg ZF;	
	
	integer k=-1, call=0, ret=0;
	
	always @(posedge Clk)
	begin
		ZF=0;
		if (k==-1)		// Initially set adress to 35D ('ADD' for this code)
		begin
			{ADDRESS_H, ADDRESS_L} = 25;
			k=k+1;
		end
		if (call==0)	// WILL NOT execute if call instr. is executed
		begin
			k=k+1;
			A = init_A;
			B = init_B;
		end		
		
		if (call!=0 && k>0)		// WILL execute if call instr. is executed
		begin
			{ADDRESS_H, ADDRESS_L} = k;
		end	
				

		if ({ADDRESS_H, ADDRESS_L} == 25)				//ADD
		begin	
			{carry_out,C}=A+B;
			ZF = (C==0)? 1:0;
			A=C;
			C=0;
			{ADDRESS_H, ADDRESS_L} = 30;
			ret = (call)? 1:0;
		end
		
		else if ({ADDRESS_H, ADDRESS_L} == 30)			//SUB
		begin
			{carry_out,C}=A-B;
			ZF = (C==0)? 1:0;
			A=C;
			C=0;
			{ADDRESS_H, ADDRESS_L} = 36;
			ret = (call)? 1:0;
		end
		
		else if	({ADDRESS_H, ADDRESS_L} == 36)			//XCHG
		begin
			C = A;
			A = B;
			B = C;
			ZF = (C==0)? 1:0;
			C = 0;
			{ADDRESS_H, ADDRESS_L} = 43;
			ret = (call)? 1:0;
		end
			
		else if	({ADDRESS_H, ADDRESS_L} == 43)			//MOV --> additional byte
		begin
			A = address_location;
			{ADDRESS_H, ADDRESS_L} = 44;
			ret = (call)? 1:0;
		end
		
		else if	({ADDRESS_H, ADDRESS_L} == 44)			//RCR --> carry_in
		begin
			C = 0;
			carry_out = carry_in;
			B = (B>>1)+carry_out*8;	
			{ADDRESS_H, ADDRESS_L} = 47;	
			ret = (call)? 1:0;	
		end
						
		else if	({ADDRESS_H, ADDRESS_L} == 47)			//IN
		begin
			carry_out= 0;
			A = port_in;	
			{ADDRESS_H, ADDRESS_L} = 49;	
			ret = (call)? 1:0;	
		end
								
		else if	({ADDRESS_H, ADDRESS_L} == 49)			//OUT
		begin
			port_out = A;
			{ADDRESS_H, ADDRESS_L} = 50;	
			ret = (call)? 1:0;	
		end
			
		else if	({ADDRESS_H, ADDRESS_L} == 50)			//AND
		begin
			C= A&B;	
			ZF = (C==0)? 1:0;
			A = C;
			C = 0 ;
			{ADDRESS_H, ADDRESS_L} = 54;	
			ret = (call)? 1:0;	
		end
			
		else if	({ADDRESS_H, ADDRESS_L} == 54)			//TEST
		begin
			C= B&byte_in;
			ZF = (C==0)? 1:0;
			C=0;
			{ADDRESS_H, ADDRESS_L} = 59;
			ret = (call)? 1:0;			
		end
			
		else if	({ADDRESS_H, ADDRESS_L} == 59)			//OR
		begin
			C= B|byte_in;	
			ZF = (C==0)? 1:0;
			B=C;
			C=0;
			{ADDRESS_H, ADDRESS_L} = 66;
			ret = (call)? 1:0;
		end
			
		else if	({ADDRESS_H, ADDRESS_L} == 66)			//XOR
		begin
			C= A^address_location;
			A= C;		
			ZF = (C==0)? 1:0;
			C=0;
			{ADDRESS_H, ADDRESS_L} = 70;
			ret = (call)? 1:0;
		end
			
		else if	({ADDRESS_H, ADDRESS_L} == 70)			//PUSH
		begin
			{stack_H, stack_L}= B;		
			{ADDRESS_H, ADDRESS_L} = 71;	
			ret = (call)? 1:0;
		end
		
		else if	({ADDRESS_H, ADDRESS_L} == 71)			//POP
		begin
			B = 15;
			B = stack_L;
			{stack_H, stack_L} = 0;	
			{ADDRESS_H, ADDRESS_L} = 745;	
			ret = (call)? 1:0;	
		end
			
		else if	({ADDRESS_H, ADDRESS_L} == 745)			//CALL
		begin
			call=36;	
			{ADDRESS_H, ADDRESS_L} = 855;	
			{stack_H, stack_L} ={ADDRESS_H, ADDRESS_L}+1;		
		end
			
		else if	({ADDRESS_H, ADDRESS_L} == 855)			//RET
		begin
			call=0;
			{ADDRESS_H, ADDRESS_L}= {stack_H, stack_L};
			{stack_H, stack_L} = 0;
		end
			
		else if	({ADDRESS_H, ADDRESS_L} == 777)			//HLT
		begin
			k=15;
			{ADDRESS_H, ADDRESS_L} = 777;	
		end	

			
		if (call!=0) 			//For CALL+RET Operation
		begin
			k=(ret)? 855:call;	
				
		end
		
	end 		
endmodule 



