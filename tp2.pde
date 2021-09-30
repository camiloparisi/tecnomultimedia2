import fisica.*;
import processing.sound.*;
import oscP5.*;

OscP5 osc;

PFont pixel_font;
PFont arcade_font;

FWorld mundo;
FBox caja; //creamos una caja
FBox pileta;//creamos el borde de la pileta donde charly va a estar sentado
FBox botella;
FBox Charly;
FBox Brazo;
FCircle bola;
FCircle Mano;
FMouseJoint mousejoint;

float espera;
float timeLeft = 3000;

SoundFile abrirLata;
SoundFile abrirBotella;
SoundFile perdiste;
SoundFile ganaste;
SoundFile cancion;

float ancho = 36.5;
float altoBotella = 94;
float alto = 64;
FCircle[] dinosaurios = new FCircle[6];

int pantalla = 0;

int contador = 0;

int anchoPileta =110;
int altoPileta =550;

float anchoCharly = 155;
float altoCharly = 250 ;


int anchoBrazo =67;
int altoBrazo =15;

int anchoMano =3;
int altoMano =3;

int friccionB;
int densidadB;
float DampingB;

int friccionL;
int densidadL;
float DampingL;

int posXp = 100;
int posYp = 100;



int tiempo ;

PImage lata, bordePileta, botellaCoca, Charlyimg, 
  agua, Fondo, dinosaurioInflable, Inicio, Perdiste, 
  Ganaste, Boton, Flecha, Pelota, green, clock;



float velocidad_agua = 0.2; //Velocidad gif
float velocidad_charly = 0.1; //Velocidad gif

int transparencia = 0;

String time;


//---------CAMARA---------//
float amortiguacion = 0.2;
float umbralDistancia = 30;

PVector indice;
PVector pulgar;

PVector indiceFilt;
PVector pulgarFilt;

PVector puntero;

boolean seTocan = false;
boolean antesSeTocaban = false;

boolean down = false;
boolean up = false;
//-------------------------------//

/*-----------------------elementos cadena agua-------------------------------------*/

float frequency = 5;
float damping = 1;
float puenteY;
//si se modifica la cantidad de cuerpos que cuelguen de la soga, va a haber mas o menos
//peso que tire hacia abajo, que puede jugar a favor o en contra si queremos poner cosas arriba
FBody[] steps = new FBody[20];
FWorld world;

int boxWidth = 400/(steps.length) - 2;

int maxPngAgua = 47;
int maxPngCharly = 6;
int imageIndex = 0; //comienzo de imagenes gif agua
int imageIndex2=0; //comienzo de imagenes gif charly
PImage [] PngAgua = new PImage[maxPngAgua];
PImage [] PngCharly = new PImage[maxPngCharly];
PImage [] barra= new PImage[5];

int color_de_carga = 0;

