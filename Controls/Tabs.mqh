//+------------------------------------------------------------------+
//|                                                         Tabs.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "ButtonsGroup.mqh"
//+------------------------------------------------------------------+
//| Class for creating tabs                                          |
//+------------------------------------------------------------------+
class CTabs : public CElement
  {
private:
   //--- Instances for creating the element
   CButtonsGroup     m_tabs;
   //--- Structure of properties and arrays of elements assigned to each tab
   struct TElements
     {
      CElement         *elements[];
     };
   TElements         m_tab[];
   //--- Tab positioning
   ENUM_TABS_POSITION m_position_mode;
   //--- Y-axis size of tabs
   int               m_tab_y_size;
   //--- Index of the selected tab
   int               m_selected_tab;
   //--- Right alignment flag
   bool              m_align_right;
   //--- Content background color
   color             m_content_back_color;
   //---
public:
                     CTabs(void);
                    ~CTabs(void);
   //--- Methods for creating tabs
   bool              CreateTabs(const int x_gap,const int y_gap);
   //--- Right alignment methods
   void              AlignRight(const bool align) { m_align_right=align; }
   bool              IsAlignRight(void)     const { return(m_align_right); }
   //---
private:
   void              InitializeProperties(const int x_gap,const int y_gap);
   bool              CreateCanvas(void);
   bool              CreateButtons(void);
   //---
public:
   //--- Returns the pointer to the button group
   CButtonsGroup    *GetButtonsGroupPointer(void) { return(::GetPointer(m_tabs)); }
   //--- (1) Returns the number of tabs, 
   //    (2) Sets/gets the tab position (top/bottom/left/right), (3) Sets the Y-axis size of tabs
   int               TabsTotal(void)                           const { return(m_tabs.ButtonsTotal()); }
   void              PositionMode(const ENUM_TABS_POSITION mode)     { m_position_mode=mode;          }
   ENUM_TABS_POSITION PositionMode(void)                       const { return(m_position_mode);       }
   void              TabsYSize(const int y_size);
   //--- (1) Stores and (2) returns the index of the selected tab
   void              SelectedTab(const int index)                    { m_selected_tab=index;          }
   int               SelectedTab(void)                         const { return(m_selected_tab);        }
   //--- Sets the text for the specified index
   void              Text(const uint index,const string text);
   //--- Selects the specified tab
   void              SelectTab(const int index);
   //--- Adds a tab
   void              AddTab(const string tab_text="",const int tab_width=50);
   //--- Adds an element to the array of the specified tab
   void              AddToElementsArray(const int tab_index,CElement &object);
   //--- Shows elements of only the selected tab
   void              ShowTabElements(void);
   //---
public:
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Control
   virtual void      Show(void);
   virtual void      Hide(void);
   virtual void      Delete(void);
   //--- Draws the element
   virtual void      Draw(void);
   //--- Updates the element to reflect the latest changes
   virtual void      Update(void);
   //---
private:
   //--- Handling tab click
   bool              OnClickTab(const int id,const int index);
   //--- Total width of all tabs
   int               SumWidthTabs(void);
   //--- Checks the index of the selected tab
   void              CheckTabIndex();

   //--- Adjust width based on the right window edge
   virtual void      ChangeWidthByRightWindowSide(void);
   //--- Adjust height based on the bottom window edge
   virtual void      ChangeHeightByBottomWindowSide(void);

   //--- Draws the background of the element area
   void              DrawMainArea(void);
   //--- Draws the tab label
   void              DrawPatch();
public:
   //--- Content background color
   void              ContentBackColor(const color clr) { m_content_back_color = clr; }
   color             ContentBackColor(void)        const { return(m_content_back_color); }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTabs::CTabs(void) : m_tab_y_size(22),
                     m_position_mode(TABS_TOP),
                     m_selected_tab(WRONG_VALUE),
                     m_align_right(false)
  {
//--- Store the element class name in the base class
   CElementBase::ClassName(CLASS_NAME);
//--- Tab height
   m_tabs.ButtonYSize(m_tab_y_size);
//--- Initialize content background color
   m_content_back_color = clrNONE;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTabs::~CTabs(void)
  {
  }
//+------------------------------------------------------------------+
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void CTabs::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Handle left mouse button click event on an object
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_GROUP_BUTTON)
     {
      //--- Tab click
      if(OnClickTab((int)lparam,(int)dparam))
         return;
      //---
      return;
     }
  }
