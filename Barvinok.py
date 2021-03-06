from sympy import * 
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

#Only works on 1-variable case with "s" as variable
s = symbols('s')


class BarvinokOutput():
	# bvop is the string output
	def __init__(self,bvop):
		chambers_all = bvop.split("[s] ->")[1:]
		self.chambers_all = chambers_all
		self.n_chambers = len(self.chambers_all)
		self.chambers_split = [self.chambers_all[i].split(":",1) for i in range(self.n_chambers)]
		self.value = [self.chambers_split[i][0] for i in range(self.n_chambers)]
		self.condition = [self.chambers_split[i][1] for i in range(self.n_chambers)]
		self.expressions = [sympify(self.value[i]) for i in range(self.n_chambers)]

	#Evaluate the i-value function at point
	def eval(self,point, i ):
		return self.expressions[i].subs(s,point)


	#Print general information of the output string
	def info(self):
		for i in range(self.n_chambers):
			print("++++++++++++++++++++++", "CHAMBER ",i+1,"++++++++++++++++++++++")
			print()
			print("VALUE = ",self.value[i] )
			print()
			print("CONDITIONS = ", self.condition[i])
			print()

	def to_latex(self): #Not finished, only value is shown properly
		tex = ""
		for i in range(self.n_chambers):
			tex += " CHAMBER " + str(i+1) + "\\\ "
			tex += " Value =  \\[ "  + latex(self.expressions[i]) + " \\] "
			tex_conditions = latex(self.condition[i]).replace("<=", "$ \\leq $").replace(">=", "$ \\geq $").replace("exists", "$\\exists $") #Ad-hoc solution (except floor)
			tex += " Conditions = \\[" + tex_conditions + "\\] "
		return tex 



bvo = BarvinokOutput(str1)
bvo.info()
bvo.eval(1,2)
print(bvo.to_latex())