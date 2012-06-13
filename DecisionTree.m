classdef DecisionTree < handle
    properties(SetAccess = 'private') % fields with default vals
        maxDepth = 10;
        numFeature = 400;
        numThreshold = 5;
        factory = {'addTwo', 'subAbs', 'sub', 'unary'};
        labelWeights;
        root;
        numNodes = 1;
    end
    
    methods(Static)
        function DT = load(fname)
            load(fname);
            DT = DecisionTree();
        end
    end
    %%%%%%%%%% Public Methods %%%%%%%%%%
    methods        
        function DT = DecisionTree(maxDepth, numFeature, numThreshold, ...
                                   factory, labelWeights)
            if nargin > 0
                DT.maxDepth = maxDepth;
                DT.numFeature = numFeature;
                DT.numThreshold = numThreshold;
                DT.factory = factory;
                DT.labelWeights = labelWeights;
            end
        end
        
        function DT = trainDepthFirst(DT, data)
            % Reset the tree
            DT.numNodes = 1;
            DT.root = DT.computeDepthFirst(TreeNode(), data, 0);            
        end
        
        % fill the tree with all of training data
        function fillAll(data)
            DT.fill(DT.root, data);
        end              
        
        function dist = classify(point)
            dist = findLeaf(root, point);
        end
        
        function bost = computeBost(data)
            bost = sparse(numNodes, 1);
            bost = findCounts(root, bost, data);
        end
        % function save(DT, fname)
        %     DT = printNode(root)
        % end
    end 
    %%%%%%%%%% end of Public methods %%%%%%%%%%
    
    %%%%%%%%%% Private methods %%%%%%%%%%
    methods(Access=private)
        %%%%%%%%%% for learning a tree %%%%%%%%%%
        function node = computeDepthFirst(DT, node, data, depth)
            if isempty(data), return, end
            if depth == DT.maxDepth || numel(unique([data.label]))==0
                %classDist = hist(double([data.label]), numel(DT.labelWeights))';
                classDist = []; % will fill this out later
                %node = TreeNode(classDist.*DT.labelWeights);
                node = TreeNode(classDist);
                node.id = DT.numNodes;
                DT.numNodes = DT.numNodes + 1;
                node.level = depth;
                return;
            end
            % if not leaf, find the best split
            bestScore = -Inf; bestDecider = [];
            numFactory = numel(DT.factory);
            fprintf('computing the best feature split for node %d\n', ...
                    DT.numNodes);
            for i = 1:DT.numFeature
                %                method = DT.factory{mod(i, numFactory)+1};
                method = mod(i, numFactory)+1;
                [values, decider] = computeFeature(data, method);
                [score, threshold] = DT.computeBestThreshold(values, data);
                if score > bestScore
                    bestScore = score;
                    bestDecider = decider;
                    bestDecider.threshold = threshold;
                end            
            end            
            % do the split
            [values, ~] = computeFeature(data, bestDecider);
            toLeft = values < bestDecider.threshold;
            leftData = data(toLeft);
            rightData = data(~toLeft);
            % housekeeping
            node.id = DT.numNodes;
            node.level = depth;
            DT.numNodes = DT.numNodes + 1;
            node.decider = bestDecider;
            node.left = DT.computeDepthFirst(TreeNode(), leftData, depth+1);
            node.right = DT.computeDepthFirst(TreeNode(), rightData, depth+1);
        end
        
        function [bestScore, bestThreshold] = computeBestThreshold(DT,values, data)
            % candidate threshold sampled from this values gaussian
            thresholds = randn(DT.numThreshold, 1).*std(values) + mean(values);
            N = numel(values);
            infogains = ones(DT.numThreshold, 1)*-Inf;
            labels = double([data.label]);
            dirichlet = 1e-4;
            numClass = length(DT.labelWeights);
            for i = 1:DT.numThreshold
                toLeft = values < thresholds(i);
                numL = numel(labels(toLeft)) + dirichlet;
                numR = numel(labels(~toLeft)) + dirichlet;
                LDist = 1/numL.*(hist(labels(toLeft), numClass) ...
                                 + dirichlet);
                RDist = 1/numR.*(hist(labels(~toLeft), numClass) ...
                                 + dirichlet);
                % calc entropy
                EL = -sum(LDist.*log2(LDist));
                ER = -sum(RDist.*log2(RDist));
                infogains(i) = -1/N*(numL*EL + numR*ER);
            end
            [bestScore, bestind] = max(infogains);
            bestThreshold = thresholds(bestind);
        end
        
        % computes the expected gain in information 
        function [E1, E2] = entropy(h1, h2)
            E1 = 0; E2 = 0;
            for i=1:numel(h1)
                E1 = E1 - h1(i)*log2(h1(i));
                E2 = E2 - h2(i)*log2(h2(i));
            end
        end

        %%fill the tree with data to build distributions at each leaf
        function fill(node, data)
            node.distributions = hist(double([data.label]), numel(DT.labelWeights))'.*...
                                 DT.labelWeights;
            if ~node.isLeaf
                [values, ~] = computeFeature(data, node.decider);
                toLeft = values < node.decider.threshold;
                leftData = data(toLeft);
                rightData = data(toRight);
                if ~isempty(leftData), fill(node.left, leftData),end
                if ~isempty(rightData), fill(node.right, rightData),end
            end
        end            
        function node = findLeaf(node, point)
            if node.isLeaf, return , end
            [value, ~] = computeFeature(point, decider);
            if value < node.decider.threshold % left
                findLeaf(node.left, point);
            else 
                findLeaf(node.right, point);
            end
        end
        
        function bost = findCounts(node, bost, data)
           % update the count by the total number of data that
           % fellin there
            bost(node.id) = numel(data);
            if ~node.isLeaf
                [values, ~] = computeFeature(data, node.decider);
                toLeft = values < node.decider.threshold;
                leftData = data(toLeft);
                rightData = data(toRight);
                if ~isempty(leftData)
                    findCounts(node.left, bost, leftData);
                end;
                if ~isempty(rightData)
                    findCounts(node.right, bost, rightData);
                end                
            end
        end

        function [left right] = splitPoints(DT, decider, data)
            [values, ~] = computeFeature(data, decider);
            toLeft = values < decider.threshold;
            left = data(toLeft);
            right = data(~toLeft);
        end
        % % pre-order traversal
        % function str = printNode(node)
        %     node.id
        % end        
    end
    %%%%%%%%%% end of Private methods %%%%%%%%%%        
end

    
    
