r"""
AUTHORS:
 - Adrian Lillo, first version (2021)
 - Emmanuel Briand, revision (2021)
 
 TODO:
     - the global dictionary ``vardics`` is troublesome. 
     
 NOTE: the computations with lcm can be done either with  ``lcm`` or with ``LCM_list``.
 The latter must be imported beforehand with ``from sage.arith.functions import LCM_list``.
 In a previous version, ``LCM_list`` was used. In the current version,  ``lcm`` is used.
 Come back to ``LCM_list`` if necessary.
 
"""

#f

import itertools, re
load("barvinok_parser.py") # to use "remove_parenthesis"
load("extract_coefficients.sage")

# Auxiliar functions
        
def lcmByComponent(lis):
    r''' Return a list with the component by component l.c.m. of the elements of ``lis``  
             
    INPUT:
    - ``lis`` - a list of lists. The inner lists are assumed to have all the same length.
        
    EXAMPLE:: 
    
        >>> lcmByComponent([[1, 2, 3], [2, 5, 3], [1, 1, 4]])   
        [2, 10, 12]
        
    '''
    return [lcm(component) for component in zip(*lis)]

def listToVarDic(lis):
    r'''Return a dictionary with the same keys as ``vardic`` 
    and values the elements of ``lis`` (auxiliar string functions are omitted).
    If len(lis) > len(vardic) only the first terms are considered.
    
    EXAMPLES:: 
        >>> s, b1 = var('s b1'); vardic = {'s': s, 'b1': b1};
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
    dic.update({var:value for (var, value) in zip(vardic, lis) if var != 'F'})
    return dic
       
def floorReduction(dic, expr):

    r'''Return ``floor(expr)`` as a polynomial without involving ``floor`` functions
    assuming the congruences given by `dic` (modulo expr.denominator())   

    EXAMPLE::
        >>> s, b1 = var('s b1'); vardic = {'s':s, 'b1': b1};
        >>> floorReduction({'s': 2, 'b1' : 1}, sage_eval("(2*s+b1)/6", locals=vardic))
        1/6*b1 + 1/3*s - 5/6
    '''       
    d = int(expr.denominator())
    N = expr.numerator()
    t = (int(sage_eval(str(N), locals = dic))) % d
    return (N-t)/d

def floorToMod(expr, dic):
        r''' Apply ``floorReduction`` to every floor function in ``expr`` with ``dic`` as parameter.
        
        EXAMPLE:
            >>> s = var('s'); vardic = {'s': s};
            >>> floorToMod('floor((2+s)/3) + floor((2+s)/4)' , {'s' : 7})
            [3, 7]
        '''
        aux = vardic
        aux['F'] = lambda X: floorReduction(dic ,X)
        # why not just: vardic['F'] = ... ?
        res = sage_eval(str(expr).replace('floor','F'), locals= vardic)        
        return res    
        
def floorDenominators(expr, var = None):
    
    r''' Return the denominators of the interior of "floor" functions which 
    involve ``var`` in ``expr`` as a list.
    ``expr`` can be either an expression or a string. 
    
    EXAMPLE:: 
        >>> floorDenominators("floor(s/3) + floor(2*s/7)")
        [3, 7]
    
    '''
    expr = str(expr).replace('\n', '')
    expr_list = []
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
    r''' Match each opening parentehsis to the corresponding closing parentehsis.
    
    OUTPUT: a dictionary that maps the index of each opening parenthesis '(' 
    in ``s`` to the index of the corresponding closing parenthesis  ')'.
    
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
    for index, elem in enumerate(L):
        if (not elem in group):
            group[elem] = [index]
        else:
            group[elem].append(index)
    return group 
  
# Main Class

