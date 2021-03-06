from sage.arith.functions import LCM_list
import itertools
import re 

# Auxiliar functions

def rangeList(lis):
    r'''Returns a list of ``range`` objects with sizes ``lis``. 
    
    EXAMPLE::
    
        >>> rangeList([2,3,4)
        [range(0, 2), range(0, 3), range(0, 4)]
        
    '''
    res = []
    for elem in lis:
        res.append(range(elem))
    return res

def listToVarDic(lis):
    r'''Returns a dictionary with the same keys as ``vardic`` and values the elements of ``lis`` (auxiliar string functions are omitted).
        If len(lis) > len(vardic) only the first terms are considered.
    
    EXAMPLE:: 
    
        >>> listToVarDic([2,3])   
        {'b1': 2, 's': 3}
        
        >>> listToVarDic([2,3,4])    
        {'b1': 2, 's': 3}
        
    '''
    dic= vardic.copy()
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
    res = re.sub("([0-9])([a-zA-Z])", r"\1*\2", string)
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
    t = (sage_eval(str(N), locals = dic))%d

    return (N-t)/d

def floorToMod(expr, dic ):
        r''' Applies ``floorReduction`` to every floor function in ``expr`` with ``dic`` as parameter.
        
        EXAMPLE:
            >>> floorToMod('floor((2+s)/3) + floor((2+s)/4)' , {'s' : 7})
            
        '''
        
        aux = vardic
        aux['F'] = lambda X: floorReduction(dic ,X)
        res = sage_eval(str(expr).replace('floor','F'), locals= vardic)        
        return res    
    
    
def floorDenominators(input_expr, var = None):
    
    r''' Returns the denominators of the interior of "floor" functions which involve ``var`` in ``expr`` as a list.
         ``expr`` can be either an expression or a string. 
    
    
    EXAMPLE:: 
    
        >>> floorDenominators("floor(s/3) + floor(2*s/7)")
        [3,7]
    '''
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
        denominators.append(sage_eval(i, locals = vardic).denominator())
    return denominators

def getFstList(s): 
    r''' Returns the first occurrence of a list seen as a substring of `s` (assuming that this first list doesn't contain another list)
 
    EXAMPLE::
        
        >>>getFstList('Take the list [1,2,3]')
        '[1,2,3]'
    '''
    lb = s.find("[")
    rb = s.find("]")
    return s[lb:rb+1]

