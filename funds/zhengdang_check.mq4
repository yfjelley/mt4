
int zhengdang_buy(){
   double v = 0.2*atr();
   int t1=0,t2=0,t3=0,t4=0; 
   
   if(ma(NULL, 20, 0) - ma(NULL, 20, 2)<v
         && ma(NULL, 8, 0) - ma(NULL, 8, 2)<v
            && ma(NULL, 50, 0) - ma(NULL, 50, 2)<v
              ) t1=1;
   
   if(ma(NULL, 20, 0) - ma(NULL, 20, 2)
         + ma(NULL, 8, 0) - ma(NULL, 8, 2)
            + ma(NULL, 50, 0) - ma(NULL, 50, 2)<1.5*v
              ) t1=1;
   
   
   if((ma(NULL, 8, 2) < ma(NULL, 8, 0) && ma(NULL, 20, 2) < ma(NULL, 20, 0) && ma(NULL,50, 2) < ma(NULL, 50, 0))
       &&(ma(NULL, 8, 0) > ma(NULL, 20, 0) && ma(NULL, 20, 0) > ma(NULL, 50, 0))) t2=1;
  
  //三均线多头排列      
   if(ma(NULL, 8, 0) > ma(NULL, 20, 0)) t3=1;
   
   //三均线纠缠
   if((ma(NULL, 8, 0) - ma(NULL, 20, 0) + 
         ma(NULL, 20, 0) - ma(NULL, 50, 0)+
           ma(NULL, 8, 0) - ma(NULL, 50, 0)
         ) < v) t4 =1;
   
   
  //禁止多     
  if(t1==1&&(t2==0)) return 1;   
  if(t3==0)return 3;
  if(t4==1)return 4;

  return 0;
}

int zhengdang_sell(){
   double v = 0.2*atr();
   int t1=0,t2=0,t3=0,t4=0;   
   
   if(ma(NULL, 20, 2) - ma(NULL, 20, 0)<v
         && ma(NULL, 8, 2) - ma(NULL, 8, 0)<v
            && ma(NULL, 50, 2) - ma(NULL, 50, 0)<v
              ) t1=1;
              
  if(ma(NULL, 20, 2) - ma(NULL, 20, 0)
         + ma(NULL, 8, 2) - ma(NULL, 8, 0)
            + ma(NULL, 50, 2) - ma(NULL, 50, 0)<1.5*v
              ) t1=1;
       //三均线向下      
  if((ma(NULL, 8, 2) > ma(NULL, 8, 0) && ma(NULL, 20, 2) > ma(NULL, 20, 0) && ma(NULL,50, 2) > ma(NULL, 50, 0))
       &&(ma(NULL, 8, 0) < ma(NULL, 20, 0) && ma(NULL, 20, 0) < ma(NULL, 50, 0))) t2=1;     
       
    //三均线多头排列      
  if(ma(NULL, 8, 0) < ma(NULL, 20, 0)) t3=1;  
  
     //三均线纠缠
   if((ma(NULL, 50, 0) - ma(NULL, 20, 0) + 
         ma(NULL, 20, 0) - ma(NULL, 8, 0)+
           ma(NULL, 50, 0) - ma(NULL, 8, 0)
         ) < v) t4 =1;
      

   //禁止多     
  if(t1==1&&(t2==0)) return 2;     
  if(t3==0) return 3;
  if(t4==1) return 4;


  return 0;
}
//+--------------手动交易安全性检测---------------------------------------+
//1.上根k线收阳且收线大于ma8和ma20
//2.布林带开口
//

void zhengdangCheck(){
   bool close = False; 
   for(int i=0;i<OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      if(filter(OrderType())) return;
      int type = OrderType(); 
      if(type==OP_BUY){  
         if(zhengdang_buy()>0){         
            comment = "zhengdang"+zhengdang_buy();
            close = True;
         }  
 
      }

      else if(type==OP_SELL){
      
         if(zhengdang_sell()>0){
            comment = "zhengdang"+zhengdang_sell(); 
            close = True;
         }          
      }
      if(filter(type)) return;
      if(close) forceClose(type, comment);
      
   }

   return;
}

