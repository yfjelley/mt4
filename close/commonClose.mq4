void forceClose(int type, string common){
   while(allLots(type)) {closeAll(type, common);RefreshRates();Sleep(10);}
   return;
}
   
void closeAll(int type, string common, int mag =  Mag1){  
   if(common=="") iDrawSign("Text",Bid,clrRed,0,"com is null!",12);
   for(int i=0;i<OrdersTotal();i++){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      //只平仓手动做单
      //if(OrderMagicNumber()!=mag){
         if(OrderType() == type) close(type, OrderTicket(), OrderLots(), common); 
      //}                                                                           
   }
   return;
}


bool filter(int type){
   double ma0 = iMA(NULL,0,5,0,mode,PRICE_CLOSE,0);
   double price_median = (High[0]+Low[0]+Open[0])/3;
   if(type == OP_BUY && price_median>ma0 ) return True;
   if(type == OP_SELL && price_median<ma0 ) return True;
   
   return False;
}

void close(int type, int tiket, double lot, string com){
   if(com=="") iDrawSign("Text",Bid,clrRed,0,"com is null!",12);
   double price;
   

   if(OrderSelect(tiket, SELECT_BY_TICKET)==false) return;
   
   for(cnt=0 ;cnt<10; cnt++){
      RefreshRates();
      
      price = Ask;
   
      if(type == OP_BUY) price = Bid; 
    
      if(OrderClose(tiket,lot,price,sliper,clrBlue)){
         iDrawSign("Text",price,clrRed,0,com,12);
         break;
      }

      else if(GetLastError()==4108) return ;
      else{
         Print("Order Close error ",GetLastError());
         Sleep(10);              
      }      
   };

}
