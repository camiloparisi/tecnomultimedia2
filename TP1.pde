/* Artista: Eduardo Vega de Seoane
 Tecnología Multimedial 2 - Comisión Lisandro
 Integrantes: Jaurena, Mendiburu, Parisi
 */
 
//Variables de Arduino comentadas para su funcionamiento sin sensor//

import processing.serial.*;  // importacion de libreria Serial
import oscP5.*; // importacion de libreria OSC

int val=20; // Variable de altura en sensor ultrasónico (=20 siempre que no haya semspr de Arduino conectado)
//Serial myPort;  // Creación de objeto de la clase serial (comunicación con Arduino)
OscP5 osc; // Creaión del objeto osc

//PALETA DE COLORES:
Paleta paleta;

int transparencia=0;
int aparecer1 = 0;
int aparecer3 = 0;

color colores[];
color colorFondo;



//TRAZOS
PGraphics capa1;

//FORMAS
PGraphics capa3;

PImage Pinceladas[];
int cantidad = 32;


//=======================================
//variables de calibración del sonido

float minimoAmp = 55; 
float maximoAmp = 80; 

float minimoPitch = 45;
float maximoPitch = 90;

float f = 0.9;

boolean monitor = true;
//=======================================


float amp = 0.0;
float pitch = 0.0;

GestorSenial gestorAmp;
GestorSenial gestorPitch;

void settings() {
  if (random (100)>50) {
    size(600, 800);
  } else {
    size(800, 600);
  }
} 

void setup() {
  osc = new OscP5(this, 12345); // parametros: puntero a processing y puerto
  //String portName = "/dev/cu.usbmodem14101"; //puerto Arduino
  //myPort = new Serial(this, portName, 9600);
  //myPort.bufferUntil('\n');     

  gestorAmp = new GestorSenial( minimoAmp, maximoAmp, f );
  gestorPitch = new GestorSenial( minimoPitch, maximoPitch, f );

  capa1 = createGraphics(1000, 1000);
  capa3 = createGraphics(1000, 1000);
  colores = new color[4];

  colores[0] =  color(235, 218, 202) ;
  colores[1] =  color(232, 218, 205) ; 
  colores[2] =  color(235, 233, 234) ;
  colores[3] =  color(219, 198, 167) ;

  colorFondo = colores[int(random(0, 3))];

  String estaObra= int(random(1, 4)) + ".jpeg" ;
  paleta = new Paleta( estaObra);  

  Pinceladas = new PImage[cantidad];
  for ( int i=0; i<cantidad; i++ ) {
    String nombre= nf(i, 2)+ ".png";
    Pinceladas[i] = loadImage(nombre);
  }
  background(colorFondo);
}

void draw() {

  gestorAmp.actualizar(amp); //Actualización de amplitud
  gestorPitch.actualizar(pitch); //Actualización de pitch

  //Recibo data de Arduino
  /*
  if (myPort.available() > 0) {
    val = constrain (myPort.read(), 0, 20);
  }*/

  capa1();
  capa3();

  //Creo rectángulo para tapar capa

  image(capa1, -50, -50);
  noStroke();
  fill(colorFondo, transparencia);
  rect(0, 0, 800, 800);
  image(capa3, -50, -50);

  //TRANSPARENCIA
  if (frameCount>500) {

    transparencia = constrain(transparencia, 0, 255);
    if (gestorPitch.derivada ==0) {
      transparencia=transparencia+1;
    } else if (gestorPitch.derivada !=0) {
      transparencia=transparencia-1;
    }
  }
}
void capa1() {
  capa1.beginDraw();
  int cual = int(random(cantidad));
  float posX = random(  width  );
  float posY= random( height );

  pushMatrix();
  capa1.tint( paleta.darUnColor(), map(val, 1, 20, 0, 255) );
  capa1.translate (posX, posY);

  //ESCALA DE TRAZOS USANDO LA AMPLITUD DEL SONIDO:
  capa1.scale(map(gestorAmp.filtradoNorm(), 0, 1, 0.25, 0.5));
  pushStyle();

  //VELOCIDAD TRAZOS USANDO SENSOR Y SONIDO
  if (frameCount%int(10)==0 && cual%2 == 0 && gestorPitch.filtradoNorm()<0.5 && gestorPitch.derivada!=0 ) {
    capa1.image(Pinceladas[cual], posX, posY);
  } else if (frameCount%int(10)==0 && cual%2 != 0 && gestorPitch.filtradoNorm()>0.5 && gestorPitch.derivada!=0) {

    capa1.image(Pinceladas[cual], posX, posY);
  }
  popStyle();
  popMatrix();
  capa1.endDraw();
}

void capa3() {
  capa3.beginDraw();
  int cual3 = int(random(cantidad));
  float posX3 = random(  width  );
  float posY3= random( height );
  pushMatrix();
  capa3.translate (posX3, posY3);

  //TRANSPARENCIA DE FORMAS
  capa3.tint( paleta.darUnColor(), map(val, 1, 20, 0, 255) );


  //ESCALA DE FORMAS USANDO LA AMPLITUD DEL SONIDO:
  capa3.scale(map(gestorAmp.filtradoNorm(), 0, 1, 0.25, 0.6));


  //VELOCIDAD FORMAS USANDO SENSOR Y SONIDO
  if (frameCount%int(10)==0 && cual3%2 == 0 && gestorPitch.filtradoNorm()<0.5 && gestorPitch.derivada!=0) {
    capa3.image(Pinceladas[cual3], posX3, posY3);
  } else if (frameCount%int(10)==0 && cual3%2 != 0 && gestorPitch.filtradoNorm()>0.5 && gestorPitch.derivada!=0) {

    //pushMatrix();
    // rotate(map(val, 0, 20, 0, TWO_PI));
    capa3.image(Pinceladas[cual3], posX3, posY3);
    //popMatrix();
  }
  popMatrix();

  capa3.endDraw();
}


void oscEvent( OscMessage m) { //Función para monitoriar sonido
  if (m.addrPattern().equals("/amp")) {
    amp = m.get(0).floatValue();
  }
  if (m.addrPattern().equals("/pitch")) {
    pitch = m.get(0).floatValue();
  }
}
