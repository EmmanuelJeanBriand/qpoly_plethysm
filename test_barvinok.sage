import unittest
load("Barvinok.sage") 

ex1= r"""{ [s] -> ((((((3/5 - 289/720 * s + 1/20 * s^2 + 1/720 * s^3) + (5/8 + 1/8 * s) *
floor((s)/2)) + (1/3 - 1/6 * s) * floor((s)/3)) + ((7/12 - 1/3 * s) + 1/2 *
floor((s)/3)) * floor((1 + s)/3) + 1/4 * floor((1 + s)/3)^2) + 1/4 * floor((s)/4))
- 1/4 * floor((3 + s)/4)) : exists (e0 = floor((-1 + s)/5): 5e0 = -1 + s and s >= 1);
[s] -> ((((((1 - 289/720 * s + 1/20 * s^2 + 1/720 * s^3) + (5/8 + 1/8 * s) *
floor((s)/2)) + (1/3 - 1/6 * s) * floor((s)/3)) + ((7/12 - 1/3 * s) + 1/2 *
floor((s)/3)) * floor((1 + s)/3) + 1/4 * floor((1 + s)/3)^2) + 1/4 * floor((s)/4)) -
1/4 * floor((3 + s)/4)) : exists (e0 = floor((-1 + s)/5), e1 = floor((s)/5): 5e1 = s
and s >= 5 and 5e0 <= -2 + s and 5e0 >= -5 + s); [s] -> (((((((-4/5 + 289/720 * s -
1/20 * s^2 - 1/720 * s^3) + (-5/8 - 1/8 * s) * floor((s)/2)) + (-1/3 + 1/6 * s) *
floor((s)/3)) + ((-7/12 + 1/3 * s) - 1/2 * floor((s)/3)) * floor((1 + s)/3) - 1/4 *
floor((1 + s)/3)^2) - 1/4 * floor((s)/4)) + 1/4 * floor((3 + s)/4)) * floor((s)/5) +
((((((4/5 - 289/720 * s + 1/20 * s^2 + 1/720 * s^3) + (5/8 + 1/8 * s) * floor((s)/2)) +
(1/3 - 1/6 * s) * floor((s)/3)) + ((7/12 - 1/3 * s) + 1/2 * floor((s)/3)) *
floor((1 + s)/3) + 1/4 * floor((1 + s)/3)^2) + 1/4 * floor((s)/4)) - 1/4 *
floor((3 + s)/4)) * floor((3 + s)/5)) : exists (e0 = floor((-1 + s)/5), e1 =
floor((s)/5): s >= 1 and 5e0 <= -2 + s and 5e0 >= -5 + s and 5e1 <= -1 + s and
5e1 >= -4 + s); [s] -> 1 : s = 0 }"""

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
        
    def test_Barvinok_one_var(self):
        global ex1
        bv = BarvinokFunction(ex1)

if __name__ == '__main__':
    unittest.main()
    
    
    
    
    