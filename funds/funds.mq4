#include "zhengdang_check.mq4"
#include "gubi_check.mq4"
#include "force_check.mq4"
#include "rsi_check.mq4"
void funds(){
  pointsMange();
  riskMange();
  //入场点位检测
  keltnerStop();
  //zhengdangCheck();
  GubiCheck();
  PointCheck();
  handCheck();
  ForceCheck();
  //买强空弱
  RsiCheck();
}

void pointsMange(){
   for(int i=0;i<OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      int type= OrderType();
      isClose = False;

      if(TimeCurrent()-OrderOpenTime()>5) return;

      //布林带带宽
      if(atrD() && (upper(0,2)-lower(0,2))>3*atrD()){
         comment = "fm_b"+3*atrD();
         isClose = True;
      }
      
      if(isClose) forceClose(type, comment);      
   }
   return;
}

//总持仓风险大于0.2 单货币持仓风险大于0.1
void riskMange(){
   double v = AccountBalance();
   //设置了止损
   //动态盈利小于0
   //整体亏损小于-3
   
   if(isSetStopLoss() && (
            (AccountBalance()<150 &&
            (AccountBalance()-AccountEquity())>30)||
                  (AccountBalance()<250 &&
            (AccountBalance()-AccountEquity())>35)||
                  (AccountBalance()<350 &&
            (AccountBalance()-AccountEquity())>40)||
                  (AccountBalance()<450 &&
            (AccountBalance()-AccountEquity())>45)||
                  (AccountBalance()<550 &&
            (AccountBalance()-AccountEquity())>50)|| 
                        
                  (AccountBalance()<650 &&
            (AccountBalance()-AccountEquity())>55)||
                  (AccountBalance()<750 &&
            (AccountBalance()-AccountEquity())>60)||
                  (AccountBalance()<850 &&
            (AccountBalance()-AccountEquity())>65)||
                  (AccountBalance()<950 &&
            (AccountBalance()-AccountEquity())>70)|| 

                   (AccountBalance()<1050 &&
            (AccountBalance()-AccountEquity())>75)||
                  (AccountBalance()<1150 &&
            (AccountBalance()-AccountEquity())>80)||
                  (AccountBalance()<1250 &&
            (AccountBalance()-AccountEquity())>85)||
                  (AccountBalance()>1250 &&
            (AccountBalance()-AccountEquity())>90)                              
            )
      ) lotsDelete();
      
   return;
}
//持仓风险
double risk(int type=0){
   double risk;
   if(type==0) risk=maxLoss("all");   //总的持仓风险
   else risk=maxLoss(Symbol());        //当前货币的持仓风险

   return NormalizeDouble(risk/AccountBalance()*100,2);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void lotsDelete(){
   int type;
   if(isMaxRiskSym()){  
      for(int i=OrdersTotal();i>=0;i--){
         RefreshRates();
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
         if(OrderSymbol()!=Symbol()) continue;    
         type=OrderType();
         if(allLots(type)<=0.01) continue;
         //仓位管理
         close(type,OrderTicket(),0.01,"lotsDelete");
         Sleep(10);
         break;

      }
   }
   return;
}
//+------------------------------------------------------------------+
//|检测当前货币对是否是风险最大的                                                                  |
//+------------------------------------------------------------------+
bool isMaxRiskSym(){
   double eurusd_risk,gbpusd_risk,audusd_risk,nzdusd_risk,usdjpy_risk,usdcad_risk,usdchf_risk,xauusd_risk,sym_risk;

   eurusd_risk = maxLoss("EURUSD");
   gbpusd_risk = maxLoss("GBPUSD");
   audusd_risk = maxLoss("AUDUSD");
   nzdusd_risk = maxLoss("NZDUSD");
   usdjpy_risk = maxLoss("USDJPY");
   usdcad_risk = maxLoss("USDCAD");
   usdchf_risk = maxLoss("USDCHF");
   xauusd_risk = MathMax(maxLoss("XAUUSD"), maxLoss("GOLD"));

   sym_risk=maxLoss(Symbol());

   if((eurusd_risk>sym_risk) || 
      (gbpusd_risk>sym_risk) || 
      (audusd_risk>sym_risk) || 
      (nzdusd_risk>sym_risk) || 
      (usdjpy_risk>sym_risk) || 
      (usdcad_risk>sym_risk) || 
      (usdchf_risk>sym_risk) || 
      (xauusd_risk > sym_risk) ) return False;

   return True;
}
//+------------------------------------------------------------------+
//|检测是否都设置了止损                                                                  |
//+------------------------------------------------------------------+
bool isSetStopLoss(){
   for(int i=0; i<OrdersTotal(); i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderStopLoss()==0) return False;
   }
   return True;
}


