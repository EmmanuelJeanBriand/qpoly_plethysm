import unittest
from barvinok_parser import *
load("Barvinok.sage")


ex1_input = r"""{ [s] -> ((((((3/5 - 289/720 * s + 1/20 * s^2 + 1/720 * s^3) + (5/8 + 1/8 * s) *
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

ex1_output = r"""{(0,): [(1/720*s^3 - 1/36*(2*s - 7)*s + 1/16*(s + 5)*s - 1/18*(s - 2)*s + 7/90*s^2 - 289/720*s + 1, [A 1-dimensional polyhedron in QQ^1 defined as the convex hull of 1 vertex and 1 ray]), (1, [A 0-dimensional polyhedron in QQ^1 defined as the convex hull of 1 vertex])], (1,): [(1/720*s^3 - 1/36*(2*s - 5)*(s - 1) + 1/16*(s + 5)*(s - 1) + 1/36*(s - 1)^2 - 1/18*(s - 1)*(s - 2) + 1/20*s^2 - 289/720*s + 7/20, [A 1-dimensional polyhedron in QQ^1 defined as the convex hull of 1 vertex and 1 ray]), (1, [A 0-dimensional polyhedron in QQ^1 defined as the convex hull of 1 vertex])], (2,): [(1/3600*(s^3 - 20*(2*s - 3)*(s + 1) + 20*(s + 1)^2 - 40*(s - 2)^2 + 45*(s + 5)*s + 36*s^2 - 289*s + 396)*(s + 3) - 1/3600*(s^3 - 20*(2*s - 3)*(s + 1) + 20*(s + 1)^2 - 40*(s - 2)^2 + 45*(s + 5)*s + 36*s^2 - 289*s + 396)*(s - 2), [A 1-dimensional polyhedron in QQ^1 defined as the convex hull of 1 vertex and 1 ray]), (1, [A 0-dimensional polyhedron in QQ^1 defined as the convex hull of 1 vertex])], (3,): [(1/3600*(s^3 + 45*(s + 5)*(s - 1) - 20*(2*s - 7)*s - 40*(s - 2)*s + 56*s^2 - 289*s + 396)*(s + 2) - 1/3600*(s^3 + 45*(s + 5)*(s - 1) - 20*(2*s - 7)*s - 40*(s - 2)*s + 56*s^2 - 289*s + 396)*(s - 3), [A 1-dimensional polyhedron in QQ^1 defined as the convex hull of 1 vertex and 1 ray]), (1, [A 0-dimensional polyhedron in QQ^1 defined as the convex hull of 1 vertex])], (4,): [(1/3600*(s^3 - 20*(2*s - 5)*(s - 1) + 20*(s - 1)^2 - 40*(s - 1)*(s - 2) + 45*(s + 5)*s + 36*s^2 - 289*s + 576)*(s + 1) - 1/3600*(s^3 - 20*(2*s - 5)*(s - 1) + 20*(s - 1)^2 - 40*(s - 1)*(s - 2) + 45*(s + 5)*s + 36*s^2 - 289*s + 576)*(s - 4), [A 1-dimensional polyhedron in QQ^1 defined as the convex hull of 1 vertex and 1 ray]), (1, [A 0-dimensional polyhedron in QQ^1 defined as the convex hull of 1 vertex])]}"""

ex1_parsed = [{'domain': [{'quantifiers': {'e0': 'floor((-1 + s)/5)'}, 
                           'linear conditions': ['5 * e0 == -1 + s', 's >= 1']
                          }], 
               'quasipolynomial': {'variables': ['s'], 
                                   'formula': '((((((3/5 - 289/720 * s + 1/20 * s^2 + 1/720 * s^3) + (5/8 + 1/8 * s) * floor((s)/2)) + (1/3 - 1/6 * s) * floor((s)/3)) + ((7/12 - 1/3 * s) + 1/2 * floor((s)/3)) * floor((1 + s)/3) + 1/4 * floor((1 + s)/3)^2) + 1/4 * floor((s)/4)) - 1/4 * floor((3 + s)/4))'
                                  }
              },
              {'domain': [{'quantifiers': {'e0': 'floor((-1 + s)/5)', 'e1': 'floor((s)/5)'},
                           'linear conditions': ['5 * e1 == s', 's >= 5', '5 * e0 <= -2 + s',
                                                 '5 * e0 >= -5 + s']
                          }], 
               'quasipolynomial': {'variables': ['s'], 
                                   'formula': '((((((1 - 289/720 * s + 1/20 * s^2 + 1/720 * s^3) + (5/8 + 1/8 * s) * floor((s)/2)) + (1/3 - 1/6 * s) * floor((s)/3)) + ((7/12 - 1/3 * s) + 1/2 * floor((s)/3)) * floor((1 + s)/3) + 1/4 * floor((1 + s)/3)^2) + 1/4 * floor((s)/4)) - 1/4 * floor((3 + s)/4))'
                                  }
              }, {'domain': [{'quantifiers': {'e0': 'floor((-1 + s)/5)', 'e1': 'floor((s)/5)'}, 
                              'linear conditions': ['s >= 1', '5 * e0 <= -2 + s', '5 * e0 >= -5 + s', 
                                                    '5 * e1 <= -1 + s', '5 * e1 >= -4 + s']
                             }], 
                  'quasipolynomial': {'variables': ['s'], 
                                      'formula': '(((((((-4/5 + 289/720 * s - 1/20 * s^2 - 1/720 * s^3) + (-5/8 - 1/8 * s) * floor((s)/2)) + (-1/3 + 1/6 * s) * floor((s)/3)) + ((-7/12 + 1/3 * s) - 1/2 * floor((s)/3)) * floor((1 + s)/3) - 1/4 * floor((1 + s)/3)^2) - 1/4 * floor((s)/4)) + 1/4 * floor((3 + s)/4)) * floor((s)/5) + ((((((4/5 - 289/720 * s + 1/20 * s^2 + 1/720 * s^3) + (5/8 + 1/8 * s) * floor((s)/2)) + (1/3 - 1/6 * s) * floor((s)/3)) + ((7/12 - 1/3 * s) + 1/2 * floor((s)/3)) * floor((1 + s)/3) + 1/4 * floor((1 + s)/3)^2) + 1/4 * floor((s)/4)) - 1/4 * floor((3 + s)/4)) * floor((3 + s)/5))'
                                     }
                 }, 
              {'domain': [{'quantifiers': {}, 
                           'linear conditions': ['s == 0']
                          }], 
               'quasipolynomial': {'variables': ['s'], 
                                   'formula': '1'
                                  }
              }
             ]

ex2_parsed = [{'domain': [{'quantifiers': {'e0': 'floor((-1 + b1)/3)'}, 
                           'linear conditions': ['3 * e0 == -1 + b1', 'b1 >= 1', 's <= -2 + b1', 
                                                 '3 * s >= 1 + 2 * b1']
                          }],
               'quasipolynomial': {'variables': ['b1', 's'], 
                                   'formula': '((((-2/3 + 2/3 * b1) + s) - floor((b1)/2)) - floor((b1 + s)/2))'}
              },
              {'domain': [{'quantifiers': {'e0': 'floor((-1 + b1)/3)'}, 
                           'linear conditions': ['s == -1 + b1', '3 * e0 == -1 + b1', 'b1 >= 4']
                          }, 
                          {'quantifiers': {'e0': 'floor((-1 + b1)/3)'}, 
                           'linear conditions': ['3 * e0 == -1 + b1', 'b1 >= 1', 's >= b1']
                          }], 
               'quasipolynomial': {'variables': ['b1', 's'], 
                                   'formula': '((-2/3 + 2/3 * b1) - floor((b1)/2))'}
              }, 
              {'domain': [{'quantifiers': {'e0': 'floor((-1 + b1)/3)','e1': 'floor((-2 + b1)/3)'},
                           'linear conditions': ['s == -1 + b1', '3 * e1 == -2 + b1', 'b1 >= 3', 
                                                 '3 * e0 >= -3 + b1', '3 * e0 <= -2 + b1']
                          }, 
                          {'quantifiers': {'e0': 'floor((-1 + b1)/3)', 'e1': 'floor((-2 + b1)/3)'},
                           'linear conditions': ['3 * e1 == -2 + b1', 'b1 >= 1', 's >= b1', 
                                                 '3 * e0 >= -3 + b1', '3 * e0 <= -2 + b1']
                          }], 
               'quasipolynomial': {'variables': ['b1', 's'], 
                                   'formula': '((-1/3 + 2/3 * b1) - floor((b1)/2))'}
              }, 
              {'domain': [{'quantifiers': {'e0': 'floor((-1 + b1)/3)', 'e1': 'floor((b1)/3)'},
                           'linear conditions': ['3 * e1 == b1', '3 * s >= 2 * b1', 's <= -2 + b1', 
                                                 '3 * e0 >= -3 + b1', '3 * e0 <= -2 + b1']
                          }], 
               'quasipolynomial': {'variables': ['b1', 's'], 
                                   'formula': '(((2/3 * b1 + s) - floor((b1)/2)) - floor((b1 + s)/2))'
                                  }
              }, 
              {'domain': [{'quantifiers': {'e0': 'floor((-1 + b1)/3)', 'e1': 'floor((b1)/3)', 
                                           'e2': 'floor((-2 + b1)/3)'},
                           'linear conditions': ['3 * e2 == -2 + b1', '3 * s >= 2 * b1', 's <= -2 + b1', 
                                                 '3 * e0 >= -3 + b1', '3 * e0 <= -2 + b1', 
                                                 '3 * e1 <= -1 + b1', '3 * e1 >= -2 + b1']
                          }], 
               'quasipolynomial': {'variables': ['b1', 's'], 
                                   'formula': '((((-1/3 + 2/3 * b1) + s) - floor((b1)/2)) - floor((b1 + s)/2))'}
              }, 
              {'domain': [{'quantifiers': {'e0': 'floor((-1 + b1)/3)', 'e1': 'floor((-2 + b1)/3)',
                                           'e2': 'floor((-3 + b1)/3)'}, 
                           'linear conditions': ['s == -1 + b1', '3 * e2 == -3 + b1', 'b1 >= 3', 
                                                 '3 * e0 >= -3 + b1', '3 * e0 <= -2 + b1', 
                                                 '3 * e1 >= -4 + b1', '3 * e1 <= -3 + b1']
                          }, 
                          {'quantifiers': {'e0': 'floor((-1 + b1)/3)', 'e1': 'floor((-2 + b1)/3)',
                                           'e2': 'floor((b1)/3)'}, 
                           'linear conditions': ['3 * e2 == b1', 'b1 >= 1', 's >= b1', '3 * e0 >= -3 + b1',
                                                 '3 * e0 <= -2 + b1', '3 * e1 >= -4 + b1', 
                                                 '3 * e1 <= -3 + b1']
                          }], 
               'quasipolynomial': {'variables': ['b1', 's'], 
                                   'formula': '(2/3 * b1 - floor((b1)/2))'}
              }]

case00=r'''[(-1/3*b1 + 1/2*s, [A 2-dimensional polyhedron in QQ^2 defined as the convex hull of 1 vertex and 2 rays]), (1/6*b1, [A 1-dimensional polyhedron in QQ^2 defined as the convex hull of 1 vertex and 1 ray, A 2-dimensional polyhedron in QQ^2 defined as the convex hull of 1 vertex and 2 rays])]'''

class TestBarvinok(unittest.TestCase):
    

    def test_BarvinokFunction(self):
        global case00
    
        with open('all-qpoly/111.qpoly') as f:
            data = f.read()
        bv = BarvinokFunction(data)
        self.assertEqual(str(bv.main_vars), '(b1, s)')
        output = bv.modRepresentation()
        self.assertEqual(str(bv.mods), '[3, 1]')
        self.assertEqual(str(output[0,0]), case00)
        
    def test_Barvinok_one_var(self):
        global ex1_input, ex1_output
        bv = BarvinokFunction(ex1_input)
        self.assertEqual(str(bv.modRepresentation()), ex1_output)
        
    def test_parse(self):                
        with open('all-qpoly/111.qpoly') as f:
            data = f.read()
        self.assertEqual(parse_function(data), ex2_parsed)
        
    def test_parse_one_var(self):
        global ex1_input, ex1_output
        self.assertEqual(parse_function(ex1_input), ex1_parsed)
        
if __name__ == '__main__':
    unittest.main()
    
    
    
    
    