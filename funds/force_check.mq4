void ForceCheck(){

   double val=iForce(NULL,0,13,MODE_SMA,PRICE_CLOSE,0);
   bool close = False; 
   
   for(int i=0;i<OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      if(TimeCurrent()-OrderOpenTime()>30) continue;   
      int type = OrderType();     
      if(type==OP_BUY){  
         if(val<-0.5){         
            comment = "forceCheck";
            close = True;
         }  
 
      }

      else if(type==OP_SELL){
      
         if(val>0.5){
            comment = "forceCheck"; 
            close = True;
         }          
      }
      if(filter(type)) return;
      if(close) forceClose(type, comment);
      
   }

   return;
}