//+------------------------------------------------------------------+
//| Creates the "Tabs" element                                       |
//+------------------------------------------------------------------+
bool CTabs::CreateTabs(const int x_gap,const int y_gap)
  {
//--- Exit if there is no pointer to the main element
   if(!CElement::CheckMainPointer())
      return(false);
//--- If there are no tabs in the group, report it
   if(TabsTotal()<1)
     {
      ::Print(__FUNCTION__," > This method should be called "
              "when there is at least one tab in the group! Use the CTabs::AddTab() method");
      return(false);
     }
//--- Initialize properties
   InitializeProperties(x_gap,y_gap);
//--- Create the element
   if(!CreateButtons())
      return(false);
   if(!CreateCanvas())
      return(false);
//--- 
   return(true);
  }
//+------------------------------------------------------------------+
//| Initializes properties                                           |
//+------------------------------------------------------------------+
void CTabs::InitializeProperties(const int x_gap,const int y_gap)
  {
   m_x        =CElement::CalculateX(x_gap);
   m_y        =CElement::CalculateY(y_gap);
   m_x_size   =(m_x_size<1 || m_auto_xresize_mode)? m_main.X2()-m_x-m_auto_xresize_right_offset : m_x_size;
   m_y_size   =(m_y_size<1 || m_auto_yresize_mode)? m_main.Y2()-m_y-m_auto_yresize_bottom_offset : m_y_size;
//--- Default background color
   m_back_color         =(m_back_color!=clrNONE)? m_back_color : clrWhiteSmoke;
   m_back_color_hover   =(m_back_color_hover!=clrNONE)? m_back_color_hover : C'229,241,251';
   m_back_color_pressed =(m_back_color_pressed!=clrNONE)? m_back_color_pressed : clrWhite;
//--- Default border color
   m_border_color         =(m_border_color!=clrNONE)? m_border_color : C'217,217,217';
   m_border_color_hover   =(m_border_color_hover!=clrNONE)? m_border_color_hover : m_border_color;
   m_border_color_pressed =(m_border_color_pressed!=clrNONE)? m_border_color_pressed : m_border_color;
//--- Offsets and text label color
   m_label_color =(m_label_color!=clrNONE)? m_label_color : clrBlack;
   m_label_x_gap =(m_label_x_gap!=WRONG_VALUE)? m_label_x_gap : 0;
   m_label_y_gap =(m_label_y_gap!=WRONG_VALUE)? m_label_y_gap : 0;
//--- Offsets from the edge
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
//--- Priority same as the parent
   CElement::Z_Order(m_main.Z_Order());
//--- Initialize content background color if not set
   m_content_back_color = (m_content_back_color != clrNONE) ? m_content_back_color : m_back_color;
  }
