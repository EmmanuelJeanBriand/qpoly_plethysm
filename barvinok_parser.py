r""" An ad hoc parser for Barvinok's output in the plethysm calculations of Kahle and Michalek.

AUTHORS:
 - Adrian Lillo, first version (2021)
 - Emmanuel Briand, revision (2021)
  
 Here we parse piecewise quasipolynomial functions as in the following example:
 
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
 
 
 These quasipolynomial functions have the following structure and delimiters:
 
 - Function: 
   { CASE1 ; CASE2  ;  ...  }
   opening: `{` ; closing: `}` ; separator: `; `
   |
   |-- CASE*: 
       QUASIPOLYOMIAL : DOMAIN
       opening: None; closing: None; separator: ` : ` (only once).
       (DOMAIN is the domain of validity of QUASIPOLYNOMIAL).
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
       |-- DOMAIN: 
           SUBDOMAIN1 ` or ` SUBDOMAIN2 ` or ` ...
           opening: None; closing: None; separator: ` or `
           The Domain is the disjoint union of its subdomains
           |
           |-- SUBDOMAIN*:  
               exists ( ALL_QUANTIFIERS  :  ALL_LINEAR_CONDITIONS )
               or just:
               ALL_LINEAR_CONDITIONS
               opening: `exists(` ; closing: `)` ; separator: ` : ` (only once).
               Each subdomain is defined by modular conditions (corresponding to the quantifiers)
               and linear inequalities.
               |
               |-- ALL_QUANTIFIERS: 
               |   QUANTIFIER1, QUANTIFIER2, ...
               |   opening: None; closing: None; separator: `, `
               |   |
               |   |-- QUANTIFIER*: 
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
    {'pieces': [{'domain': [{'linear conditions': ['3 * e0 == -1 + b1',
          'b1 >= 1',
          's <= -2 + b1',
          '3 * s >= 1 + 2 * b1'],
         'quantifiers': {'e0': 'floor((-1 + b1)/3)'}}],
       'formula': '((((-2/3 + 2/3 * b1) + s) - floor((b1)/2)) - floor((b1 + s)/2))'},
      {'domain': [{'linear conditions': ['s == -1 + b1',
          '3 * e0 == -1 + b1',
          'b1 >= 4'],
         'quantifiers': {'e0': 'floor((-1 + b1)/3)'}},
        {'linear conditions': ['3 * e0 == -1 + b1', 'b1 >= 1', 's >= b1'],
         'quantifiers': {'e0': 'floor((-1 + b1)/3)'}}],
       'formula': '((-2/3 + 2/3 * b1) - floor((b1)/2))'},
      {'domain': [{'linear conditions': ['s == -1 + b1',
          '3 * e1 == -2 + b1',
          'b1 >= 3',
          '3 * e0 >= -3 + b1',
          '3 * e0 <= -2 + b1'],
         'quantifiers': {'e0': 'floor((-1 + b1)/3)', 'e1': 'floor((-2 + b1)/3)'}},
        {'linear conditions': ['3 * e1 == -2 + b1',
          'b1 >= 1',
          's >= b1',
          '3 * e0 >= -3 + b1',
          '3 * e0 <= -2 + b1'],
         'quantifiers': {'e0': 'floor((-1 + b1)/3)', 'e1': 'floor((-2 + b1)/3)'}}],
       'formula': '((-1/3 + 2/3 * b1) - floor((b1)/2))'},
      {'domain': [{'linear conditions': ['3 * e1 == b1',
          '3 * s >= 2 * b1',
          's <= -2 + b1',
          '3 * e0 >= -3 + b1',
          '3 * e0 <= -2 + b1'],
         'quantifiers': {'e0': 'floor((-1 + b1)/3)', 'e1': 'floor((b1)/3)'}}],
       'formula': '(((2/3 * b1 + s) - floor((b1)/2)) - floor((b1 + s)/2))'},
      {'domain': [{'linear conditions': ['3 * e2 == -2 + b1',
          '3 * s >= 2 * b1',
          's <= -2 + b1',
          '3 * e0 >= -3 + b1',
          '3 * e0 <= -2 + b1',
          '3 * e1 <= -1 + b1',
          '3 * e1 >= -2 + b1'],
         'quantifiers': {'e0': 'floor((-1 + b1)/3)',
          'e1': 'floor((b1)/3)',
          'e2': 'floor((-2 + b1)/3)'}}],
       'formula': '((((-1/3 + 2/3 * b1) + s) - floor((b1)/2)) - floor((b1 + s)/2))'},
      {'domain': [{'linear conditions': ['s == -1 + b1',
          '3 * e2 == -3 + b1',
          'b1 >= 3',
          '3 * e0 >= -3 + b1',
          '3 * e0 <= -2 + b1',
          '3 * e1 >= -4 + b1',
          '3 * e1 <= -3 + b1'],
         'quantifiers': {'e0': 'floor((-1 + b1)/3)',
          'e1': 'floor((-2 + b1)/3)',
          'e2': 'floor((-3 + b1)/3)'}},
        {'linear conditions': ['3 * e2 == b1',
          'b1 >= 1',
          's >= b1',
          '3 * e0 >= -3 + b1',
          '3 * e0 <= -2 + b1',
          '3 * e1 >= -4 + b1',
          '3 * e1 <= -3 + b1'],
         'quantifiers': {'e0': 'floor((-1 + b1)/3)',
          'e1': 'floor((-2 + b1)/3)',
          'e2': 'floor((b1)/3)'}}],
       'formula': '(2/3 * b1 - floor((b1)/2))'}],
     'variables': ['b1', 's']}
       
       
doctest with: ``sage -t barvinok.sage``
unittest with ``sage test_barvinok.sage``
    
    
Structure of the output:

{
'variables': LIST
'pieces': LIST. Each item of domain is a dict as follows:
                {'formula': STRING,
                 'domain': LIST. each item in the list has the following structure:
                               {'linear conditions': LIST OF STRINGS,
                                 'quantifiers': DICT str -> str}
                 
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
        {'linear conditions': ['s >= 1',
          '5  *  e0 <= -2 + s',
          '5  *  e0 >= -5 + s',
          '5  *  e1 <= -1 + s',
          '5  *  e1 >= -4 + s'],
         'quantifiers': {'e0': 'floor((-1 + s)/5)', 'e1': 'floor((s)/5)'}}
         
        >>> parse_subdomain('s = 0')
        {'linear conditions': ['s == 0'], 'quantifiers': {}}
    """
    if "exists" in subdomain:
        subdomain = remove_parenthesis(subdomain, prefix="exists (", suffix=")")
        quantifiers, all_linear_conditions = subdomain.split(": ")
    else:
        quantifiers = None
        all_linear_conditions = subdomain
    return {'quantifiers': parse_quantifiers(quantifiers),
            'linear conditions': parse_all_linear_conditions(all_linear_conditions)}
    
