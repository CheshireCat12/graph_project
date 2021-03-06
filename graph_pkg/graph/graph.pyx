cimport cython
import numpy as np
cimport numpy as np


cdef class Graph:
    """A class that is used to work with nodes and edges of a graph"""

    def __init__(self, str name, str filename, int num_nodes):
        self.name = name
        self.filename = filename
        self.num_nodes_max = num_nodes
        self.num_nodes_current = 0
        self.nodes = [None] * num_nodes
        self._init_edges()
        self._init_adjacency_matrix()


    cdef void _init_edges(self):
        self.num_edges = 0
        self.edges = {i: [None] * self.num_nodes_max for i in range(self.num_nodes_max)}

    cdef void _init_adjacency_matrix(self):
        self.adjacency_matrix = np.zeros((self.num_nodes_max, self.num_nodes_max),
                                         dtype=np.int32)

    cdef bint _does_node_exist(self, int idx_node):
        return 0 <= idx_node < self.num_nodes_max and \
               self.nodes[idx_node] is not None

    cpdef bint has_edge(self, int idx_start, int idx_end):
        return 0 <= idx_start < self.num_nodes_max and \
               0 <= idx_end < self.num_nodes_max and \
               self.edges[idx_start][idx_end] is not None

    cpdef list get_nodes(self):
        return self.nodes

    cpdef int add_node(self, Node node) except? -1:
        assert node.idx < self.num_nodes_max, \
            f'The idx of the node {node.idx} exceed the number of nodes {self.num_nodes_max} authorized!'
        assert not self._does_node_exist(node.idx), \
            f'The position {node.idx} is already used!'

        self.nodes[node.idx] = node
        self.num_nodes_current += 1

    cpdef dict get_edges(self):
        return self.edges

    cdef Edge get_edge_by_node_idx(self, int idx_node_start, int idx_node_end):
        """
        
        !! Caution, there is no verification if the indices exist!!
        :param idx_node_start: 
        :param idx_node_end: 
        :return: Edge corresponding to the given nodes_idx
        """
        return self.edges[idx_node_start][idx_node_end]

    cpdef int add_edge(self, Edge edge) except? -1:
        assert self._does_node_exist(edge.idx_node_start), f'The starting node {edge.idx_node_start} does not exist!'
        assert self._does_node_exist(edge.idx_node_end), f'The ending node {edge.idx_node_end} does not exist!'

        cdef Edge reversed_edge = edge.reversed()
        self.edges[edge.idx_node_start][edge.idx_node_end] = edge
        self.edges[reversed_edge.idx_node_start][reversed_edge.idx_node_end] = reversed_edge

        self.adjacency_matrix[edge.idx_node_start][edge.idx_node_end] = 1
        self.adjacency_matrix[reversed_edge.idx_node_start][reversed_edge.idx_node_end] = 1

    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef int[::1] out_degrees(self):
        """
        Take the out degree of every node and create a list of them.
         
        :return: list of out degrees per nodes
        """
        cdef:
            int i, j
            int n, m
            int[::1] degrees

        n = self.adjacency_matrix.shape[0]
        m = self.adjacency_matrix.shape[1]
        degrees = np.zeros(n, dtype=np.int32)
        for i in range(n):
            for j in range(m):
                degrees[i] += self.adjacency_matrix[i][j]

        return degrees

    cpdef int[::1] in_degrees(self):
        """
        Take the out degree of every node and create a list of them.

        :return: list of out degrees per nodes
        """
        # TODO: implement the in_degree to take into account the undirected/directed graphs
        raise NotImplementedError()
        # return np.asarray(self.adjacency_matrix, dtype=np.int16).sum(axis=0)

    cpdef void remove_node_by_idx(self, int idx_node):
        assert self._does_node_exist(idx_node), f'The node {idx_node} can\'t be deleted'

        cdef Node node

        del self.nodes[idx_node]
        for node in self.nodes:
            if node.idx > idx_node:
                node.update_idx(node.idx-1)
        self.num_nodes_current -= 1

        self.remove_all_edges_by_node_idx(idx_node)

        print(self.nodes)

    cpdef void remove_all_edges_by_node_idx(self, int idx_node):
        del self.edges[idx_node]
        tmp_edges = {}
        for key, edges in self.edges.items():
            self.__del_edge(idx_node, edges)

            if key > idx_node:
                key -= 1
            tmp_edges[key] = edges

        self.edges = tmp_edges
        self.adjacency_matrix = np.delete(self.adjacency_matrix, idx_node, 0)
        self.adjacency_matrix = np.delete(self.adjacency_matrix, idx_node, 1)

        print(self.edges)
        print(self.adjacency_matrix.base)

    cdef void __del_edge(self, int idx_node, list edges):
        cdef Edge edge
        cdef int idx_to_pop
        for idx, edge in enumerate(edges):

            if edge is None:
                continue
            if edge.idx_node_end == idx_node:
                idx_to_pop = idx
            if edge.idx_node_start > idx_node:
                edge.update_idx_node_start(edge.idx_node_start-1)
            if edge.idx_node_end > idx_node:
                edge.update_idx_node_end(edge.idx_node_end-1)

        edges.pop(idx_to_pop)

    def _set_edge(self):
        edges_set = set()
        for key, edges_lst in self.edges.items():
            edges_set.update(edges_lst)

        edges_set.remove(None)
        return edges_set

    def graph_to_json(self):
        json_ = "{"

        json_ += '"edges":['
        for idx, edge in enumerate(self._set_edge()):
            if edge is None:
                continue
            json_ += f'{{"source":"{edge.idx_node_start}","target":"{edge.idx_node_end}","id":"{idx}"}},'

        json_ = json_[:-1]
        json_ += '],'

        json_ += '"nodes":['
        for node in self.nodes:
            json_ += f'{{"label":"{repr(node.label)}","id":"{node.idx}",{node.label.json_attributes()},"color":"rgb(60,45,92)","size":8}},'
        json_ = json_[:-1]
        json_ += ']}'

        return json_

    def __str__(self):
        eof = ",\n\t\t"
        return f'Graph: \n' \
               f'\tName: {self.name}\n' \
               f'\tNumber of nodes max: {self.num_nodes_max}\n' \
               f'\tNodes: \n \t\t{eof.join(str(node) for node in self.nodes)}\n' \
               f'\tEdges: \n \t\t{eof.join(str(edge) for edge in self._set_edge())}\n'

    def __repr__(self):
        return f'Graph: {self.name} -> ' \
               f'Nodes: {", ".join(str(node) for node in self.nodes)}, ' \
               f'Edges: {", ".join(str(edge) for edge in self.edges)}'

    def __len__(self):
        return self.num_nodes_current

    def __reduce__(self):
        """Define how instance of Graph are pickled."""
        d = dict()
        d['name'] = self.name
        d['filename'] = self.filename
        d['nodes'] = self.nodes
        d['edges'] = self.edges
        d['num_nodes_max'] = self.num_nodes_max
        d['num_nodes_current'] = self.num_nodes_current
        d['num_edges'] = self.num_edges
        d['adjacency_matrix'] = np.asarray(self.adjacency_matrix)
        return (rebuild, (d,))


def rebuild(data):
    cdef:
        Graph g
    g = Graph(data['name'], data['filename'], data['num_nodes_max'])
    g.nodes = data['nodes']
    g.edges = data['edges']
    g.num_nodes_current = data['num_nodes_current']
    g.num_edges = data['num_edges']
    g.adjacency_matrix = data['adjacency_matrix']

    return g