void setup() {

  size(1000, 800, P3D);

  /*CAMARA*/
  osc = new OscP5(this, 8008);

  indice = new PVector(0, 0);
  pulgar = new PVector(0, 0);
  puntero = new PVector(0, 0);

  indiceFilt = new PVector(0, 0);
  pulgarFilt = new PVector(0, 0);

  /* inicializacion */

  Fisica.init(this);
  puenteY = 450;
  mundo = new FWorld(); //creo el mundo
  mundo.setEdges();//crea unos bordes para que los elementos no se escapen del mundo
  //los bordes no se ven porque para actualizarse necesira llamar
  //a dos metodos en el draw
  mundo.setEdgesFriction(100)
    dinosaurioInflable = loadImage("dinosaurioInflable.png")
    pixel_font = createFont("FreePixel.ttf", 128);
  arcade_font = createFont("ArcadeIn.ttf", 128);
  textFont(pixel_font);
  espera = second();

  /* Loop agua */

  for (int i = 0; i< PngAgua.length; i++) {
    PngAgua[i] = loadImage("Layer 1_agua_"+i+".png");
  }

  /* carga de imagenes barra */

  for (int i = 0; i< 5; i++) {
    barra[i] = loadImage("barra"+i+".png");
  }


  /* sonido */
  abrirBotella = new SoundFile(this, "abriendo_botella.wav");
  abrirLata = new SoundFile(this, "abriendo_lata.wav");
  perdiste = new SoundFile(this, "perder.wav");
  ganaste = new SoundFile(this, "ganar.wav");
  cancion = new SoundFile(this, "cancion.wav");
  /* caja > futura lata */

  lata = loadImage("lata.png");

  caja = new FBox(ancho, alto);
  caja.setPosition(100, 200);
  mundo.setGravity(0, 500);
  mundo.add(caja);
  caja.attachImage(lata);
  caja.setRestitution(0.8);
  caja.setFriction(6);
  caja.setDensity(6);
  caja.setName("botellaCoca");

  /* pileta donde charly se va a sentar*/
  bordePileta = loadImage("piletaBorde.png");
  pileta = new FBox(anchoPileta, altoPileta);
  pileta.setPosition(width-anchoPileta/2, height - altoPileta/2 ); 
  mundo.add(pileta);
  pileta.attachImage(bordePileta);
  pileta.setStatic(true); 
  pileta.setGrabbable(false);

  /* botella */
  botellaCoca = loadImage("botella.png");
  botella = new FBox(ancho, altoBotella);
  botella.setName("botellaCoca");
  botella.setPosition(200, 200);
  mundo.add(botella);
  botella.attachImage(botellaCoca);
  botella.setRestitution(0.1);
  botella.setFriction(6);
  botella.setDensity(4);

  /* Pelota */
  Pelota = loadImage("pelota.png");
  bola = new FCircle(100);
  bola.attachImage(Pelota);
  bola.setName("bola");
  bola.setPosition(100, 550); //importante
  mundo.add(bola);

  /*Charly*/

  /* Loop charly */
  for (int i=0; i < PngCharly.length; i++) {
    PngCharly[i] = loadImage("charly_"+i+".png");
  }


  //Charlyimg = loadImage("Charly.png");

  Charly = new FBox(anchoCharly, altoCharly);
  Charly.setPosition(977, 126); 
  mundo.add(Charly);
  Charly.setStatic(true);
  Charly.setGrabbable(false);
  Charly.setNoStroke();
  Charly.setNoFill();
  Charly.setName("Charly");


  Brazo = new FBox(anchoBrazo, altoBrazo);
  Brazo.setPosition(878, 167);
  mundo.add(Brazo);
  Brazo.setNoStroke();
  Brazo.setNoFill();
  Brazo.setGrabbable(false);
  Brazo.setRotation(183);
  Brazo.setName("Brazo");
  Brazo.setStatic(true);

  Mano = new FCircle(15); 
  Mano.setStatic(true);
  Mano.setPosition(844, 143);
  Mano.setNoStroke();
  Mano.setNoFill();
  mundo.add(Mano);
  Mano.setGrabbable(false);
  Mano.setName("Mano");


  /*-----dinosaurios-----*/

  for (int i=0; i<dinosaurios.length; i++) {
    dinosaurios[i] = new FCircle(60); 
    dinosaurios[i].setPosition(width/2 + (i*20), puenteY-150);
    dinosaurios[i].setRestitution(0.1);
    dinosaurios[i].setFriction(1);
    Charly.setStatic(true);
    dinosaurios[i].setDensity(0.5);
    dinosaurios[i].attachImage(dinosaurioInflable);
    dinosaurios[i].setAngularDamping(4);

    mundo.add(dinosaurios[i]);
  }


  //estos son los circulos que unen todas las lineas con los hilos

  FCircle left = new FCircle(10);
  left.setStatic(true);
  left.setPosition(0, puenteY);
  left.setDrawable(false);

  mundo.add(left);

  FCircle right = new FCircle(10);
  right.setStatic(true);
  right.setPosition(width-anchoPileta, puenteY);
  right.setDrawable(false);

  mundo.add(right);


  /*-------------------------------------------------*/

  for (int i=0; i<steps.length; i++) {
    steps[i] = new FBox(boxWidth, 10);
    steps[i].setPosition(map(i, 0, steps.length-1, boxWidth, width-boxWidth), puenteY);
    steps[i].setNoStroke();
    steps[i].setNoFill();
    mundo.add(steps[i]);
  }

  for (int i=1; i<steps.length; i++) {

    //construye la union entre los cuerpos del medio

    FDistanceJoint junta = new FDistanceJoint(steps[i-1], steps[i]);
    junta.setNoStroke();
    junta.setNoFill();
    junta.setLength(0.2);
    mundo.add(junta);
  }


  //constituye la distancia de la soga de la izquierda y el primer cuerpo

  FDistanceJoint juntaPrincipio = new FDistanceJoint(steps[0], left);
  juntaPrincipio.setFrequency(frequency);
  juntaPrincipio.setLength(0.2);
  juntaPrincipio.setNoFill();
  juntaPrincipio.setNoStroke(); 
  mundo.add(juntaPrincipio);


  //constituye la distancia de la soga de la derecha y el primer cuerpo

  FDistanceJoint juntaFinal = new FDistanceJoint(steps[steps.length-1], right);
  juntaFinal.setLength(30)
    juntaFinal.setLength(1);
  juntaFinal.setNoFill();
  juntaFinal.setNoStroke();
  mundo.add(juntaFinal)

    Fondo = loadImage("fondo.png");
  Inicio = loadImage("1.png");
  Perdiste = loadImage("2.png");
  Ganaste = loadImage("3.png");
  Boton = loadImage("4.png")
    clock =loadImage("clock.png");
  green = loadImage("green.png");


  //MOUSE JOINT

  mousejoint = new FMouseJoint(bola, 100, 550); 
  mousejoint.setFrequency(400000);
  mousejoint.setNoStroke();
  mundo.add(mousejoint);
}


