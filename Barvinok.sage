from sage.arith.functions import LCM_list
import itertools
import re 

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

str3 = open('1111.txt', 'r').read()

def rangeList(lis):
    res = []
    for elem in lis:
        res.append(range(elem))
    return res
    
# better:
def rangeList(lis):
    r"""
    EXAMPLE::
    
        >>> rangeList([1,5,8])
        [range(0, 1), range(0, 5), range(0, 8)]
    """
    return [range(elem) for elem in lis]
    
def listToDic(lis):
    dic={}
    for i, var in enumerate(vardic):
        if var != 'F' :
            dic[var] = lis[i]
    return dic
    
# better
def listToDic(lis):
    return { var: lis[i] for  i, var in enumerate(vardic) if var != 'F'}

def floorDenominators(expr, var = None):
    # Returns the denominators of the interior of "floor" functions in ``expr`` as a list
    expr_str = str(expr)
    explist = []
    auxstr = expr_str
    count = 0
    par_match = find_parens(expr_str)

    while (auxstr.find("floor")!=-1):
        a = auxstr.find("floor")
        auxstr = auxstr[a:]
        b = find_parens(expr_str)[count+a+5] - a - count
        if  var == None:
            explist.append(auxstr[5:b+1])
            auxstr = auxstr[b:]
            count+= a + b
        else:
            if sage_eval(auxstr[5:b+1],locals = vardic).has(var):
                explist.append(auxstr[5:b+1])
            auxstr = auxstr[b:]
            count+= a + b
    denominators = []
    for i in explist:
   
        denominators.append(sage_eval(i, locals = vardic).denominator())
    return denominators




def groupList(l):
    group = {}
    for index,elem in enumerate(l):
        if (not elem in group):
            group[elem] = [index]
        else:
            group[elem].append(index)
    return group
    
    
def getFstList(s): 
    # Returns the first occurrence of a list (seen as a substring of `s`)
    lb = s.find("[")
    rb = s.find("]")
    return s[lb:rb+1]
##

def find_parens(s):
    toret = {}
    pstack = []

    for i, c in enumerate(s):
        if c == '(':
            pstack.append(i)
        elif c == ')':
            if len(pstack) == 0:
                raise IndexError("No matching closing parens at: " + str(i))
            toret[pstack.pop()] = i

    if len(pstack) > 0:
        raise IndexError("No matching opening parens at: " + str(pstack.pop()))

    return toret


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
        self.expressions = [sage_eval(self.fixFloor(self.value[i]), locals = vardic) for i in range(self.n_chambers)]
        self.lcm = [[LCM_list(floorDenominators(expr,vardic[var])+[r]) for var in vardic] for expr in self.expressions]
        self.modExpressions  = [[self.floorToMod( self.expressions[i],listToDic(list(elem))  )  for elem in list(itertools.product(*(rangeList(self.lcm[i]))))] for i in range(self.n_chambers)]
      
        
    def floorReduction(self, dic, expr):
        d = int(expr.denominator())

        N = expr.numerator()
        t = (sage_eval(str(N), locals = dic))%d
            
        return factor((N-t)/d)


    def floorToMod(self, expr, dic ):
        aux = vardic
        aux['F'] = lambda X: self.floorReduction(dic ,X)
        return sage_eval(str(expr).replace('floor','F'), locals= aux)        
        
# messy. Probably should use "split"        
    def fixFloor(self,floorstr):
        res = floorstr
        res2 = ""
        count = 0
        count2 = 0
        count3 = 0
        while (res.find("floor") != -1):
            a = res.find("floor")
            exp = res[a:]
            b = find_parens(floorstr)[a + count  + 5 + count2] - count - a 
            count += a + b  
            exp = exp[:b+1]
            for var in vardic:
                ind = exp.find(var)
                if (ind != -1) :
                    if (exp[ind-1] == " " or exp[ind-1] == "(" or ind == 0):
                        pass
                     
                    else:
                        res = str(res[:ind+a+count3])+"*"+str(res[ind+a+count3:])
                        count -= 1
                        count2 += 1
                        count3 += 1
                        
            res2 = str(res2)+str(res[:a+b+count3])
            res = res[a+b+count3:]
            count3 = 0
        return res2 + floorstr[count + count2:]  
        

    

    def FloorLCM(self, i, var = None):
        LCM_list(floorDenominators(self.expressions[i], var))
    
    def expression(self, i, elem):
        return self.floorToMod(self.expressions[i], listToDic(list(elem))) 

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
   
    def mod_info(self , group = False, difference = True):
        if (not(type(vartuple) is tuple)):
            if not group :            
                print("VARIABLES = ", vartuple)
                for i in range(self.n_chambers):
                    print()
                    print("++++++++++++++++++++++ EXPRESSION ", i+1 , " DEPENDING ON CONGRUENCE OF ", vartuple, " mod ", str(self.lcm[i]),"++++++++++++++++++++++")
                    for j in range(self.lcm[i][0]):
                        print()
                        print(vartuple, " # ", elem , " mod ", str(self.lcm) )
                        print()
                        if not difference:                            
                            print(self.modExpressions[i][j])
                            print()
                        else:
                            print(self.modExpressions[i][j] - self.modExpressions[i][0])
                        
            elif group : 
                print("VARIABLES = ", vartuple)
                for i in range(self.n_chambers):
                    print()
                    print("++++++++++++++++++++++ EXPRESSION ", i+1 , " DEPENDING ON CONGRUENCE OF ", vartuple, " mod ", str(self.lcm[i]),"++++++++++++++++++++++")
                    for elem in groupList(self.modExpressions[i]):
                        print()
                        print(vartuple, " # ", groupList(self.modExpressions[i])[elem]) , " mod ", str(self.lcm[i]) 
                        print()
                        if not difference:
                            print(elem)
                            print()
                        else:
                            print(elem - self.modExpressions[i][0])
                            print()
        else: 
            
            if not group and difference:            
                print("VARIABLES = ", vartuple)
                for i in range(self.n_chambers):
                    print()
                    print("++++++++++++++++++++++ EXPRESSION ", i+1 , "- 0 DEPENDING ON CONGRUENCE OF ", vartuple, " mod ", str(self.lcm[i]),"++++++++++++++++++++++")
                    
                    for j , elem in enumerate(itertools.product(*(rangeList(self.lcm[i])))):
                        print()
                        print(vartuple, " # ", elem , " mod ", str(self.lcm[i]) )
                        print()
                        print(self.modExpressions[i][j] - self.modExpressions[i][0])
                        print()   
                        print("-----------------------------------------------------------")
                        
            if not group and  not difference:            
                print("VARIABLES = ", vartuple)
                for i in range(self.n_chambers):
                    print()
                    print("++++++++++++++++++++++ EXPRESSION ", i+1 , " DEPENDING ON CONGRUENCE OF ", vartuple, " mod ", str(self.lcm[i]),"++++++++++++++++++++++")
                    
                    for j , elem in enumerate(itertools.product(*(rangeList(self.lcm[i])))):
                        print()
                        print(vartuple, " # ", elem , " mod ", str(self.lcm[i]) )
                        print()
                        print(self.modExpressions[i][j])
                        print()   
                        print("-----------------------------------------------------------")
           # (Caso 2-d ; s , b1 -> 3 (16), 8 (30)  

           # for i in 

"""
bvo = BarvinokOutput(str2)
bvo.info()
print(bvo.eval(1,2))"""
