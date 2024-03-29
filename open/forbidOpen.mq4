
//******************************kTrend Filter Settings*****************************************
bool forbidOpen(int type){
   //return True;
   return kTrend(type)  
               && mTrend(type)  
                     // && xTrend(type)
                          && timeForbid(type) //eurusd425 usdjpy473
                              //&& biasForbid(type)
                                 && boolForbid(type)
                                  //&& atrForbid(type)
                                    &&adxForbid()
                                     //&&maForbid(type)
                                       //&&stdDevForbid(type)
                                        &&boolForbid2(type)
                                       
                      ;
}


bool stdDevForbid(int type){
   double std, std1;
   std = iStdDev(NULL,0,20,0,MODE_SMA,PRICE_CLOSE,0);
   std1 = iStdDev(NULL,0,20,0,MODE_SMA,PRICE_CLOSE,3);
   if(std<std1) return False;
   return True;   
}

bool adxForbid(){ 
   double adx;
   adx =iADX(Symbol(),0,14,PRICE_TYPICAL,MODE_MAIN,0);

   if(minAdx() < adx && adx< maxAdx()) return True;            
   return False;
}
//******************************ADX Filter Settings*****************************************
double minAdx(){
   double v = 11;   
   if(Symbol()=="EURUSD"){v=0;}
   if(Symbol()=="USDJPY" ){v=11;}
   if(Symbol()=="GBPUSD"){v=11;}
   if(Symbol()=="AUDUSD"){v=11;}
   if(Symbol()=="USDCAD" || Symbol()=="USDCHF" ||Symbol()=="NZDUSD"){v=11;}
   if(Symbol()=="XAUUSD" ||Symbol() == "GOLD"){v=11;}
   return v;
}

double maxAdx(){
   double v = 45;   
   if(Symbol()=="EURUSD" ||Symbol()=="USDJPY" ){v=50;}
   if(Symbol()=="GBPUSD"){v=45;}
   if(Symbol()=="AUDUSD"){v=65;}
   if(Symbol()=="USDCAD" || Symbol()=="USDCHF" ||Symbol()=="NZDUSD"){v=60;}
   if(Symbol()=="XAUUSD" ||Symbol() == "GOLD"){v=45;}
   return v;
}


bool maForbid(int type){
   double ma, ma1;
   ma = iMA(NULL, 0, 15, 0, MODE_SMA,PRICE_CLOSE, 0);
   ma1 = iMA(NULL, 0, 15, 0, MODE_SMA,PRICE_CLOSE, 2);
   if(type==OP_BUY){
      if(ma<ma1) return False; 
   }
   if(type==OP_SELL){
      if(ma>ma1) return False; 
   }
   return True;
}
//******************************bool Filter Settings*****************************************
bool boolForbid2(int type){
   double up, low, low1, up1,ma, ma1;
   up = iBands(NULL,0,long_period,2,0,PRICE_CLOSE,MODE_UPPER,0);
   up1 = iBands(NULL,0,long_period,2,0,PRICE_CLOSE,MODE_UPPER,2);
   
   low = iBands(NULL,0,long_period,2,0,PRICE_CLOSE,MODE_LOWER,0);
   low1 = iBands(NULL,0,long_period,2,0,PRICE_CLOSE,MODE_LOWER,2);
   
   ma=iMA(NULL,0,long_period,0,MODE_SMA,PRICE_CLOSE,0);    
   ma1=iMA(NULL,0,long_period,0,MODE_SMA,PRICE_CLOSE,2);

   if(up>up1 && low>low1 && ma>ma1 && type == OP_SELL) return False;
 
   if(up<up1 && low<low1 && ma<ma1 && type == OP_BUY) return False;
   
   return True;
}

bool boolForbid(int type){
   double up, low;
   up = iBands(NULL,0,100,2,0,PRICE_CLOSE,MODE_UPPER,0);
   low = iBands(NULL,0,100,2,0,PRICE_CLOSE,MODE_LOWER,0);

   if((up-low)/PointValue()<vBand()) return False;
   return True;
}

double vBand(){
   double v = 70;   
   if(Symbol()=="EURUSD"){v=60;}
   if(Symbol()=="USDJPY"){v=60;}
   if(Symbol()=="GBPUSD"){v=60;}
   if(Symbol()=="AUDUSD"){v=60;}
   if(Symbol()=="USDCAD" || Symbol()=="USDCHF" ||Symbol()=="NZDUSD"){v=60;}
   if(Symbol()=="XAUUSD" ||Symbol() == "GOLD"){v=70;}
   return v;
}

