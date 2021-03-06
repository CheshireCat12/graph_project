import math

cdef class LabelNodeAIDS(LabelBase):

    def __init__(self, str symbol, int chem, int charge, float x, float y):
        self.symbol = symbol
        self.symbol_int = int.from_bytes(symbol.encode(), 'little') # sum(ord(letter) for letter in symbol)
        self.chem = chem
        self.charge = charge
        self.x = x
        self.y = y

    cpdef tuple get_attributes(self):
        return self.symbol, self.chem, self.charge, self.x, self.y

    def sigma_attributes(self):
        return f'Element: {self.symbol}'

    def sigma_position(self):
        return self.x, self.y
