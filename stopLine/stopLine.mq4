
double getTrailStop(int type){
   if(type==OP_BUY) return Ask-TrailStop-PointValue();
   if(type==OP_SELL) return Bid+TrailStop+PointValue();
   return iMA(NULL,0,short_period,0,MODE_EMA,PRICE_CLOSE,0);
}

void stopLine(){ 
   bool result;
   double ts;  

   for( int i=0;i<OrdersTotal();i++){
   
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;  
      if(OrderSymbol()!=Symbol()) continue;
      int type = OrderType();   
      ts =  getTrailStop(type);

      //下单后设置3atr止损

       
      if(type==OP_BUY){    
            //盈利小3atr， 3atr止损
            if(OrderStopLoss()==0)
               result = OrderModify(OrderTicket(),OrderOpenPrice(),ts,OrderTakeProfit(),0,Green);
               
            else if(OrderStopLoss()<ts-PointValue()
                                    && (iLow(Symbol(), PERIOD_H1, 1)-PointValue())>ts
                                          && (iLow(Symbol(), PERIOD_H1, 0)-PointValue())>ts)
               result = OrderModify(OrderTicket(),OrderOpenPrice(),ts,OrderTakeProfit(),0,Green);
            
            else if(OrderStopLoss()<ts -PointValue()  
                              &&((ts-atr())>OrderStopLoss()))
               result = OrderModify(OrderTicket(),OrderOpenPrice(),ts-atr(),OrderTakeProfit(),0,Green); 


      
      }
      else if(type==OP_SELL){
               
            //盈利小于3atr, 3atr止损
            if(OrderStopLoss()==0)
               result = OrderModify(OrderTicket(),OrderOpenPrice(),ts,OrderTakeProfit(),0,Green);
               
            else if(OrderStopLoss()>ts +PointValue()
                                    && (iHigh(Symbol(), PERIOD_H1, 1)+PointValue()) < ts
                                          && (iHigh(Symbol(), PERIOD_H1, 0)+PointValue()) < ts)
               result = OrderModify(OrderTicket(),OrderOpenPrice(),ts,OrderTakeProfit(),0,Red);
            
            else if(OrderStopLoss()>ts +PointValue()
                              && ((ts+atr())<OrderStopLoss()))
               result = OrderModify(OrderTicket(),OrderOpenPrice(),ts+atr(),OrderTakeProfit(),0,Red);
      }

   }
   return;
}
