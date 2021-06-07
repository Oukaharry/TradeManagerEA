//+------------------------------------------------------------------+
//|                                                    EA 102112.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, www.ballerquotes.com."
#property link      "https://www.mql5.com"
#property version   "2.0"
#property strict

#include <stdlib.mqh>

int ErrCode;

int Magic       = 489753; 
string EA_Name  = "TradeManagerEA";

string to_split = "";
string sep  = ",";                
ushort u_sep;                  
string Result[];       

static datetime lastupd = 0;

        
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---  
     EventSetTimer(1);
     func_WebRequest_post();  
     DisplayPanel();
     Draw_TP1_SL1();
     PartialClose();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
    //ObjectsDeleteAll();   
  }
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
    if(TimeCurrent()-lastupd >= 60*60*12)
      {   
         func_WebRequest_post();   
         lastupd = TimeCurrent();      
      } 
  }
//+------------------------------------------------------------------+
void OnTimer()
   {
      SLSettings();
      TPSettings();
      Draw_TP1_SL1();
      DrawOtherLines();
      DeleteIdleLines();
      PartialClose();  
   }
//+------------------------------------------------------------------+
void DisplayPanel() {

    int OffsetVertical_1 = 20;
    int OffsetHorizontal_1 = 10;

    const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER; // chart corner for anchoring 
    
    const int              width = 240;
    int                    height = 165;
    const color            back_clr=C'16,16,16';
    const color            clr=C'64,64,64';
    const ENUM_BORDER_TYPE border=BORDER_FLAT;
    const ENUM_LINE_STYLE  style=STYLE_SOLID;
    const int              line_width=1;        
    const bool             back=false;
    const bool             selection=false;
    const long             z_order=0;

    int LabelCorner_1 = CORNER_LEFT_UPPER;

    ObjectCreate( "xx_backOfPanel", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSet("xx_backOfPanel",OBJPROP_XDISTANCE,1); 
    ObjectSet("xx_backOfPanel",OBJPROP_YDISTANCE,1); 
    ObjectSet("xx_backOfPanel",OBJPROP_XSIZE,width); 
    ObjectSet("xx_backOfPanel",OBJPROP_YSIZE,height); 
    ObjectSet("xx_backOfPanel",OBJPROP_BGCOLOR,back_clr); 
    ObjectSet("xx_backOfPanel",OBJPROP_BORDER_TYPE,border); 
    ObjectSet("xx_backOfPanel",OBJPROP_CORNER,LabelCorner_1); 
    ObjectSet("xx_backOfPanel",OBJPROP_COLOR,clr); 
    ObjectSet("xx_backOfPanel",OBJPROP_STYLE,style); 
    ObjectSet("xx_backOfPanel",OBJPROP_WIDTH,line_width); 
    ObjectSet("xx_backOfPanel",OBJPROP_BACK,back); 
    ObjectSet("xx_backOfPanel",OBJPROP_SELECTABLE,selection); 
    ObjectSet("xx_backOfPanel",OBJPROP_SELECTED,selection); 
    ObjectSet("xx_backOfPanel",OBJPROP_HIDDEN,true); 
    ObjectSet("xx_backOfPanel",OBJPROP_ZORDER,z_order);

                
    ObjectCreate("xx_line1", OBJ_LABEL, 0, 0, 0);
    ObjectSet("xx_line1", OBJPROP_CORNER, LabelCorner_1);
    ObjectSet("xx_line1", OBJPROP_YDISTANCE, OffsetVertical_1 + 0);
    ObjectSet("xx_line1", OBJPROP_XDISTANCE, OffsetHorizontal_1);
    ObjectSet("xx_line1", OBJPROP_HIDDEN, true);
    ObjectSetText("xx_line1", "TradeManager- "+ Symbol(), 9, "Tahoma", clrWhite);

    ObjectCreate("xx_linec", OBJ_LABEL, 0, 0, 0);
    ObjectSet("xx_linec", OBJPROP_CORNER, LabelCorner_1);
    ObjectSet("xx_linec", OBJPROP_YDISTANCE, OffsetVertical_1 + 15);
    ObjectSet("xx_linec", OBJPROP_XDISTANCE, OffsetHorizontal_1);
    ObjectSet("xx_linec", OBJPROP_HIDDEN, true);
    ObjectSetText("xx_linec", "www.blueedgefinancial.com", 8, "Tahoma", clrWhite);
    
    PutButton("Min",230,OffsetVertical_1,10,10,"-",clrRed,clrWhite); 
    PutButton("Trades",160,OffsetVertical_1 + 125,56,20,"Trades",clrBlue,clrWhite); 
    
    createObject("SELL"  ,OBJ_BUTTON,10,50,75,45,clrWhite,clrRed,clrWhite,true,"SELL",8,"Arial Black");
    createObject("Lotet" ,OBJ_EDIT,90,50,50,45,clrBlack,clrWhite,clrLightSlateGray,true,"0.01",12,"Arial");
    createObject("BUY"   ,OBJ_BUTTON,145,50,72,45,clrWhite,clrBlue,clrWhite,true,"BUY",8, "Arial Black");
   
    createObject("SELLStopLimit",OBJ_BUTTON,10,100,65,30,clrWhite,clrRed,clrWhite,true,"Stop/LIMIT",8,"Arial Black");
    createObject("PriceEt" ,OBJ_EDIT,80,100,65,30,clrBlack,clrWhite,clrLightSlateGray,true,DoubleToStr(Ask + 30*point(), Digits),9,"Arial");
    createObject("BUYStopLimit",OBJ_BUTTON,150,100,65,30,clrWhite,clrBlue,clrWhite,true,"Stop/LIMIT",8,"Arial Black");
}
//+------------------------------------------------------------------+
void SLSettings()
  {
      string nameclass = "";
      string name      = ""; 
      string maxname   = "";
      long type; 
      long selected;
      double price;
      int VerticalOffset = 0;
      int HorizontalOffset = 0;
      
      //--for hlines
      long time;
      double hlineprice;
      
      //--For pop up
      string heading;
      string close;
      string action; 
      string done; 
      string lots; 
      string actionc;
      string backpanel; 
      string des;
      int count;
      string tocut;
      
         
     //-------settings buttons
       for(int i = 0; i < OrdersTotal(); i++)
           {
              if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
              if(OrderSymbol()==Symbol() && OrderMagicNumber() == Magic)
                {
                   nameclass       = (string)OrderOpenPrice()+"SL";
                   price = OrderOpenPrice();
                   count = StringLen((string)OrderOpenPrice());
                   
                   for(int k = 0; k < ObjectsTotal(); k++)
                      {
                          name = ObjectName(k);
                          type = ObjectGetInteger(0,name,OBJPROP_TYPE);
                          selected = ObjectGetInteger(0,name,OBJPROP_SELECTED);
                          maxname = name+"MAX";
                          
                          heading = "Heading" + (string)price;
                          close  = "CloseLots" + (string)price;
                          action = "Action" + (string)price; 
                          done = "Done" + (string)price; 
                          lots = "LotsC" + (string)price; 
                          actionc = "ActionC" + (string)price;
                          backpanel = "xx_backOfPanel_p" + (string)price; 
                          
                          if(StringFind(name,nameclass) >= 0 && type == OBJ_HLINE && selected == false)
                             {
                                des = ObjectGetString(0,name,OBJPROP_TEXT);
                                
                                if(des == "" && ObjectFind(backpanel) < 0)
                                   {
                                      tocut = StringSubstr(name,count);
                                      time         = ObjectGetInteger(0,name,OBJPROP_TIME);
                                      hlineprice   = ObjectGetDouble(0,name,OBJPROP_PRICE);
                                      PopUpMenu(price,clrRed);
                                   }
                             }
                      }
                  }
         }
  }
//+------------------------------------------------------------------+
void TPSettings()
  {
      string nameclass = "";
      string name      = ""; 
      string maxname   = "";
      long type; 
      long selected;
      double price;
      int VerticalOffset = 0;
      int HorizontalOffset = 0;
      
      //--for hlines
      long time;
      double hlineprice;
      
      //--For pop up
      string heading;
      string close;
      string action; 
      string done; 
      string lots; 
      string actionc;
      string backpanel; 
      string des;
      int count;
      string tocut;
      
         
     //-------settings buttons
       for(int i = 0; i < OrdersTotal(); i++)
           {
              if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
              if(OrderSymbol()==Symbol() && OrderMagicNumber() == Magic)
                {
                   nameclass       = (string)OrderOpenPrice()+"TP";
                   price = OrderOpenPrice();
                   count = StringLen((string)OrderOpenPrice());
                   
                   for(int k = 0; k < ObjectsTotal(); k++)
                      {
                          name = ObjectName(k);
                          type = ObjectGetInteger(0,name,OBJPROP_TYPE);
                          selected = ObjectGetInteger(0,name,OBJPROP_SELECTED);
                          maxname = name+"MAX";
                          
                          heading = "Heading" + (string)price;
                          close  = "CloseLots" + (string)price;
                          action = "Action" + (string)price; 
                          done = "Done" + (string)price; 
                          lots = "LotsC" + (string)price; 
                          actionc = "ActionC" + (string)price;
                          backpanel = "xx_backOfPanel_p" + (string)price; 
                          
                          if(StringFind(name,nameclass) >= 0 && type == OBJ_HLINE && selected == false)
                             {
                                des = ObjectGetString(0,name,OBJPROP_TEXT);
                                if(selected == false && des == "" && ObjectFind(backpanel) < 0)
                                   {
                                      time         = ObjectGetInteger(0,name,OBJPROP_TIME);
                                      hlineprice   = ObjectGetDouble(0,name,OBJPROP_PRICE);
                                      ChartTimePriceToXY(0,0,TimeCurrent(),hlineprice,HorizontalOffset,VerticalOffset);
                                      tocut = StringSubstr(name,count);
                                      PopUpMenu(price,clrGreen);
                                   }
                             }
                      }
                  }
         }
  }
//+------------------------------------------------------------------+
void PopUpMenu(double price, int headclr,int Mode = 0) {
    const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER; // chart corner for anchoring 
    
    int                    width = 120;
    int                    height = 120;
    const color            back_clr=clrBlack;
    const color            clr=C'64,64,64';
    const ENUM_BORDER_TYPE border=BORDER_FLAT;
    const ENUM_LINE_STYLE  style=STYLE_SOLID;
    const int              line_width=1;        
    const bool             back=false;
    const bool             selection=false;
    const long             z_order=0;

    int LabelCorner_1 = CORNER_LEFT_UPPER;
     
    int OffsetVertical_1 = 150;
    int OffsetHorizontal_1 = 300;
    
    if(Mode == 1)
      {
         height = 135;
      }
    
    string backpanel = "xx_backOfPanel_p" + (string)price; 
    
    ObjectCreate(backpanel,OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSet(backpanel,OBJPROP_XDISTANCE,OffsetHorizontal_1); //x distance
    ObjectSet(backpanel,OBJPROP_YDISTANCE,OffsetVertical_1); // y distance
    ObjectSet(backpanel,OBJPROP_XSIZE,width); 
    ObjectSet(backpanel,OBJPROP_YSIZE,height); 
    ObjectSet(backpanel,OBJPROP_BGCOLOR,back_clr); 
    ObjectSet(backpanel,OBJPROP_BORDER_TYPE,border); 
    ObjectSet(backpanel,OBJPROP_CORNER,LabelCorner_1); 
    ObjectSet(backpanel,OBJPROP_COLOR,clr); 
    ObjectSet(backpanel,OBJPROP_STYLE,style); 
    ObjectSet(backpanel,OBJPROP_WIDTH,line_width); 
    ObjectSet(backpanel,OBJPROP_BACK,back); 
    ObjectSet(backpanel,OBJPROP_SELECTABLE,selection); 
    ObjectSet(backpanel,OBJPROP_SELECTED,selection); 
    ObjectSet(backpanel,OBJPROP_HIDDEN,true); 
    ObjectSet(backpanel,OBJPROP_ZORDER,z_order);
    
    //heading
    
    string heading = "Heading" + (string)price;
    string close  = "CloseLots" + (string)price;
    string action = "Action" + (string)price; 
    string done = "Done" + (string)price; 
    string lots = "LotsC" + (string)price; 
    string actionc = "ActionC" + (string)price;
    string lotsadd = "LotsAdd" + (string)price;
    string lotsedit = "LotsEdit" + (string)price;
    static string toclose = "";
   
    if(Mode == 0)
       {
          createObject(heading,OBJ_BUTTON,OffsetHorizontal_1+20,OffsetVertical_1+4,75,20,clrWhite,headclr,clrWhite,true,"Settings",7,"Arial Black"); 
          createObject(close,OBJ_BUTTON,OffsetHorizontal_1+10,OffsetVertical_1+30,50,20,clrWhite,clrBlue,clrWhite,true,"Close%",7,"Arial Black");  
          createObject(action,OBJ_BUTTON,OffsetHorizontal_1+10,OffsetVertical_1+54,50,20,clrWhite,clrBlue,clrWhite,true,"Action",7,"Arial Black");
          createObject(done,OBJ_BUTTON,OffsetHorizontal_1+45,OffsetVertical_1+84,30,20,clrWhite,clrRed,clrWhite,true,"Done",7,"Arial Black");
          createObject(lots,OBJ_EDIT,OffsetHorizontal_1+65,OffsetVertical_1+30,50,20,clrBlack,clrWhite,clrLightSlateGray,true,"",7,"Arial");
          createObject(actionc,OBJ_BUTTON,OffsetHorizontal_1+65,OffsetVertical_1+55,50,20,clrWhite,clrGreen,clrLightSlateGray,true,"Nothing",7,"Arial");
       }
    if(Mode == 1)
       {
          createObject(heading,OBJ_BUTTON,OffsetHorizontal_1+20,OffsetVertical_1+4,75,20,clrWhite,headclr,clrWhite,true,"Settings",7,"Arial Black"); 
          createObject(close,OBJ_BUTTON,OffsetHorizontal_1+10,OffsetVertical_1+30,50,20,clrWhite,clrBlue,clrWhite,true,"Close%",7,"Arial Black");
          createObject(lots,OBJ_EDIT,OffsetHorizontal_1+65,OffsetVertical_1+30,50,20,clrBlack,clrWhite,clrLightSlateGray,true,toclose,7,"Arial");  
          createObject(action,OBJ_BUTTON,OffsetHorizontal_1+10,OffsetVertical_1+54,50,20,clrWhite,clrBlue,clrWhite,true,"Action",7,"Arial Black");
          createObject(actionc,OBJ_BUTTON,OffsetHorizontal_1+65,OffsetVertical_1+55,50,20,clrWhite,clrGreen,clrLightSlateGray,true,"AddLots",7,"Arial");
          createObject(lotsadd,OBJ_BUTTON,OffsetHorizontal_1+10,OffsetVertical_1+79,50,20,clrWhite,clrBlue,clrWhite,true,"Add-Lots",7,"Arial Black");
          createObject(lotsedit,OBJ_EDIT,OffsetHorizontal_1+65,OffsetVertical_1+79,50,20,clrBlack,clrWhite,clrLightSlateGray,true,"",7,"Arial");
          createObject(done,OBJ_BUTTON,OffsetHorizontal_1+45,OffsetVertical_1+105,30,20,clrWhite,clrRed,clrWhite,true,"Done",7,"Arial Black");
       }
    if(Mode == 2)
      {
         toclose = ObjectGetString(0,lots,OBJPROP_TEXT);
         ObjectDelete(backpanel);
         ObjectDelete(heading);
         ObjectDelete(close);
         ObjectDelete(action);
         ObjectDelete(done);
         ObjectDelete(lots);
         ObjectDelete(actionc);
      }
}
//+------------------------------------------------------------------+
void Options(long y, long x,string txt, string txt2 = "") {
    const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER; // chart corner for anchoring 
    
    const int              width = 70;
    int                    height = 60;
    const color            back_clr=clrBlack;
    const color            clr=C'64,64,64';
    const ENUM_BORDER_TYPE border=BORDER_FLAT;
    const ENUM_LINE_STYLE  style=STYLE_SOLID;
    const int              line_width=1;        
    const bool             back=false;
    const bool             selection=false;
    const long             z_order=0;

    int LabelCorner_1 = CORNER_LEFT_UPPER;
     
    int OffsetVertical_1 = (int)y;
    int OffsetHorizontal_1 = (int)x + 5;
    
    string Display = "";
    
    //heading
    createObject("NothingS",OBJ_BUTTON,OffsetHorizontal_1,OffsetVertical_1,90,20,clrWhite,clrGreen,clrWhite,true,"Nothing",7,"Arial Black"); 
    OffsetVertical_1 = OffsetVertical_1+20;
     if(txt == "SLtoBE")
       {
          Display = "Move SL to BE";
       }
    createObject(txt,OBJ_BUTTON,OffsetHorizontal_1,OffsetVertical_1,90,20,clrWhite,clrGreen,clrWhite,true,Display,7,"Arial Black"); 
    
    if(txt2 != "")
       {
         OffsetVertical_1 = OffsetVertical_1+20;
         if(txt2 == "SLtoPreviousTP")
            {
              Display = "SL to Previous TP";
            }
         createObject(txt2,OBJ_BUTTON,OffsetHorizontal_1,OffsetVertical_1,90,20,clrWhite,clrGreen,clrWhite,true,Display,7,"Arial Black");   
       }
  }
//+------------------------------------------------------------------+
void TradesDisplay() {
    int count = 0;
    string name_a = "";
    string name_b = "";
    string text_a   = "";
    string text_b   = "";
    int    X_Distance = 0;
    int    Y_Distance = 170;  
    
    PutButton("Numbers",120,170,70,30,"OrderTicket",clrBlue,clrWhite); 
    PutButton("Prices",190,170,70,30,"OpenPrice",clrBlue,clrWhite); 
    
    for(int i = 0; i < OrdersTotal(); i++)
      {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
         if(OrderSymbol()==Symbol() && OrderMagicNumber() == Magic)
           {
              count = count + 1;
              name_a = (string)count + "a";
              name_b = (string)count + "b";
              text_a = (string)OrderTicket();
              text_b = (string)OrderOpenPrice();
              Y_Distance = Y_Distance + 30;
              PutButton(name_a,120,Y_Distance,70,30,text_a,clrWhite,clrBlack); 
              PutButton(name_b,190,Y_Distance,70,30,text_b,clrWhite,clrBlack); 
              
              text_b = text_b + "Settings";
              PutButton(text_b,260,Y_Distance,45,30,"Settings",clrGreen,clrBlack); 
           }
      }   
    
}
//-----------------------------------------------------------------------------------------------------------+
void createObject ( string nameObj, 
                    ENUM_OBJECT eNUM_OBJECT,
                    int XDISTANCE, 
                    int YDISTANCE, 
                    int XSIZE,
                    int YSIZE,
                    color  oBJPROP_COLOR, 
                    color  oBJPROP_BGCOLOR, 
                    color  oBJPROP_BORDER_COLOR,
                    bool isText, 
                    string Text, 
                    int oBJPROP_FONTSIZE, 
                    string font, 
                    int corner=CORNER_LEFT_UPPER)
                   {
    
    ObjectCreate     (0,nameObj, eNUM_OBJECT, 0, 0, 0);
    ObjectSetInteger (0,nameObj, OBJPROP_XDISTANCE, XDISTANCE);
    ObjectSetInteger (0,nameObj, OBJPROP_YDISTANCE, YDISTANCE);
    ObjectSetInteger (0,nameObj, OBJPROP_XSIZE, XSIZE);
    ObjectSetInteger (0,nameObj, OBJPROP_YSIZE, YSIZE);
    ObjectSetString  (0,nameObj, OBJPROP_FONT, font);
    ObjectSetInteger (0,nameObj, OBJPROP_FONTSIZE, oBJPROP_FONTSIZE);
    ObjectSetInteger (0,nameObj, OBJPROP_COLOR, oBJPROP_COLOR);
    ObjectSetInteger (0,nameObj, OBJPROP_BGCOLOR, oBJPROP_BGCOLOR);
    ObjectSetInteger (0,nameObj, OBJPROP_BORDER_COLOR, oBJPROP_BORDER_COLOR);
    ObjectSetInteger (0,nameObj, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger (0,nameObj, OBJPROP_BACK, false);
    ObjectSetInteger (0,nameObj, OBJPROP_HIDDEN, true);
    ObjectSetInteger (0,nameObj, OBJPROP_STATE, false);
    ObjectSetInteger (0,nameObj, OBJPROP_SELECTABLE, false);
    ObjectSetInteger (0,nameObj, OBJPROP_CORNER, corner);
    if (corner==CORNER_RIGHT_LOWER)
     ObjectSetInteger (0,nameObj, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
    else
     ObjectSetInteger (0,nameObj, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
    
    if (isText) ObjectSetString  (0, nameObj, OBJPROP_TEXT,Text);
}

//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
  string name_tp_class = "";
  string name_sl_class = "";
  
  int tpcount = 0;
  int slcount = 0;
  
  if (id == CHARTEVENT_OBJECT_ENDEDIT) 
   {
     string clickedChartObject = sparam;
     if (clickedChartObject == "Lotet") 
      {
       ObjectSetString(0,"Lotet", OBJPROP_TEXT,DoubleToStr(StringToDouble(ObjectGetString(0,"Lotet",OBJPROP_TEXT)),2));
      }
     if (clickedChartObject == "PriceEt") 
      {
       ObjectSetString(0,"PriceEt", OBJPROP_TEXT,DoubleToStr(StringToDouble(ObjectGetString(0,"PriceEt",OBJPROP_TEXT)),_Digits));
      }
   }
  if(id == CHARTEVENT_OBJECT_CLICK)
     {
        string clickedChartObject = sparam;
        if(clickedChartObject == "Min")
          {
             ObjectsDeleteAll();
             PutButton("Max",230,20,10,10,"+",clrGreen,clrWhite);  
          }   
        if(clickedChartObject == "Max")
          {
             DisplayPanel(); 
          }
        if(clickedChartObject == "Trades")
          {
             long clr = ObjectGetInteger(0,"Trades",OBJPROP_BGCOLOR);
             string name_a = "";
             string name_b = "";
             int    count  = 0;
             
             if(clr == clrBlue)
                {
                  if(ActiveTrades() == 0)
                     {
                       PutButton("None",120,170,140,30,"No Trades Active",clrWhite,clrBlack); 
                     }
                  else
                     {
                        TradesDisplay(); 
                     }
                  ObjectSetInteger(0,"Trades",OBJPROP_BGCOLOR,clrRed);
                }
             if(clr == clrRed)
               {
                 ObjectDelete("None");
                 ObjectDelete("Numbers");
                 ObjectDelete("Prices");
                 
                 for(int i = 0; i < OrdersTotal(); i++)
                  {
                     if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
                     if(OrderSymbol()==Symbol() && OrderMagicNumber() == Magic)
                       {
                          count = count + 1;
                          name_a = (string)count + "a";
                          name_b = (string)count + "b";
                          
                          string tp     = (string)OrderOpenPrice()+"tps";
                          string sl     = (string)OrderOpenPrice()+"sls";
                          string price  = (string)OrderOpenPrice()+"price";
                          string lots   = (string)OrderOpenPrice()+"lots";
                          string action = (string)OrderOpenPrice()+"action";
                          
                          ObjectDelete(name_a);
                          ObjectDelete(name_b);
                          ObjectDelete(tp);
                          ObjectDelete(price);
                          ObjectDelete(lots);
                          ObjectDelete(action);
                          
                          name_a = (string)OrderOpenPrice() + "Settings";
                          
                          ObjectDelete(name_a);
                          
                          string nameclass = (string)OrderOpenPrice();
                          long type;
                          for(int k = 0; k < ObjectsTotal(); k++)
                            {
                              type = ObjectGetInteger(0,ObjectName(k),OBJPROP_TYPE);
                              if((StringFind(ObjectName(k),nameclass) >= 0&& type != OBJ_HLINE))
                                 {
                                    ObjectDelete(ObjectName(k));
                                     k--;
                                 }
                            } 
                       }
                  }  
                 ObjectSetInteger(0,"Trades",OBJPROP_BGCOLOR,clrBlue);
               }
          }
          
        if(clickedChartObject == "SELL")
          {
             double lt = StringToDouble(ObjectGetString(0,"Lotet",OBJPROP_TEXT));
             SELL(lt); 
          }
        if(clickedChartObject == "BUY")
          {
             double lt = StringToDouble(ObjectGetString(0,"Lotet",OBJPROP_TEXT));
             BUY(lt);
          }
        if(clickedChartObject == "SELLStopLimit")
          {
             double price = StringToDouble(ObjectGetString(0,"PriceEt",OBJPROP_TEXT));
             double lot = StringToDouble(ObjectGetString(0,"Lotet",OBJPROP_TEXT));
        
              if(price > Bid)
                 {
                    SELLLIMIT(lot,price);
                 }
              else
                 {
                    SELLSTOP(lot,price);
                 }
          }
        if(clickedChartObject == "BUYStopLimit")
          {
             double price = StringToDouble(ObjectGetString(0,"PriceEt",OBJPROP_TEXT));
             double lot   = StringToDouble(ObjectGetString(0,"Lotet",OBJPROP_TEXT));
              
              if(price > Ask)
                 {
                    BUYSTOP(lot,price);
                 }
              else
                 {
                    BUYLIMIT(lot,price);
                 }
          }
          
       string name;
       long clr;
       long  type;
       
       string tp     = "";
       string sl     = "";
       string price  = "";
       string lots   = "";
       string action = "";
       
       string text_tp     = "";
       string text_price  = "";
       string text_lots   = "";
       string text_action = "";
       
       string tp_class = "";
       string sl_class = "";
       
       string tp_buttons = "";
       string price_buttons = "";
       string lots_buttons = "";
       string action_buttons = "";
       
       int    X_Distance = 320;
       int    Y_Distance = 200;
       
       u_sep = StringGetCharacter(sep,0); 
       int m;
      
       int count = 0;  
       
       //-------settings buttons
       for(int i = 0; i < OrdersTotal(); i++)
           {
              if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
              if(OrderSymbol()==Symbol() && OrderMagicNumber() == Magic)
                {
                   name       = (string)OrderOpenPrice()+"Settings";
                   clr        = ObjectGetInteger(0,name,OBJPROP_BGCOLOR);
                   Y_Distance = (int)ObjectGetInteger(0,name,OBJPROP_YDISTANCE);
                   
                   tp     = (string)OrderOpenPrice()+"tps";
                   sl     = (string)OrderOpenPrice()+"sls";
                   price  = (string)OrderOpenPrice()+"price";
                   lots   = (string)OrderOpenPrice()+"lots";
                   action = (string)OrderOpenPrice()+"action";
                   
                   tp_class  = (string)OrderOpenPrice() + "TP";
                   sl_class  = (string)OrderOpenPrice() + "SL";
                   
                   tp_buttons      = (string)OrderOpenPrice() + "tps";
                   price_buttons   = (string)OrderOpenPrice() + "price";
                   lots_buttons    = (string)OrderOpenPrice() + "lots";
                   action_buttons  = (string)OrderOpenPrice() + "action";

                   if(clickedChartObject == name)
                     {
                       if(clr == clrGreen)
                          { 
                            text_tp       = "TPs";
                            text_price    = "Price";
                            text_lots     = "Lots";
                            text_action   = "Action";
                            
                            PutButton(tp,X_Distance,Y_Distance,70,30,text_tp,clrBlue,clrWhite); 
                            X_Distance = X_Distance + 70;
                            PutButton(price,X_Distance,Y_Distance,70,30,text_price,clrBlue,clrWhite); 
                            X_Distance = X_Distance + 70;
                            PutButton(lots,X_Distance,Y_Distance,70,30,text_lots,clrBlue,clrWhite); 
                            X_Distance = X_Distance + 70;
                            PutButton(action,X_Distance,Y_Distance,70,30,text_action,clrBlue,clrWhite); 
                          
                            for(int k = 0; k < ObjectsTotal(); k++)
                             {
                              if(StringFind(ObjectName(k),tp_class) >= 0 && ObjectGetInteger(0,ObjectName(k),OBJPROP_SELECTED) == false)
                                 {
                                    count    = count + 1;
                                    tp       = tp + (string)count;
                                    price    = price +(string)count;
                                    lots     = lots + (string)count;
                                    action   = action + (string)count;
                                    to_split = ObjectDescription(ObjectName(k));
                                                                        
                                    m = StringSplit(to_split,u_sep,Result); 
                                    
                                    text_tp       = "TP" + (string)count;
                                    text_price    = DoubleToString(ObjectGetDouble(0,ObjectName(k),OBJPROP_PRICE),Digits);
                                    
                                    if(to_split == "")
                                       {
                                          text_lots     = "No data";
                                          text_action   = "No data";
                                       }
                                    if(to_split != "")
                                       {
                                          text_lots     = Result[0];
                                          text_action   = Result[1];
                                       }
                                    
                                    Y_Distance  = Y_Distance + 30;
                                    X_Distance = 320;
                                    PutButton(tp,X_Distance,Y_Distance,70,30,text_tp,clrWhite,clrBlack);
                                    X_Distance = X_Distance + 70;
                                    PutButton(price,X_Distance,Y_Distance,70,30,text_price,clrWhite,clrBlack);
                                    X_Distance = X_Distance + 70;
                                    PutButton(lots,X_Distance,Y_Distance,70,30,text_lots,clrWhite,clrBlack); 
                                    X_Distance = X_Distance + 70;
                                    PutButton(action,X_Distance,Y_Distance,70,30,text_action,clrWhite,clrBlack); 
                                 }
                            }
                            count = 0;
                            for(int s = 0; s < ObjectsTotal(); s++)
                             {
                              if(StringFind(ObjectName(s),sl_class) >= 0 && ObjectGetInteger(0,ObjectName(s),OBJPROP_SELECTED) == false)
                                 {
                                    count    = count + 1;
                                    tp       = tp + (string)count+"sl";
                                    price    = price +(string)count+"sl";
                                    lots     = lots + (string)count+"sl";
                                    action   = action + (string)count+"sl";
                                    to_split = ObjectDescription(ObjectName(s));
                                                                        
                                    m = StringSplit(to_split,u_sep,Result); 
                                    
                                    text_tp       = "SL" + (string)count;
                                    text_price    = DoubleToString(ObjectGetDouble(0,ObjectName(s),OBJPROP_PRICE),Digits);
                                    
                                    if(to_split == "")
                                       {
                                          text_lots     = "No data";
                                          text_action   = "No data";
                                       }
                                    if(to_split != "")
                                       {
                                          text_lots     = Result[0];
                                          text_action   = Result[1];
                                       }
                                    
                                    Y_Distance  = Y_Distance + 30;
                                    X_Distance = 320;
                                    PutButton(tp,X_Distance,Y_Distance,70,30,text_tp,clrWhite,clrBlack);
                                    X_Distance = X_Distance + 70;
                                    PutButton(price,X_Distance,Y_Distance,70,30,text_price,clrWhite,clrBlack);
                                    X_Distance = X_Distance + 70;
                                    PutButton(lots,X_Distance,Y_Distance,70,30,text_lots,clrWhite,clrBlack); 
                                    X_Distance = X_Distance + 70;
                                    PutButton(action,X_Distance,Y_Distance,70,30,text_action,clrWhite,clrBlack); 
                                 }
                            }
                            ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrRed);
                          }
                       if(clr == clrRed)
                          {
                            text_tp       = "TPs";
                            text_price    = "Price";
                            text_lots     = "Lots";
                            text_action   = "Action";
                            type          = ObjectGetInteger(0,name,OBJPROP_TYPE);
                          
                            ObjectDelete(tp);
                            ObjectDelete(price);
                            ObjectDelete(lots);
                            ObjectDelete(action);
                          
                            for(int k = 0; k < ObjectsTotal(); k++)
                             {
                              if((StringFind(ObjectName(k),tp_buttons) >= 0 || 
                                  StringFind(ObjectName(k),price_buttons) >= 0 ||
                                  StringFind(ObjectName(k),lots_buttons) >= 0 ||
                                   StringFind(ObjectName(k),action_buttons) >= 0))
                                 {
                                   ObjectDelete(ObjectName(k));
                                   k--;
                                 }
                             }
                            ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrGreen);
                          }
                     }
                }
           }
           
        //--For pop up
        string heading;
        string close;
        string actionPopUp; 
        string done; 
        string lotsPopUp; 
        string actionc;
        string lotsadd;
        string lotsedit;
        string backpanel; 
        double pricePopUp;
        string hname;
        string des;
        bool   selected;
        string deslots;
        string desaction;
        string desaddlots;
        string descr;
        long Type;
        long y;
        long x;
        long xsize;
        int colr;
        int clrheading;
        
        for(int i = 0; i <= OrdersTotal(); i++)
           {
              if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
              if(OrderSymbol()==Symbol() && OrderMagicNumber() == Magic)
                 {
                    pricePopUp = OrderOpenPrice();
                    heading = "Heading" + (string)pricePopUp;
                    close  = "CloseLots" + (string)pricePopUp;
                    actionPopUp = "Action" + (string)pricePopUp; 
                    done = "Done" + (string)pricePopUp; 
                    lotsPopUp = "LotsC" + (string)pricePopUp; 
                    actionc = "ActionC" + (string)pricePopUp;
                    lotsadd = "LotsAdd" + (string)pricePopUp;
                    lotsedit = "LotsEdit" + (string)pricePopUp;
                    backpanel = "xx_backOfPanel_p" + (string)pricePopUp;
                    
                    if(clickedChartObject == actionc)
                       {
                          y = ObjectGetInteger(0,actionc,OBJPROP_YDISTANCE);
                          x = ObjectGetInteger(0,actionc,OBJPROP_XDISTANCE);
                          xsize = ObjectGetInteger(0,actionc,OBJPROP_XSIZE);
                          colr = (int)ObjectGetInteger(0,actionc,OBJPROP_BGCOLOR);
                          clrheading = (int)ObjectGetInteger(0,heading,OBJPROP_BGCOLOR);;
                          
                          x = x + xsize;
                          
                          if(clrheading == clrGreen)
                             {
                                if(colr == clrGreen)
                                   {
                                     Options(y,x,"SLtoBE","SLtoPreviousTP");
                                     ObjectSetInteger(0,actionc,OBJPROP_BGCOLOR,clrRed);
                                   }
                                if(colr == clrRed)
                                   {
                                     ObjectDelete("NothingS");
                                     ObjectDelete("SLtoBE");
                                     ObjectDelete("SLtoPreviousTP");
                                     ObjectSetInteger(0,actionc,OBJPROP_BGCOLOR,clrGreen);
                                   }
                             }
                         if(clrheading == clrRed)
                             {
                                if(colr == clrGreen)
                                   {
                                     Options(y,x,"AddLots");
                                     ObjectSetInteger(0,actionc,OBJPROP_BGCOLOR,clrRed);
                                   }
                                if(colr == clrRed)
                                   {
                                     ObjectDelete("NothingS");
                                     ObjectDelete("AddLots");
                                     ObjectSetInteger(0,actionc,OBJPROP_BGCOLOR,clrGreen);
                                   }
                             }

                       }
                    if(clickedChartObject == "NothingS")
                       {
                          ObjectSetString(0,actionc,OBJPROP_TEXT,"Nothing");
                          ObjectSetInteger(0,actionc,OBJPROP_BGCOLOR,clrGreen);
                          ObjectDelete("NothingS");
                          ObjectDelete("AddLots");
                          ObjectDelete("SLtoBE");
                          ObjectDelete("SLtoPreviousTP");
                       }
                    if(clickedChartObject == "AddLots")
                       {
                          ObjectSetString(0,actionc,OBJPROP_TEXT,"AddLots");
                          ObjectSetInteger(0,actionc,OBJPROP_BGCOLOR,clrGreen);
                          ObjectDelete("NothingS");
                          ObjectDelete("AddLots");
                          PopUpMenu(pricePopUp,clrRed,2);
                          PopUpMenu(pricePopUp,clrRed,1);
                       }
                    if(clickedChartObject == "SLtoBE")
                       {
                          ObjectSetString(0,actionc,OBJPROP_TEXT,"SLtoBE");
                          ObjectSetInteger(0,actionc,OBJPROP_BGCOLOR,clrGreen);
                          ObjectDelete("NothingS");
                          ObjectDelete("SLtoBE");
                          ObjectDelete("SLtoPreviousTP");
                       }
                    if(clickedChartObject == "SLtoPreviousTP")
                       {
                          ObjectSetString(0,actionc,OBJPROP_TEXT,"SLtoPreviousTP");
                          ObjectSetInteger(0,actionc,OBJPROP_BGCOLOR,clrGreen);
                          ObjectDelete("NothingS");
                          ObjectDelete("SLtoBE");
                          ObjectDelete("SLtoPreviousTP");
                       }
                    if(clickedChartObject == done)
                       {
                           for(int k =0; k < ObjectsTotal(); k++)
                              {
                                 hname = ObjectName(k);
                                 selected = ObjectGetInteger(0,hname,OBJPROP_SELECTED);
                                 des = ObjectDescription(hname);
                                 Type = ObjectGetInteger(0,hname,OBJPROP_TYPE);
                                 
                                 if(Type == OBJ_HLINE && StringFind(hname,(string)pricePopUp) >= 0 && selected == false && des == "")
                                    {
                                       deslots    = ObjectDescription(lotsPopUp);
                                       desaction  = ObjectDescription(actionc);
                                       desaddlots = ObjectDescription(lotsedit);
                                       
                                       descr = deslots+","+desaction;
                                       
                                       if(desaddlots != "")
                                          {
                                             descr = descr + "," + desaddlots;
                                          }
                                       
                                       ObjectSetString(0,hname,OBJPROP_TEXT,descr);
                                    }
                              }
                           ObjectDelete(heading);
                           ObjectDelete(close);
                           ObjectDelete(actionPopUp);
                           ObjectDelete(done);
                           ObjectDelete(lotsPopUp);
                           ObjectDelete(actionc);
                           ObjectDelete(backpanel);
                           ObjectDelete("NothingS");
                           ObjectDelete("AddLots");
                           ObjectDelete(lotsadd);
                           ObjectDelete(lotsedit);
                           ObjectDelete("SLtoBE");
                           ObjectDelete("SLtoPreviousTP");
                       }
                 }
           }  
     }
}
//---------------------------------------------------------------------------++++
void Draw_TP1_SL1()
   {
      string name_tp = ""; 
      string name_sl = ""; 
       
      for(int i = 0; i < OrdersTotal(); i++)
         {
           if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
           if(OrderSymbol()==Symbol() && OrderMagicNumber() == Magic && OrderComment() == EA_Name)
             {
                name_tp = (string)OrderOpenPrice()+"TP1";
                name_sl = (string)OrderOpenPrice()+"SL1";
                
                if(ObjectFind(name_tp) < 0 && ObjectFind((string)OrderOpenPrice()+"TP2") < 0 && ObjectFind((string)OrderOpenPrice()+"TP3") < 0 && ObjectFind((string)OrderOpenPrice()+"TP4") < 0 )
                  {
                     if(OrderType() == OP_BUY)
                        {
                           HLine(name_tp,OrderOpenPrice() + (5 * point()),clrGreen,true,true);
                        }
                     if(OrderType() == OP_SELL)
                        {
                           HLine(name_tp,OrderOpenPrice() - (5 * point()),clrGreen,true,true);
                        }
                  }
                if(ObjectFind(name_sl) < 0 && ObjectFind((string)OrderOpenPrice()+"Sl2") < 0 && ObjectFind((string)OrderOpenPrice()+"SL3") < 0 && ObjectFind((string)OrderOpenPrice()+"Sl4") < 0 )
                  {
                     if(OrderType() == OP_BUY)
                        {
                           HLine(name_sl,OrderOpenPrice() - (5 * point()),clrRed,true,true);
                        }
                     if(OrderType() == OP_SELL)
                        {
                           HLine(name_sl,OrderOpenPrice() + (5 * point()),clrRed,true,true);
                        }
                  }
             }
         }
   }
//---------------------------------------------------------------------------++++
void DeleteIdleLines()
   {
     int count = 0;
     long type;
     string name;
     string comp;
     
     for(int i = 0; i < ObjectsTotal(); i++)
        {
           name = ObjectName(i);
           type = ObjectGetInteger(0,name,OBJPROP_TYPE);
           
           for(int k = 0; k < OrdersTotal(); k++)
              {
                 if(OrderSelect(k,SELECT_BY_POS,MODE_TRADES)==false) break;
                 if(OrderSymbol()==Symbol() && OrderMagicNumber() == Magic)
                   {
                     comp = (string)OrderOpenPrice();
                     
                     if(StringFind(name,comp) >= 0 || StringFind(name,OrderComment()) >= 0)
                        {
                           count = count + 1;
                        }
                   }
              }
           if(count == 0 && type == OBJ_HLINE)
              {
                 ObjectDelete(name);
              }
           count = 0;
        }
   }
//---------------------------------------------------------------------------++++
void DrawOtherLines()
   {
      string name_tp            = ""; 
      string name_sl            = ""; 
      string name_sl_class      = "";
      string name_tp_class      = "";
      int    tpcount           = 0;
      int    tpnewcount        = 0;
      int    slcount          = 0;
      int    slnewcount       = 0;
      bool   tpselected         = true;
      bool   slselected         = true;
      double price              = 0;
      int    objecttype         = -1;
       
      for(int i = 0; i < OrdersTotal(); i++)
         {
           if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
           if(OrderSymbol()==Symbol() && OrderMagicNumber() == Magic)
             {
                tpcount = 0;
                tpnewcount = 0;
                slcount    = 0;
                slnewcount = 0;
                
                name_tp_class = (string)OrderOpenPrice() + "TP";
                name_sl_class = (string)OrderOpenPrice() + "SL";
                
                for(int k = 0; k < ObjectsTotal(); k++)
                  {
                     if(StringFind(ObjectName(k),name_tp_class) >= 0)
                        {
                           tpcount    = tpcount + 1;
                           tpnewcount = tpcount + 1;
                        }
                     if(StringFind(ObjectName(k),name_sl_class) >= 0)
                        {
                           slcount    = slcount + 1;
                           slnewcount = slcount + 1;
                        }
                  }
                name_tp  = (string)OrderOpenPrice() + "TP" +(string)tpcount;
                name_sl  = (string)OrderOpenPrice() + "SL" +(string)slcount;
                
                slselected = ObjectGetInteger(0,name_sl,OBJPROP_SELECTED); 
                tpselected = ObjectGetInteger(0,name_tp,OBJPROP_SELECTED);
                 
                //Alert(OrderTicket(), "\nSL: " , slselected, "\nTP: ", tpselected);
                if(ObjectFind(name_tp) >= 0 && tpselected == false)
                  {
                     price = ObjectGetDouble(0,name_tp,OBJPROP_PRICE);
                     name_tp = (string)OrderOpenPrice() + "TP" +(string)tpnewcount;
                     if(ObjectFind(name_tp) < 0)
                        {
                          HLine(name_tp,price,clrGreen,true,true);
                        }
                  }
                if(ObjectFind(name_sl) >= 0 && slselected == false)
                  {
                     price = ObjectGetDouble(0,name_sl,OBJPROP_PRICE);
                     name_sl = (string)OrderOpenPrice() + "SL" +(string)slnewcount;
                     if(ObjectFind(name_sl) < 0)
                        {
                           HLine(name_sl,price,clrRed,true,true);
                        }
                  }
             }
         }
   }
//---------------------------------------------------------------------------++++
void PutButton(string name,int w,int h,int xsize, int ysize, string text, color bgcolor, color txtColor)
  {
   ObjectCreate(0,name,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,w);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,h);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,xsize);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,ysize);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,"Tahoma");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,name,OBJPROP_COLOR,txtColor);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bgcolor);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,clrLightGray);
  }
