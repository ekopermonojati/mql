#property copyright   "R Eko Permono Jati"
#property link        "-"
#property description "Moving Average + RSI + STOC + Martingle Advisor"

#define MAGICMA  20131111
//--- Inputs
input double Lots          =0.1;
input bool   AllowBuy      =true;
input bool   AllowSell     =false;
input double TakeProfit1   =35;
input double TakeProfit2   =75;
input double TakeProfit3   =100;
input double Steps         =200;
input double OrderSlippage  =20;

input int                MA_period          = 150;                        // MA period
input int                MA_shift           = 0;                          // MA shift
input ENUM_MA_METHOD     MA_method          = MODE_SMA;                   // MA method
input ENUM_APPLIED_PRICE MA_applied_price   = PRICE_CLOSE;                // MA applied price
input int                RSI_period         = 3;                          // RSi period
input ENUM_APPLIED_PRICE RSI_applied_price  = PRICE_CLOSE;                // RSi applied price
input int                RSI_up_level       = 80;                         // level up - RSi 
input int                RSI_dn_level       = 20;                         // level down - RSi 
input int                STh_K_period       = 6;                          // K period
input int                STh_D_period       = 3;                          // D period
input int                STh_slowing        = 3;                          // slowing
input ENUM_MA_METHOD     STh_method         = MODE_SMA;                   // Stochastic method
input int                STh_price_field    = 0;                          // 0 - Low/High; 1 - Close/Close
input int                STh_up_level       = 70;                         // level up - Stochastic
input int                STh_dn_level       = 30;                         // level down - Stochastic

struct totalProfitStruct
{
   double   BuyProfit;
   int      BuyTotal;
   double   SellProfit;
   int      SellTotal;
   double   NettProfit;
};

totalProfitStruct totalProfit={0.0,0,0.0,0,0.0};

//+------------------------------------------------------------------+
//| Calculate open positions                                         |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
  {
   int buys=0,sells=0;
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }
//--- return orders volume
   if(buys>0) return(buys);
   else       return(-sells);
  }
  
//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   double lot=Lots;
   return(lot);
  }
  
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
   int    res;
//--- go trading only for first tiks of new bar
   if(Volume[0]>1) return;
//--- get MACD
   double _ma      = iMA        (Symbol(), 0, MA_period, MA_shift, MA_method, MA_applied_price, 0);
   double _rsi     = iRSI       (Symbol(), 0, RSI_period, RSI_applied_price, 0);
   double _STh_0_0 = iStochastic(Symbol(), 0, STh_K_period, STh_D_period, STh_slowing, STh_method, STh_price_field, 0, 0);
   double _STh_1_0 = iStochastic(Symbol(), 0, STh_K_period, STh_D_period, STh_slowing, STh_method, STh_price_field, 1, 0);
   
//--- sell conditions
   if(AllowSell==true && totalProfit.SellTotal ==0 && Ask<_ma && _rsi>RSI_up_level && (_STh_0_0>STh_up_level && _STh_1_0>STh_up_level))
   //if(AllowSell==true && totalProfit.SellTotal ==0 && Ask<_ma && _rsi>RSI_up_level )
     
     {
      if (OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,OrderSlippage,0,0,"",MAGICMA,0,Red)){
         res=OrderSend(Symbol(),OP_SELLLIMIT,LotsOptimized(),Bid+(Point*Steps*1),OrderSlippage,0,0,"",MAGICMA,0,Red);
         res=OrderSend(Symbol(),OP_SELLLIMIT,LotsOptimized(),Bid+(Point*Steps*3),OrderSlippage,0,0,"",MAGICMA,0,Red);
         res=OrderSend(Symbol(),OP_SELLLIMIT,LotsOptimized()*1.5,Bid+(Point*Steps*7),OrderSlippage,0,0,"",MAGICMA,0,Red);
         res=OrderSend(Symbol(),OP_SELLLIMIT,LotsOptimized()*2,Bid+(Point*Steps*15),OrderSlippage,0,0,"",MAGICMA,0,Red);
         res=OrderSend(Symbol(),OP_SELLLIMIT,LotsOptimized()*2.5,Bid+(Point*Steps*31),OrderSlippage,0,0,"",MAGICMA,0,Red);
      } else {
         Print("OrderOpen error " + Symbol(),GetLastError()); 
         }
      return;
     }
