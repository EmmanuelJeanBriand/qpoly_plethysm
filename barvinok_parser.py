r""" An ad hoc parser for Barvinok's output in the plethysm calculations of Kahle and Michalek.

AUTHORS:
 - Emmanuel Briand (2021)
  
 Here we parse piecewise quasipolynomial functions defined in the following ways: these functions are functions `F` o `ZZ^n`, 
 and there is:
 - a finite set of quasipolynomials functions `P_i` 
 - and for each function, a set `D_i` where `F` coincide with `P_i`. We call this set `D_i` the "domain of `P_i`"
 
The sets `D_i` are pairwise distinct. Outside of the union of the `D_i`, the function `F` is zero.  
Each set `D_i` decomposes as disjoint union of subsets `S_i` (that we call the subdomains of `P_i`). 
Each subdomain  is the intersection of a rational polyhedron with a union of cosets of some full-rank sublattice 
of `Z_n`. Each subdomain is actually defined by linear conditions (linear equations and inequalities with integer coefficients)
involving, in addition to the variables of the function `F`, extra variables `e_0`, `e_1`... fulfilling relations:
`e_i=floor(L_i/k_i)`where `L_i` is an affine form (linear form with constant term) on `ZZ^n` and `k_i` is a positive integer.
The value of `e_i` is thus `L_i/k_i` + a periodic term determined by `L_i \mod k_i`. 
The extra variables do not show up in the formulas for `F`: they only show up in the descriptions of the subdomains.
 
We call "pieces" the pairs `(P_i, D_i)`. 

The descriptions were obtained as applying the program Barvinok. Here is an example:
 
EXAMPLE::
    { [s] -> ((((((3/5 - 289/720 * s + 1/20 * s^2 + 1/720 * s^3) + (5/8 + 1/8 * s) *
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
    5e1 >= -4 + s); [s] -> 1 : s = 0 }
 
 Here is the structure of the description:
 
 - Function: 
   { PIECE1 ; PIECE2  ;  ...  }
   opening: `{` ; closing: `}` ; separator: `; `
   |
   |-- PIECE*: 
       QUASIPOLYOMIAL : ALL_SUBDOMAINS
       opening: None; closing: None; separator: ` : ` (only once).
       (ALL_SUBDOMAINS is the list of all subdoamisn, whose union is the domain 
       of validity of QUASIPOLYNOMIAL).
       |
       |-- QUASIPOLYNOMIAL: 
       |   LIST OF VARS  ->  FORMULA
       |   opening: None; closing: None; separator: ` -> ` (only once).
       |   |
       |   |-- LIST OF VARS.: 
       |   |   [ VAR1 ,  VAR2 , ...  ] 
       |   |   opening: `[` ;  closing: `]`; separator: `, `
       |   |
       |   |-- FORMULA. Involves floors in general.
       |
       |-- ALL_SUBDOMAINS: 
           SUBDOMAIN1 ` or ` SUBDOMAIN2 ` or ` ...
           opening: None; closing: None; separator: ` or `
           The Domain is the disjoint union of its subdomains
           |
           |-- SUBDOMAIN*:  
               exists ( ALL_EXTRA_VARIABLES :  ALL_LINEAR_CONDITIONS )
               or just:
               ALL_LINEAR_CONDITIONS
               opening: `exists(` ; closing: `)` ; separator: ` : ` (only once).
               Each subdomain is defined by modular conditions (corresponding to the quantifiers)
               and linear inequalities.
               |
               |-- ALL_EXTRA_VARIABLES: 
               |   EXTRA_VAR1, EXTRA_VAR22, ...
               |   opening: None; closing: None; separator: `, `
               |   |
               |   |-- EXTRA_VAR*: 
               |       ei = floor(F) 
               |       ei are variables e0, e1, e2 ... 
               |       F is a linear form with integers coefficients divided by an integer. 
               |   
               |-- ALL_LINEAR_CONDITIONS: 
                   LINEAR_CONDITION1 and LINEAR_CONDITION2 and ... 
                   opening: None; closing: None; separators: ` and `
                   |
                   | -- LINEAR_CONDITION*: a linear inequality or a linear equation. 
                        Multiplication sign is omitted. 
                        The variables have been declared before (e0, e1, .... ). 
                        
Note that the string may contain extra whitespaces and newlines. 
                        
The main function is ``parse_function``.

EXAMPLE::

    >>> with open('all-qpoly/111.qpoly') as f:
    ...     data = f.read()
    >>> parse_function(data)
    {'pieces': [{'formula': '((((-2/3 + 2/3 * b1) + s) - floor((b1)/2)) - floor((b1 + s)/2))',
       'subdomains': [{'extra variables': {'e0': 'floor((-1 + b1)/3)'},
         'linear conditions': ['3 * e0 == -1 + b1',
          'b1 >= 1',
          's <= -2 + b1',
          '3 * s >= 1 + 2 * b1']}]},
      {'formula': '((-2/3 + 2/3 * b1) - floor((b1)/2))',
       'subdomains': [{'extra variables': {'e0': 'floor((-1 + b1)/3)'},
         'linear conditions': ['s == -1 + b1', '3 * e0 == -1 + b1', 'b1 >= 4']},
        {'extra variables': {'e0': 'floor((-1 + b1)/3)'},
         'linear conditions': ['3 * e0 == -1 + b1', 'b1 >= 1', 's >= b1']}]},
      {'formula': '((-1/3 + 2/3 * b1) - floor((b1)/2))',
       'subdomains': [{'extra variables': {'e0': 'floor((-1 + b1)/3)',
          'e1': 'floor((-2 + b1)/3)'},
         'linear conditions': ['s == -1 + b1',
          '3 * e1 == -2 + b1',
          'b1 >= 3',
          '3 * e0 >= -3 + b1',
          '3 * e0 <= -2 + b1']},
        {'extra variables': {'e0': 'floor((-1 + b1)/3)',
          'e1': 'floor((-2 + b1)/3)'},
         'linear conditions': ['3 * e1 == -2 + b1',
          'b1 >= 1',
          's >= b1',
          '3 * e0 >= -3 + b1',
          '3 * e0 <= -2 + b1']}]},
      {'formula': '(((2/3 * b1 + s) - floor((b1)/2)) - floor((b1 + s)/2))',
       'subdomains': [{'extra variables': {'e0': 'floor((-1 + b1)/3)',
          'e1': 'floor((b1)/3)'},
         'linear conditions': ['3 * e1 == b1',
          '3 * s >= 2 * b1',
          's <= -2 + b1',
          '3 * e0 >= -3 + b1',
          '3 * e0 <= -2 + b1']}]},
      {'formula': '((((-1/3 + 2/3 * b1) + s) - floor((b1)/2)) - floor((b1 + s)/2))',
       'subdomains': [{'extra variables': {'e0': 'floor((-1 + b1)/3)',
          'e1': 'floor((b1)/3)',
          'e2': 'floor((-2 + b1)/3)'},
         'linear conditions': ['3 * e2 == -2 + b1',
          '3 * s >= 2 * b1',
          's <= -2 + b1',
          '3 * e0 >= -3 + b1',
          '3 * e0 <= -2 + b1',
          '3 * e1 <= -1 + b1',
          '3 * e1 >= -2 + b1']}]},
      {'formula': '(2/3 * b1 - floor((b1)/2))',
       'subdomains': [{'extra variables': {'e0': 'floor((-1 + b1)/3)',
          'e1': 'floor((-2 + b1)/3)',
          'e2': 'floor((-3 + b1)/3)'},
         'linear conditions': ['s == -1 + b1',
          '3 * e2 == -3 + b1',
          'b1 >= 3',
          '3 * e0 >= -3 + b1',
          '3 * e0 <= -2 + b1',
          '3 * e1 >= -4 + b1',
          '3 * e1 <= -3 + b1']},
        {'extra variables': {'e0': 'floor((-1 + b1)/3)',
          'e1': 'floor((-2 + b1)/3)',
          'e2': 'floor((b1)/3)'},
         'linear conditions': ['3 * e2 == b1',
          'b1 >= 1',
          's >= b1',
          '3 * e0 >= -3 + b1',
          '3 * e0 <= -2 + b1',
          '3 * e1 >= -4 + b1',
          '3 * e1 <= -3 + b1']}]}],
     'variables': ['b1', 's']}
       
doctest with: ``sage -t barvinok.sage``
unittest with ``sage test_barvinok.sage``
    
    
Structure of the output:

{
'variables': LIST
'pieces': LIST. Each item is a dict as follows:
                {'formula': STRING,
                 'subdomains': LIST. each item in the list has the following structure:
                               {'linear conditions': LIST OF STRINGS,
                                 'extra variables': DICT str -> str}
                 
                 }
}
------------------------------------------------------------------"""

