# AUTHORS:
# - Adrian Lillo, first version (2021)
# - Emmanuel Briand, revision (2021)
#------------------------------------------------------------------

from sage.arith.functions import LCM_list
import itertools
import re 

load("extract_coefficients.sage")

# Auxiliar functions

def rangeList(lis):
    r'''Return a list of ``range`` objects with sizes ``lis``. 
    
    EXAMPLE::
    
        >>> rangeList([2, 3, 4])
        [range(0, 2), range(0, 3), range(0, 4)]
        
    '''
    res = []
    for elem in lis:
        res.append(range(elem))
    return res

def lcmByComponent(lis):
    r''' Return a list with the component by component l.c.m. of the elements of ``lis``  
         
    All elements of ``lis`` are assumed to have the same length.
        
    EXAMPLE:: 
    
        >>> lcmByComponent([[1, 2, 3], [2, 5, 3], [1, 1, 4]])   
        [2, 10, 12]
        
    '''
    return [LCM_list(component) for component in zip(*lis)]

def listToVarDic(lis):
    r'''Return a dictionary with the same keys as ``vardic`` 
    and values the elements of ``lis`` (auxiliar string functions are omitted).
    If len(lis) > len(vardic) only the first terms are considered.
    
    EXAMPLE:: 
    
        >>> listToVarDic([2, 3])   
        {'b1': 2, 's': 3}
        
        >>> listToVarDic([2, 3, 4])    
        {'b1': 2, 's': 3}
        
    TODO: Several issues to be fixed here.
    - first, the use of a global dictionary
    - second, the fact that the output depends on the order of the keys of vardic.
            
    '''
    global vardic
    dic = vardic.copy()
    for i, var in (list(enumerate(vardic))[:len(lis)]):
        if (var != 'F'):
            dic[var] = lis[i]
    return dic


def insertMult(string):
    r'''Insert `` * `` between a digit and an alphabetic character. 
    
    EXAMPLE::
    
        >>> insertMult('5e1 >= -4 + s')
        '5 * e1 >= -4 + s'
        
    '''
    res = re.sub("([0-9])([a-zA-Z])", r"\1  *  \2", string)
    return res
    
    
def floorReduction(dic,expr):

    r''' Returns ``floor(expr)`` as a polynomial without involving ``floor`` functions
    assuming the congruences given by `dic` (modulo expr.denominator())   

    EXAMPLE::
    
        >>> floorReduction({'s': 2, 'b1' : 1}, sage_eval("(2*s+b1)/6", locals=vardic))
        1/6 * b1 + 1/3 * s - 5/6
    '''       
    
    d = int(expr.denominator())
    N = expr.numerator()
    t = (int(sage_eval(str(N), locals = dic)))%d
    return (N-t)/d

def floorToMod(expr, dic ):
        r''' Applies ``floorReduction`` to every floor function in ``expr`` with ``dic`` as parameter.
        
        EXAMPLE:
            >>> floorToMod('floor((2+s)/3) + floor((2+s)/4)' , {'s' : 7})
            [3, 7]
        '''
        
        aux = vardic
        aux['F'] = lambda X: floorReduction(dic ,X)
        res = sage_eval(str(expr).replace('floor','F'), locals= vardic)        
        return res    
    
    
def floorDenominators(input_expr, var = None):
    
    r''' Return the denominators of the interior of "floor" functions which 
    involve ``var`` in ``expr`` as a list.
    ``expr`` can be either an expression or a string. 
    
    EXAMPLE:: 
    
        >>> floorDenominators("floor(s/3) + floor(2*s/7)")
        [3, 7]
    
    TODO: simplify using a subroutine
    '''
    expr = str(input_expr).replace('\n', '')
    expr_list = []
    auxstr = expr
    count = 0
    pair_match = findParens(expr)

    while (auxstr.find("floor") != -1):
        a = auxstr.find("floor")
        auxstr = auxstr[a:]
        b = findParens(expr)[count+a+5] - a - count
        if  (var == None or sage_eval(auxstr[5:b+1],locals = vardic).has(var)):
            expr_list.append(auxstr[5:b+1])
        auxstr = auxstr[b:]
        count+= a + b
        
    denominators = [int(sage_eval(i, locals = vardic).denominator()) for i in expr_list]
    return denominators
    ###
    expr = str(input_expr).replace('\n', '')
    expr_str = str(expr)
    expr_list = []
    auxstr = expr_str
    count = 0
    pair_match = findParens(expr_str)

    while (auxstr.find("floor")!=-1):
        a = auxstr.find("floor")
        auxstr = auxstr[a:]
        b = findParens(expr_str)[count+a+5] - a - count
        if  (var == None or sage_eval(auxstr[5:b+1],locals = vardic).has(var)):
            expr_list.append(auxstr[5:b+1])
        auxstr = auxstr[b:]
        count+= a + b
        
    denominators = []
    for i in expr_list:
        denominators.append(int(sage_eval(i, locals = vardic).denominator()))
    return denominators

