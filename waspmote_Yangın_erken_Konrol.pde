// bu örnekte Wapsmote v1.2 ve xbee s2 verisyon kablosuz algılayıcı ağ uygulaması yapıldı.
// İletişim: eneskrgz35@gmail.com & twitter.com/leaked35   Soru sorabilirsiniz.

// xctu ile xbee s2 aygıtının condinator ve router olduklarını belirtiyoruz
//bunları blogumda detaylı anlatacağım.
//daha sonra  aşağıdaki kodları inceleyebilirsiniz. 

/*
    ------ [ZB_01] - Kordinatör Kodları --------
  ########################################################
  #                     ENES KARAGÖZ                     #
  #                   DUZCE UNIVERSITY                   #
  #                  COMPUTER ENGİNEER                   #
  ########################################################

*/

#include <WaspXBeeZB.h> //zigbee kütüphanesi
#include <WaspFrame.h> //frame gönderimi kütüphanesi
#include <string.h>
#include <stdlib.h>
/**************************************************
  IMPORTANT: Beware of the channel selected by the
  coordinator because routers are not able to scan
  both 0x19 and 0x1A channels
**************************************************/
// define variable frame gönderimi için gerekli
uint8_t error;
uint8_t destination[8];
uint8_t _payload[MAX_DATA];
char isi[6];
uint8_t degerler[100];
uint8_t  data;
uint8_t x=0,y=0,bas=0;

// coordinator's 64-bit PAN ID to set
//koordinatörün tanınması için kimlik numarası
////////////////////////////////////////////////////////////////////////
uint8_t  PANID[8] = { 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88};
////////////////////////////////////////////////////////////////////////


void setup()
{
  //  USB açılıyor
  USB.ON();
  USB.println(F("CORDINATOR UYGULAMA EKRANI..."));

//1. Open xbee

  //  XBee açmak için
  xbeeZB.ON();
  delay(1000); // 1 saniye bekleme

// 2. Set PANID


  xbeeZB.setPAN(PANID);
 //xbeeZB.PAN_ID[0000000000000000]; // pan id yi elle seçtim hata alıyorum.
  // check at command flag
  if (xbeeZB.error_AT == 0)
  {
    USB.println(F("2. PANID set OK"));
  }
  else
  {
    USB.println(F("2. Error while setting PANID"));
  }

  ///////////////////////////////////////////////
  // 3. Set channels to be scanned before creating network
  ///////////////////////////////////////////////
  /* Range:[0x0 to 0x3FFF]
    Channels are scpedified as a bitmap where depending on
    the bit a channel is selected --> Bit (Channel):
     0 (0x0B)  4 (0x0F)  8 (0x13)   12 (0x17)
     1 (0x0C)  5 (0x10)  9 (0x14)   13 (0x18)
     2 (0x0D)  6 (0x11)  10 (0x15)
     3 (0x0E)  7 (0x12)	 11 (0x16)    */
  xbeeZB.setScanningChannels(0x03, 0xFF);
                          // deneme //xbeeZB.getChannel();  // kanalı direk seçtim hata alıyorum aramada
  // check at command flag
  if (xbeeZB.error_AT == 0)
  {
    USB.println(F("3. Scanning channels set OK"));
  }
  else
  {
    USB.println(F("3. Error while setting 'Scanning channels'"));
  }

  ///////////////////////////////////////////////
  // Save values
  ///////////////////////////////////////////////
  xbeeZB.writeValues(); //yapılan/yapılacak değişiklikleri uygulamak kaydetmek için

  // wait for the module to set the parameters
  delay(10000);
 
checkNetworkParams(); // fonksiyon olarak pan id 16/64bit pan ve kanal değerlerini listelemek için çağırılır.
}


void loop()
{
  //göstermek için yazan yere kadar sadece gelen paket verisini göstermeyi yapıyoruz.
  // receive XBee packet (wait message for 20 seconds)
  error = xbeeZB.receivePacketTimeout( 20000 );



  // check answer
  if ( error == 0 )
  {
    USB.println(F("\n1. New packet received"));

    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("--> Data: "));
    USB.println( xbeeZB._payload, xbeeZB._length);
 //gelenveri = buffer[xbeeZB._payload];
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("--> Length: "));
    USB.println( xbeeZB._length, DEC);
 
for(x=0;x<=xbeeZB._length;x++)
{
  degerler[x]=xbeeZB._payload[x];
  
}
int i=0;

for(y=0;y<=sizeof(degerler);y++)
{
  if(degerler[y]=='I')
    {
      bas=y+8;
      while(i<5){
      isi[i]=degerler[bas];
      bas++;
      i++;
      }
      }
  }