def parse_domain(domain):
    r"""
    EXAMPLES::
        >>> s = '(exists (e0 = floor((-2 + b1)/4), e1 = floor((b2)/4), e2 = floor((-2 + b2)/4), e3 = floor((-4 + b1)/4): s = -2 + b1 and 4e2 = -2 + b2 and 4e3 = -4 + b1 and b2 >= b1 and 2b2 <= -8 + 3b1 and 4e0 >= -5 + b1 and 4e0 <= -3 + b1 and 4e1 <= -1 + b2 and 4e1 >= -3 + b2)) or (exists (e0 = floor((b2)/4), e1 = floor((-2 + b2)/4), e2 = floor((-2 + b1)/4): s = -2 + b1 and 4e1 = -2 + b2 and 4e2 = -2 + b1 and b2 >= b1 and 2b2 <= -8 + 3b1 and 4e0 <= -1 + b2 and 4e0 >= -3 + b2))'
        >>> parse_domain(s)
        [{'linear conditions': ['s == -2 + b1',
           '4  *  e2 == -2 + b2',
           '4  *  e3 == -4 + b1',
           'b2 >= b1',
           '2  *  b2 <= -8 + 3  *  b1',
           '4  *  e0 >= -5 + b1',
           '4  *  e0 <= -3 + b1',
           '4  *  e1 <= -1 + b2',
           '4  *  e1 >= -3 + b2'],
          'quantifiers': {'e0': 'floor((-2 + b1)/4)',
           'e1': 'floor((b2)/4)',
           'e2': 'floor((-2 + b2)/4)',
           'e3': 'floor((-4 + b1)/4)'}},
         {'linear conditions': ['s == -2 + b1',
           '4  *  e1 == -2 + b2',
           '4  *  e2 == -2 + b1',
           'b2 >= b1',
           '2  *  b2 <= -8 + 3  *  b1',
           '4  *  e0 <= -1 + b2',
           '4  *  e0 >= -3 + b2'],
          'quantifiers': {'e0': 'floor((b2)/4)',
           'e1': 'floor((-2 + b2)/4)',
           'e2': 'floor((-2 + b1)/4)'}}]
    """
    domain = domain.split(' or ')
    domain = [remove_parenthesis(subdomain) for subdomain in domain]
    return [parse_subdomain(subdomain) for subdomain in domain]

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

def parse_case(case):
    r"""
    EXAMPLE::
        >>> parse_case('[s] -> 1 : s = 0')
        {'domain': [{'linear conditions': ['s == 0'], 'quantifiers': {}}],
         'formula': '1',
         'variables': ['s']}
    """
    quasipolynomial, domain = case.split(' : ', maxsplit=1)
    Q = parse_quasipolynomial(quasipolynomial)
    return {'domain': parse_domain(domain), 
            'formula': Q['formula'], 
            'variables': Q['variables'] }

def parse_all_cases(all_cases):
    all_cases = all_cases.split('; ')
    all_cases = [parse_case(case) for case in all_cases]
    variables = all_cases[0]['variables']
    if not all(case['variables'] == variables for case in all_cases):
        raise ValueError("Not all lists of variables are equal.")
    return {'variables': variables, 
            'pieces': [{'domain': case['domain'], 'formula': case['formula']} for case in all_cases]
           }

def parse_function(function):
    r"""Parse a Barvinok function from the directory qpoly
    """
    all_cases = function.replace('\n', ' ')
    all_cases = remove_parenthesis(all_cases, prefix='{', suffix='}')
    return parse_all_cases(all_cases)