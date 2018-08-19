#include "tb_atrclose.mq4"
#include "tb_supportclose.mq4"
#include "tb_macdclose.mq4"
#include "tb_emaclose.mq4"
#include "tb_maclose.mq4"
#include "tb_higlowclose.mq4"
void tb_close(){  
   TB_macd_close();   
   if(iVolume(Symbol(),0,0)>2)return ; 
   TB_atr_close();
   TB_support_close(); 
   TB_ema_close();
   TB_ma_close();
   TB_higlow_close();
}
