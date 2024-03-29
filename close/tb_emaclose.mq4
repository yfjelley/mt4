//------------------------------------------------------------------------
// 简称: CL_ADXandMAChannelSys_L
// 名称: 基于ADX及EMA的交易系统多
// 类别: 公式应用
// 类型: 内建应用
// 输出:
// 策略说明:基于ADX及EMA进行判断
// 系统要素:
//				1. 计算30根k线最高价和最低价的EMA价差
//				2. 计算12根k线的ADX
// 入场条件:
//				满足上根K线的收盘价收于EMA30之上,且ADX向上的条件 在EntryBarBAR内该条件成立
//			    当前价大于等于BuySetup,做多,当条件满足超过EntryBarBAR后,取消入场
// 出场条件:
//				当前价格下破30根K线最高价的EMA		
//
//----------------------------------------------------------------------//


void TB_ema_close(){
   double EMAh,EMAl;
   bool close = False; 
   
   // 计算当前K线的加权均值、阻力线和支撑线
   EMAh = iMA(NULL,0,20,0,MODE_EMA,PRICE_HIGH,0);
   EMAl = iMA(NULL,0,20,0,MODE_EMA,PRICE_LOW,0);
   for(int i=0;i<OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      if(barCount(OrderOpenTime())<4) continue;
      int type = OrderType();  
      if(filter(type)) continue;    
      if(type==OP_BUY){  
         if(iClose(NULL, 0, 0)<EMAh-Spread()){         
            comment = "EMA止损";
            close = True;
         }  
 
      }

      else if(type==OP_SELL){
      
         if(iClose(NULL, 0, 0)>EMAl+Spread()){
            comment = "EMA止损"; 
            close = True;
         }          
      }
      if(close) forceClose(type, comment);
   }
}