//+------------------------------------------------------------------+
void HLine(string name,double price, color clr, bool selectable, bool selected)
   {
      if(!ObjectCreate(0,name,OBJ_HLINE,0,0,price)) 
        { 
         Print(__FUNCTION__, 
               ": failed to create a horizontal line! Error code = ",ErrorDescription(GetLastError())); 
         return; 
        } 
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr); 
      ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DASHDOT); 
      ObjectSetInteger(0,name,OBJPROP_WIDTH,1); 
      ObjectSetInteger(0,name,OBJPROP_BACK,false); 
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,selectable); 
      ObjectSetInteger(0,name,OBJPROP_SELECTED,selected); 
      ObjectSetInteger(0,name,OBJPROP_ZORDER,0); 
   }
//+------------------------------------------------------------------+
void SELL(double lots)
  {
   int sell=OrderSend(Symbol(),OP_SELL,lots,Bid,3,0,0,EA_Name,Magic,clrRed);
   if(sell<0)
     {
        ErrCode = GetLastError();
               
        Print("Unable to open sell position, ",ErrorDescription(ErrCode));
     }
   else
     {
      Print("sell placed successfully ",Magic);
     }
  }
  
//+------------------------------------------------------------------+
void BUY(double lots)
  {  
   int buy = OrderSend(Symbol(),OP_BUY,lots,Ask,3,0,0,EA_Name,Magic,clrBlue);
   if(buy<0)
     {
        ErrCode = GetLastError();
               
        Print("Unable to open buy position, ",ErrorDescription(ErrCode));
     }
   else
     {
      Print("buy placed successfully ",Magic);
     } 
   }
