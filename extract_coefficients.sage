def rel_coeffs(linrel, vars):
    r"""
    Extract the coefficients and type of a linear relation.
    
    EXAMPLE::
    
        sage: rel_coeffs( b1 >= 2*b2 +1 , [b1, b2, s])
        ('ieq', (-1, -2, 1, 0))
    """
    form = linrel.lhs() - linrel.rhs()
    if linrel.operator() == operator.ge:
        type = 'ieq'
    elif linrel.operator() == operator.eq:
        type = 'eq'
    elif linrel.operator() == operator.le:
        type = 'ieq'
        form = -form
    else:
        raise NotImplementedError('Received relation of type', linrel.operator())
    return (type, extract_coeffs(form, vars))

def extract_coeffs(form, vars):
    r"""Return the coefficients of an affine form.
    
    EXAMPLE::
    
        sage: extract_coeffs(b1 + 7*b2 -3, [b1, b2, s])
        [-3, 1, 7, 0]
    """
    R = PolynomialRing(QQ, vars)
    return ( [QQ(R(form).constant_coefficient())] 
             + [QQ(R(form).monomial_coefficient(R(X))) for X in vars])

def polyhedron(desc, vars):
    r"""
    Return the polyhedron defined by a list of affine equations and inequalities
    
    EXAMPLE::
    
        sage: polyhedron([b1 >= 0, b2 >= 0, b1 + b2 <= 1], [b1, b2])
        A 2-dimensional polyhedron in QQ^2 defined as the convex hull of 3 verteices
    """
    K = [rel_coeffs(r, vars) for r in desc]
    P = Polyhedron(ieqs=[F for (type, F) in K if type == 'ieq'],
                   eqns=[F for (type, F) in K if type == 'eq'])
    return P
