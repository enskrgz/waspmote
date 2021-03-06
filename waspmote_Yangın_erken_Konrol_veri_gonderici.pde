/*
    ------ [ZB_02b] - Router_Gönderici --------
########################################################
#                     ENES KARAGÖZ                     #
#                   DUZCE UNIVERSITY                   #
#                  COMPUTER ENGİNEER                   #
########################################################

*/
#include <WaspXBeeZB.h>
#include <WaspFrame.h>
// Destination MAC address
//////////////////////////////////////////
char RX_ADDRESS[] = "0000000000000000";
//////////////////////////////////////////

// define variable
uint8_t error;
uint8_t _payload[MAX_DATA];
uint8_t isi[10];
uint8_t degerler[100];
uint8_t  data;
uint8_t x=0,y=0,bas=0;

// PAN ID to set in order to search a new coordinator
uint8_t  PANID[8] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};


void setup()
{
  // init USB port
  USB.ON();
  ACC.ON();
  USB.println(F("ROUTER UYGULAMASI..."));


  ///////////////////////////////////////////////
  // Init XBee
  ///////////////////////////////////////////////
  xbeeZB.ON();
  


  
  ///////////////////////////////////////////////
  // 2. Dissociation process
  ///////////////////////////////////////////////
    
  /////////////////////////////////////
  // 2.1. Set PANID: 0x0000000000000000
  /////////////////////////////////////
  xbeeZB.setPAN(PANID);
 //xbeeZB.PAN_ID[0000000000000000]; // pan id yi elle seçtim hata alıyorum.
  // check at command flag
  if (xbeeZB.error_AT == 0)
  {
    USB.println(F("2.1. PANID set OK"));
  }
  else
  {
    USB.println(F("2.1. Error while setting PANID"));
  }

  
  /////////////////////////////////////
  // 2.2. set all possible channels to scan
  /////////////////////////////////////
  // channels from 0x0B to 0x18 (0x19 and 0x1A are excluded)
  /* Range:[0x0 to 0x3FFF]
    Channels are scpedified as a bitmap where depending on
    the bit a channel is selected --> Bit (Channel):
     0 (0x0B)  4 (0x0F)  8 (0x13)   12 (0x17)
     1 (0x0C)  5 (0x10)  9 (0x14)   13 (0x18)
     2 (0x0D)  6 (0x11)  10 (0x15)
     3 (0x0E)  7 (0x12)	 11 (0x16)    */
  xbeeZB.setScanningChannels(0x3F, 0xFF);
//xbeeZB.getChannel();  // kanalı direk seçtim hata alıyorum aramada
  // check AT command flag
  if ( xbeeZB.error_AT == 0 )
  {
    USB.println(F("2.2. Scanning channels set OK"));
  }
  else
  {
    USB.println(F("2.2. Error while setting 'Scanning channels'"));
  }


  /////////////////////////////////////
  // 2.3. Set channel verification JV=1 
  // in order to make the module to scan 
  // a new coordinator
  /////////////////////////////////////
  xbeeZB.setChannelVerification(1);

  // check AT command flag
  if ( xbeeZB.error_AT == 0 )
  {
    USB.println(F("2.3. Verification channel set OK"));
  }
  else
  {
    USB.println(F("2.3. Error while setting verification channel"));
  }


  // ayarları kaydetmek için
  xbeeZB.writeValues();


  ///////////////////////////////////////////////
  // Reboot XBee module
  ///////////////////////////////////////////////
  xbeeZB.OFF();
  delay(3000);
  xbeeZB.ON();

  delay(3000);



  /////////////////////////////////////
  // 3. Wait for Association
  /////////////////////////////////////

  // Wait for association indication
  xbeeZB.getAssociationIndication();

  while ( xbeeZB.associationIndication != 0 )
  {
    delay(2000);

    // get operating 64-b PAN ID
    xbeeZB.getOperating64PAN();

    USB.print(F("Operating 64-b PAN ID: "));
    USB.printHex(xbeeZB.operating64PAN[0]);
    USB.printHex(xbeeZB.operating64PAN[1]);
    USB.printHex(xbeeZB.operating64PAN[2]);
    USB.printHex(xbeeZB.operating64PAN[3]);
    USB.printHex(xbeeZB.operating64PAN[4]);
    USB.printHex(xbeeZB.operating64PAN[5]);
    USB.printHex(xbeeZB.operating64PAN[6]);
    USB.printHex(xbeeZB.operating64PAN[7]);
    USB.println();

    xbeeZB.getAssociationIndication();
  }


  USB.println(F("\n\nJoined a coordinator!"));

  // 2.2. When XBee is associated print all network
  // parameters unset channel verification JV=0
  xbeeZB.setChannelVerification(0);
  xbeeZB.writeValues();

  // 2.3. get network parameters
  xbeeZB.getOperating16PAN();
  xbeeZB.getOperating64PAN();
  xbeeZB.getChannel();

  USB.print(F("Operating 16-b PAN ID: "));
  USB.printHex(xbeeZB.operating16PAN[0]);
  USB.printHex(xbeeZB.operating16PAN[1]);
  USB.println();

  USB.print(F("Operating 64-b PAN ID: "));
  USB.printHex(xbeeZB.operating64PAN[0]);
  USB.printHex(xbeeZB.operating64PAN[1]);
  USB.printHex(xbeeZB.operating64PAN[2]);
  USB.printHex(xbeeZB.operating64PAN[3]);
  USB.printHex(xbeeZB.operating64PAN[4]);
  USB.printHex(xbeeZB.operating64PAN[5]);
  USB.printHex(xbeeZB.operating64PAN[6]);
  USB.printHex(xbeeZB.operating64PAN[7]);
  USB.println();

  USB.print(F("Channel: "));
  USB.printHex(xbeeZB.channel);
  USB.println();

  xbeeZB.getOwnNetAddress();
  USB.print(F("getownnet adress: "));
  USB.printHex(xbeeZB.sourceNA[0]);
  USB.printHex(xbeeZB.sourceNA[1]);
  USB.println();
}


