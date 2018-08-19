//------------------------------------------------------------------------
// 简称: CL_SupermanSystem_S
// 名称: 基于市场强弱和动量的通道突破系统空 
// 类别: 公式应用
// 类型: 内建应用
// 输出:
//------------------------------------------------------------------------

//----------------------------------------------------------------------//
// 策略说明:
//			 本策略是基于市场强弱指标和动量的通道突破系统
//			 
// 系统要素:
//			 1. 根据N根K线的收盘价相对前一根K线的涨跌计算出市场强弱指标
//			 2. 最近9根K线的动量变化趋势
//			 3. 最近N根K线的高低点形成的通道
// 入场条件:
//			 1. 市场强弱指标为多头，且市场动量由空转多时，突破通道高点做多
//			 2. 市场强弱指标为空头，且市场动量由多转空时，突破通道低点做空
// 出场条件: 
//			 1. 开多以开仓BAR的最近N根BAR的低点作为止损价
//			    开空以开仓BAR的最近N根BAR的高点作为止损价
//			 2. 盈利超过止损额的一定倍数止盈
//			 3. 出现反向信号止损
//
//		 注: 当前策略仅为做空系统, 如需做多, 请参见CL_SupermanSystem_L
//----------------------------------------------------------------------//

void TB_higlow_close(){
   double Hi,Lo;
   bool close = False; 
   
   // 计算当前K线的加权均值、阻力线和支撑线
   Hi = High[iHighest(NULL,0,MODE_HIGH,3,1)];
   Lo = Low[iLowest(NULL,0,MODE_LOW,3,1)];
   for(int i=0;i<OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      if(barCount(OrderOpenTime())<4) continue;
      int type = OrderType();     
      if(type==OP_BUY){  
         if(iClose(NULL, 0, 0)<Lo-Spread()){         
            comment = "HiLo止损";
            close = True;
         }  
 
      }

      else if(type==OP_SELL){
      
         if(iClose(NULL, 0, 0)>Hi+Spread()){
            comment = "HiLo止损"; 
            close = True;
         }          
      }
      if(close) forceClose(type, comment);
   }
}


