function labelNodes(node, depth)
    fprintf('@ depth %d\n', depth');
    keyboard
    if(isempty(node)), return,end
    node.data=depth;
    labelNodes(node.left, depth+1);
    labelNodes(node.right, depth+1);
end