void loop()
{
  //////////////////////////
  // 1. create frame
  //////////////////////////  

  // 1.1. create new frame
  frame.createFrame(ASCII);  
//int esik=PWR.getBatteryLevel()
//if(esik<56){int batarya=1;}
  // 1.2. add frame fields
  //buraya istenilen tüm sensör bilgilerini ekleyebiliriz
  frame.addSensor(SENSOR_STR, "\222/"); //yalnızca mesaj yollamak için 

  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel()); 
  frame.addSensor(SENSOR_BAT, ACC.getX(),ACC.getY(),ACC.getZ());
  frame.addSensor(SENSOR_IN_TEMP, (float) RTC.getTemperature());
  /*
  //frameleri şifreli yollama---->
frame.encryptFrame(AES_128,"eneskaragoz");
  //<----şifreleme
  */
  USB.println(F("\n1. gönderilecek frame oluşturuldu."));
  frame.showFrame();

  //////////////////////////
  // 2. paketi gönder
  //////////////////////////  

  // paketi xbee ile gönderme
  error = xbeeZB.send( RX_ADDRESS, frame.buffer, frame.length );   
  delay(20000);
  USB.println(F("\n2. Send a packet to the RX node: "));
  
  // check TX flag
  if( error == 0 )
  {
    USB.println(F("send ok"));
    
    // blink green LED
    Utils.blinkGreenLED();    
  }
  else 
  {
    USB.println(F("send error"));
    
    // blink red LED
    Utils.blinkRedLED();  
  }

  //////////////////////////
  // 3. receive answer ACK 
  //////////////////////////  
  
  USB.println(F("\n3. Wait for an incoming message"));
  
  // receive XBee packet
  error = xbeeZB.receivePacketTimeout( 10000 );
//gönderilen değerin durumuna göre cevap 
//*****************************************

for(x=0;x<=xbeeZB._length;x++)
{
  degerler[x]=xbeeZB._payload[x];
  
}int i=0;
for(y=0;y<=sizeof(degerler);y++)
{
  if(degerler[y]=='I')
    {
      bas=y+8;
      while(i<6){
      isi[i]=degerler[bas];
      bas++;
      i++;
      }
      }
  }

  int d=0;
        for(d=0;d<=5;d++)
          {
             USB.print(isi[d]);
           }



//******************************************


  // check answer  
  if( error == 0 ) 
  {
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("--> Data: "));  
    USB.println( xbeeZB._payload, xbeeZB._length);
    
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("--> Length: "));  
    USB.println( xbeeZB._length,DEC);
    
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("--> Source MAC address: "));      
    USB.printHex( xbeeZB._srcMAC[0] );    
    USB.printHex( xbeeZB._srcMAC[1] );    
    USB.printHex( xbeeZB._srcMAC[2] );    
    USB.printHex( xbeeZB._srcMAC[3] );    
    USB.printHex( xbeeZB._srcMAC[4] );    
    USB.printHex( xbeeZB._srcMAC[5] );    
    USB.printHex( xbeeZB._srcMAC[6] );    
    USB.printHex( xbeeZB._srcMAC[7] );    
    USB.println();
  }
  else
  {
    // Print error message:
    /*
     * '7' : Buffer full. Not enough memory space
     * '6' : Error escaping character within payload bytes
     * '5' : Error escaping character in checksum byte
     * '4' : Checksum is not correct   
     * '3' : Checksum byte is not available 
     * '2' : Frame Type is not valid
     * '1' : Timeout when receiving answer   
    */
    USB.print(F("Error receiving a packet:"));
    USB.println(error,DEC);     
  }
  
  // wait for 5 seconds
  USB.println(F("\n----------------------------------"));
  delay(5000);

}

