import pytest

from graph_pkg.edit_cost.edit_cost_AIDS import EditCostAIDS
from graph_pkg.graph.node import Node
from graph_pkg.graph.label.label_node_AIDS import LabelNodeAIDS

@pytest.mark.parametrize('coord1, coord2, expected',
                         [(('C', 1, 1, 0., 0.), ('C', 1, 1, 3., 4.), 0.),
                          (('C', 1, 3, 6., 0.3), ('C', 1, 1, 3., 4.), 0.),
                          (('H', 1, 1, 0., 0.), ('C', 1, 1, 3., 4.), 1.),
                          (('H', 4, 5, 0.5, 4.), ('O', 1, 1, 3., 4.), 1.)])
def test_euclidean_norm(coord1, coord2, expected):
    node0 = Node(0, LabelNodeAIDS(*coord1))
    node1 = Node(1, LabelNodeAIDS(*coord2))

    edit_cost = EditCostAIDS(1., 1., 1., 1., 'dirac')
    result = edit_cost.cost_substitute_node(node0, node1)

    assert result == expected