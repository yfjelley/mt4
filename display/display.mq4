 
void DisplayMA(){

   int textSize=16;

   tools();

   
   string macd;
   if(iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0)>0) macd = "多" ; else macd = "空";
   double os=iStochastic(NULL,60,60,5,5,MODE_SMA,1,MODE_MAIN,0);
      
   iDisplayInfo("loss", "持仓风险: "+NormalizeDouble(maxLoss("all"),2)+"美金   风险率:"+ risk()+"%",0,10,10,textSize,"",TextColor);   
   //iDisplayInfo("Lots", "单次下单量 "+getLots()+" 手",0,10,50,textSize,"",TextColor);
   //iDisplayInfo("Lots", "单次下单量 "+maxLots()+" 手",0,10,50,textSize,"",TextColor);
   iDisplayInfo("Stop", "Min Stop Loss "+minStopLoss(),0,10,50,textSize,"",TextColor); 
   iDisplayInfo("band_with", "band width "+bandWidth(),0,10,90,textSize,"",TextColor);  
   
   iDisplayInfo("bias8", "    乖离率："+bias(8)+"@"+biasDot(8),0,200,50,textSize,"",TextColor); 
   iDisplayInfo("bias21", "              "+bias(21)+"@"+biasDot(21),0,250,90,textSize,"",TextColor); 
   iDisplayInfo("bias50", "              "+bias(50)+"@"+biasDot(50),0,250,130,textSize,"",TextColor);  
    
   iDisplayInfo("profit", "动态盈利："+dynamicProfit()+"%",2,10,10,textSize,"",TextColor);  

   iDisplayInfo("todayProfit", "today profit: " +todayProfit() ,2,300,10,textSize,"",TextColor);

   iDisplayInfo("todayLot", "Today Lot: " + todayLot(), 2, 600,10,textSize,"",TextColor);

   iDisplayInfo("op_buy_lot", "多单: " + allLots(OP_BUY)+"手", 2, 1200,40,textSize,"",TextColor);
   iDisplayInfo("op_sell_lot", "空单: " + allLots(OP_SELL)+"手", 2, 1200,10,textSize,"",TextColor);
   
   iDisplayInfo("risk", "风险率: " + risk(1)+"%", 2, 1400,10,textSize,"",TextColor);
   return;
}

double dynamicProfit(){
   return NormalizeDouble(100*(AccountEquity()/AccountBalance()-1.0),2);
}

double bandWidth(){
   return NormalizeDouble((upper(0, 2)-lower(0, 2))/PointValue(),1);
}

double bias(int period){
     double ma = iMA(NULL,60,period,0,MODE_SMA,PRICE_CLOSE,0);
     if(ma) return NormalizeDouble(100*(Ask- ma )/ma, 2);
     return 0;
}

double bias1(int period){
     double ma = iMA(NULL,60,period,0,MODE_SMA,PRICE_CLOSE,0);
     if(ma) return NormalizeDouble((Ask- ma )/atr(), 2);
     return 0;
}

double biasDot(int period){
     double ma = iMA(NULL,0,period,0,MODE_SMA,PRICE_CLOSE,0);
     return NormalizeDouble((Ask- ma )/PointValue(), 2);
}

//每个品种的持仓风险要小于5%
double maxLots(){
   double lots=0.0;
   if(Symbol()=="EURUSD" || Symbol()=="GBPUSD" || Symbol()=="AUDUSD" ||Symbol()=="NZDUSD" 
       ||Symbol()=="EURUSD." || Symbol()=="GBPUSD." || Symbol()=="AUDUSD." ||Symbol()=="NZDUSD."){
      lots = NormalizeDouble(AccountBalance()*(0.05-maxLoss(Symbol())/AccountBalance())/(10*minStopLoss()),2);
   }
   if(Symbol()=="USDJPY"|| Symbol()=="USDCAD" || Symbol()=="USDCHF"
       ||Symbol()=="USDJPY."|| Symbol()=="USDCAD." || Symbol()=="USDCHF."){
      lots = NormalizeDouble(AccountBalance()*(0.05-maxLoss(Symbol())/AccountBalance())/(100000*PointValue()/MarketInfo(OrderSymbol(),MODE_ASK)*minStopLoss()),2);      
   }
   if(Symbol()=="XAUUSD" || Symbol() == "GOLD"||Symbol()=="XAUUSD." || Symbol() == "GOLD."){
      lots = NormalizeDouble(AccountBalance()*(0.05-maxLoss(Symbol())/AccountBalance())/(10*minStopLoss()),2);
   }  
   if (lots<0.02) lots=0.02;
   return lots;
} 