//+------------------------------------------------------------------+
void SELL(double lots, string name)
  {
   int sell=OrderSend(Symbol(),OP_SELL,lots,Bid,3,0,0,name,Magic,clrRed);
   if(sell<0)
     {
        ErrCode = GetLastError();
               
        Print("Unable to open sell position, ",ErrorDescription(ErrCode));
     }
   else
     {
      Print("sell placed successfully ",Magic);
     }
  }
  
//+------------------------------------------------------------------+
void BUY(double lots, string name)
  {  
   int buy = OrderSend(Symbol(),OP_BUY,lots,Ask,3,0,0,name,Magic,clrBlue);
   if(buy<0)
     {
        ErrCode = GetLastError();
               
        Print("Unable to open buy position, ",ErrorDescription(ErrCode));
     }
   else
     {
      Print("buy placed successfully ",Magic);
     } 
   }
//+------------------------------------------------------------------+
void BUYSTOP(double lots, double price)
  {     
   int buy=OrderSend(Symbol(),OP_BUYSTOP,lots,price,3,0,0,EA_Name,Magic,0,clrBlue);
   if(buy<0)
     {
        Print("Error placing buystop: ",ErrorDescription(ErrCode));
     }
   else
     {
      Print("buy stop placed successfully ",Magic);
     } 
   }
  
