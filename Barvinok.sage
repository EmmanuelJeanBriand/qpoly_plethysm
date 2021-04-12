r"""
AUTHORS:
 - Adrian Lillo, first version (2021)
 - Emmanuel Briand, revision (2021)
 
 TODO:
     - the global dictionary ``vardics`` is troublesome. 
"""

from sage.arith.functions import LCM_list
import itertools, re
load("barvinok_parser.py") # to use "remove_parenthesis"

load("extract_coefficients.sage")

# Auxiliar functions
        
def rangeList(lis):
    r'''Return a list of ``range`` objects with sizes ``lis``. 
    
    EXAMPLE::
    
        >>> rangeList([2, 3, 4])
        [range(0, 2), range(0, 3), range(0, 4)]    
    '''
    return [range(elem) for elem in lis]


def lcmByComponent(lis):
    r''' Return a list with the component by component l.c.m. of the elements of ``lis``  
             
    INPUT:
    - ``lis`` - a list of lists. The inner lists are assumed to have all the same length.
        
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
    #for i, var in (list(enumerate(vardic))[:len(lis)]):
    #   if (var != 'F'):
    #       dic[var] = lis[i]
    for var, value in zip(vardic, lis):
        if var != 'F':
            dic[var] = value
    return dic
       
def floorReduction(dic,expr):

    r''' Returns ``floor(expr)`` as a polynomial without involving ``floor`` functions
    assuming the congruences given by `dic` (modulo expr.denominator())   

    EXAMPLE::
    
        >>> floorReduction({'s': 2, 'b1' : 1}, sage_eval("(2*s+b1)/6", locals=vardic))
        1/6 * b1 + 1/3 * s - 5/6
    '''       
    
    d = int(expr.denominator())
    N = expr.numerator()
    t = (int(sage_eval(str(N), locals = dic))) % d
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
        
def floorDenominators(expr, var = None):
    
    r''' Return the denominators of the interior of "floor" functions which 
    involve ``var`` in ``expr`` as a list.
    ``expr`` can be either an expression or a string. 
    
    EXAMPLE:: 
        >>> floorDenominators("floor(s/3) + floor(2*s/7)")
        [3, 7]
    
    TODO: simplify using a subroutine
    '''
    expr = str(expr).replace('\n', '')
    expr_list = []
    auxstr = expr
    count = 0
    pair_match = findParens(expr)
    
    start = 0
    while (expr.find("floor", start) != -1):
        start = expr.find("floor", start) + len("floor")
        stop = pair_match[start]
        subexpr = expr[start:stop+1]
        if  (var == None or sage_eval(subexpr,locals = vardic).has(var)):
            expr_list.append(subexpr)
        start = stop + 1
        
    denominators = [int(sage_eval(i, locals = vardic).denominator()) for i in expr_list]
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
    r''' Return a dictionary with the '(' positions in ``s`` as keys 
    and the respective ')' positions as values.
    
    This deals with nested parentheses.
 
    EXAMPLE::
        >>> findParens('((a+b)-(c+d))()')
        {0: 12, 1: 5, 7: 11, 13: 14}
    '''
    res = {}
    pstack = []

    for i, c in enumerate(s):
        if c == '(':
            pstack.append(i)
        elif c == ')':
            if len(pstack) == 0:
                raise IndexError("No matching closing parens at: {i}".format(i=i))
            res[pstack.pop()] = i

    if len(pstack) > 0:
        raise IndexError("No matching opening parens at: {j}".format(j=pstack.pop()))

    return res


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
    r"""A BarvinokFunctions has as atributes:
    - full_string
    - case_strings
    - n_cases
    - var_string
    - var_string_list
    - main_vars
    - case_pairs
    - quasipolynomials_strings (before: expression_strings)
    - domains_strings (before: condition_strings)
    - lcm
    - mods
    - quasipolynomials (before: expressions)
    - domains (before: domains)
    """
    def __init__(self, output_str):
        global vardic  
        
        s = output_str.replace('\n',' ').rstrip()
        self.full_string = s
        self.var_string = getFstList(self.full_string)
        var_str = "{v} -> ".format(v=self.var_string)
        s = remove_parenthesis(s, '{ %s'%var_str, ' }')
        s =  s.split("; %s"%var_str)
        self.case_strings = s
        self.n_cases = len(self.case_strings)
        
        # Declare main variables
        s = self.var_string
        s = s.strip()
        s = remove_parenthesis(s, '[', ']')
 
        var_string_list = s.split(', ')
        self.main_vars = var(s) if len(var_string_list) > 1 else (var(s),)

        vardic = {vs: vt for vs, vt in zip(var_string_list, self.main_vars)}
        
        self.case_pairs = [insertMult(case_str).split(":",1) for case_str in self.case_strings]
        quasipolynomials_strings, domains_strings = zip(*self.case_pairs)
        self.quasipolynomials_strings = quasipolynomials_strings
        self.domains_strings = domains_strings
        #self.expression_strings = [Q for (Q,D) in self.case_pairs]
        #self.condition_strings = [D for (Q,D) in self.case_pairs]
        
        self.lcm = [[ LCM_list(floorDenominators(dom_str, var)) for var in self.main_vars] 
                    for dom_str in self.domains_strings]
        self.mods = lcmByComponent(self.lcm)
        
        # Conditions and expressions without floor reduction
        self.quasipolynomials = [sage_eval(s, locals = vardic) for s in self.quasipolynomials_strings]
        self.domains = self.parseBarvinok()
        
        # these names will disappear
        self.expression_strings = quasipolynomials_strings
        self.condition_strings = domains_strings
        self.expressions = self.quasipolynomials
        self.conditions = self.domains

    def modRepresentation(self):
        r''' Returns a dictionary where :
        - The keys are positive integer tuples s.t. the i-th value is lower than self.mods[i]
        - The values have the following structure :
                
            [ (expr1 , [pol11 ,..., pol1l] ) , ... , (exprn , [poln1 ,..., polnr]) ]

        where ``expr*`` are sage expressions and pol** are non-empty ``Polyhedra`` objects.

        Every polyhedron has been obtained by floor-reduction depending on 
        the congruence of ``index_tuple`` mod ``self.mods``.
        
        TODO: change example below so that it can doctest.
    
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
                
                # Only consider an expression if it has associated a non-empty polyhedron 
                if pols != [] and (mod_expr!= 0) :                     
                    dic[congr].append((floorToMod(expr ,listToVarDic(list(congr)) )  , pols))     
        
        return dic

    
    def parsePiece(self, s):
        r'''
        Parse a "subdomain" string ``s`` and return a list of linear conditions.
        '''        
        
        #Create auxiliar vars
        conditions = []
        cond_var_str = []
        cond_expr_str = []      
        
        # Adequate string 
        s = re.sub('[(]*[ ]*exists[ ]*[(]*',' ', s)
        s = re.sub('[)]*;',' ', s)
        s = re.sub('[ ]+=[ ]+' , '==' , s)
        pair  = s.split(':' , 1)
        
        if len(pair) == 2 :
            all_quantifiers , all_linear_conditions = pair
        elif len(pair) == 1 :
            all_quantifiers = None
            all_linear_conditions = s

        all_linear_conditions = all_linear_conditions.split(' and ')   
        
        # Split e_i equations by commas
        if all_quantifiers :
            all_quantifiers = all_quantifiers.split(',')      

            # Declare e_i variables
            for quantifier in all_quantifiers:
                var_name = re.findall('[ ]*[a-zA-Z]+[0-9]+[ ]*=', quantifier)[0][:-1]
                var_name = re.sub('[ ]+', '', var_name)
                vardic[var_name] = var(var_name)
                cond_var_str.append(quantifier)  
           
            for linear_cond in all_linear_conditions:
                
                # Convert conditions from string to sage expression 
                cond_expr_str.append(re.sub('[)]+[)]+', '' ,linear_cond))
                sub_exp = sage_eval(re.sub('[)]', '' ,linear_cond), locals = vardic) 
                
                # Substitute the e_i variables in the conditions  
                for cond_str in cond_var_str:
                    cond_var = sage_eval(cond_str , locals = vardic)
                    if sub_exp.has(cond_var.left()):
                        sub_exp = sub_exp.substitute(cond_var)
                conditions.append(sub_exp) 
        else:   
            for linear_cond in all_linear_conditions:
                
                # Convert conditions from string to sage expression 
                #linear_cond = re.sub('[)]+', '' ,linear_cond)
                #linear_cond = re.sub('[(]+', '' ,linear_cond
                linear_cond = linear_cond.rstrip(')').lstrip('(')
                cond_expr_str.append(linear_cond)
                sub_exp = sage_eval(linear_cond, locals = vardic) 
                conditions.append(sub_exp)
    
        return conditions

    
    def parseCase(self, domain):
        r'''Parse a BarvinokFunction case string and returns a list of parsed pieces.
        '''
        domain = re.sub('[}]*[{]*', '', domain)
        all_subdomains = domain.split(' or ') 
        return [self.parsePiece(subdomain) for subdomain in all_subdomains]
    
    def parseBarvinok(self):
        r'''Parse a BarvinokFunction string and returns a list of parsed cases.
        '''
        all_domains = [domain for (quasipolynomial, domain) in self.case_pairs]
        return [self.parseCase(domain) for domain in all_domains]


    

    