double minStopLoss(){
   return NormalizeDouble((TrailStop+Spread())/PointValue(),1);
}

//all所有货币对
double maxLoss(string symbol = ""){
   double loss = 0;
   if(symbol=="") symbol = Symbol();
   
   for(int i=0;i<OrdersTotal();i++){
      RefreshRates();
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(symbol!=OrderSymbol() && symbol!="all") continue;
      
      if(OrderType()==OP_BUY && OrderStopLoss()>=OrderOpenPrice()) continue;
      if(OrderType()==OP_SELL && OrderStopLoss()<=OrderOpenPrice()) continue;
      
      if(OrderSymbol()=="EURUSD" || OrderSymbol()=="GBPUSD" || OrderSymbol()=="AUDUSD" ||OrderSymbol()=="NZDUSD"
          ||OrderSymbol()=="EURUSD." || OrderSymbol()=="GBPUSD." || OrderSymbol()=="AUDUSD." ||OrderSymbol()=="NZDUSD." ){
         loss += MathAbs(OrderOpenPrice()-OrderStopLoss())*100000*OrderLots();

      }
      if(OrderSymbol()=="USDJPY"|| OrderSymbol()=="USDCAD" || OrderSymbol()=="USDCHF"
           ||OrderSymbol()=="USDJPY."|| OrderSymbol()=="USDCAD." || OrderSymbol()=="USDCHF."){
         loss += MathAbs(OrderOpenPrice()-OrderStopLoss())*(100000/MarketInfo(OrderSymbol(),MODE_ASK))*OrderLots();

      }
      if(OrderSymbol()=="XAUUSD" ||OrderSymbol() == "GOLD"||OrderSymbol()=="XAUUSD." ||OrderSymbol() == "GOLD."){
         loss += MathAbs(OrderOpenPrice()-OrderStopLoss())*100*OrderLots();
      }

   }
   return(loss);
}


//持有的单数量
double allLots(int type){
   double lot = 0;

   for(int i=0; i<OrdersTotal(); i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()==Symbol()){
         if(OrderType()==type)  lot+= OrderLots() ;
      }
   }
   
   return lot;
}

//+------------------------------------------------------------------+
//| x=0,x=1,x=2今天昨天前天                                                                 |
//+------------------------------------------------------------------+

double todayProfit(int x =0){
   double profit;
   for(int i=0;i<OrdersHistoryTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;

      if (OrderCloseTime() >= iTime(Symbol(), PERIOD_D1, x) && OrderCloseTime() < iTime(Symbol(), PERIOD_D1, x) + 86400) profit+=OrderProfit()+OrderCommission()+OrderSwap();

   }
   return profit;
}

//+------------------------------------------------------------------+
//| x=0,x=1,x=2今天昨天前天                                                             |
//+------------------------------------------------------------------+
double todayLot(int x=0){
   double lot;
   for(int i=0;i<OrdersHistoryTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;

      if (OrderCloseTime() >= iTime(Symbol(), PERIOD_D1, x) && OrderCloseTime() < iTime(Symbol(), PERIOD_D1, x) + 86400) lot+=OrderLots();

   }
   return lot;
}

//+--------------手动交易安全性检测---------------------------------------+
//1.上根k线收阳且收线大于ma8和ma20
//2.布林带开口
//

