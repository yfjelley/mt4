#define Mag1  20166666

input double Lots =0.05;
input int rate=1;//开仓比例，每1000美金的开仓数为0.05*rate
input int sliper=6;

input double DecreaseFactor=3;

int SpreadSampleSize = 10;  
double Spread[1];

string comment;
bool isClose = False;


input int long_period = 50;
input int short_period = 8;

int AtrTimeFrame=48;

color TextColor=clrFireBrick;
color bColor=clrFireBrick;
extern bool closeAllShortcut=false;
extern bool isfund_check = True;
//均线模式
int mode = MODE_SMA;


//(此时间帧内一根柱线的秒数, 对于 М15 等于 60 с х 15 = 900 с)
int delta = 900*4;//1小时
datetime Time_open=delta;
//(柱线开盘时间, 首次入场)
datetime Time_bar = 0;

int cnt;
string TextBarString,DotBarString,HLineBarString,VLineBarString; 

double atr(int tf=0){
   double atr0 = iATR(NULL, tf, AtrTimeFrame,0);
   double atr1 = iATR(NULL, tf, AtrTimeFrame/8,0);
   double atr = (0.5*atr0+0.5*atr1);
   if(atr0/PointValue()<10) atr = 10*PointValue();
   return NormalizeDouble(atr,Digits);
}


//布林上轨
double upper(int tf=0, int dev=10, int index=0){
   double up;
   up = iBands(NULL,tf,20,dev,0,PRICE_CLOSE,MODE_UPPER,0);
   return NormalizeDouble(up,Digits);
}

//布林下轨
double lower(int tf=0, int dev=10 , int index=0){
   double low;
   low = iBands(NULL,tf,20,dev,0,PRICE_CLOSE,MODE_LOWER,0);
   return NormalizeDouble(low,Digits);
}


//跟踪止损设置
double TrailStop = 1.5*atr(); 

double atrD(){
   return iATR(NULL,1440,10,0);
}
double adx(){
   return iADX(Symbol(),0,21,PRICE_TYPICAL,MODE_MAIN,0);
}

double diverge(int timeframe, int num){
   double std,ma;
   ma = iMA(NULL,timeframe,num,0,mode,PRICE_CLOSE,0);
   std = iStdDev(NULL,0,timeframe,num,mode,PRICE_CLOSE,0);
   if(std) return NormalizeDouble(MathAbs((Ask+Bid)/2-ma)/std, Digits);
   return 0.0;

}
int barCount(datetime StartTime){
   int StartPoint=iBarShift(NULL,0,StartTime,True);
   return(StartPoint+1);
}

bool newBar(int timeframe){
   if(iVolume(Symbol(),timeframe,0)>1)return False;
   return True;
}

double ma(int timeframe, int period, int index =0){
   return iMA(NULL, timeframe, period, 0, mode,PRICE_CLOSE, index);
}

double ema(int timeframe, int period, int index =0){
   return iMA(NULL, timeframe, period, 0, MODE_EMA,PRICE_CLOSE, index);
}

int macdTrend(){
   double main,single;
   main = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   single = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
   if (single>0 && main>single) return 1;
   if (single<0 && main<single) return -1;
   return 0;
}

//趋势
int myTrend(int timeframe=0){
   double short0, long0;    
   short0 = iMA(NULL, timeframe, short_period, 0, mode,PRICE_CLOSE, 0);
   long0 =iMA(NULL, timeframe, long_period, 0, mode,PRICE_CLOSE, 0); 
    
   if(short0 < long0) return -1; 
  
   if(short0 > long0) return 1; 

   return 0;
}

double Spread(double AddValue=0){
   double LastValue;
   static double ArrayTotal=0;
   
   if (AddValue == 0 && SpreadSampleSize <= 0) return(Ask-Bid);
   if (AddValue == 0 && ArrayTotal == 0) return(Ask-Bid);
   if (AddValue == 0 ) return(ArrayTotal/ArraySize(Spread));
   
   ArrayTotal = ArrayTotal + AddValue;
   ArraySetAsSeries(Spread, true); 
   if (ArraySize(Spread) == SpreadSampleSize)
      {
      LastValue = Spread[0];
      ArrayTotal = ArrayTotal - LastValue;
      ArraySetAsSeries(Spread, false);
      ArrayResize(Spread, ArraySize(Spread)-1 );
      ArraySetAsSeries(Spread, true);
      ArrayResize(Spread, ArraySize(Spread)+1 ); 
      }
   else ArrayResize(Spread, ArraySize(Spread)+1 ); 
//   Print("ArraySize = ",ArraySize(lSpread)," AddedNo. = ",AddValue);
   ArraySetAsSeries(Spread, false);
   Spread[0] = AddValue;
   return(NormalizeDouble(ArrayTotal/ArraySize(Spread), Digits));
}

double PointValue() {
   if (MarketInfo(Symbol(), MODE_DIGITS) == 5.0 || MarketInfo(Symbol(), MODE_DIGITS) == 3.0) return (10.0 * Point);
   if (MarketInfo(Symbol(), MODE_DIGITS) == 2.0) return (10.0 * Point);//Gold
   return (Point);
}