void handCheck(){
   for(int i=0;i<OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      if(TimeCurrent()-OrderOpenTime()>30) continue;
      if(OrderType()==OP_BUY){       
         if( ma(NULL, 20, 2)- ma(NULL, 20, 0)>0.2*atr()
                 )
            close(OrderType(),OrderTicket(),OrderLots(),"xie20");   
    
            
         if( ma(NULL, 8, 2)- ma(NULL, 8, 0)>0.2*atr()
                && ma(NULL, 20, 0)- ma(NULL, 20, 2)<0.2*atr()
                 )
            close(OrderType(),OrderTicket(),OrderLots(),"xie8");   
            
         if( ma(NULL, 20, 2) - ma(NULL, 20, 0)>0.2*atr()
                 && ma(NULL, 50, 2)> ma(NULL, 50, 0)
                   && upper(0, 2, 0)>ma(NULL, 50, 0))
            close(OrderType(),OrderTicket(),OrderLots(),"funds空");  
               
         
         if(upper(0,2,2)-upper(0,2,0)>0.1*atr()
                  && ma(NULL, 20, 2) - ma(NULL, 20, 0)>0.1*atr()
                    && ma(NULL, 50, 2) - ma(NULL, 50, 0)>0.1*atr())   
            close(OrderType(),OrderTicket(),OrderLots(),"funds三线2");    
         
         if(upper(0,2,2)-upper(0,2,0)>0.1*atr()
                  && ma(NULL, 20, 2) - ma(NULL, 20, 0)>0.1*atr()
                    && ma(NULL, 8, 2) - ma(NULL, 8, 0)>0.1*atr())   
            close(OrderType(),OrderTicket(),OrderLots(),"funds三线");            
            
         if((bias(8)>0.4 || bias(21)>0.6 || bias(50)>1.2)){
            close(OrderType(),OrderTicket(),OrderLots(),"乖离率过大");   
         };
         
         if(iClose(NULL,0,1) - iOpen(NULL,0,1)<0) close(OrderType(),OrderTicket(),OrderLots(),"k1阴");   
      }
      if(OrderType()==OP_SELL){  
              
         if(ma(NULL, 20, 0) - ma(NULL, 20, 2)> 0.2*atr()
                 )
            close(OrderType(),OrderTicket(),OrderLots(),"xie20"); 
   
                     
         if(
              ma(NULL, 8, 0) - ma(NULL, 8, 2)> 0.2*atr()
                  && ma(NULL, 20, 2)- ma(NULL, 20, 0)<0.2*atr()
                 )
            close(OrderType(),OrderTicket(),OrderLots(),"xie8"); 
            
         if( ma(NULL, 20, 0) - ma(NULL, 20, 2)>0.2*atr()
                 && ma(NULL, 50, 0)> ma(NULL, 50, 2)
                   && upper(0, 2,0)>ma(NULL, 50, 0))
            close(OrderType(),OrderTicket(),OrderLots(),"funds多");   
           
         if(upper(0,2,0)-upper(0,2,2)>0.1*atr()
                 && ma(NULL, 20, 0) - ma(NULL, 20, 2)>0.1*atr()
                    && ma(NULL, 50, 0) - ma(NULL, 50, 2)>0.1*atr())   
            close(OrderType(),OrderTicket(),OrderLots(),"funds三线2");  
         
         if(upper(0,2,0)-upper(0,2,2)>0.1*atr()
                 && ma(NULL, 20, 0) - ma(NULL, 20, 2)>0.1*atr()
                    && ma(NULL, 8, 0) - ma(NULL, 8, 2)>0.1*atr())   
            close(OrderType(),OrderTicket(),OrderLots(),"funds三线");   
            
         
         if((bias(8)<-0.4 || bias(21)<-0.6 || bias(50)<-1.2)){
            close(OrderType(),OrderTicket(),OrderLots(),"乖离率过大");   
         };
         
         if(iClose(NULL,0,1) - iOpen(NULL,0,1)>0) close(OrderType(),OrderTicket(),OrderLots(),"k1阳");
            
      }
      
   }

   return;
}


