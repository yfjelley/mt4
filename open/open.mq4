#include "openOrder.mq4"
bool atrDay(){
   if(atrD() && (upper(0, 2)-lower(0, 2)) > 3*atrD()) return True;
   return False;
} 

void open(){
   if(atrDay()) return;
   strageOne(OP_BUY);
   strageOne(OP_SELL);
   return;
}

void strageOne(int type){
   int magic = Mag1;    
   int signal= GetSignal(type);
   
   if(signal){  
      openOrder(type, magic);
   }   
      
   return;
}

bool GetSignal(int type){
   if( myMA(type)) return True;
   return False;
}

int emaOpen(int type){
   double MoveBack=3;  
   double hi=High[1];
   double lo=Low[1];
   double EMA, EMA1, EMA2, EMA3;
   EMA=iMA(0,0,8,0,MODE_EMA,PRICE_MEDIAN,1);
   EMA1=iMA(0,0,50,0,MODE_EMA,PRICE_MEDIAN,1);
   EMA2=iMA(0,0,8,0,MODE_EMA,PRICE_MEDIAN,0);
   EMA3=iMA(0,0,50,0,MODE_EMA,PRICE_MEDIAN,0);
   if(type==OP_BUY){
      if(
             ((EMA>EMA1) && (EMA2<EMA3))&&
             (EMA3-EMA2>2*Point && Bid>=(lo+MoveBack*Point))
               
                   
             ) return 1; 
   }
   if(type==OP_SELL){
      if(
           ((EMA<EMA1) && (EMA2>EMA3))&&
            
            (EMA2-EMA3>2*Point && Ask<=(hi-MoveBack*Point))
            
             ) return -1;  
   }
   
   return(0);
}
  
int myMACD(int type){
   double SinLin0, SinLin1, SinLin2;

   SinLin0 = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
   SinLin1 = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   SinLin2 = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,2);
   
   if(type==OP_BUY){
      if(
               (SinLin0<0 || SinLin1<0)&& 
                SinLin0>0 &&
                eFilter(type)
                   
             ) return 1; 
   }
   if(type==OP_SELL){
      if(
            (SinLin0>0 || SinLin1>0)&& 
            SinLin0<0 && 
            eFilter(type)
            
             ) return -1;  
   }
   return 0;
}
int MACDfilter(int type){
   double SinLin0;

   SinLin0 = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
   
   if(type==OP_BUY){
      if(SinLin0>0) return 1; 
   }
   if(type==OP_SELL){
      if(SinLin0<0) return -1;  
   }
   return 0;
}
int myMA(int type){
   double MoveBack=3;  
   double hi=High[1];
   double lo=Low[1];
   
   double short0,short1,long0,long1, short2, long2;
   
   short0 = iMA(NULL,0,short_period,0,MODE_SMA,PRICE_CLOSE,0);
   short1 = iMA(NULL,0,short_period,0,MODE_SMA,PRICE_CLOSE,1);
   short2 = iMA(NULL,0,short_period,0,MODE_SMA,PRICE_CLOSE,2);
  

   long0=iMA(NULL,0,long_period,0,MODE_SMA,PRICE_CLOSE,0);    
   long1=iMA(NULL,0,long_period,0,MODE_SMA,PRICE_CLOSE,1);
   long2=iMA(NULL,0,long_period,0,MODE_SMA,PRICE_CLOSE,2);
   
 

   
   if(type==OP_BUY){
      if(
               (short2<long2 || short1<long1)&& 
                short0>long0 &&
                eFilter(type)&&
                MACDfilter(type)&&
               iClose(Symbol(), 0, 0)>long0
                   
             ) return 1; 
   }
   if(type==OP_SELL){
      if(
            (short2>long2 || short1>long1)&& 
            short0<long0 && 
            eFilter(type)&&
            MACDfilter(type)&&
            iClose(Symbol(), 0, 0)<long0
            
             ) return -1;  
   }
   return 0;
}
int eFilter(int type){
   if(EMA(3)>EMA(5)
         &&EMA(5)>EMA(8)
            &&EMA(8)>EMA(10)
               &&EMA(10)>EMA(12)
                  &&EMA(12)>EMA(15)
                    && type ==OP_BUY
      ) return 1;
      
   if(EMA(3)<EMA(5)
         &&EMA(5)<EMA(8)
            &&EMA(8)<EMA(10)
               &&EMA(10)<EMA(12)
                  &&EMA(12)<EMA(15)
                    &&type== OP_SELL
      ) return 1;
   
   return 0;
}



double EMA(int n){
   return iMA(0,0,n,0,MODE_EMA,PRICE_CLOSE,0);
}