void draw() {


  //CAMARA y detección de mano

  if (pulgar.x!=0 && indice.x!=0) {
    seTocan = dist(pulgar.x, pulgar.y, indice.x, indice.y) < umbralDistancia;

    down = !antesSeTocaban && seTocan;
    up = antesSeTocaban && !seTocan;

    antesSeTocaban = seTocan;
  }


  indiceFilt.x = lerp(indiceFilt.x, indice.x, amortiguacion);
  indiceFilt.y = lerp(indiceFilt.y, indice.y, amortiguacion);

  pulgarFilt.x = lerp(pulgarFilt.x, pulgar.x, amortiguacion);
  pulgarFilt.y = lerp(pulgarFilt.y, pulgar.y, amortiguacion);

  puntero.x =  lerp(pulgarFilt.x, indiceFilt.x, 1);
  puntero.y =  lerp(pulgarFilt.y, indiceFilt.y, 1);



  //INTERACCIÓN CON PELOTA

  mousejoint.setTarget(map(puntero.x, 400, 930, 0, width), map(puntero.y, 90, 420, 450, height));


  if (pantalla == 0) {
    background(164, 65, 195);
    image(Inicio, 0, 0);

    //HARDCODE
    if (color_de_carga>35) {
      image(green, 35+300, height-195, 47, 20);
    }   
    if (color_de_carga>35*2) {
      image(green, 35+345, height-195, 47, 20);
    }  
    if (color_de_carga>35*3) {
      image(green, 35+345+45, height-195, 47, 20);
    }   
    if (color_de_carga>35*4) {
      image(green, 35+345+45+45, height-195, 47, 20);
    }  
    if (color_de_carga>35*5) {
      image(green, 35+480, height-195, 47, 20);
    }   
    if (color_de_carga>35*6) {
      image(green, 35+480+45, height-195, 47, 20);
    }   
    if (color_de_carga>35*7) {
      image(green, 35+480+45+45, height-195, 47, 20);
    }



    if ( seTocan) {
      color_de_carga++; //barra de carga inicial
    }


    if (color_de_carga==255) {
      pantalla=1;
      color_de_carga=0;
      cancion.play();
      restart();
    }



    if (mouseX>870 && mouseX<929 && mouseY>468 && mouseY<523) {
      image(Flecha, 0, 0);
    } 


    textSize(20);
    textAlign(CENTER);
  } else if (pantalla==1) {

    rectMode(CORNER);

    Fondo.resize(1000, 800);
    bordePileta.resize(120, 550);
    image(Fondo, 0, 0);


    //cambio color fondo

    fill(169, 36, 200, transparencia);
    rect(0, 0, 1000, 800);
    if (tiempo<10 && tiempo%2==0) {
      transparencia=125;
    } else {
      transparencia=0;
    }

    mundo.step();//hace los calculos matematicos en los cuerpos que interactuan en 
    //frame
    mundo.draw(); //dibuja el mundo de fisica en el lugar

    int imageIndex = int( frameCount*velocidad_agua %PngAgua.length );

    PngAgua[imageIndex].resize(1000, 800);
    image(PngAgua[imageIndex], 0, 120);

    imageIndex= int(imageIndex+1)%PngAgua.length;

    //HARDCODE 2


    image(barra[0], 125, 50);

    if (tiempo<=23) {
      image(barra[1], 125, 50);
    }
    if (tiempo<=16) {
      image(barra[2], 125, 50);
    }
    if (tiempo<=9) {
      image(barra[3], 125, 50 );
    }
    if (tiempo<=5) {
      image(barra[4], 125, 50);
    }



    image(clock, 70, 50-12);
    tiempo= round(timeLeft/100);
    image(PngCharly[imageIndex2], 440, -100, 450*1.5, 300*1.5);

    imageIndex2=(imageIndex+1)%PngCharly.length;
    timeLeft--;


    if (tiempo<10 && tiempo >=0 ) { //Texto titilando
      //  textFont(arcade_font);
      textSize(500);
      fill (255, 0, 0, 100);
      text(tiempo, width/2, height/2);
    }


    if (timeLeft == 0 && pantalla == 1) {
      pantalla = 3;
      if (!perdiste.isPlaying()) {
        perdiste.amp(.3);
        perdiste.play();
        cancion.stop();
        timeLeft = 3000;
      }
    }
  } else if (pantalla==3) {

    image(Perdiste, 0, 0);
    if ( puntero.y>0 && puntero.y<50) {
      restart();
      pantalla=0;
    }
  } else if (pantalla==2) {
    image(Ganaste, 0, 0);
    if ( puntero.y>0 && puntero.y<50) {
      restart();
      contador=0;
      pantalla=0;
    }
  }


  /* botella */

  botella.setRestitution(0.1);
  botella.setFriction(friccionB);
  botella.setDensity(densidadB);
  botella.setDamping(DampingB);
  botella.setAngularDamping(5);

  /* lata */

  caja.setRestitution(0.8);
  caja.setFriction(friccionL);
  caja.setDensity(densidadL);
  caja.setDamping(DampingL);
  caja.setAngularDamping(5);

  if ( botella.getY()>puenteY) {
    friccionB = 30;
    densidadB = 1;
    DampingB = 5;
  } else {
    friccionB =30;
    densidadB = 10;
    DampingB = 1 ;
  }

  if ( caja.getY()>puenteY) {
    friccionL = 30;
    densidadL = 3;
    DampingL = 4;
  } else {
    friccionL =30;
    densidadL = 10;
    DampingL = 2;
  }
}

