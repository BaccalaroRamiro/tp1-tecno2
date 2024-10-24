import gab.opencv.*;
import processing.core.*;
import processing.video.*;
import fisica.*;

boolean pruebaCamara = false;
PImage img;
OpenCV opencv;
FWorld mundo;
ArrayList<PVector> polygonPoints;
ArrayList<FCircle> balls;
FPoly poly;
FWorld world;

Capture camara;

int ancho = 640;
int alto = 480;
int umbral = 100;

void setup() {
  size(640, 480);

  // Inicializo el mundo físico
  Fisica.init(this);
  world = new FWorld();
  world.setGravity(0, 200); // Gravedad hacia abajo

  balls = new ArrayList<FCircle>();

  // Inicializo la cámara
  String[] listaDeCamaras = Capture.list();
  if (listaDeCamaras.length == 0) {
    println("No se encontraron cámaras.");
    exit();
  } else {
    camara = new Capture(this, listaDeCamaras[0]);
    camara.start();
  }

  // Inicializo OpenCV
  opencv = new OpenCV(this, ancho, alto);
  opencv.findContours();

  // Crear límites del mundo
  createBoundaries();
}

void draw() {
  background(0);
  if (camara.available()) {
    opencv.threshold(umbral);
    camara.read();
  }
  PImage salida = opencv.getOutput();

  if (pruebaCamara) {
    image(salida, 0, 0);
  }

  // Actualizar el mundo físico
  world.step();
  world.draw();

  // Encontrar y dibujar el contorno más grande
  findAndSimplifyLargestPolygon();

  // Crear círculos desde ambos lados cada cierto tiempo
  if (frameCount % 60 == 0) { // Cada segundo aprox.
    createball();
  }
  
  ArrayList contacts = poly.getContacts();
    for (int i=0; i<contacts.size(); i++) {
      FContact c = (FContact)contacts.get(i);
      line(c.getBody1().getX(), c.getBody1().getY(), c.getBody2().getX(), c.getBody2().getY());
    }
}

void createball() {
  FCircle ball = new FCircle(20);
  float xStart;
  float velocityX;
  
  // lado random
  if (random(1) < 0.5) {
    xStart = 10; // Lado izquierdo
    velocityX = random(300, 500); // Velocidad hacia la derecha
  } else {
    xStart = width - 10; // Lado derecho
    velocityX = random(-300, -150); // Velocidad hacia la izquierda
  }

  // Posición inicial aleatoria en Y
  ball.setPosition(xStart, random(50, 150));
  
  ball.setDensity(1.0); 

  ball.setVelocity(velocityX, random(-100, -200));

  world.add(ball);
  balls.add(ball);
}


void createBoundaries() {
  // Límites de la pantalla (rectángulos invisibles)
  FBox top = new FBox(width, 10);
  top.setPosition(width/2, 5);
  top.setStatic(true);
  world.add(top);

  FBox bottom = new FBox(width, 10);
  bottom.setPosition(width/2, height - 5);
  bottom.setStatic(true);
  world.add(bottom);

  FBox left = new FBox(10, height);
  left.setPosition(5, height/2);
  left.setStatic(true);
  world.add(left);

  FBox right = new FBox(10, height);
  right.setPosition(width - 5, height/2);
  right.setStatic(true);
  world.add(right);
}

void findAndSimplifyLargestPolygon() {
  if (poly != null) {
    world.remove(poly);
  }

  // Buscar contornos en la imagen
  opencv.loadImage(camara);
  opencv.threshold(umbral);
  opencv.findContours();
  ArrayList<Contour> contours = opencv.findContours();

  if (contours.size() > 0) {
    Contour largestContour = contours.get(0);

    // Encontrar el contorno más grande
    for (Contour contour : contours) {
      if (contour.area() > largestContour.area()) {
        largestContour = contour;
      }
    }

    // Simplificar el contorno
    largestContour = largestContour.getPolygonApproximation();

    // Dibujar el contorno simplificado
    stroke(0, 255, 0);
    strokeWeight(2);
    noFill();
    beginShape();
    polygonPoints = new ArrayList<PVector>();
    for (int i = 0; i < largestContour.numPoints(); i++) {
      PVector point = largestContour.getPoints().get(i);
      vertex(point.x, point.y);
      polygonPoints.add(point);
    }
    endShape(CLOSE);

    // Crear un nuevo objeto de físicas
    poly = new FPoly();
    for (PVector point : polygonPoints) {
      poly.vertex(point.x, point.y);
    }
    poly.setStatic(true);
    poly.setFill(0, 255, 0, 50);
    world.add(poly);
  }
}

void contactStarted(FContact c) {
  FBody ball = null;
  if (c.getBody1() == poly) {
    ball = c.getBody2();
  } else if (c.getBody2() == poly) {
    ball = c.getBody1();
  }

  if (ball == null) {
    return;
  }

  ball.setFill(30, 190, 200);
}
void contactPersisted(FContact c) {
  FBody ball = null;
  if (c.getBody1() == poly) {
    ball = c.getBody2();
  } else if (c.getBody2() == poly) {
    ball = c.getBody1();
  }

  if (ball == null) {
    return;
  }

  ball.setFill(255, 120, 200);

  noStroke();
  fill(255, 220, 0);
  ellipse(c.getX(), c.getY(), 10, 10);
}
void contactEnded(FContact c) {
  FBody ball = null;
  if (c.getBody1() == poly) {
    ball = c.getBody2();
  } else if (c.getBody2() == poly) {
    ball = c.getBody1();
  }

  if (ball == null) {
    return;
  }

  ball.setFill(0, 0, 0);
}
