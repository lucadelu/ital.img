#!/usr/bin/python
# -*- coding: utf-8 -*-

# newclass.py

import wx
import wx.lib.filebrowsebutton as filebrowse
from os import system

class Gui(wx.Frame):

    def __init__(self, parent, title):    
        super(Gui, self).__init__(parent, title=title, 
            size=(460, 300))

        self.InitUI()
        self.Centre()
        self.Show()     

    def InitUI(self):
	#create panel
        panel = wx.Panel(self)
        
        sizer = wx.GridBagSizer(7, 5)
	#create text on the top
        text1 = wx.StaticText(panel, label="Seleziona un file dell'Italia se non vuoi scaricarne uno nuovo")
        sizer.Add(text1, pos=(0, 0), flag=wx.TOP|wx.LEFT, border=15)

        dsnInput = filebrowse.FileBrowseButton(panel, id=wx.ID_ANY, 
                  labelText='', dialogTitle='Scegli il file da processare',
                  buttonText='Browse', fileMode=0,changeCallback=self.OnSetDsn)
        sizer.Add(dsnInput,pos = (1, 0), span=(1, 5), 
            flag = wx.EXPAND|wx.TOP|wx.LEFT|wx.RIGHT , border=1)
	#box
        sb = wx.StaticBox(panel, label="Scegli almeno una mappa da creare")
        boxsizer = wx.StaticBoxSizer(sb, wx.VERTICAL)
        sizer.Add(boxsizer, pos = (2, 0), span=(1, 5), 
	    flag = wx.EXPAND|wx.TOP|wx.LEFT|wx.RIGHT , border=10)
        
        #checkbox for italy, gfoss style
        self.cbIt = wx.CheckBox(panel, label = "Italia stile GFOSS.it")        
        boxsizer.Add(self.cbIt, flag = wx.LEFT, border=5)
        #checkbox for italy, hiking style           
        self.cbItEsc = wx.CheckBox(panel, label = "Italia stile escursionismo")
        boxsizer.Add(self.cbItEsc, flag = wx.LEFT, border=5)
        #checkbox for all regions, gfoss style   
        self.cbAllReg = wx.CheckBox(panel, label = "Tutte le regioni stile GFOSS.it")
        boxsizer.Add(self.cbAllReg, flag = wx.LEFT, border=5)
        #checkbox for one region, gfoss style 
        self.cbOneReg = wx.CheckBox(panel, label="Scegli una regione: ")
        boxsizer.Add(self.cbOneReg, flag=wx.LEFT, border=5)     
        #combo box for chose a region
        listReg = ['Abruzzi','Basilicata','Calabria','Campania',
		  'Emilia Romagna', 'Friuli Venezia Giulia', 'Lazio', 'liguria',
		  'Lombardia','Marche','Molise','Piemonte','Puglia','Sardegna',
		  'Sicilia','Toscana','Trentino Alto Adige','Umbria',
		  'Valle d\'Aosta','Veneto']
        self.comboReg = wx.ComboBox(panel, choices=listReg)
        boxsizer.Add(self.comboReg, flag=wx.TOP|wx.EXPAND, border=5)
        self.comboReg.Disable()
        self.cbOneReg.Bind(wx.EVT_CHECKBOX, self.enableCombo, id = self.cbOneReg.GetId())           
        #help button
        buttonH = wx.Button(panel, id = wx.ID_HELP)
        #buttonH.Disable()
        sizer.Add(buttonH, pos=(3, 0), flag=wx.LEFT, border=10)
        buttonH.Bind(wx.EVT_BUTTON, self.onHelp, id = buttonH.GetId())
        #ok button
        buttonOk = wx.Button(panel, id = wx.ID_OK)
        buttonOk.Bind(wx.EVT_BUTTON, self.onOk, id = buttonOk.GetId())
        sizer.Add(buttonOk, pos=(3, 2))
	#canc button
        buttonCanc = wx.Button(panel, id = wx.ID_CLOSE)
        buttonCanc.Bind(wx.EVT_BUTTON, self.onCancel, id = buttonCanc.GetId())       
        sizer.Add(buttonCanc, pos=(3, 3), span=(1, 1), 
		  flag=wx.BOTTOM|wx.RIGHT, border=5)

        sizer.AddGrowableCol(2)
        
        panel.SetSizer(sizer)

    def OnSetDsn(self, event):
        """!Input DXF file defined, update list of layer widget"""
        path = event.GetString()
        if not path:
            return
        else:
            print path

    def onOk(self, events):
	"""Ok dialog"""
	max_value = 50
	if self.cbItEsc.GetValue():
	    system('sh test.sh -e')
	elif self.cbIt.GetValue():
	    system('sh test.sh -i')
	elif self.cbAllReg.GetValue():
	    system('sh test.sh -r')
	elif self.cbOneReg.GetValue():
	    system('sh test.sh -R ' + self.comboReg.GetValue())	    
	else:
	    print("Devi selezionare almeno un\'opzione da eseguire")
	    return 0
	#dialog = wx.ProgressDialog('A progress box', 'Time Remaining:', 
				  #max_value, style=wx.PD_CAN_ABORT
                                   #| wx.PD_ELAPSED_TIME | wx.PD_REMAINING_TIME)
 
	#keep_going = True
	#count = 0
	#while (keep_going and count < max_value):
	    #count = count + 1
	    #wx.Sleep(1)
	    #(keep_going, skip) = dialog.Update(count)
	#dialog.Destroy()
	self.Close(wx.ID_CANCEL)
                                   
    def onCancel(self, events):
        """Close dialog."""
        self.Close(wx.ID_CANCEL)
        
    def onHelp(self, events):
        """Help dialog."""
	GuiHelp(None, title="Aiuto ital.imgui")
    
    def enableCombo(self,events):
	if self.cbOneReg.GetValue():
	    self.comboReg.Enable()
	else:
	    self.comboReg.Disable()