import re

def remove_parenthesis(s, prefix='(', suffix=')'):
    r"""Remove prefix and suffix in string ``s`` when they are both present. 
    Adapted from https://www.python.org/dev/peps/pep-0616/
    Note that the methods removeprefix and removesuffix are standard only in python >= 3.9
    
    The string is also stripped (from whitespaces) before looking for the prefix and suffix,
    and after removing them.
    
    EXAMPLES::
        >>> remove_parenthesis('(1, 2, 3)')
        '1, 2, 3'
        
        >>> remove_parenthesis('[1, 2, 3]', '[', ']')
        '1, 2, 3'
        
        >>> remove_parenthesis('The tuple is (1, 2, 3)')
        'The tuple is (1, 2, 3)'
        
    Beware::
        >>> remove_parenthesis('(1, 2) is smaller than (2, 1)')
        '1, 2) is smaller than (2, 1'
        
    Initial and final whitespaces are removed before checking the prefix and suffix,
    as well as after removing them::
        >>> remove_parenthesis('      ( 1, 2, 3  )      ')
        '1, 2, 3'
        
        >>> remove_parenthesis('  The tuple is    ( 1, 2, 3  )      ')
        'The tuple is    ( 1, 2, 3  )'
    """
    s = s.strip()
    if s.startswith(prefix) and s.endswith(suffix):
        return s[len(prefix):-len(suffix)].strip()
    else:
        return s[:]