void contactStarted(FContact contacto) {

  FBody body1 = contacto.getBody1();
  FBody body2 =contacto.getBody2();


  if ((body1.getName() == "Mano" && body1.getName() == "botellaCoca") || body2.getName() == "Mano") {
    if (!abrirBotella.isPlaying()) {
      abrirBotella.play();
    }
    contador ++;
  }
  if (contador == 1) {
    timeLeft = 3000;
    if (!ganaste.isPlaying()) {
      ganaste.amp(.3);
      ganaste.play();
      cancion.stop();
    }
    pantalla = 2;
  }


  FBody coca = null;
  if (contacto.getBody1() == Mano) {
    coca = contacto.getBody2();
  } else if (contacto.getBody2() == Mano) {
    coca = contacto.getBody1();
  }

  if (coca == null) {
    return;
  }

  mundo.remove(coca);
  mundo.add(coca);
}

void restart() {
  caja.setPosition(300, 200);
  botella.setPosition(200, 200);
  for (int i=0; i<dinosaurios.length; i++) {
    dinosaurios[i].setPosition(500 + (i*70), puenteY-150);
  }
}

void oscEvent(OscMessage m) {

  if (m.addrPattern().equals("/annotations/thumb")) {
    pulgar.x = map( m.get(9).floatValue(), 0, 1000, width, 0 );
    pulgar.y = map( m.get(10).floatValue(), 0, 800, 0, height );
  }
  if (m.addrPattern().equals("/annotations/indexFinger")) {
    indice.x = map( m.get(9).floatValue(), 0, 1000, width, 0 );
    indice.y = map( m.get(10).floatValue(), 0, 800, 0, height );
  }
}
