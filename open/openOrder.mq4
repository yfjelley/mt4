

void openOrder(int type, int mag){
   double lot, price;
   string com;
   color clr;
   
   int curLot, ticket;
   
   if(iVolume(Symbol(),0,0)>100) return;
  
   curLot = ordersCount(type, mag);
   
   //lot = Lots;
   lot = getLots();
   lot = 0.01;
   //lot = maxLots();
   //lot = LotsOptimized();
   
   if(type == OP_BUY){ 
      price = Ask;
      com = "EAbuy";
      clr = Red;
      if(ordersCount(OP_SELL, mag)){
         //if(ma(0,80,0)>ma(0,80,2))
         //lot = 2*lot;
      }
   }
   
   if(type == OP_SELL){
      price = Bid;
      com = "EAsell";
      clr = Blue;
      
      if(ordersCount(OP_BUY, mag)){ 
         //if(ma(0,80,0)<ma(0,80,2)) lot = 2*lot;
      }
   }
   
   if((TimeCurrent() - Time_bar) > delta ) Time_open = delta;  
   
   if(curLot == 0  && (TimeCurrent()-Time[0])<Time_open){
      
      
      ticket = OrderSend(Symbol(), type, lot, price, 3, 0, 0, com, mag, 0, clr); 
      
      if(ticket>0){
         if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)){
            Time_open = TimeCurrent()-Time[0];
            Time_bar = Time[0]; 
            Print("open order at:"+OrderOpenPrice()+"is ok!");
         }
         
      }
      else Print("open order error: ",GetLastError()); 
      
      iDrawSign("Text",price,clrCrimson,0,com,12);
   }

   return;
}

double getLots(){
   //每1000美金开0.05*rate
   return MathMax(NormalizeDouble(AccountBalance()*0.01*rate/1000, 2),0.01);
}

double LotsOptimized(){
   double lot=maxLots();
   int    orders=HistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break

   //lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);

   if(DecreaseFactor>0){
      for(int i=orders-1;i>=0;i--){
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false){
            Print("Error in history!");
            break;
         }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL)
            continue;
         //---
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
        }
      if(losses>1)
         lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
   }
   if(lot<0.01) lot=0.01;
   return(lot);
}

//持有的单数量
int ordersCount(int type, int mag){
   int num = 0;

   for(int i=0;i<OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==mag){
         if(OrderType()==type)  num++ ;
      }
   }
   
   return num;
}

//浮动盈利
double ordersProfit(int type){
   double profit=0;
   for(int i=0;i<OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()==Symbol()){
         if(OrderType()==type)  profit+=OrderProfit() ;
      }
   }
   return profit;
}