//--- buy conditions
   if(AllowBuy==true && totalProfit.BuyTotal==0 && Bid>_ma && _rsi<RSI_dn_level && (_STh_0_0<STh_dn_level && _STh_1_0<STh_dn_level))
   //if(AllowBuy==true && totalProfit.BuyTotal==0 && Bid>_ma && _rsi<RSI_dn_level)
     {
      if (OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,OrderSlippage,0,0,"",MAGICMA,0,Blue)){
         res=OrderSend(Symbol(),OP_BUYLIMIT,LotsOptimized(),Ask-(Point*Steps*1),OrderSlippage,0,0,"",MAGICMA,0,Blue);
         res=OrderSend(Symbol(),OP_BUYLIMIT,LotsOptimized(),Ask-(Point*Steps*3),OrderSlippage,0,0,"",MAGICMA,0,Blue);
         res=OrderSend(Symbol(),OP_BUYLIMIT,LotsOptimized()*1.5,Ask-(Point*Steps*7),OrderSlippage,0,0,"",MAGICMA,0,Blue);
         res=OrderSend(Symbol(),OP_BUYLIMIT,LotsOptimized()*2,Ask-(Point*Steps*15),OrderSlippage,0,0,"",MAGICMA,0,Blue);
         res=OrderSend(Symbol(),OP_BUYLIMIT,LotsOptimized()*2.5,Ask-(Point*Steps*31),OrderSlippage,0,0,"",MAGICMA,0,Blue);
      } else {
         Print("OrderOpen error " + Symbol() ,GetLastError()); 
         }
      return;
     }
//---
  }


//Calculate Order Profit
double CheckForProfit() {
   totalProfitStruct totalProfitTemp = {0.0,0,0.0,0,0.0};
   for(int i=0;i<OrdersTotal();i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
      {
         totalProfitTemp.NettProfit += OrderProfit();
         if(OrderType()==OP_BUY) {
            totalProfitTemp.BuyProfit+=OrderProfit();
            totalProfitTemp.BuyTotal+=1;
         }
         if(OrderType()==OP_SELL) {
            totalProfitTemp.SellProfit+=OrderProfit();
            totalProfitTemp.SellTotal+=1;
         }
      }  
   }
   totalProfit = totalProfitTemp;
   //Print("Profit:",totalProfit.BuyProfit);
   return totalProfitTemp.NettProfit;
}

void CheckForClose(){
   if (OrdersTotal()==0) return;
   double BuyProfitTarget=TakeProfit1,SellProfitTarget = TakeProfit1;
  
   //calculate profit target
   if (totalProfit.BuyTotal==4) BuyProfitTarget=TakeProfit2;
   if (totalProfit.SellTotal==4) SellProfitTarget=TakeProfit2;
   if (totalProfit.BuyTotal>=5) BuyProfitTarget=TakeProfit3;
   if (totalProfit.SellTotal>=5) SellProfitTarget=TakeProfit3;
   
   //close sell order if profit
   if(totalProfit.SellProfit>SellProfitTarget){
      for(int i=OrdersTotal()-1; i >=0; i--){ //for(int i=0;i<OrdersTotal();i++){
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
         {
            if(OrderType()==OP_SELL)
              {
                  if(!OrderClose(OrderTicket(),OrderLots(),Ask,OrderSlippage,White))
                     Print("OrderClose error " + Symbol(),GetLastError()); 
              }
            if (OrderType()==OP_SELLLIMIT)
               {
                  OrderDelete(OrderTicket());
               }
         } 
      }
   }
   
   //close buy order if profit
   if(totalProfit.BuyProfit>BuyProfitTarget){
      for(int j=OrdersTotal()-1; j >=0; j--){ //for(int i=0;i<OrdersTotal();i++){
         if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)==false) break;
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
         {
            //--- check order type 
            if(OrderType()==OP_BUY)
              {
                  if(!OrderClose(OrderTicket(),OrderLots(),Bid,OrderSlippage,White))
                     Print("OrderClose error " + Symbol(),GetLastError());
              }
            if (OrderType()==OP_BUYLIMIT)
               {
                  OrderDelete(OrderTicket());
               }
         } 
      }
   }
}

void showLabel(){
   ObjectCreate("lbl_profit", OBJ_LABEL, 0, 0, 0);
   ObjectSet("lbl_profit", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSet("lbl_profit", OBJPROP_XDISTANCE, 30);
   ObjectSet("lbl_profit", OBJPROP_YDISTANCE, 30);
   ObjectSetText("lbl_profit", "Nett Profit : "+ DoubleToStr(totalProfit.NettProfit,4), 15, "Arial", Blue);
   
   ObjectCreate("lbl_buyprofit", OBJ_LABEL, 0, 0, 0);
   ObjectSet("lbl_buyprofit", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSet("lbl_buyprofit", OBJPROP_XDISTANCE, 30);
   ObjectSet("lbl_buyprofit", OBJPROP_YDISTANCE, 60);
   ObjectSetText("lbl_buyprofit", "Buy Profit : "+ DoubleToStr(totalProfit.BuyProfit,4), 15, "Arial", Blue);
   
   ObjectCreate("lbl_sellprofit", OBJ_LABEL, 0, 0, 0);
   ObjectSet("lbl_sellprofit", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSet("lbl_sellprofit", OBJPROP_XDISTANCE, 30);
   ObjectSet("lbl_sellprofit", OBJPROP_YDISTANCE, 90);
   ObjectSetText("lbl_sellprofit", "Sell Profit : "+ DoubleToStr(totalProfit.SellProfit,4), 15, "Arial", Blue);
}

//+------------------------------------------------------------------+
//| OnTick function                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false)
      return;

   CheckForOpen();
   CheckForProfit();
   CheckForClose();
   showLabel();
   
   //if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();
   //else                                    CheckForClose();
//---
  }
//+------------------------------------------------------------------+

