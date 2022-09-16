mutable struct TreeNode
    number::Int
    super::Union{TreeNode, Nothing}
    brother::Union{TreeNode, Nothing}
end
TreeNode(x) = TreeNode(x, nothing, nothing)
TreeNode(x, y) = TreeNode(x, y, nothing)

a = TreeNode(0)
b = TreeNode(1, a)
c = TreeNode(2, a, b)
t = c

println(dump(t))

mutable struct Node
    vertex::String
end 

A = Node[]
