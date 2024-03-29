// ------------------------------------------------------------------------
//  简称: CL_AverageChannelRangeLeader_L
//  名称: 基于平移的高低点均值通道与K线中值突破的系统多 
//  类别: 公式应用
//  类型: 内建应用
//  输出:
// ------------------------------------------------------------------------


// ----------------------------------------------------------------------// 
//  策略说明:
//  			基于平移的高点和低点均线通道与K线中值突破进行判断

//  系统要素:
//  			1. Range Leader是个当前K线的中点在之前K线的最高点上, 且当前K线的振幅大于之前K线的振幅的K线
//  			2. 计算高点和低点的移动平均线

//  入场条件:
//  			1、上根K线为RangeLead，并且上一根收盘价大于N周期前高点的MA，当前无多仓，则开多仓
//  			2、上根K线为RangeLead，并且上一根收盘价小于N周期前低点的MA，当前无空仓，则开空仓
// 
//  出场条件:
//  			1. 开仓后，5个K线内用中轨止损，5个K线后用外轨止损
// 
//     注:当前策略仅为做多系统, 如需做空, 请参见CL_AverageChannelRangeLeader_S
// ----------------------------------------------------------------------// 


void TB_ma_close(){
   double MAh,MAl,MAm;
   bool close = False; 
   
   // 计算当前K线的加权均值、阻力线和支撑线
   MAh = iMA(NULL,0,20,0,MODE_SMA,PRICE_HIGH,0);
   MAl = iMA(NULL,0,20,0,MODE_SMA,PRICE_LOW,0);
   MAm = iMA(NULL,0,20,0,MODE_SMA,PRICE_MEDIAN,0);
   for(int i=0;i<OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      
      int type = OrderType();   
      
      if(filter(type)) continue;  
      if(type==OP_BUY){  
         if(
               (barCount(OrderOpenTime())>5 &&iClose(NULL, 0, 0)<MAh-Spread())||
               (barCount(OrderOpenTime())<=5 &&iClose(NULL, 0, 0)<MAm-Spread())
          ){
            comment = "MA止损";
            close = True;
         }  
 
      }

      else if(type==OP_SELL){
      
         if(               
               (barCount(OrderOpenTime())>5 &&iClose(NULL, 0, 0)>MAl+Spread())||
               (barCount(OrderOpenTime())<=5 &&iClose(NULL, 0, 0)>MAm+Spread())
         ){
            comment = "MA止损"; 
            close = True;
         }          
      }
      if(close) forceClose(type, comment);
   }
}


