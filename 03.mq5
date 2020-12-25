//+------------------------------------------------------------------+
//|                                                           03.mq5 |
//|                                                          Mostafa |
//|                                              mostafaramezani.com |
//+------------------------------------------------------------------+
#property copyright "Mostafa"
#property link      "https://github.com/forexit"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\SignalTRIX.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingParabolicSAR.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedRisk.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title                 = "03";       // Document name
ulong                    Expert_MagicNumber           = 9921;       //
bool                     Expert_EveryTick             = false;      //
//--- inputs for main signal
input int                Signal_ThresholdOpen         = 10;         // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose        = 10;         // Signal threshold value to close [0...100]
input double             Signal_PriceLevel            = 0.0;        // Price level to execute a deal
input double             Signal_StopLevel             = 50.0;       // Stop Loss level (in points)
input double             Signal_TakeLevel             = 50.0;       // Take Profit level (in points)
input int                Signal_Expiration            = 4;          // Expiration of pending orders (in bars)
input int                Signal_TriX_PeriodTriX       = 20;         // Triple Exponential Average Period of calculation
input ENUM_APPLIED_PRICE Signal_TriX_Applied          = PRICE_CLOSE; // Triple Exponential Average Prices series
input double             Signal_TriX_Weight           = 1.0;        // Triple Exponential Average Weight [0...1.0]
//--- inputs for trailing
input double             Trailing_ParabolicSAR_Step   = 0.02;       // Speed increment
input double             Trailing_ParabolicSAR_Maximum = 0.2;       // Maximum rate
//--- inputs for money
input double             Money_FixRisk_Percent        = 10.0;       // Risk percentage
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(), Period(), Expert_EveryTick, Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__ + ": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Creating signal
   CExpertSignal *signal = new CExpertSignal;
   if(signal == NULL)
     {
      //--- failed
      printf(__FUNCTION__ + ": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ExtExpert.InitSignal(signal);
   signal.ThresholdOpen(Signal_ThresholdOpen);
   signal.ThresholdClose(Signal_ThresholdClose);
   signal.PriceLevel(Signal_PriceLevel);
   signal.StopLevel(Signal_StopLevel);
   signal.TakeLevel(Signal_TakeLevel);
   signal.Expiration(Signal_Expiration);
//--- Creating filter CSignalTriX
   CSignalTriX *filter0 = new CSignalTriX;
   if(filter0 == NULL)
     {
      //--- failed
      printf(__FUNCTION__ + ": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.PeriodTriX(Signal_TriX_PeriodTriX);
   filter0.Applied(Signal_TriX_Applied);
   filter0.Weight(Signal_TriX_Weight);
//--- Creation of trailing object
   CTrailingPSAR *trailing = new CTrailingPSAR;
   if(trailing == NULL)
     {
      //--- failed
      printf(__FUNCTION__ + ": error creating trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__ + ": error initializing trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set trailing parameters
   trailing.Step(Trailing_ParabolicSAR_Step);
   trailing.Maximum(Trailing_ParabolicSAR_Maximum);
//--- Creation of money object
   CMoneyFixedRisk *money = new CMoneyFixedRisk;
   if(money == NULL)
     {
      //--- failed
      printf(__FUNCTION__ + ": error creating money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__ + ": error initializing money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set money parameters
   money.Percent(Money_FixRisk_Percent);
//--- Check all trading objects parameters
   if(!ExtExpert.ValidationSettings())
     {
      //--- failed
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__ + ": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
