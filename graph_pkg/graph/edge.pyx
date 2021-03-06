
cdef class Edge:

    def __init__(self, int idx_node_start, int idx_node_end, LabelBase weight):
        assert idx_node_start != idx_node_end, f'No loops accepted, the node: {idx_node_start} loops on itself!'
        assert idx_node_start >= 0 and idx_node_end >= 0, f'Invalid negative index!'

        self.idx_node_start = idx_node_start
        self.idx_node_end = idx_node_end
        self.weight = weight

    cdef void update_idx_node_start(self, unsigned int new_idx_node_start):
        self.idx_node_start = new_idx_node_start

    cdef void update_idx_node_end(self, unsigned int new_idx_node_end):
        self.idx_node_end = new_idx_node_end

    cpdef Edge reversed(self):
        return Edge(self.idx_node_end, self.idx_node_start, self.weight)

    def __richcmp__(self, Edge other, int op):
        assert isinstance(other, Edge), f'The element {str(other)} is not an Edge!'

        if op == Py_EQ:
            return self.idx_node_start == other.idx_node_start and \
                   self.idx_node_end == other.idx_node_end and \
                   self.weight == other.weight
        else:
            assert False

    def __repr__(self):
        return f'Edge: {self.idx_node_start} --> {self.idx_node_end},' \
               f' weight {", ".join(str(element) for element in self.weight.get_attributes())}'

    def __hash__(self):
        return hash((self.idx_node_start, self.idx_node_end))