class BarvinokFunction(): 
    r"""A BarvinokFunction has as atributes
    ``_lcm``, ``_mods, ``_pieces``, ``_main_vars``   
    """
    def __init__(self, s):
        global vardic  
        
        s = s.replace('\n',' ').rstrip()
        var_str = getFstList(s)
        
        all_pieces_str = remove_parenthesis(s, '{ %s ->'%var_str, ' }')
        all_pieces_str = all_pieces_str.split("; %s -> "%var_str)
        all_pieces_str = [insertMult(piece_str) for piece_str in all_pieces_str]
        all_pieces_str = [piece_str.split(":", 1) for piece_str in all_pieces_str]
        
        # Declare main variables
        s = remove_parenthesis(var_str, '[', ']')
        var_names = s.split(', ')
        self._main_vars = var(s) if len(var_names) > 1 else (var(s),)

        vardic = {name: variable for name, variable in zip(var_names, self._main_vars)}
        
        self._pieces = [ (sage_eval(P_str, locals=vardic), parseDomain(dom_str)) 
                       for (P_str, dom_str) in all_pieces_str]
        
        self._lcm = [[ lcm(floorDenominators(dom_str, var)) for var in self._main_vars] 
                    for (P_str, dom_str) in all_pieces_str]
        self._mods = lcmByComponent(self._lcm)
     
    def variables(self):
        return self._main_vars
        
    def mods(self):
        return self._mods
    
    def lcm(self):
        return self._lcm
        
    def pieces(self):
        return self._pieces
    
    def num_pieces(self):
        return len(self.pieces())
    
    def quasipolynomials(self):
        return [P for (P, dom) in self.pieces()]
    
    def domains(self):
        return [dom for (P, dom) in self.pieces()]
        
    def modRepresentation(self):
        r'''Calculate the quasipolynomials of ``self`` for each coset modulo the lattice of ``self``.  
        
        The output is a dictionary where :
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
        for coset in itertools.product(*(range(k) for k in (self.mods()))):
            X = listToVarDic(coset)
           # Set polyhedra lists as values
            dic[coset] = []
            for expr, domain in self.pieces():
                mod_expr = floorToMod(expr , X)
                polyhedra = []
                for subdomain in domain:
                    # Create the polyhedron 
                    pol = polyhedron([floorToMod(linear_cond , X) 
                                      for linear_cond in subdomain], 
                                     self.variables())
                    # Only consider non-empty polyhedra
                    if not pol.is_empty():
                        polyhedra.append(pol)
                
                # Only consider an expression if it has associated a non-empty list of polyhedra
                if polyhedra != [] and (mod_expr != 0) :                     
                    dic[coset].append((mod_expr  , polyhedra))     
        
        return dic
    
def parseSubdomain(s):
    r'''Parse a "subdomain" string ``s`` and return a list of linear conditions.
    
    EXAMPLE::
        >>> subdomain = "exists (e0 = floor((-1 + s)/5): 5 * e0 = -1 + s and s >= 1)"
        >>> vardic = {}; vardic['s'] = var('s')
        >>> parseSubdomain(subdomain)
        [5*floor(1/5*s - 1/5) == s - 1, s >= 1]
        >>> vardic
        {'s': s, 'e0': e0}
        
    NOTE: at this step, the string ``s`` has already been arranged so that no
    product appears without product sign ``*``, e.g. ``5 * e0 `` does not 
    appear as ``5e0`` (else it could be interpreted as scientific notation
    for 5 x 10^0).     
    '''       
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

    if all_quantifiers :
        all_quantifiers = all_quantifiers.split(',')
        # Declare e_i variables
        for quantifier in all_quantifiers:
            var_name = re.search('[ ]*([a-zA-Z]+[0-9]+)[ ]*=', quantifier).group(1)
            vardic[var_name] = var(var_name)

        cond_expr_str = [re.sub('[)]+[)]+', '', linear_cond) 
                         for linear_cond in all_linear_conditions]    
       
        cond_vars = [sage_eval(quantifier, locals = vardic) for quantifier in all_quantifiers]
        all_linear_conditions = [sage_eval(re.sub('[)]', '' ,linear_cond), locals = vardic)
                            for linear_cond in all_linear_conditions]
        conditions = [linear_cond.substitute([eq for eq in cond_vars if linear_cond.has(eq.left())])
                      for linear_cond in all_linear_conditions] 
    else: 
        cond_expr_str = [linear_cond.lstrip('(').rstrip(')')
                        for linear_cond in all_linear_conditions]
        conditions = [sage_eval(linear_cond, locals = vardic)
                     for linear_cond in cond_expr_str]    
    return conditions


def parseDomain(domain):
    r'''Parse a BarvinokFunction case string and returns a list of parsed pieces.
    '''
    domain = re.sub('[}]*[{]*', '', domain)
    all_subdomains = domain.split(' or ') 
    return [parseSubdomain(subdomain) for subdomain in all_subdomains]
    



    

    