/*
                //************* dereceyi float olarak dizi içerisinden yazdırmak için****************
  int d=0;
        for(d=0;d<=4;d++)
          {
             USB.print(isi[d]);
             
           }
*/


float der=atoi(isi);
int derece=der;
USB.print(" Suan Sicallik: ");USB.print(derece);USB.println("C"); // Eşik değeri olarak kullanacağım bu değeri 



    // get Source's MAC address
    destination[0] = xbeeZB._srcMAC[0];
    destination[1] = xbeeZB._srcMAC[1];
    destination[2] = xbeeZB._srcMAC[2];
    destination[3] = xbeeZB._srcMAC[3];
    destination[4] = xbeeZB._srcMAC[4];
    destination[5] = xbeeZB._srcMAC[5];
    destination[6] = xbeeZB._srcMAC[6];
    destination[7] = xbeeZB._srcMAC[7];
    USB.print(F("--> Source MAC address: "));
    
    USB.printHex( destination[0] );
    USB.printHex( destination[1] );
    USB.printHex( destination[2] );
    USB.printHex( destination[3] );
    USB.printHex( destination[4] );
    USB.printHex( destination[5] );
    USB.printHex( destination[6] );
    USB.printHex( destination[7] );
    USB.println();
    //göstermek için
    // insert small delay to wait TX node
    // to prepare to receive messages
    delay(1000);

    //GERİ MESAJ YOLLAMAK İÇİN YAPILMASI GEREKEN İŞLEMLER(ack)
    //burada gelen veriye göre komut verme gibi işlemler yapılabilir

    /*** Send message to TX node ***/

    USB.println(F("\n2. Send a response to the TX node: "));

    // send XBee packet
    error = xbeeZB.send( destination, " Mesaj alindi (ACK)");

    // check TX flag
     if ( error == 0 )
    {
      USB.println(F("mesaj alindi..."));

      // blink green LED
      Utils.blinkGreenLED();
    }
    else
    {
      USB.println(F("mesaj alinmadi..."));

      // blink red LED
      Utils.blinkRedLED();
    }
  }
  //GERİ MESAJ YOLLAMAK İÇİN YAPILMASI GEREKEN İŞLEMLER



else
  {
    // Print error message:
/*
       '7' : Buffer full. Not enough memory space
       '6' : Error escaping character within payload bytes
       '5' : Error escaping character in checksum byte
       '4' : Checksum is not correct
       '3' : Checksum byte is not available
       '2' : Frame Type is not valid
       '1' : Timeout when receiving answer
*/
    USB.print(F("Error receiving a packet:"));
    USB.println(error,DEC);
  }
  USB.println(F("\n----------------------------------"));
  }
/*******************************************

    checkNetworkParams - Check operating
    network parameters in the XBee module

  bağlantının yapıldığını teyit etmek için verileri görselleştirme
 *******************************************/
void checkNetworkParams()
{
  // 1. get operating 64-b PAN ID
  xbeeZB.getOperating64PAN();

  // 2. wait for association indication
  xbeeZB.getAssociationIndication();

  USB.println(F("Wait for association"));
  while ( xbeeZB.associationIndication != 0 )
  {
    delay(2000);

    //printAssociationState(); kullanımda olmayan bir fonksiyon hata verebilir


    // get operating 64-b PAN ID
    xbeeZB.getOperating64PAN();

    USB.print(F("operating 64-b PAN ID: "));
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

  USB.println(F("\nAga baglanildi!"));

  // 3. get network parameters
  xbeeZB.getOperating16PAN();
  xbeeZB.getOperating64PAN();
  xbeeZB.getChannel();

  USB.print(F("operating 16-b PAN ID: "));
  USB.printHex(xbeeZB.operating16PAN[0]);
  USB.printHex(xbeeZB.operating16PAN[1]);
  USB.println();

  USB.print(F("operating 64-b PAN ID: "));
  USB.printHex(xbeeZB.operating64PAN[0]);
  USB.printHex(xbeeZB.operating64PAN[1]);
  USB.printHex(xbeeZB.operating64PAN[2]);
  USB.printHex(xbeeZB.operating64PAN[3]);
  USB.printHex(xbeeZB.operating64PAN[4]);
  USB.printHex(xbeeZB.operating64PAN[5]);
  USB.printHex(xbeeZB.operating64PAN[6]);
  USB.printHex(xbeeZB.operating64PAN[7]);
  USB.println();

  USB.print(F("channel: "));
  USB.printHex(xbeeZB.channel);
  USB.println();

}