def findParens(s):
    r''' Returns a dictionary with the '(' positions on s as keys and the respective ')' positions as values.
 
    EXAMPLE::
        
        >>>findParens('((a+b)-(c+d))()')
        {1: 5, 7: 11, 0: 12, 13: 14}
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


def groupList(l):
    r''' Returns a dictionary with the different elements of the list ``l`` as keys and the lists of its
    appearance indices as values
    
    EXAMPLE::
        >>> groupList([2,3,2,2,2,1,0,3])
        {2: [0, 2, 3, 4], 3: [1, 7], 1: [5], 0: [6]}
    '''
    group = {}
    for index,elem in enumerate(l):
        if (not elem in group):
            group[elem] = [index]
        else:
            group[elem].append(index)
    return group 
    
# Main Class

class BarvinokOutput():
    
    def __init__(self,output_str,r=1):
        global vardic , vartuple 
        
        self.full_string = output_str.replace('\n',' ')
        self.var_string = getFstList(self.full_string)
        self.case_strings = output_str.replace('\n',' ').split( self.var_string + " ->")[1:]
        var_string_list = self.var_string[1:-1].split(', ')
        var_string_spaced = self.var_string[1:-1].replace(',',' ')
        vartuple = var(var_string_spaced)
        vardic = {}
        
        if (len(var_string_list) > 1):
            for i in range(len(var_string_list)):
                vardic[var_string_list[i]] = vartuple[i]
        else:
            vardic[var_string_list[0]] = vartuple 
            
        self.n_cases = len(self.case_strings)
        self.case_pairs = [insertMult(self.case_strings[i]).split(":",1) for i in range(self.n_cases)]
        self.expression_strings = [self.case_pairs[i][0] for i in range(self.n_cases)]
        self.expressions = [sage_eval(self.expression_strings[i], locals = vardic) for i in range(self.n_cases)]
        self.lcm = [[ LCM_list(floorDenominators(expr,vardic[var])+[r]) for var in vardic] for expr in self.expressions]
        self.conditions = []
        self.fixConditions()
        

    def fixConditions(self):
        r''' 
            Parses the condition strings to the needed format
        '''
        gross_conditions = [self.case_pairs[i][1] for i in range(self.n_cases)]
        self.cond_expr_str = []
        self.cond_var_str = []
         
        for ind in range(len(gross_conditions)):
            self.cond_expr_str.append([])
            self.cond_var_str.append([])
            self.conditions.append([])
            gross_conditions[ind] = re.sub('[}]*[{]*','',gross_conditions[ind])
            gross_conditions[ind] = gross_conditions[ind].split(' or ')
            for ind2 in range(len(gross_conditions[ind])):
                self.cond_expr_str[ind].append([])
                self.cond_var_str[ind].append([])
                self.conditions[ind].append([])
                gross_conditions[ind][ind2] = re.sub('[(]*[ ]*exists[ ]*[(]*',' ',gross_conditions[ind][ind2])
                gross_conditions[ind][ind2] = re.sub('[)]*;',' ',gross_conditions[ind][ind2])
                gross_conditions[ind][ind2] = re.sub('[ ]+=[ ]+' , '==' , gross_conditions[ind][ind2])
                gross_conditions[ind][ind2] = gross_conditions[ind][ind2].split(':', 1 ) 
                gross_conditions[ind][ind2][-1] = gross_conditions[ind][ind2][-1].split(' and ')
                if len(gross_conditions[ind][ind2]) == 2 :
                    gross_conditions[ind][ind2][0] = gross_conditions[ind][ind2][0].split(',')
                    #Declare e_i variables
                    for var_eq in gross_conditions[ind][ind2][0]:
                        var_name = re.findall('[ ]*[a-zA-Z]+[0-9]+[ ]*=',var_eq)[0][:-1]
                        var_name = re.sub('[ ]+','',var_name)
                        vardic[var_name] = var(var_name)
                        self.cond_var_str[ind][ind2].append(var_eq)
                   
                    for condition_expr in gross_conditions[ind][ind2][1]:
                        self.cond_expr_str[ind][ind2].append(re.sub('[)]+[)]+', '' ,condition_expr))
                        sub_exp = sage_eval(re.sub('[)]', '' ,condition_expr), locals = vardic)
                        for ind3 in range(len(self.cond_var_str[ind][ind2])):
                            cond_var = sage_eval(self.cond_var_str[ind][ind2][ind3] , locals = vardic)
                            if sub_exp.has(cond_var.left()):
                                sub_exp = sub_exp.substitute(cond_var)
                        self.conditions[ind][ind2].append(sub_exp)

        for i in range(len(self.cond_var_str)):
            if self.cond_var_str[i]  in self.cond_expr_str:
                self.cond_var_str[i] = None
          
    def modExpressions(self):
        r''' Returns a dictionary where :
                - The keys are positive integer tuples with i-esim value lower than self.lcm[i]
                - The values have the following structure :
                
                [ (expr1 , [or_cond11 ,..., or_cond1k] , ... , (exprn , [or_condn1 ,..., or_condnr]) ]
                
                    where ``expr*`` are expressions and or_cond** are lists of expressions.
                 
                 Every expression has been floor-reduced depending on the congruence of ``index_tuple`` mod ``self.lcm`` 
    
        EXAMPLE::
            >>> bv.modExpressions()[(1,0,0)]  # bv is a BarvinokOutput object
            
            (-1/12*b1^3 + 1/24*(3*b1 - 19)*b2^2 + 1/12*b2^3 - 2/3*(b1 - b2 - 1)*s^2 + 1/9*(4*b1 + 5*b2 + 2*s - 1)*(b1 - 1) +
            1/9*(2*b1 + 4*b2 + s - 2)*(b1 - 1) - 5/12*b1^2 - 1/24*(3*b1^2 + 34*b1 - 21)*b2 + 1/9*(4*b1 + 4*b2 + 2*s - 1)*b2 +
            1/9*(2*b1 + 2*b2 + s + 1)*b2 + 1/6*(3*b1^2 - 3*b2^2 - 8*b1 - 2*b2 + 5)*s + 3/4*b1 - 1/4,
            [[b1 - 1 == b1 - 1, b2 == b2, b2 >= b1, 4*s >= b1 + 2*b2, s <= b1 - 3]])
            
        '''
        lis = []
        for case in range(self.n_cases):
            lis.append({})
            for elem in list(itertools.product(*(rangeList(self.lcm[case])))):
                lis[case][elem] = (floorToMod(self.expressions[case] ,  listToVarDic(list(elem))) ,
                             [[floorToMod(cond_and , listToVarDic(list(elem))) for cond_and in self.conditions[case][cond_or] ] for cond_or in range(len(self.conditions[case]))])
        return lis

    
    