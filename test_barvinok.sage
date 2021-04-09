import unittest
load("Barvinok.sage") 

case00=r'''[(-1/3*b1 + 1/2*s, [A 2-dimensional polyhedron in QQ^2 defined as the convex hull of 1 vertex and 2 rays]), (1/6*b1, [A 1-dimensional polyhedron in QQ^2 defined as the convex hull of 1 vertex and 1 ray, A 2-dimensional polyhedron in QQ^2 defined as the convex hull of 1 vertex and 2 rays])]'''

class TestBarvinok(unittest.TestCase):

    def test_BarvinokFunction(self):
        global case00
        dir = "all-qpoly/"
        label = "111"
        with open(dir + label + '.qpoly') as f:
            data = f.read()
        bv = BarvinokFunction(data)
        self.assertEqual(str(bv.main_vars), '[b1, s]')
        output = bv.modRepresentation()
        self.assertEqual(str(bv.mods), '[3, 1]')
        self.assertEqual(str(output[0,0]), case00)

if __name__ == '__main__':
    unittest.main()
    
    
    
    
    