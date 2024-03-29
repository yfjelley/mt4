//------------------------------------------------------------------------
// 简称: CL_FirstPullBackSys_S
// 名称: 基于MACD判断的交易系统
// 类别: 公式应用
// 类型: 内建应用
// 输出:
// 策略说明:
//			基于MACD在价格回撤时进行判断的交易系统
//			 
// 系统要素:
//			 1. 用MACD慢线在零轴下判断趋势
//			 2. 在空头趋势中以收盘价和波动率构成入场出场通道
// 入场条件:
//			 1. 价格低于MACD慢线下穿零轴的当前价格和波动率组成的通道下轨
//			 
// 出场条件: 
//			 1. macd慢线在零轴上
//			 2. 价格高于MACD慢线下穿零轴的当前价格和波动率组成的通道上轨
//           3. 价格高于空头趋势形成时的最高价格出场
//		 注: 
//----------------------------------------------------------------------//


void TB_macd_close(){
   double SingnalLine ;
   bool close = False; 
   
   SingnalLine = iMACD(NULL,0,12,26,5,PRICE_CLOSE,MODE_SIGNAL,0);

   for(int i=0;i<OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      int type = OrderType(); 
      if(filter(type)) continue;     
      if(type==OP_BUY){  
         if(SingnalLine<0){         
            comment = "MACD慢线小于0";
            close = True;
         }  
 
      }

      else if(type==OP_SELL){
      
         if(SingnalLine>0){
            comment = "MACD慢线大于0"; 
            close = True;
         }          
      }
       
      if(close) forceClose(type, comment);
   }
}


