//import toxi.math.conversion.*;
//import toxi.geom.*;
//import toxi.math.*;
//import toxi.geom.mesh2d.*;
//import toxi.util.datatypes.*;
//import toxi.util.events.*;
//import toxi.geom.mesh.subdiv.*;
//import toxi.geom.mesh.*;
//import toxi.math.waves.*;
//import toxi.util.*;
//import toxi.math.noise.*;
//import toxi.processing.*;

//ToxiclibsSupport gfx;
//Voronoi voronoi;

//void initVoronoi() {
//  gfx = new ToxiclibsSupport( this );
//  voronoi = new Voronoi();

//  for ( int i = 0; i < 400; i++ ) {
//    voronoi.addPoint( new Vec2D( random(width), random(startH, startH + bigSideH) ) );
//  }
//}

//void drawVoronoi() {
//  int i = 0;
//  stroke(255);
//  strokeWeight(4);
//  for ( Polygon2D polygon : voronoi.getRegions() ) {
//    i++;
//    o.fill((millis()/300 + i*20) % 255 );
//    gfx.polygon2D( polygon );
//  }
//}