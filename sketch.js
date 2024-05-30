let figuras = [];
let textura_papel;
let r;
let x1, x2, x3, x4, y1, y2, y3, y4;
let c1, c2, c3, c4;
let ImagenActual = 3;

let caminantes = [];

function preload() {
  for (let i = 0; i < 4; i++) {
    figuras.push(loadImage("imagenes/figura" + i + ".png"));
  }
  textura_papel = loadImage("imagenes/textura_fondo.png");
}

function setup() {
  createCanvas(594, 869);

  x1 = 150;
  x2 = 400;
  x3 = 400;
  x4 = 150;

  y1 = 300;
  y2 = 300;
  y3 = 600;
  y4 = 600;

  c1 = new Caminante(x1, y1);
  c2 = new Caminante(x2, y2);
  c3 = new Caminante(x3, y3);
  c4 = new Caminante(x4, y4);

  caminantes = [c1, c2, c3, c4];

  r = 25;
}

function draw() {
  background(textura_papel);
  push();
  imageMode(CENTER);
  image(figuras[ImagenActual], width / 2, height / 2);
  pop();
  push();
  strokeWeight(20);
  line(c1.x - r, c1.y - r, c2.x + r, c2.y - r);
  line(c2.x + r, c2.y - r, c3.x + r, c3.y + r);
  line(c3.x + r, c3.y + r, c4.x - r, c4.y + r);
  line(c4.x - r, c4.y + r, c1.x - r, c1.y - r);
  pop();

  console.log(mouseX, mouseY);

  for (let caminante of caminantes) {
    caminante.dibujar();
    caminante.mover(caminantes);
  }
}
function mouseClicked() {
  ImagenActual++;

  if (ImagenActual >= figuras.length) {
    ImagenActual = 0;
  }
}