//+------------------------------------------------------------------+
//| Creates the drawing object                                       |
//+------------------------------------------------------------------+
bool CTabs::CreateCanvas(void)
  {
//--- Form the object name
   string name=CElementBase::ElementName("tabs");
//--- Create the object
   if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the button group                                         |
//+------------------------------------------------------------------+
bool CTabs::CreateButtons(void)
  {
   int x=0,y=0;
//--- Get the number of tabs
   int tabs_total=TabsTotal();
//--- If there are no tabs in the group, report it and exit
   if(tabs_total<1)
     {
      ::Print(__FUNCTION__," > This method should be called "
              "when there is at least one tab in the group! Use the CTabs::AddTab() method");
      return(false);
     }
//--- Store the pointer to the main element
   m_tabs.MainPointer(this);
//--- Calculate coordinates based on tab positioning
   if(m_position_mode==TABS_TOP)
     {
      y=-m_tab_y_size+1;
      // Right alignment for top tabs
      if(m_align_right)
        {
         x = SumWidthTabs();
         m_tabs.AnchorRightWindowSide(true);
        }
     }
   else if(m_position_mode==TABS_BOTTOM)
     {
      y=1;
      m_tabs.AnchorBottomWindowSide(true);
      // Right alignment for bottom tabs
      if(m_align_right)
        {
         x =SumWidthTabs();
         m_tabs.AnchorRightWindowSide(true);
        }
     }
   else if(m_position_mode==TABS_RIGHT)
     {
      x=1;
      m_tabs.AnchorRightWindowSide(true);
     }
   else if(m_position_mode==TABS_LEFT)
     {
      x=-SumWidthTabs()+1;
     }
//--- Check the index of the selected tab
   CheckTabIndex();
//--- Properties
   m_tabs.NamePart("tab");
   m_tabs.RadioButtonsMode(true);
   m_tabs.IsCenterText(CElement::IsCenterText());
//--- Create the button group
   if(!m_tabs.CreateButtonsGroup(x,y))
      return(false);
//--- Add element to the array
   CElement::AddToArray(m_tabs);
//---
   for(int i=0; i<tabs_total; i++)
     {
      m_tabs.GetButtonPointer(i).LabelYGap(2);
      m_tabs.GetButtonPointer(i).BackColor(m_back_color);
      m_tabs.GetButtonPointer(i).BackColorHover(m_back_color_hover);
      m_tabs.GetButtonPointer(i).BackColorPressed(m_back_color_pressed);
      m_tabs.GetButtonPointer(i).BorderColor(m_border_color);
      m_tabs.GetButtonPointer(i).BorderColorHover(m_border_color);
      m_tabs.GetButtonPointer(i).BorderColorPressed(m_border_color);
      m_tabs.GetButtonPointer(i).BorderColorLocked(m_border_color);
     }
//---
   m_back_color=m_back_color_pressed;
//--- Select the button
   m_tabs.SelectButton(m_selected_tab);
   return(true);
  }
//+------------------------------------------------------------------+
//| Sets the height of tabs                                          |
//+------------------------------------------------------------------+
void CTabs::TabsYSize(const int y_size)
  {
   m_tab_y_size=y_size;
   m_tabs.ButtonYSize(y_size);
  }
//+------------------------------------------------------------------+
//| Sets the tab text                                               |
//+------------------------------------------------------------------+
void CTabs::Text(const uint index,const string text)
  {
//--- Get the number of tabs
   uint tabs_total=TabsTotal();
//--- Exit if there are no tabs in the group
   if(tabs_total<1)
      return;
//--- Adjust the index value if it is out of range
   uint correct_index=(index>=tabs_total)? tabs_total-1 : index;
//--- Set the text
   m_tabs.GetButtonPointer(correct_index).LabelText(text);
  }
//+------------------------------------------------------------------+
//| Selects the tab                                                 |
//+------------------------------------------------------------------+
void CTabs::SelectTab(const int index)
  {
//--- Get the number of tabs
   uint tabs_total=TabsTotal();
   for(uint i=0; i<tabs_total; i++)
     {
      //--- If this tab is selected
      if(index==i)
        {
         //--- Store the index of the selected tab
         SelectedTab(index);
         //---
         m_tabs.SelectButton(index);
        }
     }
//--- Show elements of only the selected tab
   ShowTabElements();
  }
//+------------------------------------------------------------------+
//| Adds a tab                                                       |
//+------------------------------------------------------------------+
void CTabs::AddTab(const string tab_text,const int tab_width)
  {
//--- Reserve size
   int reserve=10;
//--- Set the size of the tab arrays
   int array_size=::ArraySize(m_tab);
   ::ArrayResize(m_tab,array_size+1,reserve);
//--- Coordinates
   int x=0,y=0;
   if(array_size>0)
     {
      if(m_position_mode==TABS_TOP || m_position_mode==TABS_BOTTOM)
        {
         x=SumWidthTabs()-1;
         // Right alignment adjustment
         if(m_align_right)
           {
            x = m_x_size - SumWidthTabs() - tab_width + 1;
           }
        }
      else
         y=((array_size*m_tab_y_size)+m_tab_y_size)-m_tab_y_size-array_size;
     }
//--- Add a button to the group
   m_tabs.AddButton(x,y,tab_text,tab_width,m_back_color,m_back_color_hover,m_back_color_pressed);
  }
//+------------------------------------------------------------------+
//| Adds an element to the array of the specified tab                |
//+------------------------------------------------------------------+
void CTabs::AddToElementsArray(const int tab_index,CElement &object)
  {
//--- Check for out-of-range
   int array_size=::ArraySize(m_tab);
   if(array_size<1 || tab_index<0 || tab_index>=array_size)
      return;
//--- Add the pointer of the passed element to the array of the specified tab
   int size=::ArraySize(m_tab[tab_index].elements);
   ::ArrayResize(m_tab[tab_index].elements,size+1);
   m_tab[tab_index].elements[size]=::GetPointer(object);
  }
//+------------------------------------------------------------------+
//| Shows elements of only the selected tab                         |
//+------------------------------------------------------------------+
void CTabs::ShowTabElements(void)
  {
//--- Exit if the tabs are hidden
   if(!CElementBase::IsVisible())
      return;
//--- Check the index of the selected tab
   CheckTabIndex();
//---
   uint tabs_total=TabsTotal();
   for(uint i=0; i<tabs_total; i++)
     {
      //--- Get the number of elements assigned to the tab
      int tab_elements_total=::ArraySize(m_tab[i].elements);
      //--- If this tab is selected
      if(i==m_selected_tab)
        {
         //--- Show the tab elements
         for(int j=0; j<tab_elements_total; j++)
           {
            //--- Show elements
            CElement *el=m_tab[i].elements[j];
            el.Reset();
            //--- If this element is 'Tabs', show the elements of the open tab
            CTabs *tb=dynamic_cast<CTabs*>(el);
            if(tb!=NULL)
               tb.ShowTabElements();
           }
        }
      //--- Hide elements of inactive tabs
      else
        {
         for(int j=0; j<tab_elements_total; j++)
            m_tab[i].elements[j].Hide();
        }
     }
//--- Send a message about this
   ::EventChartCustom(m_chart_id,ON_CLICK_TAB,CElementBase::Id(),m_selected_tab,"");
  }
//+------------------------------------------------------------------+
//| Show                                                             |
//+------------------------------------------------------------------+
void CTabs::Show(void)
  {
//--- Exit if the element is already visible
   if(CElementBase::IsVisible())
      return;
//--- Visibility state
   CElementBase::IsVisible(true);
//--- Update object positions
   Moving();
//--- Show elements
   int elements_total=ElementsTotal();
   for(int i=0; i<elements_total; i++)
     {
      if(!m_elements[i].IsDropdown())
         m_elements[i].Show();
     }
//--- Show the object (must be above the button group)
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
  }
//+------------------------------------------------------------------+
//| Hide                                                             |
//+------------------------------------------------------------------+
void CTabs::Hide(void)
  {
//--- Exit if the element is already hidden
   if(!CElementBase::IsVisible())
      return;
//--- Hide the object
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
//--- Visibility state
   CElementBase::IsVisible(false);
   CElementBase::MouseFocus(false);
//--- Hide elements
   int elements_total=ElementsTotal();
   for(int i=0; i<elements_total; i++)
      m_elements[i].Hide();
//--- Hide tab elements
   int tabs_total=TabsTotal();
   for(int i=0; i<tabs_total; i++)
     {
      int tab_elements_total=::ArraySize(m_tab[i].elements);
      for(int t=0; t<tab_elements_total; t++)
         m_tab[i].elements[t].Hide();
     }
  }
//+------------------------------------------------------------------+
//| Delete                                                           |
//+------------------------------------------------------------------+
void CTabs::Delete(void)
  {
   CElement::Delete();
//--- Free the element arrays
   uint tabs_total=TabsTotal();
   for(uint i=0; i<tabs_total; i++)
      ::ArrayFree(m_tab[i].elements);
//--- 
   ::ArrayFree(m_tab);
   m_back_color=clrNONE;
  }
//+------------------------------------------------------------------+
//| Tab click in the group                                           |
//+------------------------------------------------------------------+
bool CTabs::OnClickTab(const int id,const int index)
  {
//--- Exit if (1) identifiers do not match or (2) the element is locked
   if(id!=CElementBase::Id() || CElementBase::IsLocked())
      return(false);
//--- Exit if the index does not match
   if(index!=m_tabs.SelectedButtonIndex())
      return(true);
//--- Store the index of the selected tab
   SelectedTab(index);
//--- Redraw the element
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   CElement::Update(true);
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
//--- Show elements of only the selected tab
   ShowTabElements();
//--- Send a message about the change in the graphical interface
   ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0.0,"");
   return(true);
  }
