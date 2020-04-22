
# akvarko bez pukliny
mesh.yaml - model akvarka bez pukliny, pocatek souradnic v levem dolnim rohu v bode X=2,Y=0 cm
parametry: 
sirka 77cm
vysky hladiny: 27, 38
repository: X=21, Y=25

make mesh:

gmsh -2 -format msh2 mesh.geo


# akvarko s puklinou
mesh_frac.yaml - model akvarka bez pukliny, pocatek souradnic v levem dolnim rohu v bode 2,2 cm

make mesh:

gmsh -2 -format msh2 mesh.geo
