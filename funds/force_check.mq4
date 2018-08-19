void ForceCheck(){

   double val=iForce(NULL,0,13,MODE_SMA,PRICE_CLOSE,0);
   
   for(int i=0;i<OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      if(TimeCurrent()-OrderOpenTime()>30) continue;
      if(OrderType()==OP_BUY){
            
         if(val<-0.5) close(OrderType(),OrderTicket(),OrderLots(),"forceCheck");            
 
      }
      if(OrderType()==OP_SELL){      
            
         if(val>0.5)close(OrderType(),OrderTicket(),OrderLots(),"forceCheck"); 
                 
      }
      
   }

   return;
}