//+------------------------------------------------------------------+
//| Total width of all tabs                                          |
//+------------------------------------------------------------------+
int CTabs::SumWidthTabs(void)
  {
   int width=0;
//--- If tabs are positioned left or right, return the width of the first tab
   if(m_position_mode==TABS_LEFT || m_position_mode==TABS_RIGHT)
      return(m_tabs.GetButtonPointer(0).XSize());
//--- Sum the width of all tabs
   int tabs_total=m_tabs.ButtonsTotal();
   for(int i=0; i<tabs_total; i++)
     {
      width=width+m_tabs.GetButtonPointer(i).XSize();
     }
//--- Account for overlap by one pixel
   width=width-(tabs_total-1);
   return(width);
  }
//+------------------------------------------------------------------+
//| Checks the index of the selected tab                             |
//+------------------------------------------------------------------+
void CTabs::CheckTabIndex(void)
  {
//--- Check for out-of-range
   int array_size=::ArraySize(m_tab);
   if(m_selected_tab<0)
      m_selected_tab=0;
   if(m_selected_tab>=array_size)
      m_selected_tab=array_size-1;
  }
//+------------------------------------------------------------------+
//| Adjusts width based on the right window edge                     |
//+------------------------------------------------------------------+
void CTabs::ChangeWidthByRightWindowSide(void)
  {
//--- Exit if the right window side anchor mode is enabled
   if(m_anchor_right_window_side)
      return;
//--- Sizes
   int x_size=0;
//--- Calculate and set the new size for the element background
   x_size=m_main.X2()-m_canvas.X()-m_auto_xresize_right_offset;
   
//--- Do not change size if it is less than the set limit
   if(x_size == m_x_size)
      return;
//---
   CElementBase::XSize(x_size);
   m_canvas.XSize(x_size);
   m_canvas.Resize(x_size,m_y_size);
   
//--- Redraw the element
   Draw();
//--- Update object positions
   Moving();
  }