//+------------------------------------------------------------------+
void BUYLIMIT(double lots, double price)
  {  
   int buy=OrderSend(Symbol(),OP_BUYLIMIT,lots,price,3,0,0,EA_Name,Magic,0,clrBlue);
   if(buy<0)
     {
        ErrCode = GetLastError();
        Print("Error placing buystop: ", ErrorDescription(ErrCode));
     }
   else
     {
      Print("buy limit placed successfully ",Magic);
     } 
   } 
   
//+------------------------------------------------------------------+
void SELLSTOP(double lots,double price)
  { 
   int sell=OrderSend(Symbol(),OP_SELLSTOP,lots,price,3,0,0,EA_Name,Magic,0,clrRed);
   if(sell<0)
     {
        ErrCode = GetLastError();
        Print("Error placing buystop: ", ErrorDescription(ErrCode));
     }
   else
     {
      Print("sell stop placed successfully ",Magic);
     }
  }
  
//+------------------------------------------------------------------+
void SELLLIMIT(double lots, double price)
  {
   int sell=OrderSend(Symbol(),OP_SELLLIMIT,lots,price,3,0,0,EA_Name,Magic,0,clrRed);
   if(sell<0)
     {
        ErrCode = GetLastError();
        Print("Error placing sell limit: ",ErrorDescription(ErrCode));
     }
   else
     {
      Print("sell limit placed successfully ",Magic);
     }
  }
