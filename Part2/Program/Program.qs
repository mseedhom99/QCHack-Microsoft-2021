namespace Program {
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;
    open Library;

    @EntryPoint()
    operation runProgram() : Int {
        let iterations = Round(PI() / 4.0 * Sqrt(IntAsDouble(4 / 1)));
        use control = Qubit[4]{
            RunGroversSearch(control, ApplyMarkingOracleAsPhaseOracle, iterations);
            let res = MultiM(control);
            return ResultArrayAsInt(res);
        }
    }

    operation RunGroversSearch(
        register : Qubit[], 
        phaseOracle : (((Qubit[], Qubit) => Unit is Adj), Qubit[]) => Unit is Adj, 
        iterations : Int
    ) : Unit {
        // Prepare register into uniform superposition.
        ApplyToEach(H, register);
        // Start Grover's loop.
        for _ in 1 .. iterations {
            // Apply phase oracle for the task.
            phaseOracle(is0101, register);
            // Apply Grover's diffusion operator.
            ReflectAboutUniform(register);
        }
    }

    operation ReflectAboutUniform(inputQubits : Qubit[]) : Unit{
        within {
            ApplyToEachA(H, inputQubits);
            ApplyToEachA(X, inputQubits);
        } apply {
            Controlled Z(Most(inputQubits), Tail(inputQubits));
        }
    }

    operation ApplyMarkingOracleAsPhaseOracle(
        markingOracle : (Qubit[], Qubit) => Unit is Adj,
        register : Qubit[]
    ):Unit is Adj{
        use target = Qubit();
        within {
            X(target);
            H(target);
        } apply {
            markingOracle(register, target);
        }
    }
}
