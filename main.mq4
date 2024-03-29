//公共文件
#include "common/common.mq4"
//开仓
#include "open/open.mq4"
//资金管理和资金安全
#include "funds/funds.mq4"
//平仓策略
#include "close/close.mq4"

//移动止损
#include "stopLine/stopLine.mq4"
//显示
#include "display/display.mq4"

int OnInit(){
   //ObjectsDeleteAll();
   //tools();   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
    //ObjectsDeleteAll(); 
}

void tools(){
   // 按钮：全部一键平仓
   button("closeAllShortcut",clrBlack,10,210," 全部一键平仓 ",200,clrRed);
}

bool isTrade(){
   bool trade = True;
   
   if(DayOfWeek()==5 && Hour()>12) trade=false;
   if(DayOfWeek()==1){ 
      if(Hour()<1) trade=false;
      if(Hour()<10 && gap())trade=false;//有效果
   }
   if(trade){   
      if(DayOfWeek()==0 && DayOfWeek()==6) trade = false;
   }
   
   return trade;
}

void OnTick(){  
    
   stopLine();
   if(isfund_check) funds();  
   close();
   stopWeekend();
   
   if(isTrade()) open();
   
   if(!IsTesting() && !IsOptimization()){
      DisplayMA();
   } 
   return;
}

bool isWeekend(){
   if(DayOfWeek()==5 && Hour()>=22) return True;
   return False;
}

void stopWeekend(){
   if(isWeekend()){
      for(int i=0;i<OrdersTotal();i++){
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
         if(OrderSymbol()!=Symbol()) continue;      
         int type = OrderType();       
         close(type,OrderTicket(), OrderLots(), "weekend");       
      }
   }
   return;
}


//周一有缺口不做单
bool gap(){
   for(int i=0; i<15; i++){
      if(MathAbs(Open[i]-Close[i+1])>atr()) return True;
   }
   return False;
}


//EA 平仓工具
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam){  

   if(id==CHARTEVENT_OBJECT_CLICK){  
                   
      if(sparam=="closeAllShortcut"){
         if(ObjectGetInteger(0,"closeAllShortcut",OBJPROP_STATE)==1){
            ObjectSetInteger(0,"closeAllShortcut",OBJPROP_BGCOLOR,clrWhite);   
         }
         else{
            ObjectSetInteger(0,"closeAllShortcut",OBJPROP_BGCOLOR,clrRed);
         }  
         forceClose(OP_BUY, "88");         
         forceClose(OP_SELL, "88");             
       }     
    }
}
