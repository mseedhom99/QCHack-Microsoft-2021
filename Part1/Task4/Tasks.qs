namespace QCHack.Task4 {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arrays;

    // Task 4 (12 points). f(x) = 1 if the graph edge coloring is triangle-free
    // 
    // Inputs:
    //      1) The number of vertices in the graph "V" (V ≤ 6).
    //      2) An array of E tuples of integers "edges", representing the edges of the graph (0 ≤ E ≤ V(V-1)/2).
    //         Each tuple gives the indices of the start and the end vertices of the edge.
    //         The vertices are indexed 0 through V - 1.
    //         The graph is undirected, so the order of the start and the end vertices in the edge doesn't matter.
    //      3) An array of E qubits "colorsRegister" that encodes the color assignments of the edges.
    //         Each color will be 0 or 1 (stored in 1 qubit).
    //         The colors of edges in this array are given in the same order as the edges in the "edges" array.
    //      4) A qubit "target" in an arbitrary state.
    //
    // Goal: Implement a marking oracle for function f(x) = 1 if
    //       the coloring of the edges of the given graph described by this colors assignment is triangle-free, i.e.,
    //       no triangle of edges connecting 3 vertices has all three edges in the same color.
    //
    // Example: a graph with 3 vertices and 3 edges [(0, 1), (1, 2), (2, 0)] has one triangle.
    // The result of applying the operation to state (|001⟩ + |110⟩ + |111⟩)/√3 ⊗ |0⟩ 
    // will be 1/√3|001⟩ ⊗ |1⟩ + 1/√3|110⟩ ⊗ |1⟩ + 1/√3|111⟩ ⊗ |0⟩.
    // The first two terms describe triangle-free colorings, 
    // and the last term describes a coloring where all edges of the triangle have the same color.
    //
    // In this task you are not allowed to use quantum gates that use more qubits than the number of edges in the graph,
    // unless there are 3 or less edges in the graph. For example, if the graph has 4 edges, you can only use 4-qubit gates or less.
    // You are guaranteed that in tests that have 4 or more edges in the graph the number of triangles in the graph 
    // will be strictly less than the number of edges.
    //
    // Hint: Make use of helper functions and helper operations, and avoid trying to fit the complete
    //       implementation into a single operation - it's not impossible but make your code less readable.
    //       GraphColoring kata has an example of implementing oracles for a similar task.
    //
    // Hint: Remember that you can examine the inputs and the intermediary results of your computations
    //       using Message function for classical values and DumpMachine for quantum states.
    //
    operation Task4_TriangleFreeColoringOracle (
        V : Int, 
        edges : (Int, Int)[], 
        colorsRegister : Qubit[], 
        target : Qubit
    ) : Unit is Adj+Ctl {
        if Length(edges) < 3{
            X(target);
        }else{
            let AdjM = constructAdjacencyMatrix(V, edges);
            let triangles = findTriangles(V, AdjM);
            if Length(triangles)==0{
                X(target);
            }else{
                X(colorsRegister[0]);
                X(colorsRegister[0]);
                use monoTri = Qubit[Length(triangles)];
                for t in 0..Length(triangles)-1{
                    Task3_ValidTriangle(Subarray(findEdgeIndices(triangles[t], edges), colorsRegister), monoTri[t]);
                }
                Controlled X(monoTri, target);
                for t in 0..Length(triangles)-1{
                    mutable (i, j, k) = triangles[t];
                    Task3_ValidTriangle(Subarray(findEdgeIndices(triangles[t], edges), colorsRegister), monoTri[t]);
                }
            }
        }
    }

    operation Task3_ValidTriangle (inputs : Qubit[], output : Qubit) : Unit is Adj+Ctl {
        use a = Qubit();
        use b = Qubit();
        CNOT(inputs[0], output);
        CNOT(inputs[1], output);
        CNOT(inputs[0], a);
        CNOT(inputs[2], a);
        CNOT(inputs[1], b);
        CNOT(inputs[2], b);
        CCNOT(a, b, output);
        CNOT(inputs[0], a);
        CNOT(inputs[2], a);
        CNOT(inputs[1], b);
        CNOT(inputs[2], b);
    }

    function constructAdjacencyMatrix(V: Int, edges: (Int, Int)[]):Int[]{
        mutable AdjM = new Int[V^2];
        for edge in edges{
            mutable (x, y) = edge;
            set AdjM w/= x*V+y <- 1;
            set AdjM w/= y*V+x <- 1;
        }
        return AdjM;
    }

    function findTriangles(V: Int, AdjM: Int[]): (Int, Int, Int)[]{
        mutable triangles = new (Int, Int, Int)[0];
        for i in 0..V-3{
            for j in i+1..V-2{
                if AdjM[i*V+j]==1{
                    for k in j+1..V-1{
                        if AdjM[j*V+k]==1 and AdjM[k*V+i]==1 {
                            set triangles += [(i, j, k)];
                        }
                    }
                }
            }
        }
        return triangles;
    }

    function findEdgeIndices(triangle: (Int, Int, Int), edges: (Int, Int)[]): Int[]{
        let (i, j, k) = triangle;
        mutable indices = new Int[0];
        for e in 0..Length(edges)-1{
            mutable (u, v) = edges[e];
            if (u == i or u == j or u == k) and (v == i or v == j or v == k){
                set indices += [e];
            }
        }
        return indices;
    }
}

