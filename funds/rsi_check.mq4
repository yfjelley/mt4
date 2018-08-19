bool IsNotForce(){
   double val0=iRSI(NULL,0,14,PRICE_CLOSE,0);
   double val1=iRSI("EURUSD",0,14,PRICE_CLOSE,0);
   double val2=iRSI("GBPUSD",0,14,PRICE_CLOSE,0);
   double val3=iRSI("XAUUSD",0,14,PRICE_CLOSE,0);
   double val4=iRSI("JPYUSD",0,14,PRICE_CLOSE,0);
   
   double M1 = MathMin(val1,val2);
   double M2 = MathMin(val3,val4);
   double Min = MathMin(M1,M2);
   if(val0 == Min) return True;

   return False;
}


void RsiCheck(){


   
   for(int i=0;i<OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      if(TimeCurrent()-OrderOpenTime()>30) continue;
      if(OrderType()==OP_BUY){
            
         if(IsNotForce()) close(OrderType(),OrderTicket(),OrderLots(),"RSIcheck");            
 
      }
      if(OrderType()==OP_SELL){      
            
         if(IsNotForce())close(OrderType(),OrderTicket(),OrderLots(),"RSICheck"); 
                 
      }
      
   }

   return;
}