//+------------------------------------------------------------------+     
double point(string symbol=NULL)  
   {  
      string sym=symbol;
      if(symbol==NULL) sym=Symbol();
      double bid=MarketInfo(sym,MODE_BID);
      int digits=(int)MarketInfo(sym,MODE_DIGITS);
      
      if(digits<=1) return(1); //CFD & Indexes  
      if(digits==4 || digits==5) return(0.0001); 
      if((digits==2 || digits==3) && bid>1000) return(1);
      if((digits==2 || digits==3) && bid<1000) return(0.01);
      if(StringFind(sym,"XAU")>-1 || StringFind(sym,"xau")>-1 || StringFind(sym,"GOLD")>-1) return(0.1);//Gold  
      return(0);
   }
//+------------------------------------------------------------------+
void PartialClose()
  {
      string Class = "";
      double ClassOpen = 0;
      string Name  = "";
      string name  = "";
      double Price = 0;
      double price = 0;
      int m;
      string text_lots;
      string text_action;
      double Lots = 0;
      double AddLots = 0;
      double LottoClose;
      bool state;
      int ordertype = -1;
      long BGcolor = ChartGetInteger(0,CHART_COLOR_BACKGROUND);
      long Objcolor;
      
      for(int i=0;i<OrdersTotal();i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == false) break;
         if(OrderSymbol() != Symbol())continue;
         if(OrderMagicNumber() == Magic || (StringFind(OrderComment(),"from") >= 0))
           {
              Class = (string)OrderOpenPrice();
              ClassOpen = OrderOpenPrice();
              ordertype = OrderType();
              
              for(int k = ObjectsTotal()-1; k >= 0; k--)
                {
                   Name = ObjectName(k);
                   Objcolor = ObjectGetInteger(0,Name,OBJPROP_COLOR);
                   
                   state = ObjectGetInteger(0,Name,OBJPROP_SELECTED);//Harry
                   
                   if(StringFind(Name,Class) >= 0 && state == false && (Objcolor == clrRed || Objcolor == clrGreen))
                     {
                        Price = ObjectGetDouble(0,Name,OBJPROP_PRICE);
                        
                        to_split = ObjectDescription(Name);
                        m = StringSplit(to_split,u_sep,Result); 
                          
                        if(to_split != "" && ArraySize(Result) >= 2)
                          {
                             text_lots     = Result[0];
                             text_action   = Result[1];
                             AddLots       = StringToDouble(Result[2]);
                                 
                             Lots = StringToDouble(text_lots);
                           }                        
                        if(ordertype == OP_BUY)
                           {
                              if(StringFind(Name,"SL") >= 0 && Ask <= Price)
                                 {
                                    if(text_action == "AddLots")
                                      {
                                         ObjectSetInteger(0,Name,OBJPROP_COLOR,BGcolor);
                                         ObjectSetInteger(0,Name,OBJPROP_BACK,true);
                                         
                                         if(AddLots == 0)AddLots = 0.01;
                                         BUY(AddLots,(string)OrderOpenPrice());
                                         
                                         LottoClose = NormalizeDouble((Lots/100)*OrderLots(),2);
                                         if(LottoClose < 0.01)LottoClose = 0.01;
                                         
                                         if(!OrderClose(OrderTicket(),LottoClose,OrderOpenPrice(),3))
                                           {
                                             Print("Error closing trade partially: ", ErrorDescription(GetLastError()));
                                           }
                                         break;
                                      }
                                    if(text_action == "Nothing")
                                      {
                                         ObjectSetInteger(0,Name,OBJPROP_COLOR,BGcolor);
                                         ObjectSetInteger(0,Name,OBJPROP_BACK,true);
                                         LottoClose = NormalizeDouble((Lots/100)*OrderLots(),2);
                                         if(LottoClose < 0.01)LottoClose = 0.01;
                                         if(Lots == 100)
                                            {
                                               for(int h=0;h<OrdersTotal();h++)
                                                  {
                                                   if(OrderSelect(h,SELECT_BY_POS,MODE_TRADES) == false) break;
                                                   if(OrderSymbol() != Symbol())continue;
                                                   if(OrderComment() == (string)ClassOpen || OrderOpenPrice() == ClassOpen)
                                                     {
                                                       if(!OrderClose(OrderTicket(),OrderLots(),OrderOpenPrice(),3))
                                                          {
                                                            Print("Error closing additional trade partially: ", ErrorDescription(GetLastError()));
                                                          }
                                                       h--;
                                                     }
                                                   }
                                             }
                                         if(!OrderClose(OrderTicket(),LottoClose,OrderOpenPrice(),3))
                                           {
                                             Print("Error closing trade partially: ", ErrorDescription(GetLastError()));
                                           }
                                         break;
                                      }
                                 }
                              if(StringFind(Name,"TP") >= 0 && Ask >= Price)
                                 {
                                    if(text_action == "Nothing")
                                      {
                                         ObjectSetInteger(0,Name,OBJPROP_COLOR,BGcolor);
                                         ObjectSetInteger(0,Name,OBJPROP_BACK,true);
                                         LottoClose = NormalizeDouble((Lots/100)*OrderLots(),2);
                                         if(LottoClose < 0.01)LottoClose = 0.01;
                                         if(Lots == 100)
                                            {
                                               for(int h=0;h<OrdersTotal();h++)
                                                  {
                                                   if(OrderSelect(h,SELECT_BY_POS,MODE_TRADES) == false) break;
                                                   if(OrderSymbol() != Symbol())continue;
                                                   if(OrderComment() == (string)ClassOpen || OrderOpenPrice() == ClassOpen)
                                                     {
                                                       if(!OrderClose(OrderTicket(),OrderLots(),OrderOpenPrice(),3))
                                                          {
                                                            Print("Error closing additional trade partially: ", ErrorDescription(GetLastError()));
                                                          }
                                                       h--;
                                                     }
                                                   }
                                             }
                                         if(!OrderClose(OrderTicket(),LottoClose,OrderOpenPrice(),3))
                                           {
                                             Print("Error closing trade partially: ", ErrorDescription(GetLastError()));
                                           }
                                         break;
                                      }
                                   if(text_action == "SLtoBE")
                                      {
                                         ObjectSetInteger(0,Name,OBJPROP_COLOR,BGcolor);
                                         ObjectSetInteger(0,Name,OBJPROP_BACK,true);
                                         LottoClose = NormalizeDouble((Lots/100)*OrderLots(),2);
                                         if(LottoClose < 0.01)LottoClose = 0.01;
                                         if(!OrderClose(OrderTicket(),LottoClose,OrderOpenPrice(),3))
                                           {
                                             Print("Error closing trade partially: ", ErrorDescription(GetLastError()));
                                           }
                                         for(int j =0; j < OrdersTotal(); j++)
                                            {
                                               if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES) == false) break;
                                               if(OrderSymbol() != Symbol())continue;
                                               if(OrderMagicNumber() == Magic && OrderOpenPrice() == ClassOpen)
                                                  {
                                                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0))
                                                       {
                                                         Print("Error modifying stoploss: ", ErrorDescription(GetLastError()));
                                                       }
                                                  }
                                            }
                                           
                                         for(int h = 0; h < ObjectsTotal(); h++)
                                            {
                                               name = ObjectName(h);
                                               
                                               if(StringFind(name,Class+"SL") >= 0)
                                                  {
                                                     ObjectDelete(name);
                                                     h--;
                                                  }
                                            }
                                         break;
                                     }
                                   if(text_action == "SLtoPreviousTP")
                                     {
                                        price = ObjectGetDouble(0,ObjectName(k+1),OBJPROP_PRICE);
                                        ObjectSetInteger(0,Name,OBJPROP_COLOR,BGcolor);
                                        ObjectSetInteger(0,Name,OBJPROP_BACK,true);
                                        LottoClose = NormalizeDouble((Lots/100)*OrderLots(),2);
                                        if(LottoClose < 0.01)LottoClose = 0.01;
                                        if(!OrderClose(OrderTicket(),LottoClose,OrderOpenPrice(),3))
                                           {
                                              Print("Error closing trade partially: ", ErrorDescription(GetLastError()));
                                           }      
                                        for(int j =0; j < OrdersTotal(); j++)
                                            {
                                               if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES) == false) break;
                                               if(OrderSymbol() != Symbol())continue;
                                               if(OrderMagicNumber() == Magic && OrderOpenPrice() == ClassOpen)
                                                 {
                                                    if(!OrderModify(OrderTicket(),OrderOpenPrice(),price,OrderTakeProfit(),0))
                                                       {
                                                          Print("Error modifying stoploss: ", ErrorDescription(GetLastError()));
                                                       }
                                                 }
                                               }
                                              break;
                                       }
                                 }
                        if(ordertype == OP_SELL)
                           {
                              if(StringFind(Name,"SL") >= 0 && Bid >= Price)
                                 {
                                    if(text_action == "AddLots")
                                      {
                                         ObjectSetInteger(0,Name,OBJPROP_COLOR,BGcolor);
                                         ObjectSetInteger(0,Name,OBJPROP_BACK,true);
                                         if(AddLots == 0)AddLots = 0.01;
                                         SELL(AddLots,(string)OrderOpenPrice());
                                         
                                         LottoClose = NormalizeDouble((Lots/100)*OrderLots(),2);
                                         if(LottoClose < 0.01)LottoClose = 0.01;
                                         if(!OrderClose(OrderTicket(),LottoClose,OrderOpenPrice(),3))
                                           {
                                             Print("Error closing trade partially: ", ErrorDescription(GetLastError()));
                                           }
                                         break;
                                      }
                                    if(text_action == "Nothing")
                                      {
                                         ObjectSetInteger(0,Name,OBJPROP_COLOR,BGcolor);
                                         ObjectSetInteger(0,Name,OBJPROP_BACK,true);
                                         LottoClose = NormalizeDouble((Lots/100)*OrderLots(),2);
                                         if(Lots == 100)
                                            {
                                               for(int h=0;h<OrdersTotal();h++)
                                                  {
                                                   if(OrderSelect(h,SELECT_BY_POS,MODE_TRADES) == false) break;
                                                   if(OrderSymbol() != Symbol())continue;
                                                   if(OrderComment() == (string)ClassOpen || OrderOpenPrice() == ClassOpen)
                                                     {
                                                       if(!OrderClose(OrderTicket(),LottoClose,OrderOpenPrice(),3))
                                                          {
                                                            Print("Error closing additional trade partially: ", ErrorDescription(GetLastError()));
                                                          }
                                                       h--;
                                                     }
                                                   }
                                             }
                                         if(LottoClose < 0.01)LottoClose = 0.01;
                                         if(!OrderClose(OrderTicket(),LottoClose,OrderOpenPrice(),3))
                                           {
                                             Print("Error closing trade partially: ", ErrorDescription(GetLastError()));
                                           }
                                         break;
                                      }
                                 }
                              if(StringFind(Name,"TP") >= 0 && Bid <= Price)
                                 {
                                    if(text_action == "Nothing")
                                      {
                                         ObjectSetInteger(0,Name,OBJPROP_COLOR,BGcolor);
                                         ObjectSetInteger(0,Name,OBJPROP_BACK,true);
                                         LottoClose = NormalizeDouble((Lots/100)*OrderLots(),2);
                                         if(LottoClose < 0.01)LottoClose = 0.01;
                                         if(Lots == 100)
                                            {
                                               for(int h=0;h<OrdersTotal();h++)
                                                  {
                                                   if(OrderSelect(h,SELECT_BY_POS,MODE_TRADES) == false) break;
                                                   if(OrderSymbol() != Symbol())continue;
                                                   if(OrderComment() == (string)ClassOpen || OrderOpenPrice() == ClassOpen)
                                                     {
                                                       if(!OrderClose(OrderTicket(),LottoClose,OrderOpenPrice(),3))
                                                          {
                                                            Print("Error closing additional trade partially: ", ErrorDescription(GetLastError()));
                                                          }
                                                       h--;
                                                     }
                                                   }
                                             }
                                         if(!OrderClose(OrderTicket(),LottoClose,OrderOpenPrice(),3))
                                           {
                                             Print("Error closing trade partially: ", ErrorDescription(GetLastError()));
                                           }
                                         break;
                                      }
                                   if(text_action == "SLtoBE")
                                      {
                                         ObjectSetInteger(0,Name,OBJPROP_COLOR,BGcolor);
                                         ObjectSetInteger(0,Name,OBJPROP_BACK,true);
                                         LottoClose = NormalizeDouble((Lots/100)*OrderLots(),2);
                                         if(LottoClose < 0.01)LottoClose = 0.01;
                                         if(!OrderClose(OrderTicket(),LottoClose,OrderOpenPrice(),3))
                                           {
                                             Print("Error closing trade partially: ", ErrorDescription(GetLastError()));
                                           }
                                         for(int j =0; j < OrdersTotal(); j++)
                                            {
                                               if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES) == false) break;
                                               if(OrderSymbol() != Symbol())continue;
                                               if(OrderMagicNumber() == Magic && OrderOpenPrice() == ClassOpen)
                                                  {
                                                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0))
                                                       {
                                                         Print("Error modifying stoploss: ", ErrorDescription(GetLastError()));
                                                       }
                                                  }
                                            }
                                         for(int h = 0; h < ObjectsTotal(); h++)
                                            {
                                               name = ObjectName(h);
                                               
                                               if(StringFind(name,Class+"SL") >= 0)
                                                  {
                                                     ObjectDelete(name);
                                                     h--;
                                                  }
                                            }
                                         break;
                                      }
                                    
                                   if(text_action == "SLtoPreviousTP")
                                      {
                                         price = ObjectGetDouble(0,ObjectName(k+1),OBJPROP_PRICE);
                                         Print("Name: ", ObjectName(k+1), "\nPrice: ", price);
                                         ObjectSetInteger(0,Name,OBJPROP_COLOR,BGcolor);
                                         ObjectSetInteger(0,Name,OBJPROP_BACK,true);
                                         LottoClose = NormalizeDouble((Lots/100)*OrderLots(),2);
                                         if(LottoClose < 0.01)LottoClose = 0.01;
                                         if(!OrderClose(OrderTicket(),LottoClose,OrderOpenPrice(),3))
                                           {
                                             Print("Error closing trade partially: ", ErrorDescription(GetLastError()));
                                           }
                                         for(int j =0; j < OrdersTotal(); j++)
                                            {
                                               if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES) == false) break;
                                               if(OrderSymbol() != Symbol())continue;
                                               if(OrderMagicNumber() == Magic && OrderOpenPrice() == ClassOpen)
                                                  {
                                                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),price,OrderTakeProfit(),0))
                                                       {
                                                         Print("Error modifying stoploss: ", ErrorDescription(GetLastError()));
                                                       }
                                                  }
                                            }
                                         break;
                                      }
                                 }
                           }
                     }
                }
           }
         }
      }
  }
