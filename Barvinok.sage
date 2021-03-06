from sympy import * 
from sage.arith.functions import LCM_list
import re 

init_printing()

str1 = """{ [s] -> ((((((3/5 - 289/720 * s + 1/20 * s^2 + 1/720 * s^3) + (5/8 + 1/8 * s) *
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

str2 = """{ [b1, s] -> (2/3 + 1/3 * b1) : exists (e0 = floor((-1 + b1)/3): 3e0 = -1 + b1 and 3s >= 1 + 2b1 and b1 >= 1 and s >= 1 + b1); [b1, s] -> ((2/3 - 1/6 * b1 - 1/2 * b1^2) + (1/2 + b1) * s - 1/2 * s^2) : exists (e0 = floor((-1 + b1)/3): 3e0 = -1 + b1 and 3s >= 1 + 2b1 and s >= -1 + b1 and s <= b1); [b1, s] -> ((2/3 - 2/3 * b1) + s) : exists (e0 = floor((-1 + b1)/3): 3e0 = -1 + b1 and 3s >= 1 + 2b1 and s <= -2 + b1); [b1, s] -> 1/3 * b1 : exists (e0 = floor((-1 + b1)/3), e1 = floor((b1)/3): 3e1 = b1 and b1 >= 1 and s >= 1 + b1 and 3e0 >= -3 + b1 and 3e0 <= -2 + b1); [b1, s] -> ((-1/6 * b1 - 1/2 * b1^2) + (1/2 + b1) * s - 1/2 * s^2) : exists (e0 = floor((-1 + b1)/3), e1 = floor((b1)/3): 3e1 = b1 and b1 >= 1 and 3s >= 2b1 and s >= -1 + b1 and s <= b1 and 3e0 <= -2 + b1 and 3e0 >= -3 + b1); [b1, s] -> (1/3 + 1/3 * b1) : exists (e0 = floor((-1 + b1)/3), e1 = floor((b1)/3), e2 = floor((-2 + b1)/3): 3e2 = -2 + b1 and b1 >= 1 and s >= 1 + b1 and 3e0 >= -3 + b1 and 3e0 <= -2 + b1 and 3e1 <= -1 + b1 and 3e1 >= -2 + b1); [b1, s] -> ((1/3 - 1/6 * b1 - 1/2 * b1^2) + (1/2 + b1) * s - 1/2 * s^2) : exists (e0 = floor((-1 + b1)/3), e1 = floor((b1)/3), e2 = floor((-2 + b1)/3): 3e2 = -2 + b1 and b1 >= 1 and 3s >= 2b1 and s >= -1 + b1 and s <= b1 and 3e0 <= -2 + b1 and 3e0 >= -3 + b1 and 3e1 <= -1 + b1 and 3e1 >= -2 + b1); [b1, s] -> (-2/3 * b1 + s) : exists (e0 = floor((-1 + b1)/3), e1 = floor((b1)/3): 3e1 = b1 and 3s >= 2b1 and s <= -2 + b1 and 3e0 <= -2 + b1 and 3e0 >= -3 + b1); [b1, s] -> ((1/3 - 2/3 * b1) + s) : exists (e0 = floor((-1 + b1)/3), e1 = floor((b1)/3), e2 = floor((-2 + b1)/3): 3e2 = -2 + b1 and 3s >= 2b1 and s <= -2 + b1 and 3e0 <= -2 + b1 and 3e0 >= -3 + b1 and 3e1 <= -1 + b1 and 3e1 >= -2 + b1) }"""

#Only works on 1-variable case with "s" as variable
def floorDenominators(expr, var = None):
    # Returns the denominators of the interior of "floor" functions in ``expr`` as a list
    expr_str = str(expr)
    explist = []
    auxstr = expr_str
    while (auxstr.find("floor")!=-1):
        a = auxstr.find("floor")
        auxstr = auxstr[a:]
        b = auxstr.find(')')
        if  var == None:
            explist.append(auxstr[5:b+1])
            auxstr = auxstr[b:]
        else:
            if auxstr[5:b+1].has(var):
                explist.append(auxstr[5:b+1])
            auxstr = auxstr[b:]
    denominators = []
    for i in explist:
        denominators.append(sage_eval(i, locals = vardic).denominator())
    return denominators
                            
def floorReduction(n,expr):
    # Returns ``expr`` as a polynomial in ``s`` when `s \equiv m \mod k , where k is a multiple of ``expr.denominator()``
    d = int(expr.denominator())
    N = expr.numerator()
    t = n%d
    return (N-t)/d
    
    
##Prueba 

def getFstList(s): 
    # Returns the first occurrence of a list (seen as  in `s`
    lb = s.find("[")
    rb = s.find("]")
    return s[lb:rb+1]

def floorToMod(expr, m ):
    aux = vardic
    aux['F'] = lambda X: floorReduction(m ,X)
    return factor(sage_eval(str(expr).replace('floor','F'), locals= aux))
##


class BarvinokOutput():
    # Bvop is the output string
    def __init__(self,bvop,r=1):
        global vardic , vartuple
        self.var_string = getFstList(bvop)
        chambers_all = bvop.split( self.var_string + " ->")[1:]
        varliststring = self.var_string[1:-1].split(', ')
        varlistspace = self.var_string[1:-1].replace(',',' ')
        vartuple = var(varlistspace)
        vardic = {}
        if (len(varliststring) > 1):
            for i in range(len(varliststring)):
                vardic[varliststring[i]] = vartuple[i]
        else:
            vardic[varliststring[0]] = vartuple 
        self.chambers_all = chambers_all
        self.n_chambers = len(self.chambers_all)
        self.chambers_split = [self.chambers_all[i].split(":",1) for i in range(self.n_chambers)]
        self.value = [self.chambers_split[i][0] for i in range(self.n_chambers)]
        self.condition = [self.chambers_split[i][1] for i in range(self.n_chambers)]
        self.expressions = [sage_eval(self.value[i], locals = vardic) for i in range(self.n_chambers)]
        self.lcm = [LCM_list(floorDenominators(expr)+[r]) for expr in self.expressions]
        self.modExpressions  = [[floorToMod(expr , i) for i in range(LCM_list(floorDenominators(expr)))] for expr in self.expressions]

    #Print general information of the output string
    def info(self):
        print("VARIABLES = ", vartuple)
        for i in range(self.n_chambers):
            print("++++++++++++++++++++++", "CHAMBER ",i+1,"++++++++++++++++++++++")
            print()
            print("EXPRESSION = ",self.value[i] )
            print()
            print("CONDITIONS = ", self.condition[i])
            print()
   
    def mod_info(self):
        if (not(type(vartuple) is tuple)):
            print("VARIABLES = ", vartuple)
            for i in range(self.n_chambers):
                print("++++++++++++++++++++++", "CHAMBER ",i+1,"++++++++++++++++++++++")
                print()
                print("EXPRESSION ", i+1 , " DEPENDING ON CONGRUENCE OF ", vartuple, " mod ", str(self.lcm[i]))
                for j in range(self.lcm[i]):
                    print()
                    print(vartuple, " # ", j, " mod ", str(self.lcm[i]) )
                    print()
                    print(self.modExpressions[i][j])
                    print()
        else: 
            print("The multivariable mod_info function is in development process")
        
            



"""
bvo = BarvinokOutput(str2)
bvo.info()
print(bvo.eval(1,2))"""