/*
函    数：在屏幕上显示文字标签
输入参数：string LableName 标签名称，如果显示多个文本，名称不能相同
          string LableDoc 文本内容
          int Corner 文本显示角
          int LableX 标签X位置坐标
          int LableY 标签Y位置坐标
          int DocSize 文本字号
          string DocStyle 文本字体
          color DocColor 文本颜色
输出参数：在指定的位置（X,Y）按照指定的字号、字体及颜色显示指定的文本
算法说明：
*/
void iDisplayInfo(string LableName,string LableDoc,int Corner,int LableX,int LableY,int DocSize,string DocStyle,color DocColor)
   {
      if (Corner == -1) return;
      ObjectCreate(LableName, OBJ_LABEL, 0, 0, 0);
      ObjectSetText(LableName, LableDoc, DocSize, DocStyle,DocColor);
      ObjectSet(LableName, OBJPROP_CORNER, Corner);
      ObjectSet(LableName, OBJPROP_XDISTANCE, LableX);
      ObjectSet(LableName, OBJPROP_YDISTANCE, LableY);
      return;
   }
/*
函    数：两点间连线(主图)
输入参数：string myLineName  线段名称
          int myFirstTime  起点时间
          int myFirstPrice  起点价格
          int mySecondTime  终点时间
          int mySecondPrice  终点价格
          int myLineStyle  线型 0-实线 1-断线 2-点线 3-点划线 4-双点划线
          color myLineColor 线色
输出参数：在指定的两点间连线
算法说明：
*/
void iTwoPointsLine(string myLineName,int myFirstTime,double myFirstPrice,int mySecondTime,double mySecondPrice,int myLineStyle,color myLineColor)
   {
      ObjectCreate(myLineName,OBJ_TREND,0,myFirstTime,myFirstPrice,mySecondTime,mySecondPrice);//确定两点坐标
      ObjectSet(myLineName,OBJPROP_STYLE,myLineStyle); //线型
      ObjectSet(myLineName,OBJPROP_COLOR,myLineColor); //线色
      ObjectSet(myLineName,OBJPROP_WIDTH, 1); //线宽
      ObjectSet(myLineName,OBJPROP_BACK,false);
      ObjectSet(myLineName,OBJPROP_RAY,false);
      return;
   }
   
/*
函    数：标注符号和画线、文字
参数说明：string myType 标注类型：Dot画点、HLine画水平线、VLine画垂直线、myString显示文字
          int myBarPos 指定蜡烛坐标
          double myPrice 指定价格坐标
          color myColor 符号颜色
          int mySymbol 符号代码，108为圆点
          string myString 文字内容，在指定的蜡烛位置显示文字
函数返回：在指定的蜡烛和价格位置标注符号或者画水平线、垂直线
*/
void iDrawSign(string myType,double myPrice,color myColor,int mySymbol,string myString,int myDocSize)
      {
         if (myType=="Text")
            {
               TextBarString=myType+Time[iBarShift(Symbol(),0,TimeCurrent())];
               ObjectCreate(TextBarString,OBJ_TEXT,0,Time[iBarShift(Symbol(),0,TimeCurrent())],myPrice);
               ObjectSet(TextBarString,OBJPROP_COLOR,myColor);//颜色
               ObjectSet(TextBarString,OBJPROP_FONTSIZE,myDocSize);//大小
               ObjectSetText(TextBarString,myString);//文字内容
               ObjectSet(TextBarString,OBJPROP_BACK,true);
            }
         if (myType=="Dot")
            {
               DotBarString=myType+Time[iBarShift(Symbol(),0,TimeCurrent())];
               ObjectCreate(DotBarString,OBJ_ARROW,0,Time[iBarShift(Symbol(),0,TimeCurrent())],myPrice);
               ObjectSet(DotBarString,OBJPROP_COLOR,myColor);
               ObjectSet(DotBarString,OBJPROP_ARROWCODE,mySymbol);
               ObjectSet(DotBarString,OBJPROP_BACK,false);
            }
         if (myType=="HLine")
            {
               HLineBarString=myType+Time[iBarShift(Symbol(),0,TimeCurrent())];
               ObjectCreate(HLineBarString,OBJ_HLINE,0,Time[iBarShift(Symbol(),0,TimeCurrent())],myPrice);
               ObjectSet(HLineBarString,OBJPROP_COLOR,myColor);
               ObjectSet(HLineBarString,OBJPROP_BACK,false);
            }
         if (myType=="VLine")
            {
               VLineBarString=myType+Time[iBarShift(Symbol(),0,TimeCurrent())];
               ObjectCreate(VLineBarString,OBJ_VLINE,0,Time[iBarShift(Symbol(),0,TimeCurrent())],myPrice);
               ObjectSet(VLineBarString,OBJPROP_COLOR,myColor);
               ObjectSet(VLineBarString,OBJPROP_BACK,false);
            }
        return;
     }
     
     
void button(string name,color yanse,int x,int y,string text,int changdu=0,color clr=clrDarkGray)
  {
   ObjectCreate(0,name,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_COLOR,yanse);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   if(changdu==0)
    {
      int as=StringLen(text);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,as*16);
    }
   else
    {
      ObjectSetInteger(0,name,OBJPROP_XSIZE,changdu);
    }
   ObjectSetInteger(0,name,OBJPROP_YSIZE,30);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,clrRed);//OBJPROP_COLOR clrYellow  OBJPROP_BORDER_COLOR   OBJPROP_COLOR  OBJPROP_LEVELCOLOR
  // ObjectSetInteger(0,name,OBJPROP_CORNER,0);
  }