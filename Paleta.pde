class Paleta {

  PImage imagen;
  int posX, posY;
  color colores[];


  Paleta (String nombreArchivo) {

    imagen = loadImage(nombreArchivo);
    colores = new color[4];
  }

  color darUnColor() {

    posX = int(random(imagen.width));
    posY = int(random(imagen.height));
    return imagen.get(posX, posY);
  }

  color darUnColorFondo() {


    colores[0] =  color(235, 218, 202) ;
    colores[1] =  color(232, 218, 205) ;
    colores[2] =  color(235, 233, 234) ;
    colores[3] =  color(219, 198, 167) ;


    return colores[int(random(0, 3))];
  }
}