void PointCheck(){
   int magic = Mag1;//EA下单的magic都为Mag1
   for(int i=0;i<OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      if(TimeCurrent()-OrderOpenTime()>10) continue;
      if(OrderType()==OP_BUY){
          if(OrderOpenPrice()>ema(NULL,3,0)+0.5*atr())close(OrderType(),OrderTicket(),OrderLots(),"入场点");
          if(Low[1]>upper(0,2,1)&&High[1]>upper(0,2,1))close(OrderType(),OrderTicket(),OrderLots(),"悬空");
          if(OrderOpenPrice()>upper(0,2,0)+MathMin(0.3*atr(),6*PointValue()))close(OrderType(),OrderTicket(),OrderLots(),"布林外");
          if(OrderOpenPrice()>upper(240,2,0)+0.1*atr())close(OrderType(),OrderTicket(),OrderLots(),"4h布林外");
          if(OrderOpenPrice()>ema(240,3,0)+1*atr()) close(OrderType(),OrderTicket(),OrderLots(),"4h_3_ema");  
      }
      if(OrderType()==OP_SELL){
      
         if(OrderOpenPrice()<ema(NULL,3,0)-0.5*atr())close(OrderType(),OrderTicket(),OrderLots(),"入场点");
         if(Low[1]<lower(0,2,1)&&High[1]<lower(0,2,1))close(OrderType(),OrderTicket(),OrderLots(),"悬空"); 
         if(OrderOpenPrice()<lower(0,2,0)-MathMin(0.3*atr(),6*PointValue()))close(OrderType(),OrderTicket(),OrderLots(),"布林外");
         if(OrderOpenPrice()<lower(240,2,0)-0.1*atr())close(OrderType(),OrderTicket(),OrderLots(),"4h布林外");
         if(OrderOpenPrice()<ema(240,3,0)-1*atr()) close(OrderType(),OrderTicket(),OrderLots(),"4h_3_ema");  
      }  
   }
   return;
}


void keltnerStop(){
   int magic = Mag1;//EA下单的magic都为Mag1
   for(int i=0;i<OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      if(OrderMagicNumber()==magic) continue;//EA下单的不做检测
      if(TimeCurrent()-OrderOpenTime()>10) continue;
      if(OrderType()==OP_BUY){
          if(OrderOpenPrice()>iMA(NULL,NULL,49,0,3,PRICE_CLOSE,0)+3.2*atr())close(OrderType(),OrderTicket(),OrderLots(),"keltner");
      }
      if(OrderType()==OP_SELL){
         if(OrderOpenPrice()<iMA(NULL,NULL,49,0,3,PRICE_CLOSE,0)-3.2*atr())close(OrderType(),OrderTicket(),OrderLots(),"keltner");

      }  
   }
   return;
}
//+------------------------------------------------------------------+