//+------------------------------------------------------------------+
int ActiveTrades()
  {
   int count = 0;

   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == false) break;
      if(OrderSymbol() != Symbol())continue;
      if(OrderMagicNumber() == Magic)
        {
          count++;
        }
     }
      return count;
  }
//+------------------------------------------------------------------+
bool func_WebRequest_post()
{
 
   ResetLastError();
   
   string ls_RequestResult ="";
   string gs_ResultHeaders = "";
   char     gc_ReqDataArray[],
            gc_ResultDataArray[];
   
   string gs_URL = "https://blueedgefinancial.com/",php = "titan-x.php?brokerid="+IntegerToString(AccountNumber());                   
   
   int li_RequestResp= WebRequest("GET",gs_URL+php,NULL,0,gc_ReqDataArray,gc_ResultDataArray,gs_ResultHeaders);
   
   if(GetLastError() == 4060)  
   {
      Alert ("WebRequest() function is not enabled. \n"
               + "It is required to connect to the database server. \n\n"
               + "Please enable it by following below-mentioned steps: \n"
               + "Step 1: Select Tools -> Options in the MetaTrader 4 terminal \n"
               + "Step 2: Select \"Exper Advisor\" tab in the \"Options\" subwindow \n"
               + "Step 3: Tick mark \"Allow WebRequest for listed URL:\" option \n"
               + "Step 4: Add " + gs_URL + " in the list of allowed URLs");
               
       ExpertRemove();
       return false;   
    }
   ls_RequestResult = CharArrayToString(gc_ResultDataArray);
    
    if(StringFind(ls_RequestResult,"Product Not Found")>=0)
    {
      Alert("Please update your MT4 account number " + (string)AccountNumber() + " under Edit Account Details in your client area.");
         
      ExpertRemove();
      return false;  
        
    }
    else
    {
      return true;
    } 
}