def parse_quantifiers(quantifiers):
    r"""
    EXAMPLES::
        >>> parse_quantifiers('e0 = floor((-1 + s)/5), e1 = floor((s)/5)')
        {'e0': 'floor((-1 + s)/5)', 'e1': 'floor((s)/5)'}
        
        >>> parse_quantifiers(None)
        {}
    """
    if quantifiers == None:
        return {}
    else:
        quantifiers = quantifiers.split(", ")
        quantifiers = map(lambda s: s.split(" = "), quantifiers)
        return {name: value for name, value in quantifiers}

def insertMult(string):
    r'''Insert `` * `` between a digit and an alphabetic character. 
    
    EXAMPLE::
        >>> insertMult('5e1 >= -4 + s')
        '5 * e1 >= -4 + s'        
    '''
    res = re.sub("([0-9])([a-zA-Z])", r"\1 * \2", string)
    return res

def parse_linear_condition(linear_cond):
    r"""
    EXAMPLES::
        >>> parse_linear_condition('s >= 1')
        's >= 1'
        
        >>> parse_linear_condition('5e0 <= -2 + s')
        '5 * e0 <= -2 + s'
        
        >>> parse_linear_condition(' (4e2 = b2) ')
        '4 * e2 == b2'
    """
    linear_cond = linear_cond.strip()
    linear_cond = remove_parenthesis(linear_cond) 
    linear_cond = insertMult(linear_cond)
    linear_cond = linear_cond.replace(' = ', ' == ') 
    return linear_cond

def parse_all_linear_conditions(all_linear_conditions):
    r"""
    EXAMPLES::
        >>> s = 's >= 1 and 5e0 <= -2 + s and 5e0 >= -5 + s and 5e1 <= -1 + s and 5e1 >= -4 + s'
        >>> parse_all_linear_conditions(s)
        ['s >= 1', 
         '5  *  e0 <= -2 + s', 
         '5  *  e0 >= -5 + s', 
         '5  *  e1 <= -1 + s', 
         '5  *  e1 >= -4 + s']
    """
    all_linear_conditions = all_linear_conditions.split(' and ')
    return [parse_linear_condition(cond) for cond in all_linear_conditions]

def parse_subdomain(subdomain):
    r"""
    The subdomain may contain quantifiers, or not.
    
    EXAMPLES::
        >>> s = 'exists (e0 = floor((-1 + s)/5), e1 = floor((s)/5): s >= 1 and 5e0 <= -2 + s and 5e0 >= -5 + s and 5e1 <= -1 + s and 5e1 >= -4 + s)'
        >>> parse_subdomain(s)
        {'extra variables': {'e0': 'floor((-1 + s)/5)', 'e1': 'floor((s)/5)'},
         'linear conditions': ['s >= 1',
          '5 * e0 <= -2 + s',
          '5 * e0 >= -5 + s',
          '5 * e1 <= -1 + s',
          '5 * e1 >= -4 + s']}
         
        >>> parse_subdomain('s = 0')
        {'extra variables': {}, 'linear conditions': ['s == 0']}
    """
    if "exists" in subdomain:
        subdomain = remove_parenthesis(subdomain, prefix="exists (", suffix=")")
        quantifiers, all_linear_conditions = subdomain.split(": ")
    else:
        quantifiers = None
        all_linear_conditions = subdomain
    return {'extra variables': parse_quantifiers(quantifiers),
            'linear conditions': parse_all_linear_conditions(all_linear_conditions)}
    