//+------------------------------------------------------------------+
//| Adjusts height based on the bottom window edge                   |
//+------------------------------------------------------------------+
void CTabs::ChangeHeightByBottomWindowSide(void)
  {
//--- Exit if the bottom window side anchor mode is enabled
   if(m_anchor_bottom_window_side)
      return;
//--- Sizes
   int y_size=0;
//--- Calculate and set the new size for the element background
   y_size=m_main.Y2()-m_canvas.Y()-m_auto_yresize_bottom_offset;
//--- Do not change size if it is less than the set limit
   if(y_size==m_y_size)
      return;
//---
   CElementBase::YSize(y_size);
   m_canvas.YSize(y_size);
   m_canvas.Resize(m_x_size,y_size);
//--- Redraw the element
   Draw();
//--- Update object positions
   Moving();
  }
//+------------------------------------------------------------------+
//| Draws the element                                                |
//+------------------------------------------------------------------+
void CTabs::Draw(void)
  {
//--- Draw the content area background with custom color
   m_canvas.Erase(::ColorToARGB(m_content_back_color,m_alpha));
//--- Draw the border
   CElement::DrawBorder();
//--- Draw the label of the selected tab
   DrawPatch();
  }
//+------------------------------------------------------------------+
//| Draws the tab label                                              |
//+------------------------------------------------------------------+
void CTabs::DrawPatch(void)
  {
//--- Coordinates
   int x1 =0,x2 =0;
   int y1 =0,y2 =0;
//---
   if(m_position_mode==TABS_TOP)
     {
      x1 =m_tabs.GetButtonPointer(m_selected_tab).XGap()+1;
      x2 =x1+m_tabs.GetButtonPointer(m_selected_tab).XSize()-3;
      // Adjust for right alignment
      if(m_align_right)
        {
         x1 = m_x_size - SumWidthTabs() + m_tabs.GetButtonPointer(m_selected_tab).XGap()+1;
         x2 = x1 + m_tabs.GetButtonPointer(m_selected_tab).XSize()-3;
        }
     }
   else if(m_position_mode==TABS_BOTTOM)
     {
      x1 =m_tabs.GetButtonPointer(m_selected_tab).XGap()+1;
      x2 =x1+m_tabs.GetButtonPointer(m_selected_tab).XSize()-3;
      y1 =YSize()-1;
      y2 =y1;
      // Adjust for right alignment
      if(m_align_right)
        {
         x1 = m_x_size - SumWidthTabs() + m_tabs.GetButtonPointer(m_selected_tab).XGap()+1;
         x2 = x1 + m_tabs.GetButtonPointer(m_selected_tab).XSize()-3;
        }
     }
   else if(m_position_mode==TABS_LEFT)
     {
      y1 =m_tabs.GetButtonPointer(m_selected_tab).YGap()+1;
      y2 =y1+m_tabs.GetButtonPointer(m_selected_tab).YSize()-3;
     }
   else if(m_position_mode==TABS_RIGHT)
     {
      x1 =XSize()-1;
      x2 =x1;
      y1 =m_tabs.GetButtonPointer(m_selected_tab).YGap()+1;
      y2 =y1+m_tabs.GetButtonPointer(m_selected_tab).YSize()-3;
     }
//--- Determine the color for the line
   color clr = m_tabs.GetButtonPointer(m_selected_tab).BackColor();
   if(m_tabs.GetButtonPointer(m_selected_tab).CElementBase::IsLocked())
      clr = m_tabs.GetButtonPointer(m_selected_tab).BackColorLocked();
//--- Draw the line
   m_canvas.Line(x1,y1,x2,y2,::ColorToARGB(clr,m_alpha));
  }
//+------------------------------------------------------------------+
//| Updates the element                                              |
//+------------------------------------------------------------------+
void CTabs::Update(void)
  {
//--- Draw the background
   CElement::Update(true);
//--- Draw the buttons
   int tabs_total=TabsTotal();
   for(int i=0; i<tabs_total; i++)
      m_tabs.GetButtonPointer(i).Update(true);
  }
//+------------------------------------------------------------------+