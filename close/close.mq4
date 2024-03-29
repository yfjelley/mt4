#include "commonClose.mq4"
#include "tb_close.mq4"

void close(){  

   //atrCloseMain();
   profitClose();
   //atrClose();
  
   tb_close(); 
   if(iVolume(Symbol(),0,0)>1)return ;
   //xkClose();
   //atrCloseOther(); 
}

void profitClose(){      
   comment = "profitClose";
   if(profitStop(OP_SELL)) forceClose(OP_SELL, comment);                              
   if(profitStop(OP_BUY)) forceClose(OP_BUY, comment);   
}



bool profitStop(int type){
   double stop ;   
   if(type==OP_BUY){
      //多单止盈
      stop = upper(0, 20);
      //多单止盈 PointValue()为了避免报错
      if((stop - ma(NULL, 50, 0))>TrailStop && Bid>stop) return True;
      //bid大于ema3+2atr
      if(Bid>(ema(NULL,3,0)+TrailStop)) return True;
    }
      
   if(type==OP_SELL){
      //空单止盈
      stop = lower(0, 20);      
      //空单止盈
      if(ma(NULL, 50, 0)-stop>TrailStop && Ask<stop) return True;
      //bid大于ema3+2atr
      if(Ask<(ema(NULL,3,0)-TrailStop)) return True;
    }
   return False;
}

void atrClose(){      
   comment = "atrClose";
   if(atrStop(OP_SELL)) forceClose(OP_SELL, comment);                              
   if(atrStop(OP_BUY)) forceClose(OP_BUY, comment);   
}
bool atrStop(int type){   
   if(type==OP_BUY){
      //bid大于ema3+2atr
      if(Bid>(ema(NULL,3,0)+2*atr())) return True;
      if(Bid>(ema(NULL,5,0)+3*atr())) return True;
      if(Bid>(ema(NULL,8,0)+3.6*atr())) return True;
      if(Bid>(ema(NULL,10,0)+4*atr())) return True;
      if(Bid>(ema(NULL,13,0)+4.2*atr())) return True;
      if(Bid>(ema(NULL,15,0)+4.4*atr())) return True;
      if(Bid>(ema(NULL,20,0)+4.8*atr())) return True;
      if(Bid>(ema(NULL,26,0)+5*atr())) return True;
    }
   if(type==OP_SELL){
      if(Ask<(ema(NULL,3,0)-2*atr())) return True;
      if(Ask<(ema(NULL,5,0)-3*atr())) return True;
      if(Ask<(ema(NULL,8,0)-3.6*atr())) return True;
      if(Ask<(ema(NULL,10,0)-4*atr())) return True;
      if(Ask<(ema(NULL,13,0)-4.2*atr())) return True;
      if(Ask<(ema(NULL,15,0)-4.4*atr())) return True;
      if(Ask<(ema(NULL,20,0)-4.8*atr())) return True;
       if(Ask<(ema(NULL,26,0)-5*atr())) return True;
    }
   return False;
}

void xkClose(){      
   comment = "xkClose";
   if(xuankongstop(OP_SELL)) forceClose(OP_SELL, comment);                              
   if(xuankongstop(OP_BUY)) forceClose(OP_BUY, comment);   
}

bool xuankongstop(int type){   
   if(type==OP_BUY){
      if(Low[1]>upper(0,2,1)&&High[1]>upper(0,2,1))return True;
    }
   if(type==OP_SELL){
      if(Low[1]<lower(0,2,1)&&High[1]<lower(0,2,1))return True;
    }
   return False;
}