def getFstList(s): 
    r''' Return the first occurrence of a list seen as a substring of `s` 
    (assuming no nestings)
 
    EXAMPLE::
        
        >>> getFstList('Take the list [1,2,3]')
        '[1,2,3]'
    '''
    lb = s.find("[")
    rb = s.find("]")
    return s[lb:rb+1]

def findParens(s):
    r''' Return a dictionary with the '(' positions on s as keys 
    and the respective ')' positions as values.
 
    EXAMPLE::
        
        >>> findParens('((a+b)-(c+d))()')
        {0: 12, 1: 5, 7: 11, 13: 14}
    '''
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


def groupList(L):
    r''' Return a dictionary with the different elements of the list ``L`` as keys 
    and the lists of its indices in ``L`` as values
    
    EXAMPLE::
        >>> groupList([2, 3, 2, 2, 2, 1, 0, 3])
        {0: [6], 1: [5], 2: [0, 2, 3, 4], 3: [1, 7]}
    '''
    group = {}
    for index,elem in enumerate(L):
        if (not elem in group):
            group[elem] = [index]
        else:
            group[elem].append(index)
    return group 
    

# Main Class

class BarvinokFunction(): 

    def __init__(self, output_str):
        global vardic  
        
        self.full_string = output_str.replace('\n',' ')
        self.var_string = getFstList(self.full_string)
        self.case_strings = output_str.replace('\n',' ').split( self.var_string + " ->")[1:]
        self.n_cases = len(self.case_strings)
        
        # Declare main variables
        var_string_list = self.var_string[1:-1].split(', ') # obscure
        var_string_spaced = self.var_string[1:-1].replace(',',' ')
        vartuple = var(var_string_spaced)
        vardic = {}  
        self.main_vars = []
        if (len(var_string_list) > 1):
            for vs, vt in zip(var_string_list, vartuple): 
                vardic[vs] = vt
                self.main_vars.append(vt)
            
            #for i in range(len(var_string_list)):
            #   vardic[var_string_list[i]] = vartuple[i]
            #   self.main_vars.append(vartuple[i])
        else:
            vardic[var_string_list[0]] = vartuple 
            self.main_vars.append(vartuple)
        
        # Main substrings
        
        self.case_pairs = [insertMult(case_str).split(":",1) for case_str in self.case_strings]
        self.expression_strings = [X for (X,Y) in self.case_pairs]
        self.condition_strings = [Y for (X,Y) in self.case_pairs]
        
        self.lcm = [[ LCM_list(floorDenominators(cond, var)) for var in self.main_vars] 
                    for cond in self.condition_strings]
        self.mods = lcmByComponent(self.lcm)
        
        # Conditions and expressions without floor reduction
        self.expressions = [sage_eval(expr_str, locals = vardic) 
                            for expr_str in self.expression_strings]
        self.conditions = self.parseBarvinok()

    def modRepresentation(self):
        r''' Returns a dictionary where :
        - The keys are positive integer tuples s.t. the i-esim value is lower than self.mods[i]
        - The values have the following structure :
                
            [ (expr1 , [pol11 ,..., pol1l] ) , ... , (exprn , [poln1 ,..., polnr]) ]

        where ``expr*`` are sage expressions and pol** are non-empty ``Polyhedra`` objects.

        Every polyhedra has been obtained by floor-reduction depending on the congruence of ``index_tuple`` mod ``self.mods`` 
    
        EXAMPLE::
            >>> bv.modRepresentation()[(0,0,0)]  # bv is a BarvinokFunction object
            [(1/24*(b1 + 1)*b2^2 - 1/12*b1^2 - 1/24*(b1^2 + 6*b1 - 14)*b2 + 2/3*(b2 - 1)*floor(1/3*b1)
            + 1/3*(b2 - 1)*floor(1/3*b1 + 1/3) + 1/3*(b1 - 3*floor(1/3*b1) - 2)*floor(1/3*b2) +
            1/3*(2*b1 - 3*floor(1/3*b1) - 3*floor(1/3*b1 + 1/3) - 1)*floor(1/3*b2 + 1/3) + 1/3*b1,
            [A 3-dimensional polyhedron in QQ^3 defined as the convex hull of 1 vertex and 3 rays,
            A 2-dimensional polyhedron in QQ^3 defined as the convex hull of 1 vertex and 2 rays,
            A 2-dimensional polyhedron in QQ^3 defined as the convex hull of 1 vertex and 2 rays]), ...
        '''
        # Create the dictionary
        dic = {}
        # Set congruence tuples as keys
        for congr in list(itertools.product(*(rangeList(lcmByComponent(self.lcm))))):
           # Set polyhedra lists as values
            dic[congr] = []
            for expr, cond in zip(self.expressions, self.conditions):
            #for case in range(self.n_cases):
                mod_expr = floorToMod(expr ,listToVarDic(list(congr)))
                pols = []
                for cond_piece in cond:
                    # Create the polyhedron 
                    pol = polyhedron([floorToMod(cond_and , listToVarDic(list(congr))) 
                                      for cond_and in cond_piece], 
                                     self.main_vars)
                    # Only consider non-empty polyhedra
                    if not pol.is_empty():
                        pols.append(pol)
                
                # Only consider an expression if it has asociated a non-empty polyhedron 
                if pols != [] and (mod_expr!= 0) :                     
                    dic[congr].append((floorToMod(expr ,listToVarDic(list(congr)) )  , pols))     
        
        return dic

    
    def parsePiece(self, piece_str):
        r'''
        Parse a BarvinokFunction piece string and returns a list of condition expressions .
        '''        
        
        #Create auxiliar vars
        conditions = []
        cond_var_str = []
        cond_expr_str = []      
        
        # Adequate string 
        piece_str = re.sub('[(]*[ ]*exists[ ]*[(]*',' ',piece_str)
        piece_str = re.sub('[)]*;',' ', piece_str)
        piece_str = re.sub('[ ]+=[ ]+' , '==' , piece_str)
        pair  = piece_str.split(':' , 1)
        
        if len(pair) == 2 :
            var_equations , conds = pair
        elif len(pair) == 1 :
            var_equations = None
            conds = piece_str

        # Split by 'and'      
        conds = conds.split(' and ')   
        
        # Split e_i equations by commas
        if var_equations :
            var_equations = var_equations.split(',')      

            # Declare e_i variables
            for var_eq in var_equations:
                var_name = re.findall('[ ]*[a-zA-Z]+[0-9]+[ ]*=',var_eq)[0][:-1]
                var_name = re.sub('[ ]+','',var_name)
                vardic[var_name] = var(var_name)
                cond_var_str.append(var_eq)  
           
            for condition_expr in conds:
                
                # Convert conditions from string to sage expression 
                cond_expr_str.append(re.sub('[)]+[)]+', '' ,condition_expr))
                sub_exp = sage_eval(re.sub('[)]', '' ,condition_expr), locals = vardic) 
                
                # Substitute the e_i variables in the conditions  
                for cond_str in cond_var_str:
                    cond_var = sage_eval(cond_str , locals = vardic)
                    if sub_exp.has(cond_var.left()):
                        sub_exp = sub_exp.substitute(cond_var)
                conditions.append(sub_exp) 
        else:   
            for condition_expr in conds:
                
                # Convert conditions from string to sage expression 
                condition_expr = re.sub('[)]+', '' ,condition_expr)
                condition_expr = re.sub('[(]+', '' ,condition_expr)
                cond_expr_str.append(condition_expr)
                sub_exp = sage_eval(condition_expr, locals = vardic) 
                conditions.append(sub_exp)
    
        return conditions

    
    def parseCase(self, case):
        r'''Parse a BarvinokFunction case string and returns a list of parsed pieces.
        '''
        case_conditions = []
        case = re.sub('[}]*[{]*','',case)
        case = case.split(' or ')           
        for piece in case :
            case_conditions.append(self.parsePiece(piece)) 
        return case_conditions
    
    def parseBarvinok(self):
        r'''Parse a BarvinokFunction string and returns a list of parsed cases.
        '''
        gross_conditions = [Y for (X, Y) in self.case_pairs]
        return [self.parseCase(case) for case in gross_conditions]
        
        conditions = []
        for case in gross_conditions:
            conditions.append(self.parseCase(case))
        return conditions
    
