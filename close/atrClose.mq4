
void atrCloseMain(){
   double hig,low;
   int openCount, count;
   bool close = False;
  
   for(int i=0;i<OrdersTotal();i++){
   
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol()) continue;
   
      openCount = barCount(OrderOpenTime());
   
      hig = High[iHighest(NULL,0,MODE_CLOSE,MathMax(openCount,0),0)];
      low = Low[iLowest(NULL,0,MODE_CLOSE,MathMax(openCount,0),0)];
      
      datetime timehig = Time[iHighest(NULL,0,MODE_HIGH,openCount,0)];
      datetime timelow = Time[iLowest(NULL,0,MODE_LOW,openCount,0)]; 
      
      int type = OrderType();     
      
      if(!PF3(type)) continue;//过滤器  
      
      if(type==OP_BUY){
  
         count = openCount - barCount(timehig)-(barCount(timehig)-barCount(timelow));
      
         //最大回撤2.8atr+0.1*count*atr, 最大6atr
         if(Ask<MathMax(hig-N()*atr()-0.1*count*atr(), hig-6*atr())){         
            comment = "count"+count; 
            close = True;
         }
                  
         //盈利小于0时，最大回撤2.8atr
         else if(Ask<hig-N()*atr() && OrderProfit()<0){
            comment = "back1"; 
            close = True;
         }
         //相对于前一根k线的收盘价，回撤2.5atr止损   
         else if(Ask<(iHigh(Symbol(), 0, 0)-N()*atr()) && Close[0]< ma(0,8)){
            comment = "back2";
            close = True;
         }
         
      }

      else if(type==OP_SELL){
         count = openCount - barCount(timelow) - (barCount(timelow)-barCount(timehig));
      
         if(Bid>MathMin(low+N()*atr()+0.1*count*atr(), low+6*atr())){
            comment = "count"+count; 
            close = True;
         }
              
         else if(Bid>low+N()*atr() && OrderProfit()<0){
            comment = "back1"; 
            close = True;
         }

         else if(Bid>(iLow(Symbol(), 0, 0)+ N()*atr()) && Close[0]> ma(0,8)){
            comment = "back2";
            close = True;
         }          
      }
      if(close) forceClose(type, comment);
   }
}


void atrCloseOther(){    
   comment = "retAtr";
   if(retAtr(OP_SELL, 0)) forceClose(OP_SELL, comment);                        
   if(retAtr(OP_BUY, 0)) forceClose(OP_BUY, comment);
   return;
}

bool retAtr(int type, int timeframe){

   //buy
   if(type == OP_BUY){
      if(Ask<(iClose(Symbol(), timeframe, 1)-X()*atr())) return True;
   }
   //sell
   if(type == OP_SELL){
      if(Bid>(iClose(Symbol(), timeframe, 1)+X()*atr())) return True;
   }
   return false;
}

int retK(int timeframe, int type){

   if(type == OP_BUY){
      if(iOpen(Symbol(),timeframe,1)-iClose(Symbol(),timeframe,1)>X()*atr()) return True;
   }
   if(type == OP_SELL){
      if(iClose(Symbol(),timeframe,1)-iOpen(Symbol(),timeframe,1)>X()*atr()) return True;
   }
   return false;
}


//******************************PRICE Filter Settings*****************************************
int PF3(int type){
   if(type==OP_SELL){
      if(iOpen(NULL,PERIOD_H1,0)<iClose(NULL,PERIOD_H1,0)) return 1;
   } 
   if(type==OP_BUY){
      if(iOpen(NULL,PERIOD_H1,0)>iClose(NULL,PERIOD_H1,0)) return 1;
   }
   return 0;
}
//回撤倍数
double N(){
   double n = 2.8;   
   if(Symbol()=="EURUSD" || Symbol()=="GBPUSD" || Symbol()=="AUDUSD"){n=2.8;}
   if(Symbol()=="USDJPY"|| Symbol()=="USDCAD" || Symbol()=="USDCHF"){n=3;}
   if(Symbol()=="USDCAD"){n=3;}
   if(Symbol()=="NZDUSD"){n=3;}
   if(Symbol()=="XAUUSD" ||Symbol() == "GOLD"){n=2.8;}
   return n;
}
//回撤倍数
double X(){
   double n = 2;   
   if(Symbol()=="EURUSD" || Symbol()=="GBPUSD" || Symbol()=="AUDUSD"){n=2;}
   if(Symbol()=="USDJPY"|| Symbol()=="USDCAD" || Symbol()=="USDCHF"){n=2;}
   if(Symbol()=="USDCAD"){n=2;}
   if(Symbol()=="NZDUSD"){n=2;}
   if(Symbol()=="XAUUSD" ||Symbol() == "GOLD"){n=2;}
   return n;
}