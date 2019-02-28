

ph = 1.618034;
iph = 1/ph;
dihedral = 116.565;

vertices =
[
    [   1,  1,  1],    //  0
    [   1,  1,  -1],   //  1
    [   1, -1, -1],    //  2
    [   1, -1,  1],    //  3
    [  -1,  1,  1],   //  4
    [  -1,  1,  -1],  //  5
    [  -1, -1, -1],   //  6
    [  -1, -1,  1],   //  7
    
    [  0, ph, iph],   // 8
    [  0, ph, -iph],  // 9
    [  0, -ph, iph],  // 10
    [  0, -ph, -iph], // 11
    
    [iph, 0, ph],  // 12
    [iph, 0, -ph],  // 13
    [-iph, 0, ph],  // 14
    [-iph, 0, -ph],  // 15
    
    [ph, iph, 0],  // 16
    [ph, -iph, 0],  // 17
    [-ph, iph, 0],  // 18
    [-ph, -iph, 0],  // 19
];

edges = 
[
    [ 0,  8], [ 0, 12], [ 0, 16],    
    [ 1,  9], [ 1, 13], [ 1, 16],
    [ 2, 11], [ 2, 13], [ 2, 17],
    [ 3, 10], [ 3, 12], [ 3, 17],
    [ 4,  8], [ 4, 14], [ 4, 18],
    [ 5,  9], [ 5, 15], [ 5, 18],
    [ 6, 11], [ 6, 15], [ 6, 19],
    [ 7, 10], [ 7, 14], [ 7, 19],
    
    [ 9,  8], [11, 10],
    [13, 15], [12, 14],
    [16, 17], [18, 19],
];

interiorRects =
[
   [ 0, 11], [ 0, 15], [ 0, 19],
   [ 1, 10], [ 1, 14], [ 1, 19],
   [ 2,  8], [ 2, 14], [ 2, 18],
   [ 3,  9], [ 3, 15], [ 3, 18],
   [ 4, 11], [ 4, 13], [ 4, 17],
   [ 5, 10], [ 5, 12], [ 5, 17],
   [ 6,  8], [ 6, 12], [ 6, 16],
   [ 7,  9], [ 7, 13], [ 7, 16],
   
   [ 8, 10],
   [ 9, 11],
   [15, 14],
   [13, 12],
   [19, 17],
   [16, 18]

];

interiorTest =
[
];

interiorDiameters =
[
    [ 0, 6], 
    [1, 7], 
    [2, 4],
    [ 9, 10], 
    [11,  8],
    [15, 12], 
    [13, 14],
    [16, 19], 
    [18, 17],
    [3, 5]
];

/*
for (v = vertices)
{
    translate(v * 10) cube([1, 1, 1,]);
}
*/

//https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Tips_and_Tricks#Drawing_%22lines%22_in_OpenSCAD

// Find the unitary vector with direction v. Fails if v=[0,0,0].
function unit(v) = norm(v)>0 ? v/norm(v) : undef; 
// Find the transpose of a rectangular matrix
function transpose(m) = // m is any rectangular matrix of objects
  [ for(j=[0:len(m[0])-1]) [ for(i=[0:len(m)-1]) m[i][j] ] ];
// The identity matrix with dimension n
function identity(n) = [for(i=[0:n-1]) [for(j=[0:n-1]) i==j ? 1 : 0] ];

// computes the rotation with minimum angle that brings a to b
// the code fails if a and b are opposed to each other
function rotate_from_to(a,b) = 
    let( axis = unit(cross(a,b)) )
    axis*axis >= 0.99 ? 
        transpose([unit(b), axis, cross(axis, unit(b))]) * 
            [unit(a), axis, cross(axis, unit(a))] : 
        identity(3);

// An application of the minimum rotation
// Given to points p0 and p1, draw a thin cylinder with its
// bases at p0 and p1
module line(p0, p1, diameter=1) {
    v = p1-p0;
    
    translate(p0)
        // rotate the cylinder so its z axis is brought to direction v
        multmatrix(rotate_from_to([0,0,1],v))
            cylinder(d=diameter, h=norm(v), $fn=24);
}

module lineExtend(p0, p1, diameter=1, extend = 2) {
    v = p1-p0;
    
    u = unit(v);
    
    translate(p0 - u * extend)
        // rotate the cylinder so its z axis is brought to direction v
        multmatrix(rotate_from_to([0,0,1],v))
            cylinder(d=diameter, h=norm(v + u * extend * 2), $fn=24);
}

module plotEdgeList(edgeList, scale, diameter)
{
    for (e = edgeList)
    {
        p0 = vertices[e[0]] * scale;
        p1 = vertices[e[1]] * scale;
        lineExtend(p0, p1, diameter, .5);
    }
}

module dodecahedron(scale, diameter)
{
    plotEdgeList(edges, scale, diameter);
}

module simpleDodecahedron()
{
    rotate([0, dihedral/2, 0]) 
        dodecahedron(20, 4);
}

//simpleDodecahedron();

rotate([0, dihedral/2, 0])
{
    scale = 30;
    dia = 5;
    color("green", 0.5) dodecahedron(scale, dia);
    color("red") plotEdgeList(interiorRects, scale, dia);
    //color("blue") plotEdgeList(interiorDiameters, scale, dia);
}