def parse_domain(all_subdomains):
    r"""
    EXAMPLES::
        >>> s = '(exists (e0 = floor((-2 + b1)/4), e1 = floor((b2)/4), e2 = floor((-2 + b2)/4), e3 = floor((-4 + b1)/4): s = -2 + b1 and 4e2 = -2 + b2 and 4e3 = -4 + b1 and b2 >= b1 and 2b2 <= -8 + 3b1 and 4e0 >= -5 + b1 and 4e0 <= -3 + b1 and 4e1 <= -1 + b2 and 4e1 >= -3 + b2)) or (exists (e0 = floor((b2)/4), e1 = floor((-2 + b2)/4), e2 = floor((-2 + b1)/4): s = -2 + b1 and 4e1 = -2 + b2 and 4e2 = -2 + b1 and b2 >= b1 and 2b2 <= -8 + 3b1 and 4e0 <= -1 + b2 and 4e0 >= -3 + b2))'
        >>> parse_domain(s)
        [{'extra variables': {'e0': 'floor((-2 + b1)/4)',
         'e1': 'floor((b2)/4)',
         'e2': 'floor((-2 + b2)/4)',
         'e3': 'floor((-4 + b1)/4)'},
         'linear conditions': ['s == -2 + b1',
         '4 * e2 == -2 + b2',
         '4 * e3 == -4 + b1',
         'b2 >= b1',
         '2 * b2 <= -8 + 3 * b1',
         '4 * e0 >= -5 + b1',
         '4 * e0 <= -3 + b1',
         '4 * e1 <= -1 + b2',
         '4 * e1 >= -3 + b2']},
         {'extra variables': {'e0': 'floor((b2)/4)',
         'e1': 'floor((-2 + b2)/4)',
         'e2': 'floor((-2 + b1)/4)'},
         'linear conditions': ['s == -2 + b1',
         '4 * e1 == -2 + b2',
         '4 * e2 == -2 + b1',
         'b2 >= b1',
         '2 * b2 <= -8 + 3 * b1',
         '4 * e0 <= -1 + b2',
         '4 * e0 >= -3 + b2']}]
    """
    all_subdomains = all_subdomains.split(' or ')
    all_subdomains = [remove_parenthesis(subdomain) for subdomain in all_subdomains]
    return [parse_subdomain(subdomain) for subdomain in all_subdomains]

def parse_quasipolynomial(quasipolynomial):
    r"""
    EXAMPLES::
        >>> parse_quasipolynomial('[s] -> 1')
        {'formula': '1', 'variables': ['s']}
    """
    variables, formula = quasipolynomial.split(' -> ')
    variables = remove_parenthesis(variables, '[', ']')
    variables = variables.split(', ')
    return {'variables': variables, 'formula': formula}

def parse_piece(piece):
    r"""
    EXAMPLE::
        >>> parse_piece('[s] -> 1 : s = 0')
        {'formula': '1',
         'subdomains': [{'extra variables': {}, 'linear conditions': ['s == 0']}],
         'variables': ['s']}
    """
    quasipolynomial, subdomains = piece.split(' : ', maxsplit=1)
    Q = parse_quasipolynomial(quasipolynomial)
    return {'subdomains': parse_domain(subdomains), 
            'formula': Q['formula'], 
            'variables': Q['variables'] }

def parse_all_pieces(all_pieces):
    all_pieces = all_pieces.split('; ')
    all_pieces = [parse_piece(piece) for piece in all_pieces]
    variables = all_pieces[0]['variables']
    if not all(piece['variables'] == variables for piece in all_pieces):
        raise ValueError("Not all lists of variables are equal.")
    return {'variables': variables, 
            'pieces': [{'subdomains': piece['subdomains'], 'formula': piece['formula']} for piece in all_pieces]
           }

def parse_function(function):
    r"""Parse a Barvinok function from the directory qpoly
    """
    all_pieces = function.replace('\n', ' ')
    all_pieces = remove_parenthesis(all_pieces, prefix='{', suffix='}')
    return parse_all_pieces(all_pieces)
