bool gubikong(int tf,int t1,int t2,int t3){
   if(ema(tf, t1, 0)<=ema(tf, t2, 0)&&ema(tf, t2, 0)<=ema(tf, t3, 0))  return True;
   return False;
}

bool gubiduo(int tf,int t1,int t2,int t3){

   if(ema(tf, t1, 0)>=ema(tf, t2, 0)&&ema(tf, t2, 0)>=ema(tf, t3, 0))  return True;
   return False;
}

bool gubiduankong(int tf=NULL){
   if(gubikong(tf=NULL, 3, 5, 8)&&gubikong(tf=NULL, 10, 13, 15)) return True;
   return False;
}

bool gubiduanduo(int tf=NULL){
   
   if(gubiduo(tf=NULL, 3, 5, 8)&&gubiduo(tf=NULL, 10, 13, 15)) return True;
   return False;
}

bool gubichangkong(int tf=NULL){
   if(gubikong(tf=NULL, 26, 30, 35)&&gubikong(tf=NULL, 40, 45,50)) return True;
   return False;
}

bool gubichangduo(int tf=NULL){
   //Print("cchang",gubiduo(tf=NULL, 26, 30, 35),gubiduo(tf=NULL, 40, 45, 50));
   if(gubiduo(tf=NULL, 26, 30, 35)&&gubiduo(tf=NULL, 40, 45, 50)) return True;
   return False;
}



void GubiCheck(){
   double ma5 = ma(NULL,5, 0);
   double ma10 = ma(NULL,10, 0);
   
   for(int i=0;i<OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      if(TimeCurrent()-OrderOpenTime()>30) continue;
      int tf;
      if(OrderType()==OP_BUY){
         if((Low[0]+High[0])*0.5>ma5) return; 
        
         //if(!gubichangduo(tf=15)) close(OrderType(),OrderTicket(),OrderLots(),"gubichangduo15");    
         //if(!gubichangduo(tf=30)) close(OrderType(),OrderTicket(),OrderLots(),"gubichangduo30"); 
         if(gubichangduo(tf=60)) return;
         //else if(!gubichangduo(tf=240)) close(OrderType(),OrderTicket(),OrderLots(),"gubichangduo240");
         
         //if(!gubiduanduo(tf=15)) close(OrderType(),OrderTicket(),OrderLots(),"gubiduo15!");   
         //else if(!gubiduanduo(tf=30)) close(OrderType(),OrderTicket(),OrderLots(),"gubiduo30!");
         if(gubiduanduo(tf=60)) return;
         //else if(!gubiduanduo(tf=240)) close(OrderType(),OrderTicket(),OrderLots(),"gubiduo240!");
         close(OrderType(),OrderTicket(),OrderLots(),"gubichangduo60");             
      }
      if(OrderType()==OP_SELL){ 
         if((Low[0]+High[0])*0.5<ma5) return;  
         
         //if(!gubiduankong(tf=15)) close(OrderType(),OrderTicket(),OrderLots(),"gubiduankong15!");    
         //if(!gubiduankong(tf=30)) close(OrderType(),OrderTicket(),OrderLots(),"gubiduankong30!"); 
         if(gubiduankong(tf=60)) return;
         //if(!gubiduankong(tf=240)) close(OrderType(),OrderTicket(),OrderLots(),"gubiduankong240!");    
         
         //else if(!gubichangkong(tf=15)) close(OrderType(),OrderTicket(),OrderLots(),"gubichangkong15!");    
         //else if(!gubichangkong(tf=30)) close(OrderType(),OrderTicket(),OrderLots(),"gubichangkong30!"); 
         if(gubichangkong(tf=60)) return;
         //else if(!gubichangkong(tf=240)) close(OrderType(),OrderTicket(),OrderLots(),"gubichangkong240!");
         close(OrderType(),OrderTicket(),OrderLots(),"gubiduankong60!");       
        
      }
      
   }

   return;
}   