class GuiHelp(wx.Frame):

    def __init__(self, parent, title):    
        super(GuiHelp, self).__init__(parent, title=title, 
            size=(150, 150))

        self.InitUI()
        self.Centre()
        self.Show()     

    def InitUI(self):
      
        panelHelp = wx.Panel(self)
        
        sizerHelp = wx.GridBagSizer(3, 3)

        text = wx.StaticText(panelHelp, label="Aiuto italimgui")
        sizerHelp.Add(text, pos=(0, 0), flag=wx.TOP|wx.LEFT, border=5)
        #line = wx.StaticLine(panel)
        #sizer.Add(line, pos=(1, 0), span=(1, 5), 
            #flag=wx.EXPAND|wx.BOTTOM, border=10)
            
	##box
        sbHelp = wx.StaticBox(panelHelp, label="Scegli almeno una mappa da creare")
        boxHelp = wx.StaticBoxSizer(sbHelp, wx.VERTICAL)
        sizerHelp.Add(boxHelp, pos = (2, 0), span=(1, 5), 
	    flag = wx.EXPAND|wx.TOP|wx.LEFT|wx.RIGHT , border=10)
        
        ##checkbox for italy, gfoss style
        #self.cbIt = wx.CheckBox(panel, label = "Italia stile GFOSS.it")        
        #boxsizer.Add(self.cbIt, flag = wx.LEFT, border=5)
        ##checkbox for italy, hiking style           
        #self.cbItEsc = wx.CheckBox(panel, label = "Italia stile escursionismo")
        #boxsizer.Add(self.cbItEsc, flag = wx.LEFT|wx.BOTTOM, border=5)
        ##checkbox for all regions, gfoss style   
        #self.cbReg = wx.CheckBox(panel, label = "Tutte le regioni stile GFOSS.it")
        #boxsizer.Add(self.cbReg, flag = wx.LEFT|wx.TOP, border=5)
        ##checkbox for one region, gfoss style   
        #textCombo = wx.StaticText(panel, label="Scegli una regione")
        #comboReg = wx.ComboBox(panel)
        #boxsizer.Add(textCombo, flag=wx.TOP|wx.LEFT, border=10)
        #boxsizer.Add(comboReg, flag=wx.TOP|wx.EXPAND, border=5)

        buttonK = wx.Button(panelHelp, id = wx.ID_OK)
        buttonK.Bind(wx.EVT_BUTTON, self.onOk, id = buttonK.GetId())
        sizerHelp.Add(buttonK, pos=(3, 0),flag=wx.BOTTOM|wx.RIGHT,)

        #sizer.AddGrowableCol(2)
        
        #panel.SetSizer(sizer)
        
    def onOk(self, events):
        """Close dialog."""
        self.Close(wx.ID_CANCEL)


if __name__ == '__main__':
  
    app = wx.App()
    Gui(None, title="ital.imgui")
    app.MainLoop()