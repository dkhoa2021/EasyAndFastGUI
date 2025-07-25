//+------------------------------------------------------------------+
//|                                               PicturesSlider.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "Picture.mqh"
#include "Button.mqh"
#include "ButtonsGroup.mqh"
//--- Default picture
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp64\\no_image.bmp"
//+------------------------------------------------------------------+
//| Class for creating a picture slider                              |
//+------------------------------------------------------------------+
class CPicturesSlider : public CElement
  {
private:
   //--- Objects for creating the element
   CPicture          m_pictures[];
   CButtonsGroup     m_radio_buttons;
   CButton           m_left_arrow;
   CButton           m_right_arrow;
   //--- Array of pictures (path to pictures)
   string            m_file_path[];
   //--- Path to the default picture
   string            m_default_path;
   //--- Y-axis offset for pictures
   int               m_pictures_y_gap;
   //--- Offsets for buttons
   int               m_arrows_x_gap;
   int               m_arrows_y_gap;
   //--- Radio button width
   int               m_radio_button_width;
   //--- Offsets for radio buttons
   int               m_radio_buttons_x_gap;
   int               m_radio_buttons_y_gap;
   int               m_radio_buttons_x_offset;
   //---
public:
                     CPicturesSlider(void);
                    ~CPicturesSlider(void);
   //--- Methods for creating the picture slider
   bool              CreatePicturesSlider(const int x_gap,const int y_gap);
   //---
private:
   void              InitializeProperties(const int x_gap,const int y_gap);
   bool              CreateCanvas(void);
   bool              CreatePictures(void);
   bool              CreateRadioButtons(void);
   bool              CreateArrow(CButton &button_obj,const int index);
   //---
public:
   //--- Returns pointers to component elements
   CButtonsGroup    *GetRadioButtonsPointer(void)            { return(::GetPointer(m_radio_buttons)); }
   CButton          *GetLeftArrowPointer(void)               { return(::GetPointer(m_left_arrow));    }
   CButton          *GetRightArrowPointer(void)              { return(::GetPointer(m_right_arrow));   }
   CPicture         *GetPicturePointer(const uint index);
   //--- Offsets for arrow buttons
   void              ArrowsXGap(const int x_gap)             { m_arrows_x_gap=x_gap;                  }
   void              ArrowsYGap(const int y_gap)             { m_arrows_y_gap=y_gap;                  }
   //--- (1) Returns the number of pictures, (2) Y-axis offset for pictures
   int               PicturesTotal(void)               const { return(::ArraySize(m_pictures));       }
   void              PictureYGap(const int y_gap)            { m_pictures_y_gap=y_gap;                }
   //--- (1) Radio button offsets, (2) distance between radio buttons
   void              RadioButtonsXGap(const int x_gap)       { m_radio_buttons_x_gap=x_gap;           }
   void              RadioButtonsYGap(const int y_gap)       { m_radio_buttons_y_gap=y_gap;           }
   void              RadioButtonsXOffset(const int x_offset) { m_radio_buttons_x_offset=x_offset;     }
   //--- Adds a picture
   void              AddPicture(const string file_path="");
   //--- Switches to the picture at the specified index
   void              SelectPicture(const int index);
   //---
public:
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Show, delete
   virtual void      Show(void);
   virtual void      Delete(void);
   //--- Draws the element
   virtual void      Draw(void);
   //---
private:
   //--- Handling radio button click
   bool              OnClickRadioButton(const string clicked_object,const int id,const int index);
   //--- Handling left arrow button click
   bool              OnClickLeftArrow(const string clicked_object,const int id,const int index);
   //--- Handling right arrow button click
   bool              OnClickRightArrow(const string clicked_object,const int id,const int index);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPicturesSlider::CPicturesSlider(void) : m_default_path("Images\\EasyAndFastGUI\\Icons\\bmp64\\no_image.bmp"),
                                         m_arrows_x_gap(2),
                                         m_arrows_y_gap(2),
                                         m_radio_button_width(18),
                                         m_radio_buttons_x_gap(25),
                                         m_radio_buttons_y_gap(1),
                                         m_radio_buttons_x_offset(20),
                                         m_pictures_y_gap(25)
  {
//--- Store the element class name in the base class
   CElementBase::ClassName(CLASS_NAME);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPicturesSlider::~CPicturesSlider(void)
  {
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CPicturesSlider::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Handle left mouse button click event on an object
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      //--- Radio button click
      if(OnClickRadioButton(sparam,(int)lparam,(int)dparam))
         return;
      //--- If clicked on slider arrow buttons, switch the picture
      if(OnClickLeftArrow(sparam,(int)lparam,(int)dparam))
         return;
      if(OnClickRightArrow(sparam,(int)lparam,(int)dparam))
         return;
      //---
      return;
     }
  }
//+------------------------------------------------------------------+
//| Creates the element                                              |
//+------------------------------------------------------------------+
bool CPicturesSlider::CreatePicturesSlider(const int x_gap,const int y_gap)
  {
//--- Exit if there is no pointer to the main element
   if(!CElement::CheckMainPointer())
      return(false);
//--- Initialize properties
   InitializeProperties(x_gap,y_gap);
//--- Create the element
   if(!CreateCanvas())
      return(false);
   if(!CreatePictures())
      return(false);
   if(!CreateRadioButtons())
      return(false);
   if(!CreateArrow(m_left_arrow,0))
      return(false);
   if(!CreateArrow(m_right_arrow,1))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Initializes properties                                           |
//+------------------------------------------------------------------+
void CPicturesSlider::InitializeProperties(const int x_gap,const int y_gap)
  {
   m_x      =CElement::CalculateX(x_gap);
   m_y      =CElement::CalculateY(y_gap);
   m_x_size =(m_x_size<1)? 300 : m_x_size;
   m_y_size =(m_y_size<1)? 300 : m_y_size;
//--- Default properties
   m_back_color   =(m_back_color!=clrNONE)? m_back_color : m_main.BackColor();
   m_border_color =(m_border_color!=clrNONE)? m_border_color : m_main.BackColor();
//--- Offsets from the edge
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
  }
//+------------------------------------------------------------------+
//| Creates the drawing object                                       |
//+------------------------------------------------------------------+
bool CPicturesSlider::CreateCanvas(void)
  {
//--- Form the object name
   string name=CElementBase::ElementName("pictures_slider");
//--- Create the object
   if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the group of pictures                                    |
//+------------------------------------------------------------------+
bool CPicturesSlider::CreatePictures(void)
  {
//--- Get the number of pictures
   int pictures_total=PicturesTotal();
//--- If there are no pictures in the group, report it
   if(pictures_total<1)
     {
      ::Print(__FUNCTION__," > This method should be called "
              "when there is at least one picture in the group! Use the CPicturesSlider::AddPicture() method");
      return(false);
     }
//--- Coordinates
   int x=0,y=m_pictures_y_gap;
//--- Sizes
   uint x_size=0,y_size=0;
//--- Array for image data
   uint image_data[];
//---
   for(int i=0; i<pictures_total; i++)
     {
      //--- Store the window pointer
      m_pictures[i].MainPointer(this);
      //--- Read image data
      if(!::ResourceReadImage("::"+m_file_path[i],image_data,x_size,y_size))
        {
         ::Print(__FUNCTION__," > Error reading image ("+m_file_path[i]+"): ",::GetLastError());
         return(false);
        }
      //--- Calculate offset
      x=(m_x_size>>1)-(int(x_size>>1));
      //--- Properties
      m_pictures[i].Index(i);
      m_pictures[i].XSize((int)x_size);
      m_pictures[i].YSize((int)y_size);
      m_pictures[i].NamePart("picture_slider");
      m_pictures[i].IconFile(m_file_path[i]);
      m_pictures[i].IconFileLocked(m_file_path[i]);
      //--- Create the button
      if(!m_pictures[i].CreatePicture(x,y))
         return(false);
      //--- Add element to the array
      CElement::AddToArray(m_pictures[i]);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the group of radio buttons                               |
//+------------------------------------------------------------------+
bool CPicturesSlider::CreateRadioButtons(void)
  {
//--- Store the pointer to the parent element
   m_radio_buttons.MainPointer(this);
//--- Coordinates
   int x=m_radio_buttons_x_gap,y=m_radio_buttons_y_gap;
//--- Number of pictures
   int pictures_total=PicturesTotal();
//--- Properties
   int buttons_x_offset[];
//--- Set the size of the arrays
   ::ArrayResize(buttons_x_offset,pictures_total);
//--- Offsets between radio buttons
   for(int i=0; i<pictures_total; i++)
      buttons_x_offset[i]=(i>0)? buttons_x_offset[i-1]+m_radio_buttons_x_offset : 0;
//---
   m_radio_buttons.NamePart("radio_button");
   m_radio_buttons.RadioButtonsMode(true);
   m_radio_buttons.RadioButtonsStyle(true);
//--- Add buttons to the group
   for(int i=0; i<pictures_total; i++)
      m_radio_buttons.AddButton(buttons_x_offset[i],0,"",m_radio_button_width);
//--- Create the button group
   if(!m_radio_buttons.CreateButtonsGroup(x,y))
      return(false);
//--- Show the picture based on the selected radio button
   SelectPicture(1);
//--- Add element to the array
   CElement::AddToArray(m_radio_buttons);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates an arrow button                                          |
//+------------------------------------------------------------------+
//#resource "\\Images\\EasyAndFastGUI\\Controls\\left_thin_black.bmp"
//#resource "\\Images\\EasyAndFastGUI\\Controls\\right_thin_black.bmp"
//---
bool CPicturesSlider::CreateArrow(CButton &button_obj,const int index)
  {
//--- Store the pointer to the main element
   button_obj.MainPointer(this);
//--- Coordinates
   int x =(index<1)? m_arrows_x_gap : m_arrows_x_gap+16;
   int y =m_arrows_y_gap;
//--- Set properties before creation
   button_obj.Index(index);
   button_obj.XSize(16);
   button_obj.YSize(16);
//--- Labels for buttons
   if(index<1)
     {
      button_obj.IconFile(RESOURCE_LEFT_THIN_BLACK);
      button_obj.IconFileLocked(RESOURCE_LEFT_THIN_BLACK);
     }
   else
     {
      button_obj.IconFile(RESOURCE_RIGHT_THIN_BLACK);
      button_obj.IconFileLocked(RESOURCE_RIGHT_THIN_BLACK);
      button_obj.AnchorRightWindowSide(true);
     }
//--- Create the control element
   if(!button_obj.CreateButton("",x,y))
      return(false);
//--- Add element to the array
   CElement::AddToArray(button_obj);
   return(true);
  }
//+------------------------------------------------------------------+
//| Returns a pointer to a picture                                   |
//+------------------------------------------------------------------+
CPicture *CPicturesSlider::GetPicturePointer(const uint index)
  {
   uint array_size=PicturesTotal();
//--- Check the size of the object array
   if(array_size<1)
     {
      Print(__FUNCTION__," > There are no elements in the group!");
      return(NULL);
     }
//--- Adjust in case of out-of-range
   uint i=(index>=array_size)? array_size-1 : index;
//--- Return the object pointer
   return(::GetPointer(m_pictures[i]));
  }
//+------------------------------------------------------------------+
//| Adds a picture                                                   |
//+------------------------------------------------------------------+
void CPicturesSlider::AddPicture(const string file_path="")
  {
//--- Increase the size of arrays by one element
   int array_size=::ArraySize(m_pictures);
   int new_size=array_size+1;
   ::ArrayResize(m_pictures,new_size);
   ::ArrayResize(m_file_path,new_size);
//--- Store the values of the passed parameters
   m_file_path[array_size]=(file_path=="")? m_default_path : file_path;
  }
//+------------------------------------------------------------------+
//| Specifies which picture should be shown                          |
//+------------------------------------------------------------------+
void CPicturesSlider::SelectPicture(const int index)
  {
//--- Get the number of pictures
   int pictures_total=PicturesTotal();
//--- If there are no pictures in the group, report it
   if(pictures_total<1)
     {
      ::Print(__FUNCTION__," > This method should be called "
              "when there is at least one picture in the group! Use the CPicturesSlider::AddPicture() method");
      return;
     }
//--- Adjust the index value if it is out of range
   uint correct_index=(index>=pictures_total)? pictures_total-1 :(index<0)? 0 : index;
//--- Select the radio button by this index
   m_radio_buttons.SelectButton(correct_index);
//--- Switch the picture
   for(int i=0; i<pictures_total; i++)
     {
      if(i==correct_index)
         m_pictures[i].Show();
      else
         m_pictures[i].Hide();
     }
  }
//+------------------------------------------------------------------+
//| Show                                                             |
//+------------------------------------------------------------------+
void CPicturesSlider::Show(void)
  {
   CElement::Show();
   SelectPicture(m_radio_buttons.SelectedButtonIndex());
  }
//+------------------------------------------------------------------+
//| Delete                                                           |
//+------------------------------------------------------------------+
void CPicturesSlider::Delete(void)
  {
   CElement::Delete();
//--- Free the element arrays
   ::ArrayFree(m_pictures);
  }
//+------------------------------------------------------------------+
//| Radio button click                                               |
//+------------------------------------------------------------------+
bool CPicturesSlider::OnClickRadioButton(const string clicked_object,const int id,const int index)
  {
//--- Exit if the click was not on a button
   if(::StringFind(clicked_object,m_radio_buttons.NamePart(),0)<0)
      return(false);
//--- Exit if (1) identifiers do not match or (2) the element is locked
   if(id!=CElementBase::Id() || CElementBase::IsLocked())
      return(false);
//--- Exit if the index matches
   if(index==m_radio_buttons.SelectedButtonIndex())
      return(true);
//--- Select the picture
   SelectPicture(index);
//--- Redraw the element
   m_radio_buttons.Update(true);
   return(true);
  }
//+------------------------------------------------------------------+
//| Left arrow button click                                          |
//+------------------------------------------------------------------+
bool CPicturesSlider::OnClickLeftArrow(const string clicked_object,const int id,const int index)
  {
//--- Exit if the click was not on a button
   if(::StringFind(clicked_object,m_left_arrow.NamePart(),0)<0)
      return(false);
//--- Exit if (1) identifiers do not match or (2) the element is locked
   if(id!=CElementBase::Id() || index!=m_left_arrow.Index() || CElementBase::IsLocked())
      return(false);
//--- Get the current index of the selected radio button
   int selected_radio_button=m_radio_buttons.SelectedButtonIndex();
//--- Switch the picture
   SelectPicture(--selected_radio_button);
//--- Redraw the radio buttons
   m_radio_buttons.Update(true);
//--- Send a message about this
   ::EventChartCustom(m_chart_id,ON_CLICK_BUTTON,CElementBase::Id(),CElementBase::Index(),"");
   return(true);
  }
//+------------------------------------------------------------------+
//| Right arrow button click                                         |
//+------------------------------------------------------------------+
bool CPicturesSlider::OnClickRightArrow(const string clicked_object,const int id,const int index)
  {
//--- Exit if the click was not on a button
   if(::StringFind(clicked_object,m_right_arrow.NamePart(),0)<0)
      return(false);
//--- Exit if (1) identifiers do not match or (2) the element is locked
   if(id!=CElementBase::Id() || index!=m_right_arrow.Index() || CElementBase::IsLocked())
      return(false);
//--- Get the current index of the selected radio button
   int selected_radio_button=m_radio_buttons.SelectedButtonIndex();
//--- Switch the picture
   SelectPicture(++selected_radio_button);
//--- Redraw the radio buttons
   m_radio_buttons.Update(true);
//--- Send a message about this
   ::EventChartCustom(m_chart_id,ON_CLICK_BUTTON,CElementBase::Id(),CElementBase::Index(),"");
   return(true);
  }
//+------------------------------------------------------------------+
//| Draws the element                                                |
//+------------------------------------------------------------------+
void CPicturesSlider::Draw(void)
  {
//--- Draw the background
   CElement::DrawBackground();
//--- Draw the border
   CElement::DrawBorder();
  }
//+------------------------------------------------------------------+