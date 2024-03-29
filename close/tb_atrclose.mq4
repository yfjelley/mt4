// 出场条件: 
//			 1. 基于ATR的保护性止损
//			 2. 基于ATR的盈亏平衡止损
//			 3. 基于ATR的盈利止盈
//
//----------------------------------------------------------------------//


void TB_atr_close(){
   double stop_line, profit_line;
   bool close = False; 

   for(int i=0;i<OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      int type = OrderType();     
      if(type==OP_BUY){
  
         stop_line = Low[1] - 0.5*atr();
         profit_line = High[1] + 3*atr();
         //1. 基于ATR的保护性止损
         if(Ask<stop_line){         
            comment = "Ask小于Low[1]-0.5*atr";
            close = True;
         }  
         else if(Bid>profit_line){
            comment = "Bid大于High[1]+3*atr";
            close = True;     
         
         }   
      }

      else if(type==OP_SELL){
         
         stop_line = High[1] + 0.5*atr();
         profit_line = Low[1] - 3*atr();
      
         if(Bid>stop_line){
            comment = "Bid大于High[1]+0.5*atr"; 
            close = True;
         }    
         else if(Ask<profit_line){
            comment = "Ask小于Low[1]-3*atr";
            close = True;     
         
         }       
      }
      if(close) forceClose(type, comment);
   }
}


