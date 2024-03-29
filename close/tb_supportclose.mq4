//------------------------------------------------------------------------
// 简称: CL_RedRover_L
// 名称: 基于K线加权均值的支撑阻力线突破系统多 
// 类别: 公式应用
// 类型: 内建应用
// 输出:
//------------------------------------------------------------------------

//----------------------------------------------------------------------//
// 策略说明:
//			 本策略是基于K线加权均值的支撑阻力线突破系统
//			 
// 系统要素:
//			 1. K线的加权均值 = (最高价+最低价+2*收盘价)/4
//			 2. 支撑线 = K线加权均值 - ( 最高价 - K线加权均值)
//			 3. 阻力线 = K线加权均值 + ( K线加权均值 - 最低价)
// 入场条件:
//			 1. 当价格向上突破阻力线做多
//			 2. 当价格向下突破支撑线做空
// 出场条件: 
//			 1. 趋势反转即反向突破时出场
//			 2. 基于ATR的一定倍数的止盈
//
//		 注: 当前策略仅为做多系统, 如需做空, 请参见CL_RedRover_S
//----------------------------------------------------------------------//


void TB_support_close(){
   double WAvgPrice,Resistance,Support ;
   bool close = False; 
   
   // 计算当前K线的加权均值、阻力线和支撑线
   WAvgPrice = (High[1]+Low[1]+2*Close[1])/4;
   Resistance = (WAvgPrice * 2) - Low[1];
   Support = (WAvgPrice * 2) - High[1];

   for(int i=0;i<OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      int type = OrderType();     
      if(type==OP_BUY){  
         if(Ask<Support-Spread()){         
            comment = "Ask小于支撑位";
            close = True;
         }  
      }

      else if(type==OP_SELL){    
         if(Bid>Resistance+Spread()){
            comment = "Bid大于阻力位"; 
            close = True;
         }          
      }
      if(close) forceClose(type, comment);
   }
}