bool atrForbid(int type){
   double atr, ma0, ma1;
   atr = iATR(NULL, 0, 12,0);
   
   ma0 = iMA(NULL, 0, long_period, 0, MODE_SMA,PRICE_CLOSE, 0);
   ma1 = iMA(NULL, 0, long_period, 0, MODE_SMA,PRICE_CLOSE, 8);
   
   if(atr/PointValue()<10){
      if(type == OP_BUY){
         if(ma0<ma1) return False;
      }
      if(type == OP_SELL){
         if(ma0>ma1) return False;
      }
   }    
   return True;
}

bool biasForbid(int type){

   if(type == OP_BUY){
      if(bias1(8)>8) return False;
   }
   if(type == OP_SELL){
      if(bias1(8)<-8) return False;
   }

   return True;
}

bool timeForbid(int type){
   for(int i=0;i<HistoryTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      if(OrderType()==type){
         if(type == OP_BUY){
            if(barCount(OrderOpenTime())<3) return False;
         }
         if(type == OP_SELL){
            if(barCount(OrderOpenTime())<3) return False;
         }
      }
   }
   return True;
}

double iMa(int i){
   return iMA(NULL, 0, long_period, 0, MODE_EMA,PRICE_CLOSE, i);
}

double iHi(int i){
   return iHigh(Symbol(), 0, i);
}

double iLo(int i){
   return iLow(Symbol(), 0, i);
}

bool rTrend(int type){
   int i,j;

   if(type==OP_BUY){
      for(j=0;j<1;j++){
         for(i=j; i<50+j; i++){
           if(bias1(50)<-8) break;        
         }
         if(i-j<35) return False;
      }
   }

   if(type==OP_SELL){
      for(j=0;j<3;j++){
         for(i=j; i<50+j; i++){
            if(bias1(50)>8) break; 
         }
         if(i-j<35) return False;
      }

   }

   return True;
}

bool xTrend(int type){
   int i,j;
   double ma0, ma1,mas;
   //连续35根k线最高价都在均线下方，不做多单
   if(type==OP_BUY){
      for(j=1;j<5;j++){
         for(i=j; i<50+j; i++){
           ma0 = iMA(NULL, 0, long_period, 0, MODE_EMA,PRICE_CLOSE, i);
           ma1 = iMA(NULL, 0, long_period, 0, MODE_EMA,PRICE_CLOSE, i+1);
           mas = iMA(NULL, 0, short_period, 0, MODE_EMA,PRICE_CLOSE, i);
           if(mas >ma0 || ma0>ma1) break;        
         }
         if(i-j>34) return False;
      }
   }

   if(type==OP_SELL){
      for(j=1;j<5;j++){
         for(i=j; i<50+j; i++){
           ma0 = iMA(NULL, 0, long_period, 0, MODE_EMA,PRICE_CLOSE, i);
           ma1 = iMA(NULL, 0, long_period, 0, MODE_EMA,PRICE_CLOSE, i+1);
           mas = iMA(NULL, 0, short_period, 0, MODE_EMA,PRICE_CLOSE, i);
           if(mas < ma0 || ma0< ma1) break; 
         }
         if(i-j>34) return False;
      }

   }

   return True;
}

bool kTrend(int type){
   int i,j;
   //连续35根k线最高价都在均线下方，不做多单
   if(type==OP_BUY){
      for(j=1;j<10;j++){
         for(i=j; i<50+j; i++){
           if(iHi(i)>iMa(i)) break;
         }
         if(i-j>34) return False;
      }
   }

   if(type==OP_SELL){
      for(j=1;j<10;j++){
         for(i=j; i<50+j; i++){
           if(iLo(i)<iMa(i)) break;
         }
         if(i-j>34) return False;
      }

   }

   return True;
}

int mTrend(int type){
   int i,j;
   int count;
   //最高价大于ma的k线数，不做多单
   if(type==OP_BUY){
      for(j=0;j<1;j++){
         count =0;
         for(i=j; i<35+j; i++){
           if(iHi(i)>iMa(i)) count++;
           if(iHi(i)>upper(0, 2)) return True;         
         }
         if(count<5) return False;
      }
   }

   if(type==OP_SELL){
      for(j=0;j<1;j++){
         count =0;
         for(i=j; i<35+j; i++){
           if(iLo(i)<iMa(i)) count++;
           if(iLo(i)<lower(0, 2)) return True;           
         }
         if(count<5) return False;
      }
   }

   return True;
}

